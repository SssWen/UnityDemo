

#define unity_LightGammaCorrectionConsts_PIDiv4 (UNITY_PI/4) // 直接拿出UnityDeprecated的线性空间下的计算

half sqr( half x){
	return x*x;
}

half3 WrappedDiffuse(half NdotL, half Wrap)
{
	return saturate((NdotL + Wrap) / ((1 + Wrap) * (1 + Wrap)));
}


fixed3 ShiftTangent ( fixed3 T, fixed3 N, fixed shift)
{
	return normalize(T + shift * N);
}


half3 Fuzz(half NdotV, half3 Color, half FuzzRange, half FuzzBias)
{
	half3 FuzzColor = pow(exp2( - NdotV), FuzzRange) + FuzzBias;
	FuzzColor *= Color;
	return FuzzColor;
}


half AnisotropicSpecular (half TdotH, half NdotL, half NdotV, half TdotL, half TdotV, half gloss, half3 worldTangent, half SpecPower, out fixed3 Diffuse)
{
	half Specular = 0;

	#if defined(_SPECULARHIGHLIGHTS_OFF)
		Specular = 0;
		Diffuse = NdotL;
	#else
		half PI = 3.1415;
		half roughness = 1.0 - gloss;	
		Diffuse = sqrt(1.0 - sqr(TdotL)) * NdotL;
		Specular = NdotL * pow(saturate(sqrt(1.0 - sqr(TdotL)) * sqrt(1.0 - sqr(TdotV)) - TdotL * TdotV), SpecPower);	
		half normalization =  sqrt((SpecPower+1)*((SpecPower)+1))/(8 * PI);//
		Specular *= normalization;
		//Unity 2017.1f1 seems to look way too dark
		Specular *= 2;
	#endif

	return Specular;
}

// 这里使用UnityBRDFCore的PerceptualRoughnessToSpecPower代替RoughnessToSpecPower
inline half RoughnessToSpecPower(half perceptualRoughness)
{
	half m = PerceptualRoughnessToRoughness(perceptualRoughness);   // m is the true academic roughness.
	half sq = max(1e-4f, m*m);
	half n = (2.0 / sq) - 2.0;                          // https://dl.dropboxusercontent.com/u/55891920/papers/mm_brdf.pdf
	n = max(n, 1e-4f);                                  // prevent possible cases of pow(0,0), which could happen when roughness is 1.0 and NdotH is zero
	return n;
}

