#ifndef TCP2_STANDARD_BRDF_INCLUDED
#define TCP2_STANDARD_BRDF_INCLUDED


// Main BRDF function, based on UnityStandardBRDF.cginc

//-------------------------------------------------------------------------------------



inline half WrapRampNL(half nl, fixed threshold, fixed smoothness)
{
	#ifndef TCP2_DISABLE_WRAPPED_LIGHT
	//TCP2 Note: disabling wrapped lighting to save 1 instruction, else the shader fails to compile on SM2
	  #if SHADER_TARGET >= 30
		nl = nl * 0.5 + 0.5;
	  #endif
	#endif
	#if TCP2_RAMPTEXT
		nl = tex2D(_Ramp, fixed2(nl, nl)).r;
	#else
		nl = smoothstep(threshold - smoothness*0.5, threshold + smoothness*0.5, nl);
	#endif
	
	return nl;
}

inline half StylizedSpecular(half specularTerm, fixed specSmoothness)
{
	return smoothstep(specSmoothness*0.5, 0.5 + specSmoothness*0.5, specularTerm);
}

inline half3 StylizedFresnel(half nl, half roughness, UnityLight light, half3 normal, fixed3 rimParams)
{
	#if _RIMOFFSET
		half rim = 1 - abs(dot(normal, -normalize(half3(_RimOffsetX, _RimOffsetY, _RimOffsetZ))));
	#else
		half rim = 1 - nl;
	#endif
	
	rim = smoothstep(rimParams.x, rimParams.y, rim) * rimParams.z * abs(1.33-roughness);
	return rim * light.color * _RimColor;
}

//-------------------------------------------------------------------------------------

// Note: BRDF entry points use smoothness and oneMinusReflectivity for optimization
// purposes, mostly for DX9 SM2.0 level. Most of the math is being done on these (1-x) values, and that saves
// a few precious ALU slots.


