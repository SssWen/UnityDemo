#ifndef UNIVERSAL_FORWARD_CLOTH_LIT_PASS_INCLUDED
#define UNIVERSAL_FORWARD_CLOTH_LIT_PASS_INCLUDED


#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 lightmapUV   : TEXCOORD1;
    float2 uv3   : TEXCOORD2;
    float2 uv4   : TEXCOORD3;    
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
// target 3.0 <= 10 interpolators
struct Varyings
{
    float4 uv                       : TEXCOORD0; // float2 to float4
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    float3 positionWS               : TEXCOORD2;
#endif

// 考虑剔除分支，以防后面太多判断
// #ifdef _NORMALMAP
    float4 normalWS                 : TEXCOORD3;    // xyz: normal, w: viewDir.x
    float4 tangentWS                : TEXCOORD4;    // xyz: tangent, w: viewDir.y
    float4 bitangentWS              : TEXCOORD5;    // xyz: bitangent, w: viewDir.z
// #else
//     float3 normalWS                 : TEXCOORD3;
//     float3 viewDirWS                : TEXCOORD4;
// #endif

    half4 fogFactorAndVertexLight   : TEXCOORD6; // x: fogFactor, yzw: vertex light

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    float4 shadowCoord              : TEXCOORD7;
#endif

    float4 detailUV                 : TEXCOORD8;

    float4 positionCS               : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};
half3 ShiftTangent ( half3 T, half3 N, half3 shift)
{
	return normalize(T + shift * N);
}

// 修正切线
// void SampleAnisoTangent(FragmentState s, out half3 tangent, out half3 bitangent, half3 tAnisoDirectionMap,half dir /*_Reflection_Anisotropic_Anisotropy_Direction*/)
// {
// 	//Direction
// 	tangent = tAnisoDirectionMap;
// 	tangent = 2*tangent -1;
// 	tangent.xy = tangent.yx;
// 	tangent.x = -tangent.x;
// 	//swizzle tangent and binormal directions
	
// 	float a = dir / 180 * 3.1415926;
// 	float3x3 tangent_roate = float3x3(cos(a), sin(a), 0,
// 		                            sin(a), cos(a),0,
// 		                            0,         0,1
// 		                              );

// 	tangent = mul(tangent_roate, tangent);

   
// 	//transform into render space
// 	tangent = tangent.x * s.vertexTangent +
// 		tangent.y * s.vertexBitangent +
// 		tangent.z * s.vertexNormal;
// 	//tangent = mul(tangent,half3x3(s.vertexTangent, s.vertexBitangent, s.vertexNormal));

// 	//project tangent onto normal plane
// 	tangent = tangent - s.normal*dot(tangent, s.normal);
// 	tangent = normalize(tangent);
// 	bitangent = normalize(cross(s.normal, tangent));
// }

		// float3 RotateYDegrees918( float3 normal , float degrees )
		// {
		// 	float alpha = degrees * UNITY_PI / 180.0;
		// 	float sina, cosa;
		// 					sincos(alpha, sina, cosa);
		// 					float2x2 m = float2x2(cosa, -sina, sina, cosa);
		// 	return float3(mul(m, normal.xz), normal.y).xzy;
		// }