fixed4 AnisoLighting(fixed3 specCol, fixed3 diffuseColor, half gloss, half alpha, half3 customNormal, half3 viewDirection, float4 tangentTransform[3], half3 posWorld, half4 ambientOrLightmapUV, half4 uv, half AO, UnityLight light, fixed attenuation)
{

	half3 normalLocalAniso = customNormal;
	half3 normalDirectionAniso = customNormal;

	half3 tangentDir = tangentTransform[0].xyz;
	half3 bitangentDir = tangentTransform[1].xyz;
	half3 normalDir = tangentTransform[2].xyz;

	half3 viewReflectDirection = reflect( -viewDirection, customNormal );
	half3 viewReflectDirectionAniso = reflect( -viewDirection, normalDirectionAniso );
	half3 lightDirection = normalize(light.dir);
	half3 lightColor = _LightColor0.rgb; 
	half3 halfDirection = normalize(viewDirection + lightDirection); 

	half3 attenColor = attenuation * lightColor;	

 	half NdotV =  max(0, dot( customNormal, viewDirection ));	
    half NdotH =  max(0, dot( customNormal, halfDirection ));	
    half VdotH =  max(0, dot( viewDirection, halfDirection ));
	half LdotH = max(0.0,dot(lightDirection, halfDirection));	

	half SpecularPower = RoughnessToSpecPower(1.0 - gloss);
	float3x3 tangentToWorld = transpose(float3x3(tangentDir, bitangentDir, normalDir));
	half3 hTangent = mul(tangentToWorld, half3(0, 1, 0));		
	half3 Tangent = lerp(tangentDir, hTangent, _XCurve);
	half3 worldTangent = mul(tangentToWorld, half3(normalLocalAniso.rg, 0.0)  ).xyz;
	worldTangent = normalize(lerp(Tangent, worldTangent, _YCurve));


	fixed3 noiseTexCol = fixed3(1,0,1);
	#if _NOISE_TEX
		noiseTexCol = tex2D(_NoiseTex, TRANSFORM_TEX(uv.xy, _NoiseTex));
	#endif
	worldTangent = ShiftTangent(worldTangent, customNormal, _Offset + noiseTexCol.g);

	half TdotL = dot( lightDirection, worldTangent );
	half TdotV = dot( viewDirection, worldTangent );
	half TdotH = dot( halfDirection, worldTangent );
	/*float visTerm = SmithVisibilityTerm( NdotL, NdotV, 1.0 - (gloss));	*/               

	half NdotL = max(0.0, dot( customNormal, lightDirection ));	
	NdotL = WrapRampNL(NdotL, _RampThreshold, _RampSmooth);

	fixed3 directDiffuse;
	half specularTerm = AnisotropicSpecular(TdotH, NdotL, NdotV, TdotL, TdotV, gloss, worldTangent, SpecularPower, directDiffuse);
	
	#if TCP2_SPEC_TOON
		half r = sqrt(1 - gloss)*0.85;
		r += 1e-4h;
		specularTerm = lerp(specularTerm, StylizedSpecular(specularTerm, _SpecSmooth) * (1/r), _SpecBlend);
	#endif
	
	fixed3 directSpecular = attenColor * FresnelTerm(specCol, LdotH) /** visTerm*/ * unity_LightGammaCorrectionConsts_PIDiv4 * specularTerm;

	#if _HAIR
		half3 worldTangent2 = ShiftTangent(worldTangent, customNormal, _Offset2 + noiseTexCol.g);
		half3 worldTangent3 = ShiftTangent(worldTangent, customNormal, _Offset3 + noiseTexCol.g);
		half TdotL2 = dot( lightDirection, worldTangent2 );
		half TdotV2 = dot( viewDirection, worldTangent2 );
		half TdotH2 = dot( halfDirection, worldTangent2 );
		half TdotL3 = dot( lightDirection, worldTangent3 );
		half TdotV3 = dot( viewDirection, worldTangent3 );
		half TdotH3 = dot( halfDirection, worldTangent3 );
		half specularTerm2 = AnisotropicSpecular(TdotH2, NdotL, NdotV, TdotL2, TdotV2, gloss, worldTangent2, RoughnessToSpecPower(1.0 - _Smoothness2), directDiffuse);
		half specularTerm3 = AnisotropicSpecular(TdotH3, NdotL, NdotV, TdotL3, TdotV3, gloss, worldTangent3, RoughnessToSpecPower(1.0 - _Smoothness3), directDiffuse);
		fixed3 hairSpecCol = _HairSpecCol.rgb * _HairSpecCol.a * specularTerm + _HairSpecCol2.rgb * _HairSpecCol2.a * specularTerm2 + _HairSpecCol3.rgb * _HairSpecCol3.a * specularTerm3;
		directSpecular = attenColor * FresnelTerm(specCol, LdotH) * unity_LightGammaCorrectionConsts_PIDiv4 * hairSpecCol;
	#endif

	fixed3 shadowColor = lerp(_HColor, _SColor, _SColor.a);	
	directDiffuse = lerp(shadowColor, _HColor.rgb, NdotL ) * attenColor;

///////// env lighting
	//UnityLight light;

	#ifdef LIGHTMAP_OFF
		light.color = lightColor;
		light.dir = lightDirection;
		light.ndotl = LambertTerm(customNormal, light.dir);
	#else
		light.color = half3(0.f, 0.f, 0.f);
		light.ndotl = 0.0f;
		light.dir = half3(0.f, 0.f, 0.f);
	#endif

	UnityGIInput d;
	d.light = light;
	d.worldPos = posWorld;
	d.worldViewDir = viewDirection;
	d.atten = attenuation;

	#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
		d.ambient = 0;
		d.lightmapUV = ambientOrLightmapUV;
	#else
		d.ambient = ambientOrLightmapUV;
	#endif

	d.boxMax[0] = unity_SpecCube0_BoxMax;
	d.boxMin[0] = unity_SpecCube0_BoxMin;
	d.probePosition[0] = unity_SpecCube0_ProbePosition;
	d.probeHDR[0] = unity_SpecCube0_HDR;
	d.boxMax[1] = unity_SpecCube1_BoxMax;
	d.boxMin[1] = unity_SpecCube1_BoxMin;
	d.probePosition[1] = unity_SpecCube1_ProbePosition;
	d.probeHDR[1] = unity_SpecCube1_HDR;
	Unity_GlossyEnvironmentData ugls_en_data;
	ugls_en_data.roughness = 1.0 - gloss;
    ugls_en_data.reflUVW = viewReflectDirectionAniso;
    UnityGI gi = UnityGlobalIllumination(d, AO, customNormal, ugls_en_data );
    lightDirection = gi.light.dir;
    lightColor = gi.light.color;
    half grazingTerm = saturate( gloss + Luminance(_SpecColor) );
    half3 indirectDiffuse = 0, indirectSpecular = 0;
    indirectSpecular = (gi.indirect.specular);
	
    indirectSpecular *= FresnelLerp (_SpecColor.rgb * specCol, grazingTerm,  NdotV);
	
	indirectDiffuse = half3(0,0,0);
    indirectDiffuse += gi.indirect.diffuse;
	
    fixed3 finalColor = 0;
	fixed3 specular = 0;
	
///////////Lacquer	
	//#ifdef _LACQUER
	//	half3 Lacquer_normalDirection = normalDir;
	//	half3 Lacquer_viewReflectDirection = reflect(-viewDirection, Lacquer_normalDirection);
	//	half3 Lacquer_EnvironmentReflections = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, 
	//		Lacquer_viewReflectDirection, 1 - _LacquerSmoothness);
	//	Lacquer_EnvironmentReflections *= FresnelTerm(_LacquerReflection, NdotV);
		
	//	#ifdef LACQUER_OCCLUSION_ON
	//		//Lacquer_EnvironmentReflections *= AO.a;
	//		Lacquer_EnvironmentReflections *= AO;
	//	#endif
	//#endif


///////// specular:	
	#if defined(_SPECULARHIGHLIGHTS_OFF)
		specular = 0;
	#else
		specular = (directSpecular + indirectSpecular) * AO * _HColor.rgb * _Gloss * VdotH * lerp(1, noiseTexCol.b, _SpecNoise);
	#endif


///////// Diffuse:				
	fixed3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor * AO;


////////// Fuzz:
	#ifdef _FUZZ					
		fixed3 fuzzTexCol = fixed3(1,1,1);
		#if _FUZZ_TEX
			fuzzTexCol = tex2D(_FuzzTex, TRANSFORM_TEX(uv.xy, _FuzzTex)).xyz;
		#endif

		fixed3 FuzzLighting = Fuzz(NdotV, fuzzTexCol * AO * (_FuzzColor * indirectDiffuse + _FuzzColor * WrappedDiffuse(NdotL, _WrapDiffuse) * attenuation * lightColor), _FuzzRange, _FuzzBias);
	#else
		fixed3 FuzzLighting = 0;
	#endif


///////// Final Color:              	
	finalColor = diffuse + specular + FuzzLighting;			   
	
	//#ifdef _LACQUER
	//	return fixed4(finalColor * (1- _LacquerReflection) + Lacquer_EnvironmentReflections, alpha);
	//#else
		return fixed4(finalColor, alpha);
	//#endif

  }