// Main Physically Based BRDF
// Derived from Disney work and based on Torrance-Sparrow micro-facet model
//
//   BRDF = kD / pi + kS * (D * V * F) / 4
//   I = BRDF * NdotL
//
// * NDF (depending on UNITY_BRDF_GGX):
//  a) Normalized BlinnPhong
//  b) GGX
// * Smith for Visiblity term
// * Schlick approximation for Fresnel
half4 BRDF1_TCP2_PBS (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
	half3 normal, half3 viewDir,
	UnityLight light, UnityIndirect gi,
	//TCP2 added properties
	fixed rampThreshold, fixed rampSmoothness,
	fixed4 highlightColor, fixed4 shadowColor,
	fixed specSmooth, fixed specBlend,
	fixed3 rimParams,
	half atten,
	half alpha)
{
	half perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
	half3 halfDir = Unity_SafeNormalize (light.dir + viewDir);

// NdotV should not be negative for visible pixels, but it can happen due to perspective projection and normal mapping
// In this case normal should be modified to become valid (i.e facing camera) and not cause weird artifacts.
// but this operation adds few ALU and users may not want it. Alternative is to simply take the abs of NdotV (less correct but works too).
// Following define allow to control this. Set it to 0 if ALU is critical on your platform.
// This correction is interesting for GGX with SmithJoint visibility function because artifacts are more visible in this case due to highlight edge of rough surface
// Edit: Disable this code by default for now as it is not compatible with two sided lighting used in SpeedTree.
#define TCP2_HANDLE_CORRECTLY_NEGATIVE_NDOTV 0 

#if TCP2_HANDLE_CORRECTLY_NEGATIVE_NDOTV
	// The amount we shift the normal toward the view vector is defined by the dot product.
	half shiftAmount = dot(normal, viewDir);
	normal = shiftAmount < 0.0f ? normal + viewDir * (-shiftAmount + 1e-5f) : normal;
	// A re-normalization should be applied here but as the shift is small we don't do it to save ALU.
	//normal = normalize(normal);

	half nv = abs(dot(normal, viewDir)); // TODO: this abs should no be necessary here
#else
	half nv = abs(dot(normal, viewDir));	// This abs allow to limit artifact
#endif

	half nl = abs(dot(normal, light.dir));

	//TCP2 Ramp N.L
	nl = WrapRampNL(nl, rampThreshold, rampSmoothness);

	half nh = abs(dot(normal, halfDir));

	half lv = abs(dot(light.dir, viewDir));
	half lh = abs(dot(light.dir, halfDir));

	// Diffuse term
	half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;

	// Specular term
	// HACK: theoretically we should divide diffuseTerm by Pi and not multiply specularTerm!
	// BUT 1) that will make shader look significantly darker than Legacy ones
	// and 2) on engine side "Non-important" lights have to be divided by Pi too in cases when they are injected into ambient SH
	half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
#if UNITY_BRDF_GGX
	half V = SmithJointGGXVisibilityTerm (nl, nv, roughness);
	half D = GGXTerm (nh, roughness);
#else
	// Legacy
	half V = SmithBeckmannVisibilityTerm (nl, nv, roughness);
	half D = NDFBlinnPhongNormalizedTerm (nh, PerceptualRoughnessToSpecPower(perceptualRoughness));
#endif

#if defined(_SPECULARHIGHLIGHTS_OFF)
	half specularTerm = 0.0;
#else
	half specularTerm = V*D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later

  #if TCP2_SPEC_TOON
	//TCP2 Stylized Specular
	half r = sqrt(roughness)*0.85;
	r += 1e-4h;
	specularTerm = lerp(specularTerm, StylizedSpecular(specularTerm, specSmooth) * (1/r), specBlend);
  #endif
#	ifdef UNITY_COLORSPACE_GAMMA
		specularTerm = sqrt(max(1e-4h, specularTerm));
#	endif

	// specularTerm * nl can be NaN on Metal in some cases, use max() to make sure it's a sane value
	specularTerm = max(0, specularTerm * nl);
#endif	//	_SPECULARHIGHLIGHTS_OFF


	// surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
	half surfaceReduction;
#	ifdef UNITY_COLORSPACE_GAMMA
		surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;		// 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
#	else
		surfaceReduction = 1.0 / (roughness*roughness + 1.0);			// fade \in [0.5;1]
#	endif

	// To provide true Lambert lighting, we need to be able to kill specular completely.
	specularTerm *= any(specColor) ? 1.0 : 0.0;
	
	//TCP2 Colored Highlight/Shadows
	shadowColor = lerp(highlightColor, shadowColor, shadowColor.a);	//Shadows intensity through alpha
	diffuseTerm *= atten;
	half3 diffuseTermRGB = lerp(shadowColor.rgb, highlightColor.rgb, diffuseTerm);
	half3 diffuseTCP2 = diffColor * (gi.diffuse + light.color * diffuseTermRGB);
	//original: diffColor * (gi.diffuse + light.color * diffuseTerm)
	
	//TCP2: atten contribution to specular since it was removed from light calculation
	specularTerm *= atten;

	half grazingTerm = abs(smoothness + (1-oneMinusReflectivity));
    half3 color =	diffuseTCP2
                    + specularTerm * light.color * FresnelTerm (specColor, lh) * alpha
					+ surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv);


	#if RIM
		//TCP2 Enhanced Rim/Fresnel
		color += StylizedFresnel(nv, roughness, light, normal, rimParams);
	#endif


	#if _REAL_FRESNEL
		alpha = (1 - abs(smoothstep(_Thickness - _Gradient * 0.5, _Thickness + _Gradient * 0.5, nv))) * alpha;
	#endif

	return half4(color, abs(_AlphaScale * alpha));
	
}

