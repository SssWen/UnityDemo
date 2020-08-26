// #ifndef TCP2_STANDARD_BRDF_INCLUDED
// #define TCP2_STANDARD_BRDF_INCLUDED
#ifndef FUN_UNITY_STANDARD_BRDF_INCLUDED
#define FUN_UNITY_STANDARD_BRDF_INCLUDED // 临时用这个方法，后面再查找
// Main BRDF function, based on UnityStandardBRDF.cginc
//-------------------------------------------------------------------------------------
#include "UnityCG.cginc"
#include "UnityStandardConfig.cginc"
#include "FunDream_UnityStandardInput.cginc"
#include "UnityLightingCommon.cginc"


// Unity 自带部分
//-----------------------------------------------------------------------------
// Helper to convert smoothness to roughness
//-----------------------------------------------------------------------------

float PerceptualRoughnessToRoughness(float perceptualRoughness)
{
    return perceptualRoughness * perceptualRoughness;
}

half RoughnessToPerceptualRoughness(half roughness)
{
    return sqrt(roughness);
}

// Smoothness is the user facing name
// it should be perceptualSmoothness but we don't want the user to have to deal with this name
half SmoothnessToRoughness(half smoothness)
{
    return (1 - smoothness) * (1 - smoothness);
}

float SmoothnessToPerceptualRoughness(float smoothness)
{
    return (1 - smoothness);
}

//-------------------------------------------------------------------------------------

inline half Pow4 (half x)
{
    return x*x*x*x;
}

inline float2 Pow4 (float2 x)
{
    return x*x*x*x;
}

inline half3 Pow4 (half3 x)
{
    return x*x*x*x;
}

inline half4 Pow4 (half4 x)
{
    return x*x*x*x;
}

// Pow5 uses the same amount of instructions as generic pow(), but has 2 advantages:
// 1) better instruction pipelining
// 2) no need to worry about NaNs
inline half Pow5 (half x)
{
    return x*x * x*x * x;
}

inline half2 Pow5 (half2 x)
{
    return x*x * x*x * x;
}

inline half3 Pow5 (half3 x)
{
    return x*x * x*x * x;
}

inline half4 Pow5 (half4 x)
{
    return x*x * x*x * x;
}

inline half3 FresnelTerm (half3 F0, half cosA)
{
    half t = Pow5 (1 - cosA);   // ala Schlick interpoliation
    return F0 + (1-F0) * t;
}
inline half3 FresnelLerp (half3 F0, half3 F90, half cosA)
{
    half t = Pow5 (1 - cosA);   // ala Schlick interpoliation
    return lerp (F0, F90, t);
}
// approximage Schlick with ^4 instead of ^5
inline half3 FresnelLerpFast (half3 F0, half3 F90, half cosA)
{
    half t = Pow4 (1 - cosA);
    return lerp (F0, F90, t);
}

// Note: Disney diffuse must be multiply by diffuseAlbedo / PI. This is done outside of this function.
half DisneyDiffuse(half NdotV, half NdotL, half LdotH, half perceptualRoughness)
{
    half fd90 = 0.5 + 2 * LdotH * LdotH * perceptualRoughness;
    // Two schlick fresnel term
    half lightScatter   = (1 + (fd90 - 1) * Pow5(1 - NdotL));
    half viewScatter    = (1 + (fd90 - 1) * Pow5(1 - NdotV));

    return lightScatter * viewScatter;
}
// NOTE: Visibility term here is the full form from Torrance-Sparrow model, it includes Geometric term: V = G / (N.L * N.V)
// This way it is easier to swap Geometric terms and more room for optimizations (except maybe in case of CookTorrance geom term)

// Generic Smith-Schlick visibility term
inline half SmithVisibilityTerm (half NdotL, half NdotV, half k)
{
    half gL = NdotL * (1-k) + k;
    half gV = NdotV * (1-k) + k;
    return 1.0 / (gL * gV + 1e-5f); // This function is not intended to be running on Mobile,
                                    // therefore epsilon is smaller than can be represented by half
}

// Smith-Schlick derived for Beckmann
inline half SmithBeckmannVisibilityTerm (half NdotL, half NdotV, half roughness)
{
    half c = 0.797884560802865h; // c = sqrt(2 / Pi)
    half k = roughness * c;
    return SmithVisibilityTerm (NdotL, NdotV, k) * 0.25f; // * 0.25 is the 1/4 of the visibility term
}