fixed4 AnisoLightingAdd(fixed3 specCol, fixed3 diffuseColor, half gloss, half alpha, half3 customNormal, half3 viewDirection, float4 tangentTransform[3], half3 posWorld, half4 uv, UnityLight light, fixed attenuation)
{

	half3 normalLocalAniso = customNormal;
	half3 normalDirectionAniso = customNormal;
	half _Temp = 1;

	half3 tangentDir = tangentTransform[0].xyz;
	half3 bitangentDir = tangentTransform[1].xyz;
	half3 normalDir = tangentTransform[2].xyz;

	half3 viewReflectDirection = reflect( -viewDirection, customNormal );
	half3 viewReflectDirectionAniso = reflect( -viewDirection, normalDirectionAniso );

	//float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
	half3 lightDirection = normalize(light.dir);

	half3 lightColor = _LightColor0.rgb;
	half3 halfDirection = normalize(viewDirection + lightDirection); 

	//UNITY_LIGHT_ATTENUATION(attenuation, i,posWorld);	
	half3 attenColor = attenuation * lightColor;	

 	half NdotV =  max(0, dot( customNormal, viewDirection ));	
    half NdotH =  max(0, dot( customNormal, halfDirection ));	
    half VdotH =  max(0, dot( viewDirection, halfDirection ));
    half LdotH = max(0.0,dot(lightDirection, halfDirection));	

	half SpecularPower = RoughnessToSpecPower(1.0 - gloss);
	float3x3 tangentToWorld = transpose(float3x3(tangentDir, bitangentDir, normalDir));
	half3 hTangent = mul(tangentToWorld, half3(0, 1, 0));		
	half3 Tangent = lerp(tangentDir, hTangent, _XCurve);
	half3 worldTangent = mul(tangentToWorld, half3(normalLocalAniso.rg, 0.0) ).xyz;
	worldTangent = normalize(lerp(Tangent, worldTangent, _YCurve));

	fixed3 noiseTexCol = fixed3(1,0,1);
	#if _NOISE_TEX
		noiseTexCol = tex2D(_NoiseTex, TRANSFORM_TEX(uv.xy, _NoiseTex));
	#endif
	worldTangent = ShiftTangent(worldTangent, customNormal, _Offset + noiseTexCol.g);
	half TdotL = dot( lightDirection, worldTangent );
	half TdotV = dot( viewDirection, worldTangent );
	half TdotH = dot( halfDirection, worldTangent );

	half NdotL = max(0.0, dot( customNormal, lightDirection ));	
	NdotL = WrapRampNL(NdotL, _RampThreshold, _RampSmooth);
	
	fixed3 directDiffuse;
	half specularTerm = AnisotropicSpecular(TdotH, NdotL, NdotV, TdotL, TdotV, gloss, worldTangent, SpecularPower, directDiffuse);
	
	#if TCP2_SPEC_TOON
		half r = sqrt(1 - gloss)*0.85;
		r += 1e-4h;
		specularTerm = lerp(specularTerm, StylizedSpecular(specularTerm, _SpecSmooth) * (1/r), _SpecBlend);
	#endif
	
	fixed3 directSpecular = attenColor * FresnelTerm(specCol, LdotH) /** visTerm*/ * unity_LightGammaCorrectionConsts_PIDiv4 * specularTerm;

	#if _HAIR
		half3 worldTangent2 = ShiftTangent(worldTangent, customNormal, _Offset2 + noiseTexCol.g);
		half3 worldTangent3 = ShiftTangent(worldTangent, customNormal, _Offset3 + noiseTexCol.g);
		half TdotL2 = dot( lightDirection, worldTangent2 );
		half TdotV2 = dot( viewDirection, worldTangent2 );
		half TdotH2 = dot( halfDirection, worldTangent2 );
		half TdotL3 = dot( lightDirection, worldTangent3 );
		half TdotV3 = dot( viewDirection, worldTangent3 );
		half TdotH3 = dot( halfDirection, worldTangent3 );
		half specularTerm2 = AnisotropicSpecular(TdotH2, NdotL, NdotV, TdotL2, TdotV2, gloss, worldTangent2, RoughnessToSpecPower(1.0 - _Smoothness2), directDiffuse);
		half specularTerm3 = AnisotropicSpecular(TdotH3, NdotL, NdotV, TdotL3, TdotV3, gloss, worldTangent3, RoughnessToSpecPower(1.0 - _Smoothness3), directDiffuse);
		fixed3 hairSpecCol = _HairSpecCol.rgb * _HairSpecCol.a * specularTerm + _HairSpecCol2.rgb * _HairSpecCol2.a * specularTerm2 + _HairSpecCol3.rgb * _HairSpecCol3.a * specularTerm3;
		directSpecular = attenColor * FresnelTerm(specCol, LdotH) * unity_LightGammaCorrectionConsts_PIDiv4 * hairSpecCol;
	#endif

	fixed3 shadowColor = lerp(_HColor, _SColor, _SColor.a);	
	directDiffuse = lerp(shadowColor, _HColor.rgb, NdotL ) * attenColor;
	
    fixed3 finalColor = 0;
	fixed3 specular = 0;

///////// specular:	
	#if defined(_SPECULARHIGHLIGHTS_OFF)
		specular = 0;
	#else
		specular = directSpecular * _HColor.rgb * _Gloss * VdotH * lerp(1, noiseTexCol.b, _SpecNoise);
	#endif


///////// Diffuse:				
	fixed3 diffuse = directDiffuse * diffuseColor;




////////// Fuzz:
	#ifdef _FUZZ	
		fixed3 fuzzTexCol = fixed3(1,1,1);
		#if _FUZZ_TEX
			fuzzTexCol = tex2D(_FuzzTex, TRANSFORM_TEX(uv.xy, _FuzzTex)).xyz;
		#endif
		fixed3 FuzzLighting = Fuzz(NdotV, fuzzTexCol * _FuzzColor * WrappedDiffuse(NdotL, _WrapDiffuse) * attenuation * lightColor, _FuzzRange, _FuzzBias);
	#else
		fixed3 FuzzLighting = 0;
	#endif


///////// Final Color:              	
	finalColor = diffuse + specular + FuzzLighting;			   
	
	//#ifdef _LACQUER
	//	return fixed4(finalColor * (1- _LacquerReflection) , alpha);
	//#else
		return fixed4(finalColor, alpha);
	//#endif

  }

  