// Based on Minimalist CookTorrance BRDF
// Implementation is slightly different from original derivation: http://www.thetenthplanet.de/archives/255
//
// * NDF (depending on UNITY_BRDF_GGX):
//  a) BlinnPhong
//  b) [Modified] GGX
// * Modified Kelemen and Szirmay-​Kalos for Visibility term
// * Fresnel approximated with 1/LdotH
half4 BRDF2_TCP2_PBS (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
	half3 normal, half3 viewDir,
	UnityLight light, UnityIndirect gi,
	//TCP2 added properties
	fixed rampThreshold, fixed rampSmoothness,
	fixed4 highlightColor, fixed4 shadowColor,
	fixed specSmooth, fixed specBlend,
	fixed3 rimParams,
	half atten,
	half alpha)
{
	half3 halfDir = Unity_SafeNormalize (light.dir + viewDir);

	half nl = abs(dot(normal, light.dir));
	//TCP2 Ramp N.L
	nl = WrapRampNL(nl, rampThreshold, rampSmoothness);

	half nh = abs(dot(normal, halfDir));
	half nv = abs(dot(normal, viewDir));
	half lh = abs(dot(light.dir, halfDir));

	// Specular term
	half perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
	half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

#if defined(_SPECULARHIGHLIGHTS_OFF)
	half specularTerm = 0.0;
#else
 #if UNITY_BRDF_GGX

	// GGX Distribution multiplied by combined approximation of Visibility and Fresnel
	// See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
	// https://community.arm.com/events/1155
	half a = roughness;
	half a2 = a*a;

	half d = nh * nh * (a2 - 1.h) + 1.00001h;
  #ifdef UNITY_COLORSPACE_GAMMA
	// Tighter approximation for Gamma only rendering mode!
	// DVF = sqrt(DVF);
	// DVF = (a * sqrt(.25)) / (max(sqrt(0.1), lh)*sqrt(roughness + .5) * d);
	half specularTerm = a / (max(0.32h, lh) * (1.5h + roughness) * d);
  #else
	half specularTerm = a2 / (max(0.1h, lh*lh) * (roughness + 0.5h) * (d * d) * 4);
  #endif

	// on mobiles (where half actually means something) denominator have risk of overflow
	// clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
	// sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
  #if defined (SHADER_API_MOBILE)
	specularTerm = specularTerm - 1e-4h;
  #endif

 #else	// UNITY_BRDF_GGX

	// Legacy
	half specularPower = PerceptualRoughnessToSpecPower(perceptualRoughness);
	// Modified with approximate Visibility function that takes roughness into account
	// Original ((n+1)*N.H^n) / (8*Pi * L.H^3) didn't take into account roughness 
	// and produced extremely bright specular at grazing angles

	half invV = lh * lh * smoothness + perceptualRoughness * perceptualRoughness; // approx ModifiedKelemenVisibilityTerm(lh, perceptualRoughness);
	half invF = lh;

	half specularTerm = ((specularPower + 1) * pow (nh, specularPower)) / (8 * invV * invF + 1e-4h);

  #ifdef UNITY_COLORSPACE_GAMMA
	specularTerm = sqrt(max(1e-4h, specularTerm));
  #endif

 #endif		// UNITY_BRDF_GGX
#endif		// _SPECULARHIGHLIGHTS_OFF

#if !defined(_SPECULARHIGHLIGHTS_OFF)
  #if defined (SHADER_API_MOBILE)
	specularTerm = clamp(specularTerm, 0.0, 100.0);	// Prevent FP16 overflow on mobiles
  #endif

  #if TCP2_SPEC_TOON
	//TCP2 Stylized Specular
   #ifdef UNITY_COLORSPACE_GAMMA
	half r = sqrt(roughness)*1.5;
   #else
	half r = sqrt(roughness);
   #endif
	
	r += 1e-4h;
	specularTerm = lerp(specularTerm, StylizedSpecular(specularTerm, specSmooth) * (1/r), specBlend);
  #endif
#endif		// !_SPECULARHIGHLIGHTS_OFF

	// surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(realRoughness^2+1)

	// 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
	// 1-x^3*(0.6-0.08*x)   approximation for 1/(x^4+1)
#ifdef UNITY_COLORSPACE_GAMMA
	half surfaceReduction = 0.28;
#else
	half surfaceReduction = (0.6-0.08*perceptualRoughness);
#endif

	surfaceReduction = 1.0 - roughness*perceptualRoughness*surfaceReduction;

	//TCP2 Colored Highlight/Shadows
	shadowColor = lerp(highlightColor, shadowColor, shadowColor.a);	//Shadows intensity through alpha
	half3 diffuseTermRGB = lerp(shadowColor.rgb, highlightColor.rgb, nl * atten);
	half3 diffuseTCP2 = (diffColor + specularTerm * specColor) * light.color * diffuseTermRGB;
	//original: (diffColor + specularTerm * specColor) * light.color * nl
	
	half grazingTerm = abs(smoothness + (1-oneMinusReflectivity));
	half3 color =	diffuseTCP2
					+ gi.diffuse * diffColor
					+ surfaceReduction * gi.specular * FresnelLerpFast (specColor, grazingTerm, nv);

	#if RIM
		//TCP2 Enhanced Rim/Fresnel
		color += StylizedFresnel(nl, roughness, light, normal, rimParams);
	#endif

	#if _REAL_FRESNEL
		alpha = (1 - abs(smoothstep(_Thickness - _Gradient * 0.5, _Thickness + _Gradient * 0.5, nv))) * alpha;
	#endif

	return half4(color, abs(_AlphaScale * alpha));

}