// Ref: http://jcgt.org/published/0003/02/03/paper.pdf
inline half SmithJointGGXVisibilityTerm (half NdotL, half NdotV, half roughness)
{
#if 0
    // Original formulation:
    //  lambda_v    = (-1 + sqrt(a2 * (1 - NdotL2) / NdotL2 + 1)) * 0.5f;
    //  lambda_l    = (-1 + sqrt(a2 * (1 - NdotV2) / NdotV2 + 1)) * 0.5f;
    //  G           = 1 / (1 + lambda_v + lambda_l);

    // Reorder code to be more optimal
    half a          = roughness;
    half a2         = a * a;

    half lambdaV    = NdotL * sqrt((-NdotV * a2 + NdotV) * NdotV + a2);
    half lambdaL    = NdotV * sqrt((-NdotL * a2 + NdotL) * NdotL + a2);

    // Simplify visibility term: (2.0f * NdotL * NdotV) /  ((4.0f * NdotL * NdotV) * (lambda_v + lambda_l + 1e-5f));
    return 0.5f / (lambdaV + lambdaL + 1e-5f);  // This function is not intended to be running on Mobile,
                                                // therefore epsilon is smaller than can be represented by half
#else
    // Approximation of the above formulation (simplify the sqrt, not mathematically correct but close enough)
    half a = roughness;
    half lambdaV = NdotL * (NdotV * (1 - a) + a);
    half lambdaL = NdotV * (NdotL * (1 - a) + a);

    return 0.5f / (lambdaV + lambdaL + 1e-5f);
#endif
}

inline float GGXTerm (float NdotH, float roughness)
{
    float a2 = roughness * roughness;
    float d = (NdotH * a2 - NdotH) * NdotH + 1.0f; // 2 mad
    return UNITY_INV_PI * a2 / (d * d + 1e-7f); // This function is not intended to be running on Mobile,
                                            // therefore epsilon is smaller than what can be represented by half
}

inline half PerceptualRoughnessToSpecPower (half perceptualRoughness)
{
    half m = PerceptualRoughnessToRoughness(perceptualRoughness);   // m is the true academic roughness.
    half sq = max(1e-4f, m*m);
    half n = (2.0 / sq) - 2.0;                          // https://dl.dropboxusercontent.com/u/55891920/papers/mm_brdf.pdf
    n = max(n, 1e-4f);                                  // prevent possible cases of pow(0,0), which could happen when roughness is 1.0 and NdotH is zero
    return n;
}

// BlinnPhong normalized as normal distribution function (NDF)
// for use in micro-facet model: spec=D*G*F
// eq. 19 in https://dl.dropboxusercontent.com/u/55891920/papers/mm_brdf.pdf
inline half NDFBlinnPhongNormalizedTerm (half NdotH, half n)
{
    // norm = (n+2)/(2*pi)
    half normTerm = (n + 2.0) * (0.5/UNITY_PI);

    half specTerm = pow (NdotH, n);
    return specTerm * normTerm;
}

//-------------------------------------------------------------------------------------
/*
// https://s3.amazonaws.com/docs.knaldtech.com/knald/1.0.0/lys_power_drops.html

const float k0 = 0.00098, k1 = 0.9921;
// pass this as a constant for optimization
const float fUserMaxSPow = 100000; // sqrt(12M)
const float g_fMaxT = ( exp2(-10.0/fUserMaxSPow) - k0)/k1;
float GetSpecPowToMip(float fSpecPow, int nMips)
{
   // Default curve - Inverse of TB2 curve with adjusted constants
   float fSmulMaxT = ( exp2(-10.0/sqrt( fSpecPow )) - k0)/k1;
   return float(nMips-1)*(1.0 - clamp( fSmulMaxT/g_fMaxT, 0.0, 1.0 ));
}

    //float specPower = PerceptualRoughnessToSpecPower(perceptualRoughness);
    //float mip = GetSpecPowToMip (specPower, 7);
*/

inline float3 Unity_SafeNormalize(float3 inVec)
{
    float dp3 = max(0.001f, dot(inVec, inVec));
    return inVec * rsqrt(dp3);
}

// ---------------------------------Unity自带部分--------------------------


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
// 这里暂时只做一种适配，高端机的适配，
// TODO:后面修改其他适配模式
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

#endif // TCP2_STANDARD_BRDF_INCLUDED