void InitializeInputData(Varyings input, half3 normalTS, out F_InputData inputData)
{
    inputData = (F_InputData)0;

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    inputData.positionWS = input.positionWS;
#endif

// #ifdef _NORMALMAP
    half3 viewDirWS = half3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
    inputData.normalWS = TransformTangentToWorld(normalTS,
        half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
// #else
//     half3 viewDirWS = input.viewDirWS;
//     inputData.normalWS = input.normalWS;
// #endif

    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    viewDirWS = SafeNormalize(viewDirWS);
    inputData.viewDirectionWS = viewDirWS;

    #ifdef _ANISTROPIC_ON

        inputData.bitangentWS = normalize(cross(inputData.normalWS.xyz, input.tangentWS.xyz));
        inputData.tangentWS =   normalize(cross(inputData.bitangentWS.xyz, input.normalWS.xyz));   

        #ifdef _ANIS_NOISE_TEX
            half a = _Rotate;
            float3x3 tangent_roate = float3x3(  cos(a), sin(a), 0,
                                                sin(a), cos(a),0,
                                                0,         0,1
                                                );
            half3 tangent2  = mul(tangent_roate, input.tangentWS);
            tangent2 = tangent2.x * input.tangentWS + tangent2.y * input.bitangentWS + tangent2.z * input.normalWS;

            half2 uv = input.uv.xy * _AnisNoiseTex_ST.xy + _AnisNoiseTex_ST.zw;            
            half3 noise = SAMPLE_TEXTURE2D_Default(_AnisNoiseTex, uv);
            half3 hTangent = TransformTangentToWorld(half3(0,1,0), half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
            half3 Tangent = lerp(inputData.tangentWS, hTangent, _ShiftX);
             tangent2 = lerp(tangent2, hTangent, _ShiftX);

            half3 worldTangent = mul(half3(noise.xy, 0.0), half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
            half3 worldTangent2  = normalize(lerp(tangent2, worldTangent, _ShiftY));
            worldTangent = normalize(lerp(Tangent, worldTangent, _ShiftY));            
                 
            worldTangent2 = ShiftTangent(worldTangent2, inputData.normalWS, _Offset + noise.y);
            worldTangent = ShiftTangent(worldTangent, inputData.normalWS, _Offset + noise.y);
            // inputData.bitangentWS = (cross(inputData.normalWS.xyz, worldTangent));
            // inputData.tangentWS =   normalize(cross(inputData.bitangentWS.xyz, input.normalWS.xyz));
            inputData.tangentWS =   worldTangent;
   
            tangent2 = normalize(worldTangent2);
            inputData.tangentWS2 = tangent2;
            inputData.bitangentWS2 = normalize(cross(inputData.normalWS, tangent2));
	        
        #endif    

    #endif

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    inputData.shadowCoord = input.shadowCoord;
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
#else
    inputData.shadowCoord = float4(0, 0, 0, 0);
#endif

    inputData.fogCoord = input.fogFactorAndVertexLight.x;
    inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
    inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
}

half AddFlash(half4 baseUV, half4 detailUV, half3 normalDir, half3 lightDir, half3 viewDir, out half3 diffCol, out half shapeMask, out half edgeCtrl) 
{
	// half2 flashUV = GetFlashTexcoord(baseUV, detailUV);
	half2 flashUV = baseUV.xy;
	half2 transformedUV = flashUV * _FlashTex_ST.xy + _FlashTex_ST.zw ;//+_TimeParameters.yz;
	half2 id = floor(transformedUV);
	half2 eachUV = frac(transformedUV);

    half rand = SAMPLE_TEXTURE2D(_SparkleNoiseTex, sampler_SparkleNoiseTex, id / _SparkleNoiseTex_TexelSize.zw).r;    
	rand = lerp(1 / _RadiusRandom, 1, rand);
	half rand2 = SAMPLE_TEXTURE2D(_SparkleNoiseTex,sampler_SparkleNoiseTex, (id + 1 + _RandomSeed) / _SparkleNoiseTex_TexelSize.zw).r;
    half rand3 = SAMPLE_TEXTURE2D(_SparkleNoiseTex,sampler_SparkleNoiseTex, (id + 2 + _RandomSeed) / _SparkleNoiseTex_TexelSize.zw).r;
    half rand4 = SAMPLE_TEXTURE2D(_SparkleNoiseTex,sampler_SparkleNoiseTex, (id + 3 + _RandomSeed) / _SparkleNoiseTex_TexelSize.zw).r;	


	//half h = lightDir + viewDir;
	half nh_flash = dot(normalize(lightDir + viewDir * _FlashZone), normalDir);

	half deleteSmall = step(_DeleteSmall, 1 - rand);
	half deleteRand = step(_DeleteRandom, rand2 * 0.99);
	half colorRand = step(_ColorRandom, rand3 * 0.99);

	half uvScale = rand * _RadiusRandom;
	half uvOffset = rand2 * (uvScale - 1) * lerp(_OffsetRandom, 0, 1 / _RadiusRandom);
	half2 newEachUV = eachUV * uvScale - uvOffset;

	half densityCtrl = 1;
    // #if _DENSITY
    // 	half rand5 = tex2D(_SparkleNoiseTex, (id + 4 + _RandomSeed) / _SparkleNoiseTex_TexelSize.zw).r;
    // 	half2 densityUV = id / _FlashTex_ST.xy + _FlashTex_ST.zw;
    // 	half densityMask = tex2D(_SparkleNoiseTex, densityUV).b;
    // 	densityCtrl = step(1 - densityMask, lerp(deleteRand, 0, _DensityCtrl) + rand5 * _DensitySmooth);
    // #endif

	// shapeMask = tex2D(_FlashTex, newEachUV).r * deleteSmall * deleteRand * densityCtrl;
	shapeMask = SAMPLE_TEXTURE2D(_FlashTex, sampler_FlashTex, newEachUV).r * deleteSmall * deleteRand * densityCtrl;
	// shapeMask = SAMPLE_TEXTURE2D(_FlashTex, sampler_FlashTex, newEachUV).r ; //* deleteSmall * deleteRand * densityCtrl;
	edgeCtrl = pow(nh_flash, 2);
	diffCol = lerp(_FlashColor2.xyz, _FlashColor1.xyz, colorRand);

	//half viewRotate = abs(dot(half3(-1,0,-1), forwardDir));
	// half flash = abs(sin(rand4 * 20 + _FlashRotate * _FlashSpeed * 10));    
	half flash = abs(sin(rand4 * 20 +  _TimeParameters.x* _FlashSpeed * 5));
	flash = max(pow(flash, 0.1*_DarkTime), _FlashMin);

	return flash;

}
half DoPreFunction(Varyings input, half alpha)
{
    half NdotV = 0;
    // #ifdef _NORMALMAP
        half3 viewDirWS = half3( input.normalWS.w,input.tangentWS.w, input.bitangentWS.w);
        NdotV = dot(input.normalWS, viewDirWS);
    // #else
    //     NdotV = dot(input.normalWS, input.viewDirWS);
    // #endif
    half alphaControll = pow(1- abs(max(NdotV,0)),2);
    half alphaEnhance = smoothstep(_RimAlphaMin, _RimAlphaMax, alphaControll) * _RimAlphaEnhance;    
    half finalAlpha = lerp( alpha, 1, alphaEnhance );
    return finalAlpha;
}
// no "inline" keyword either, useless.
void InitializeStandardClothSurfaceData(Varyings input, out F_SurfaceData outSurfaceData)
{
    half4 albedoAlpha = SampleAlbedoAlpha(input.uv*_BaseMap_ST.xy + _BaseMap_ST.zw, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    // _BaseColor.a = lerp(_MinTransparency, 1.0)
    outSurfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff); // SurfaceInput.hlsl    

    // half4 specGloss = SampleMetallicSpecGloss(input.uv*_BaseMap_ST.xy + _BaseMap_ST.zw, albedoAlpha.a);
    half4 specGloss = SampleMetallicSpecGloss(input.uv, albedoAlpha.a);
    // outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
    half3 outCol = albedoAlpha.rgb * _BaseColor.rgb;
    half outMetallic = specGloss.r;
    half outSmoothness = specGloss.a;    
    half3 outNormalTS = SampleNormal(input.uv*_BaseMap_ST.xy + _BaseMap_ST.zw, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
    half3 InitNormal;
    half _mask;
    half temp;

    #if (_LAYER_0_TEX || _LAYER_0_NORMAL)
		half2 layer0SourceUV = GetLayer0Texcoord(input.uv, input.detailUV);
        #if _LAYER_0_TEX
			half2 layer0UV = layer0SourceUV * _Layer0Tex_ST.xy + _Layer0Tex_ST.zw;
            half4 layer0TexCol = SAMPLE_TEXTURE2D_Default (_Layer0Tex, layer0UV);	
		#elif _LAYER_0_NORMAL
			half2 layer0UV = layer0SourceUV * _Layer0Normal_ST.xy + _Layer0Normal_ST.zw;
            half4 layer0TexCol = half4(1,1,1,1);
		#endif

		half2 layer0Mask = GetLayer0Mask(layer0UV);		                
		layer0TexCol = layer0TexCol*layer0Mask.x; 			

        // #ifdef _LAYER_0_TEX
		//     outCol.rgb = lerp(outCol.rgb, layer0TexCol*_Layer0Color.rgb,layer0TexCol.a*_Layer0Color.a); 
        // #endif
        layer0Mask.x *= layer0TexCol.w;
        #if _Layer0NormalMode_0
            outMetallic +=  _Layer0Metallic * layer0TexCol.a;
		    outSmoothness += _Layer0Smoothness * layer0TexCol.a;
            #ifdef _LAYER_0_TEX
                outCol.rgb = lerp(outCol.rgb, layer0TexCol*_Layer0Color.rgb,layer0TexCol.a*_Layer0Color.a);             
            #endif   
        #elif _Layer0NormalMode_1            		    
            temp = _Layer0Metallic * layer0TexCol.a;
            outMetallic = BlendValue(outMetallic, temp, layer0Mask);
            temp = _Layer0Smoothness * layer0TexCol.a;
            outSmoothness = BlendValue(outSmoothness, temp, layer0Mask);
            #ifdef _LAYER_0_TEX
                outCol.rgb = lerp(outCol.rgb, layer0TexCol*_Layer0Color.rgb,layer0TexCol.a*_Layer0Color.a); 
                outCol.rgb = lerp(outCol.rgb,  layer0TexCol*_Layer0Color.rgb, layer0Mask.x);
            #endif            
        #endif
		
        // Normal Blend Model
        #if _LAYER_0_NORMAL
            half3 layer0NormalTS = UnpackScaleNormal(SAMPLE_TEXTURE2D_Default (_Layer0Normal, layer0UV), _Layer0NormalScale);            
            #if _Layer0NormalMode_0
                #if _LAYER_0_TEX
                    InitNormal = outNormalTS;
                    outNormalTS = UDNBlendNormal(outNormalTS, layer0NormalTS);
                    outNormalTS = BlendNormalTS(InitNormal, outNormalTS, layer0Mask.x);
                #else
                    outNormalTS = UDNBlendNormal(outNormalTS, layer0NormalTS);
                #endif
            #elif _Layer0NormalMode_1
                outNormalTS = BlendNormalTS(outNormalTS, layer0NormalTS, layer0Mask.x);
            #endif
        #endif
	#endif

    #if (_LAYER_1_TEX || _LAYER_1_NORMAL)
		half2 layer1SourceUV = GetLayer1Texcoord(input.uv, input.detailUV);
        #if _LAYER_1_TEX
			half2 layer1UV = layer1SourceUV * _Layer1Tex_ST.xy + _Layer1Tex_ST.zw;
            half4 layer1TexCol = SAMPLE_TEXTURE2D_Default (_Layer1Tex, layer1UV);	
		#elif _LAYER_1_NORMAL
			half2 layer1UV = layer1SourceUV * _Layer1Normal_ST.xy + _Layer1Normal_ST.zw;
            half4 layer1TexCol = half4(1,1,1,1);
		#endif		
		half2 layer1Mask = GetLayer1Mask(layer1UV);		        

        // Layer1 AlphaTest
        #if defined(_ALPHATEST_ON)
            // half _alpha = _BaseColor.a*layer1TexCol.a*_Layer1Color.a;
            half _alpha = _BaseColor.a*_Layer1Color.a;
            _alpha = lerp(_MinTransparency, 1 ,_alpha*layer1TexCol.a*_Transparency);
            clip(_alpha - _Layer1Cutoff);
            // outSurfaceData.alpha = DoPreFunction(input, outSurfaceData.alpha);
            outSurfaceData.alpha = DoPreFunction(input, _alpha);            
        #endif
        
		layer1TexCol = layer1TexCol*layer1Mask.x;
        // #ifdef _LAYER_1_TEX
		//     outCol.rgb = lerp(outCol.rgb, layer1TexCol*_Layer1Color.rgb,layer1TexCol.a*_Layer1Color.a); 
        // #endif

        

        layer1Mask.x *= layer1TexCol.w;
        #if _Layer1NormalMode_0
            outMetallic +=  _Layer1Metallic * layer1TexCol.a;
		    outSmoothness += _Layer1Smoothness * layer1TexCol.a;
            #ifdef _LAYER_1_TEX
                outCol.rgb = lerp(outCol.rgb, layer1TexCol*_Layer1Color.rgb,layer1TexCol.a*_Layer1Color.a);                 
            #endif
        #elif _Layer1NormalMode_1            		    
            temp = _Layer1Metallic * layer1TexCol.a;
            outMetallic = BlendValue(outMetallic, temp, layer1Mask);
            temp = _Layer1Smoothness * layer1TexCol.a;
            outSmoothness = BlendValue(outSmoothness, temp, layer1Mask);
            #ifdef _LAYER_1_TEX
                outCol.rgb = lerp(outCol.rgb, layer1TexCol*_Layer1Color.rgb,layer1TexCol.a*_Layer1Color.a); 
                outCol.rgb = lerp(outCol.rgb,  layer1TexCol*_Layer1Color.rgb, layer1Mask.x);
            #endif
        #endif
		

        // Normal Blend Model
        #if _LAYER_1_NORMAL
            half3 layer1NormalTS = UnpackScaleNormal(SAMPLE_TEXTURE2D_Default (_Layer1Normal, layer1UV), _Layer1NormalScale);            
            #if _Layer1NormalMode_0
                #if _LAYER_1_TEX
                    InitNormal = outNormalTS;                                    
                    outNormalTS = UDNBlendNormal(outNormalTS, layer1NormalTS,layer1Mask.x);
                    outNormalTS = BlendNormalTS(InitNormal, outNormalTS, layer1Mask.x);
                #else
                    outNormalTS = UDNBlendNormal(outNormalTS, layer1NormalTS);
                #endif
            #elif _Layer1NormalMode_1
                outNormalTS = BlendNormalTS(outNormalTS, layer1NormalTS, layer1Mask.x);
                // InitNormal = outNormalTS;
                // outNormalTS = BlendNormalTS(outNormalTS, layer1NormalTS, layer1Mask.x);
                // _mask = layer1TexCol.a*(1-layer1Mask.y);
                // outNormalTS = lerp(BlendNormalTS(outNormalTS,InitNormal, _mask),outNormalTS,step(_mask,0));
            #endif            
        #endif
	#endif

    #if (_LAYER_2_TEX || _LAYER_2_NORMAL)
		half2 layer2SourceUV = GetLayer2Texcoord(input.uv, input.detailUV);
        #if _LAYER_2_TEX
			half2 layer2UV = layer2SourceUV * _Layer2Tex_ST.xy + _Layer2Tex_ST.zw;
            half4 layer2TexCol = SAMPLE_TEXTURE2D_Default (_Layer2Tex, layer2UV);	
		#elif _LAYER_2_NORMAL
			half2 layer2UV = layer2SourceUV * _Layer2Normal_ST.xy + _Layer2Normal_ST.zw;
            half4 layer2TexCol = half4(1,1,1,1);
		#endif

		half2 layer2Mask = GetLayer2Mask(layer2UV);		                
		layer2TexCol = layer2TexCol*layer2Mask.x; 			

        // #ifdef _LAYER_2_TEX
		//     outCol.rgb = lerp(outCol.rgb, layer2TexCol*_Layer2Color.rgb,layer2TexCol.a*_Layer2Color.a); 
        // #endif

        layer2Mask.x *= layer2TexCol.w;
        #if _Layer2NormalMode_0
            outMetallic +=  _Layer2Metallic * layer2TexCol.a;
		    outSmoothness += _Layer2Smoothness * layer2TexCol.a;
            #ifdef _LAYER_2_TEX
                outCol.rgb = lerp(outCol.rgb, layer2TexCol*_Layer2Color.rgb,layer2TexCol.a*_Layer2Color.a);                 
            #endif
        #elif _Layer2NormalMode_1            		    
            temp = _Layer2Metallic * layer2TexCol.a;
            outMetallic = BlendValue(outMetallic, temp, layer2Mask);
            temp = _Layer2Smoothness * layer2TexCol.a;
            outSmoothness = BlendValue(outSmoothness, temp, layer2Mask);

            #ifdef _LAYER_2_TEX
                outCol.rgb = lerp(outCol.rgb, layer2TexCol*_Layer2Color.rgb,layer2TexCol.a*_Layer2Color.a); 
                outCol.rgb = lerp(outCol.rgb,  layer2TexCol*_Layer2Color.rgb, layer2Mask.x);
            #endif
        #endif		

        // Normal Blend Model
        #if _LAYER_2_NORMAL
            half3 layer2NormalTS = UnpackScaleNormal(SAMPLE_TEXTURE2D_Default (_Layer2Normal, layer2UV), _Layer2NormalScale);            
            #if _Layer2NormalMode_0
                #if _LAYER_2_TEX
                    InitNormal = outNormalTS;
                    outNormalTS = UDNBlendNormal(outNormalTS, layer2NormalTS);
                    outNormalTS = BlendNormalTS(InitNormal, outNormalTS, layer2Mask.x);
                #else
                    outNormalTS = UDNBlendNormal(outNormalTS, layer2NormalTS);
                #endif
            #elif _Layer2NormalMode_1
                outNormalTS = BlendNormalTS(outNormalTS, layer2NormalTS, layer2Mask.x);
            #endif
        #endif
	#endif


    #if (_LAYER_3_TEX || _LAYER_3_NORMAL)
		half2 layer3SourceUV = GetLayer3Texcoord(input.uv, input.detailUV);
        #if _LAYER_3_TEX
			half2 layer3UV = layer3SourceUV * _Layer3Tex_ST.xy + _Layer3Tex_ST.zw;
            half4 layer3TexCol = SAMPLE_TEXTURE2D_Default (_Layer3Tex, layer3UV);	
		#elif _LAYER_3_NORMAL
			half2 layer3UV = layer3SourceUV * _Layer3Normal_ST.xy + _Layer3Normal_ST.zw;
            half4 layer3TexCol = half4(1,1,1,1);
		#endif		
		half2 layer3Mask = GetLayer3Mask(layer3UV);		
        
        
		layer3TexCol = layer3TexCol*layer3Mask.x;
        // #ifdef _LAYER_3_TEX
		//     outCol.rgb = lerp(outCol.rgb, layer3TexCol*_Layer3Color.rgb,layer3TexCol.a*_Layer3Color.a); 
        // #endif

        layer3Mask.x *= layer3TexCol.w;
        #if _Layer3NormalMode_0
            outMetallic +=  _Layer3Metallic * layer3TexCol.a;
		    outSmoothness += _Layer3Smoothness * layer3TexCol.a;

            #ifdef _LAYER_3_TEX
                outCol.rgb = lerp(outCol.rgb, layer3TexCol*_Layer3Color.rgb,layer3TexCol.a*_Layer3Color.a);                 
            #endif
        #elif _Layer3NormalMode_1            		    
            temp = _Layer3Metallic * layer3TexCol.a;
            outMetallic = BlendValue(outMetallic, temp, layer3Mask);
            temp = _Layer3Smoothness * layer3TexCol.a;
            outSmoothness = BlendValue(outSmoothness, temp, layer3Mask);

            #ifdef _LAYER_3_TEX
                outCol.rgb = lerp(outCol.rgb, layer3TexCol*_Layer3Color.rgb,layer3TexCol.a*_Layer3Color.a); 
                outCol.rgb = lerp(outCol.rgb,  layer3TexCol*_Layer3Color.rgb, layer3Mask.x);
            #endif
        #endif		
		
        // Normal Blend Model
        #if _LAYER_3_NORMAL
            half3 layer3NormalTS = UnpackScaleNormal(SAMPLE_TEXTURE2D_Default (_Layer3Normal, layer3UV), _Layer3NormalScale);            
            #if _Layer3NormalMode_0
                #if _LAYER_3_TEX
                    InitNormal = outNormalTS;                                    
                    outNormalTS = UDNBlendNormal(outNormalTS, layer3NormalTS);                
                    outNormalTS = BlendNormalTS(InitNormal, outNormalTS, layer3Mask.x);
                #else
                    outNormalTS = UDNBlendNormal(outNormalTS, layer3NormalTS);
                #endif
            #elif _Layer3NormalMode_1                
                outNormalTS = BlendNormalTS(outNormalTS, layer3NormalTS, layer3Mask.x);
            #endif            
        #endif                
	#endif


    #if (_LAYER_4_TEX || _LAYER_4_NORMAL)
		half2 layer4SourceUV = GetLayer4Texcoord(input.uv, input.detailUV);
        #if _LAYER_4_TEX
			half2 layer4UV = layer4SourceUV * _Layer4Tex_ST.xy + _Layer4Tex_ST.zw;
            half4 layer4TexCol = SAMPLE_TEXTURE2D_Default (_Layer4Tex, layer4UV);	
		#elif _LAYER_4_NORMAL
			half2 layer4UV = layer4SourceUV * _Layer4Normal_ST.xy + _Layer4Normal_ST.zw;
            half4 layer4TexCol = half4(1,1,1,1);
		#endif		
		half2 layer4Mask = GetLayer4Mask(layer4UV);		
        
        
		layer4TexCol = layer4TexCol*layer4Mask.x;
        // #ifdef _LAYER_4_TEX
		//     outCol.rgb = lerp(outCol.rgb, layer4TexCol*_Layer4Color.rgb,layer4TexCol.a*_Layer4Color.a); 
        // #endif

        layer4Mask.x *= layer4TexCol.w;
        #if _Layer4NormalMode_0
            outMetallic +=  _Layer4Metallic * layer4TexCol.a;
		    outSmoothness += _Layer4Smoothness * layer4TexCol.a;

            #ifdef _LAYER_4_TEX
                outCol.rgb = lerp(outCol.rgb, layer4TexCol*_Layer4Color.rgb,layer4TexCol.a*_Layer4Color.a); 
            #endif
            
        #elif _Layer4NormalMode_1            		    
            temp = _Layer4Metallic * layer4TexCol.a;
            outMetallic = BlendValue(outMetallic, temp, layer4Mask);
            temp = _Layer4Smoothness * layer4TexCol.a;
            outSmoothness = BlendValue(outSmoothness, temp, layer4Mask);

            #ifdef _LAYER_4_TEX
                outCol.rgb = lerp(outCol.rgb, layer4TexCol*_Layer4Color.rgb,layer4TexCol.a*_Layer4Color.a);
                outCol.rgb = lerp(outCol.rgb, layer4TexCol*_Layer4Color.rgb, layer4Mask.x);
            #endif
        #endif			

        // Normal Blend Model
        #if _LAYER_4_NORMAL
            half3 layer4NormalTS = UnpackScaleNormal(SAMPLE_TEXTURE2D_Default (_Layer4Normal, layer4UV), _Layer4NormalScale);            
            #if _Layer4NormalMode_0
                #if _LAYER_4_TEX
                    InitNormal = outNormalTS;                                    
                    outNormalTS = UDNBlendNormal(outNormalTS, layer4NormalTS);                
                    outNormalTS = BlendNormalTS(InitNormal, outNormalTS, layer4Mask.x);
                #else
                    outNormalTS = UDNBlendNormal(outNormalTS, layer4NormalTS);
                #endif
            #elif _Layer4NormalMode_1                
                outNormalTS = BlendNormalTS(outNormalTS, layer4NormalTS, layer4Mask.x);
            #endif            
        #endif                
	#endif

    #if (_LAYER_5_TEX || _LAYER_5_NORMAL)
		half2 layer5SourceUV = GetLayer5Texcoord(input.uv, input.detailUV);
        #if _LAYER_5_TEX
			half2 layer5UV = layer5SourceUV * _Layer5Tex_ST.xy + _Layer5Tex_ST.zw;
            half4 layer5TexCol = SAMPLE_TEXTURE2D_Default (_Layer5Tex, layer5UV);	
		#elif _LAYER_5_NORMAL
			half2 layer5UV = layer5SourceUV * _Layer5Normal_ST.xy + _Layer5Normal_ST.zw;
            half4 layer5TexCol = half4(1,1,1,1);
		#endif		
		half2 layer5Mask = GetLayer5Mask(layer5UV);		
        
        
		layer5TexCol = layer5TexCol*layer5Mask.x;
        // #ifdef _LAYER_5_TEX 			
		//     outCol.rgb = lerp(outCol.rgb, layer5TexCol*_Layer5Color.rgb,layer5TexCol.a*_Layer5Color.a); 
        // #endif

        layer5Mask.x *= layer5TexCol.w;
        #if _Layer5NormalMode_0
            outMetallic +=  _Layer5Metallic * layer5TexCol.a;
		    outSmoothness += _Layer5Smoothness * layer5TexCol.a;
            #ifdef _LAYER_5_TEX
                outCol.rgb = lerp(outCol.rgb, layer5TexCol*_Layer5Color.rgb,layer5TexCol.a*_Layer5Color.a); 
            #endif
        #elif _Layer5NormalMode_1            		    
            temp = _Layer5Metallic * layer5TexCol.a;
            outMetallic = BlendValue(outMetallic, temp, layer5Mask);
            temp = _Layer5Smoothness * layer5TexCol.a;
            outSmoothness = BlendValue(outSmoothness, temp, layer5Mask);
            #ifdef _LAYER_5_TEX
                outCol.rgb = lerp(outCol.rgb, layer5TexCol*_Layer5Color.rgb,layer5TexCol.a*_Layer5Color.a);
                outCol.rgb = lerp(outCol.rgb, layer5TexCol*_Layer5Color.rgb, layer5Mask.x);
            #endif
        #endif	
		

        // Normal Blend Model
        #if _LAYER_5_NORMAL
            half3 layer5NormalTS = UnpackScaleNormal(SAMPLE_TEXTURE2D_Default (_Layer5Normal, layer5UV), _Layer5NormalScale);            
            #if _Layer5NormalMode_0
                #if _LAYER_5_TEX
                    InitNormal = outNormalTS;                                    
                    outNormalTS = UDNBlendNormal(outNormalTS, layer5NormalTS);                
                    outNormalTS = BlendNormalTS(InitNormal, outNormalTS, layer5Mask.x);
                #else
                    outNormalTS = UDNBlendNormal(outNormalTS, layer5NormalTS);
                #endif
            #elif _Layer5NormalMode_1                
                outNormalTS = BlendNormalTS(outNormalTS, layer5NormalTS, layer5Mask.x);
            #endif            
        #endif                
	#endif

    #if (_LAYER_6_TEX || _LAYER_6_NORMAL)
		half2 layer6SourceUV = GetLayer6Texcoord(input.uv, input.detailUV);
        #if _LAYER_6_TEX
			half2 layer6UV = layer6SourceUV * _Layer6Tex_ST.xy + _Layer6Tex_ST.zw;
            half4 layer6TexCol = SAMPLE_TEXTURE2D_Default (_Layer6Tex, layer6UV);	
		#elif _LAYER_6_NORMAL
			half2 layer6UV = layer6SourceUV * _Layer6Normal_ST.xy + _Layer6Normal_ST.zw;
            half4 layer6TexCol = half4(1,1,1,1);
		#endif		
		half2 layer6Mask = GetLayer6Mask(layer6UV);		
        
        
		layer6TexCol = layer6TexCol*layer6Mask.x;
        // #ifdef _LAYER_6_TEX
		//     outCol.rgb = lerp(outCol.rgb, layer6TexCol*_Layer6Color.rgb,layer6TexCol.a*_Layer6Color.a); 
        // #endif

        layer6Mask.x *= layer6TexCol.w;
        #if _Layer6NormalMode_0
            outMetallic +=  _Layer6Metallic * layer6TexCol.a;
		    outSmoothness += _Layer6Smoothness * layer6TexCol.a;
            #ifdef _LAYER_6_TEX
                outCol.rgb = lerp(outCol.rgb, layer6TexCol*_Layer6Color.rgb,layer6TexCol.a*_Layer6Color.a); 
            #endif
        #elif _Layer6NormalMode_1            		    
            temp = _Layer6Metallic * layer6TexCol.a;
            outMetallic = BlendValue(outMetallic, temp, layer6Mask);
            temp = _Layer6Smoothness * layer6TexCol.a;
            outSmoothness = BlendValue(outSmoothness, temp, layer6Mask);            
            #ifdef _LAYER_6_TEX
                outCol.rgb = lerp(outCol.rgb, layer6TexCol*_Layer6Color.rgb,layer6TexCol.a*_Layer6Color.a); 
                outCol.rgb = lerp(outCol.rgb,  layer6TexCol*_Layer6Color.rgb, layer6Mask.x);
            #endif
        #endif	

        // Normal Blend Model
        #if _LAYER_6_NORMAL
            half3 layer6NormalTS = UnpackScaleNormal(SAMPLE_TEXTURE2D_Default (_Layer6Normal, layer6UV), _Layer6NormalScale);            
            #if _Layer6NormalMode_0
                #if _LAYER_6_TEX
                    InitNormal = outNormalTS;                                    
                    outNormalTS = UDNBlendNormal(outNormalTS, layer6NormalTS);                
                    outNormalTS = BlendNormalTS(InitNormal, outNormalTS, layer6Mask.x);
                #else
                    outNormalTS = UDNBlendNormal(outNormalTS, layer6NormalTS);
                #endif
            #elif _Layer6NormalMode_1                
                outNormalTS = BlendNormalTS(outNormalTS, layer6NormalTS, layer6Mask.x);
            #endif            
        #endif                
	#endif

    #if (_LAYER_7_TEX || _LAYER_7_NORMAL)
		half2 layer7SourceUV = GetLayer7Texcoord(input.uv, input.detailUV);
        #if _LAYER_7_TEX
			half2 layer7UV = layer7SourceUV * _Layer7Tex_ST.xy + _Layer7Tex_ST.zw;
            half4 layer7TexCol = SAMPLE_TEXTURE2D_Default (_Layer7Tex, layer7UV);	
		#elif _LAYER_7_NORMAL
			half2 layer7UV = layer7SourceUV * _Layer7Normal_ST.xy + _Layer7Normal_ST.zw;
            half4 layer7TexCol = half4(1,1,1,1);
		#endif		
		half2 layer7Mask = GetLayer7Mask(layer7UV);		
        
        
		layer7TexCol = layer7TexCol*layer7Mask.x;
        // #ifdef _LAYER_7_TEX // #ifndef
		//     outCol.rgb = lerp(outCol.rgb, layer7TexCol*_Layer7Color.rgb,layer7TexCol.a*_Layer7Color.a); 
        // #endif
        
		// #if _LAYER_7_MASK 
		// 	half _layer7Mask = SAMPLE_TEXTURE2D_Default (_Layer7Mask, layer7UV);			
		// 	_layer7Mask = lerp(7,0,step(_layer7Mask,0)); 
		// 	layer7TexCol.a *= layer7Mask.x* _layer7Mask;
		// #endif

        layer7Mask.x *= layer7TexCol.w;
        #if _Layer7NormalMode_0
            outMetallic +=  _Layer7Metallic * layer7TexCol.a;
		    outSmoothness += _Layer7Smoothness * layer7TexCol.a;
            #ifdef _LAYER_7_TEX
                outCol.rgb = lerp(outCol.rgb, layer6TexCol*_Layer6Color.rgb,layer6TexCol.a*_Layer6Color.a);             
            #endif
        #elif _Layer7NormalMode_1            		    
            temp = _Layer7Metallic * layer7TexCol.a;
            outMetallic = BlendValue(outMetallic, temp, layer7Mask);
            temp = _Layer7Smoothness * layer7TexCol.a;
            outSmoothness = BlendValue(outSmoothness, temp, layer7Mask);

            #ifdef _LAYER_7_TEX
                outCol.rgb = lerp(outCol.rgb, layer7TexCol*_Layer7Color.rgb,layer7TexCol.a*_Layer7Color.a); 
                outCol.rgb = lerp(outCol.rgb,  layer7TexCol*_Layer7Color.rgb, layer7Mask.x);
            #endif
        #endif	

        // Normal Blend Model
        #if _LAYER_7_NORMAL
            half3 layer7NormalTS = UnpackScaleNormal(SAMPLE_TEXTURE2D_Default (_Layer7Normal, layer7UV), _Layer7NormalScale);            
            #if _Layer7NormalMode_0
                #if _LAYER_7_TEX
                    InitNormal = outNormalTS;                                    
                    outNormalTS = UDNBlendNormal(outNormalTS, layer7NormalTS);
                    outNormalTS = BlendNormalTS(InitNormal, outNormalTS, layer7Mask.x);
                #else
                    outNormalTS = UDNBlendNormal(outNormalTS, layer7NormalTS);
                #endif
            #elif _Layer7NormalMode_1                
                outNormalTS = BlendNormalTS(outNormalTS, layer7NormalTS, layer7Mask.x);                
            #endif            
        #endif                
	#endif

  
    
#if _SPECULAR_SETUP
    outSurfaceData.metallic = 1.0h;
    outSurfaceData.specular = specGloss.rgb;
#else
    outSurfaceData.metallic = outMetallic;
    outSurfaceData.specular = half3(0.0h, 0.0h, 0.0h);
#endif

    outSurfaceData.smoothness = outSmoothness;

    outSurfaceData.albedo = outCol;
    outSurfaceData.normalTS = outNormalTS;
    outSurfaceData.occlusion = SampleOcclusion(input.uv);
    outSurfaceData.emission = SampleEmission(input.uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap)); 

}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

// Used in Standard (Physically Based) shader
Varyings Cloth_LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    half3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

    output.uv = float4(input.texcoord,input.lightmapUV);
    output.detailUV.xyzw = float4(input.uv3,input.uv4);
// #ifdef _NORMALMAP
    output.normalWS = half4(normalInput.normalWS, viewDirWS.x);
    output.tangentWS = half4(normalInput.tangentWS, viewDirWS.y);
    output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.z);
// #else
//     output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
//     output.viewDirWS = viewDirWS;
// #endif
    
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    output.positionWS = vertexInput.positionWS;
#endif

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    output.shadowCoord = GetShadowCoord(vertexInput);
#endif

    output.positionCS = vertexInput.positionCS;

    return output;
}

void DoComplexFunction(Varyings input, inout F_SurfaceData outSurfaceData, F_InputData inputData)
{
    #if _SPARKLE_ON
        half3 diffCol;
        half3 specColor;
        half shapeMask;
        half edgeCtrl;
        half3 viewDir;
        viewDir = half3(inputData.viewDirectionWS);
        half3 lightDir = _MainLightPosition.xyz;
        half3 normal = inputData.normalWS;
        half flashTerm = AddFlash(input.uv, input.detailUV, normal, lightDir, viewDir, diffCol, shapeMask, edgeCtrl);
        outSurfaceData.smoothness = lerp(outSurfaceData.smoothness, _FlashSmoothness, shapeMask);
        outSurfaceData.alpha = lerp(outSurfaceData.alpha, 1, shapeMask);
        outSurfaceData.albedo = lerp(outSurfaceData.albedo, diffCol,  shapeMask * flashTerm * edgeCtrl);        
        outSurfaceData.specular = lerp(outSurfaceData.specular, specColor, shapeMask * flashTerm * edgeCtrl);                                      
    #endif         
}

void InitializeAdditionalData(F_InputData inputData, out AdditionalData addData)
{
    addData.tangentWS = inputData.tangentWS.xyz;
    addData.tangentWS2 = inputData.tangentWS2.xyz;
    addData.bitangentWS2 = inputData.bitangentWS2.xyz;
    addData.bitangentWS = inputData.bitangentWS.xyz;
    addData.roughnessT = _RoughnessX;
    addData.roughnessB = _RoughnessY;    
    addData.lightDir1 = half3(_LightDirX,_LightDirY,_LightDirZ);
    addData.specularColor = _SpecularColor.xyz;
    addData.rimLight = half4(_RimLightMin,_RimLightMax,0,0);
    addData.rimLightColor = _RimLightColor.xyz;
    addData.rimAlpha = half4(_RimAlphaMin,_RimAlphaMax,_RimAlphaEnhance,0);
    
    addData.highLightColor = _HighLightColor;
    addData.shadowLightColor = _ShadowLightColor;

    addData.threshold1 = _Threshold1;
    addData.threshold2 = _Threshold2;
    addData.attenuationControl = _AttenuationControl;
    
    addData.tcp_rimColor = _TCP_RimColor;
    addData.tcp_rimData = half3(_TCP_RimMin,_TCP_RimMax,_TCP_RimStrength);
    addData.tcp_rimoffset = half3(_TCP_RimOffsetX, _TCP_RimOffsetY, _TCP_RimOffsetZ);

}

// Used in Standard (Physically Based) shader
half4 Cloth_LitPassFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);    
    F_SurfaceData surfaceData;
    AdditionalData addData;    
    InitializeStandardClothSurfaceData(input, surfaceData);// (uv, out SurfaceData outSurfaceData)
    // LitInput.hlsl SurfaceData: alpha,albedo,metallic,specular,smoothness,normalTS,occlusion,emission
    F_InputData inputData;    
    // current
    InitializeInputData(input, surfaceData.normalTS, inputData); 
    
    DoComplexFunction(input,surfaceData, inputData);
    // Add additional data
    InitializeAdditionalData(inputData, addData);
    // Lighting.hlsl
    // #ifdef _BLINEPHONG_ON    
    
    // #endif
    half4 color = Cloth_FragmentPBR(inputData, surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.occlusion, surfaceData.emission, surfaceData.alpha, addData);
    
    color.rgb = MixFog(color.rgb, inputData.fogCoord);  
    #ifdef _ANISTROPIC_ON    
        
    #endif
    // color.rgb = surfaceData.normalTS;
    // half a = GetLayer1MaskReal(input.uv.xy);
    // color.rgb = half3(a,a,a);
    return color;
}




#endif