half3 BRDF3_Direct_TCP2(half3 diffColor, half3 specColor, half rlPow4, half smoothness,
	/* TCP2 */			half atten, fixed specSmooth, fixed specBlend)
{
#if defined(_SPECULARHIGHLIGHTS_OFF)
	half specular = 0.0;
#else
	half LUT_RANGE = 16.0; // must match range in NHxRoughness() function in GeneratedTextures.cpp
	// Lookup texture to save instructions
	half specular = tex2D(unity_NHxRoughness, half2(rlPow4, SmoothnessToPerceptualRoughness(smoothness))).UNITY_ATTEN_CHANNEL * LUT_RANGE;
  #if TCP2_SPEC_TOON
	//TCP2 Stylized Specular
   #ifdef UNITY_COLORSPACE_GAMMA
	half r = sqrt(1-smoothness) * 0.85;
   #else
	half r = sqrt(1-smoothness);
   #endif
	r += 1e-4h;
	specular = lerp(specular, StylizedSpecular(specular, specSmooth) * (1/r), specBlend);
  #endif
#endif		 // _SPECULARHIGHLIGHTS_OFF

	//TCP2: atten contribution to specular since it was removed from light calculation
	specular *= atten;

	return diffColor + specular * specColor;
}

/*
half3 BRDF3_Indirect(half3 diffColor, half3 specColor, UnityIndirect indirect, half grazingTerm, half fresnelTerm)
{
	half3 c = indirect.diffuse * diffColor;
	c += indirect.specular * lerp (specColor, grazingTerm, fresnelTerm);
	return c;
}
*/

// Old school, not microfacet based Modified Normalized Blinn-Phong BRDF
// Implementation uses Lookup texture for performance
//
// * Normalized BlinnPhong in RDF form
// * Implicit Visibility term
// * No Fresnel term
//
// TODO: specular is too weak in Linear rendering mode
half4 BRDF3_TCP2_PBS (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
	half3 normal, half3 viewDir,
	UnityLight light, UnityIndirect gi,
	//TCP2 added properties
	fixed rampThreshold, fixed rampSmoothness,
	fixed4 highlightColor, fixed4 shadowColor,
	fixed specSmooth, fixed specBlend,
	fixed3 rimParams,
	half atten,
	half alpha)
{
	half3 reflDir = reflect (viewDir, normal);
	half nl = abs(dot(normal, light.dir));
	//TCP2 Ramp N.L
	nl = WrapRampNL(nl, rampThreshold, rampSmoothness);

	half nv = abs(dot(normal, viewDir));

	// Vectorize Pow4 to save instructions
	half2 rlPow4AndFresnelTerm = Pow4 (half2(dot(reflDir, light.dir), 1-nv));  // use R.L instead of N.H to save couple of instructions
	half rlPow4 = rlPow4AndFresnelTerm.x; // power exponent must match kHorizontalWarpExp in NHxRoughness() function in GeneratedTextures.cpp
	half fresnelTerm = rlPow4AndFresnelTerm.y;

	half grazingTerm = abs(smoothness + (1-oneMinusReflectivity));

	half3 color = BRDF3_Direct_TCP2(diffColor, specColor, rlPow4, smoothness,
									atten, specSmooth, specBlend);

	//TCP2 Colored Highlight/Shadows
	half3 diffuseTermRGB = lerp(shadowColor.rgb, highlightColor.rgb, nl * atten);
	color *= light.color * diffuseTermRGB;
	//original: color *= light.color * nl;

	color += BRDF3_Indirect(diffColor, specColor, gi, grazingTerm, fresnelTerm);

#if RIM
	//TCP2 Enhanced Rim/Fresnel
	color += StylizedFresnel(nl, 1-smoothness, light, normal, rimParams);
#endif

	#if _REAL_FRESNEL
		alpha = 1 - abs(smoothstep(_Thickness - _Gradient * 0.5, _Thickness + _Gradient * 0.5, nv));
	#endif

	return half4(color, abs(_AlphaScale * alpha));
}

#endif // TCP2_STANDARD_BRDF_INCLUDED



//half4 BRDF_ANISO(half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
//	half3 normal, half3 viewDir,
//	UnityLight light, UnityIndirect gi,
//	//TCP2 added properties
//	fixed rampThreshold, fixed rampSmoothness,
//	fixed4 highlightColor, fixed4 shadowColor,
//	fixed specSmooth, fixed specBlend,
//	fixed3 rimParams,
//	half atten,
//	half alpha,
//	float4 tangentToWorld[3],
//	half retroReflectivity)
//{

//	half3 tangent = tangentToWorld[0].xyz;
//	half3 binormal = tangentToWorld[1].xyz;

//	half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness);
//	half3 halfDir = Unity_SafeNormalize(light.dir + viewDir);


//#define TCP2_HANDLE_CORRECTLY_NEGATIVE_NDOTV 0 

//#if TCP2_HANDLE_CORRECTLY_NEGATIVE_NDOTV
//	// The amount we shift the normal toward the view vector is defined by the dot product.
//	half shiftAmount = dot(normal, viewDir);
//	normal = shiftAmount < 0.0f ? normal + viewDir * (-shiftAmount + 1e-5f) : normal;
//	// A re-normalization should be applied here but as the shift is small we don't do it to save ALU.
//	//normal = normalize(normal);

//	half nv = abs(dot(normal, viewDir)); // TODO: this abs should no be necessary here
//#else
//	half nv = abs(dot(normal, viewDir));	// This abs allow to limit artifact
//#endif

//	half nl = abs(dot(normal, light.dir));

//	//TCP2 Ramp N.L
//	nl = WrapRampNL(nl, rampThreshold, rampSmoothness);

//	half nh = abs(dot(normal, halfDir));

//	half lv = abs(dot(light.dir, viewDir));
//	half lh = abs(dot(light.dir, halfDir));

//	//// Diffuse term
//	//half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;

//	half diffuseTerm = nl * (1 - oneMinusReflectivity);

//	// Specular term
//	// HACK: theoretically we should divide diffuseTerm by Pi and not multiply specularTerm!
//	// BUT 1) that will make shader look significantly darker than Legacy ones
//	// and 2) on engine side "Non-important" lights have to be divided by Pi too in cases when they are injected into ambient SH
//	half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

//	half V = SmithJointGGXVisibilityTerm(nl, nv, roughness);
//	half D = GGXTerm(nh, roughness);

//#if defined(_SPECULARHIGHLIGHTS_OFF)
//	half specularTerm = 0.0;
//#else

//	half vh = abs(dot(viewDir, halfDir));



//#if _ANISO
//	half RoughnessX, RoughnessY;
//	half th = dot(tangent, halfDir);
//	half bh = dot(binormal, halfDir);
//	half tl = dot(tangent, light.dir);
//	half tv = dot(tangent, viewDir);
//	//half specularTerm = D_GGXAnisotropic(th, bh, nh, _RoughnessX, _RoughnessY);// *UNITY_PI;
//	half specularTerm = AnisotropicSpecular(nl, nv, tl, tv, _Temp);
//	half fdsa = specularTerm;
//#else
//	half specularTerm =  V * D * UNITY_PI;
//#endif


//	specColor = (0.08 * (1 - oneMinusReflectivity)) + diffColor * oneMinusReflectivity;
//	//half3 tempCol = specColor;

//	//half retroMask = abs(retroReflectivity);
//	////retroMask = max(retroMask, _Temp);
//	//half3 stdBRDF = EnvBRDFApproxCustom(specColor, roughness, nv);
//	//half3 retroBRDF = GetSpecularRetroReflectiveBRDF(specColor, vh, nh, retroMask);
//	//half envSpecColor = lerp(stdBRDF, GetEnvRetroReflectiveBRDF(specColor, nv, retroMask, roughness), retroMask);

//	//specColor = lerp(stdBRDF, retroBRDF, 1); // retroMask);

//#if TCP2_SPEC_TOON
//	//TCP2 Stylized Specular
//	half r = sqrt(roughness)*0.85;
//	r += 1e-4h;
//	specularTerm = lerp(specularTerm, StylizedSpecular(specularTerm, specSmooth) * (1 / r), specBlend);
//#endif

//#ifdef UNITY_COLORSPACE_GAMMA
//	specularTerm = sqrt(max(1e-4h, specularTerm));
//#endif

//	// specularTerm * nl can be NaN on Metal in some cases, use max() to make sure it's a sane value
//	specularTerm = abs(specularTerm * nl);
//#endif	//	_SPECULARHIGHLIGHTS_OFF


//	// surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
//	half surfaceReduction;
//#	ifdef UNITY_COLORSPACE_GAMMA
//	surfaceReduction = 1.0 - 0.28*roughness*perceptualRoughness;		// 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
//#	else
//	surfaceReduction = 1.0 / (roughness*roughness + 1.0);			// fade \in [0.5;1]
//#	endif

//	// To provide true Lambert lighting, we need to be able to kill specular completely.
//	specularTerm *= any(specColor) ? 1.0 : 0.0;

//	//TCP2 Colored Highlight/Shadows
//	shadowColor = lerp(highlightColor, shadowColor, shadowColor.a);	//Shadows intensity through alpha
//	diffuseTerm *= atten;
//	half3 diffuseTermRGB = lerp(shadowColor.rgb, highlightColor.rgb, diffuseTerm);
//	half3 diffuseTCP2 = diffColor * (gi.diffuse + light.color * diffuseTermRGB);
//	//original: diffColor * (gi.diffuse + light.color * diffuseTerm)

//	//TCP2: atten contribution to specular since it was removed from light calculation
//	specularTerm *= atten;

//	half grazingTerm = abs(smoothness + (1 - oneMinusReflectivity));
//	half3 color = half3(0, 0, 0);
//#if _ANISO

//	 //color =	diffuseTCP2 +
//	 //               + specularTerm * light.color * FresnelTerm (specColor, lh)
//		//			+ surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv) ;
//	 color = fdsa;
//#endif


//#if RIM
//	//TCP2 Enhanced Rim/Fresnel
//	color += StylizedFresnel(nv, roughness, light, normal, rimParams);
//#endif


//#if _REAL_FRESNEL
//	alpha = (1 - abs(smoothstep(_Thickness - _Gradient * 0.5, _Thickness + _Gradient * 0.5, nv))) * alpha;
//#endif

//	return half4(color, abs(_AlphaScale * alpha));

//}


