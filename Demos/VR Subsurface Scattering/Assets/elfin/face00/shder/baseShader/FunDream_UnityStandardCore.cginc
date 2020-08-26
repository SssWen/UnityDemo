
// 这里主要放Vert，Frag的计算（包括AddPass的），和对应的结构体
// Unity GI的计算
// ------------------------------------------------------------------
//  Base forward pass (directional light, emission, lightmaps, ...)

#ifndef FUN_UNITY_STANDARD_CORE_INCLUDED
#define FUN_UNITY_STANDARD_CORE_INCLUDED

#include "UnityCG.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityStandardConfig.cginc"

#include "FunDream_UnityStandardInput.cginc"
#include "FunDream_UnityStandardBRDF.cginc"
#include "FunDream_UnityStandardUtils.cginc"
#include "FunDream_UnityGlobalIllumination.cginc"

#if _ANISO
	#include "FunDream_Aniso.cginc"
#endif
#if _SSS
	#include "FunDream_SSS.cginc"
#endif
// for layer options
#include "FunDream_Tools.cginc"
#include "AutoLight.cginc"

#define TCP2_BRDF_PBS BRDF1_TCP2_PBS

#if _FLASH

half AddFlash(half4 baseUV, half4 detailUV, half3 normalDir, half3 lightDir, half3 viewDir, out fixed3 diffCol, out half shapeMask, out half edgeCtrl) {

	half2 flashUV = GetFlashTexcoord(baseUV, detailUV);
	half2 transformedUV = flashUV * _FlashTex_ST.xy + _FlashTex_ST.zw;
	half2 id = floor(transformedUV);
	half2 eachUV = frac(transformedUV);


	// 1  |	  2	   | 3
	//���� �������� ����
	// 4  | 5��uv��| 6
	//���� �������� ����
	// 7  |   8    | 9

	//half u = id.x;
	//half v = id.y;
	//half4 id_19 = half4(u-1, v+1, u+1, v-1);
	//half4 id_28 = half4(u, v+1, u, v-1);
	//half4 id_37 = half4(u+1, v+1, u-1, v-1);
	//half4 id_46 = half4(u-1, v, u+1, v);


	half rand = tex2D(_FlashNoiseTex, id / _FlashNoiseTex_TexelSize.zw).r;
	rand = lerp(1 / _RadiusRandom, 1, rand);
	half rand2 = tex2D(_FlashNoiseTex, (id + 1 + _RandomSeed) / _FlashNoiseTex_TexelSize.zw).r;
	half rand3 = tex2D(_FlashNoiseTex, (id + 2 + _RandomSeed) / _FlashNoiseTex_TexelSize.zw).r;
	half rand4 = tex2D(_FlashNoiseTex, (id + 3 + _RandomSeed) / _FlashNoiseTex_TexelSize.zw).r;


	//half h = lightDir + viewDir;
	half nh_flash = saturate(dot(normalize(lightDir + viewDir * _FlashZone), normalDir));

	half deleteSmall = step(_DeleteSmall, 1 - rand);
	half deleteRand = step(_DeleteRandom, rand2 * 0.99);
	half colorRand = step(_ColorRandom, rand3 * 0.99);

	half uvScale = rand * _RadiusRandom;
	half uvOffset = rand2 * (uvScale - 1) * lerp(_OffsetRandom, 0, 1 / _RadiusRandom);
	half2 newEachUV = eachUV * uvScale - uvOffset;

	half densityCtrl = 1;
#if _DENSITY
	half rand5 = tex2D(_FlashNoiseTex, (id + 4 + _RandomSeed) / _FlashNoiseTex_TexelSize.zw).r;
	half2 densityUV = id / _FlashTex_ST.xy + _FlashTex_ST.zw;
	half densityMask = tex2D(_FlashNoiseTex, densityUV).b;
	densityCtrl = step(1 - densityMask, lerp(deleteRand, 0, _DensityCtrl) + rand5 * _DensitySmooth);
#endif

	shapeMask = tex2D(_FlashTex, newEachUV).r * deleteSmall * deleteRand * densityCtrl;
	edgeCtrl = pow(nh_flash, 2);
	diffCol = lerp(_FlashColor2.xyz, _FlashColor1.xyz, colorRand);

	//half viewRotate = abs(dot(half3(-1,0,-1), forwardDir));
	half flash = abs(sin(rand4 * 20 + _FlashRotate * _FlashSpeed * 10));
	flash = max(pow(flash, _DarkTime), _FlashMin);

	return flash;

}

#endif   //#if _FLASH

#if 1 // UntiyStandardCore的一些方法
    // counterpart for NormalizePerPixelNormal
    // skips normalization per-vertex and expects normalization to happen per-pixel
    half3 NormalizePerVertexNormal (float3 n) // takes float to avoid overflow
    {
        #if (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
            return normalize(n);
        #else
            return n; // will normalize per-pixel instead
        #endif
    }

    float3 NormalizePerPixelNormal (float3 n)
    {
        #if (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
            return n;
        #else
            return normalize((float3)n); // takes float to avoid overflow
        #endif
    }

    //-------------------------------------------------------------------------------------
    UnityLight MainLight ()
    {
        UnityLight l;

        l.color = _LightColor0.rgb;
        l.dir = _WorldSpaceLightPos0.xyz;
        return l;
    }

    UnityLight AdditiveLight (half3 lightDir, half atten)
    {
        UnityLight l;

        l.color = _LightColor0.rgb;
        l.dir = lightDir;
        #ifndef USING_DIRECTIONAL_LIGHT
            l.dir = NormalizePerPixelNormal(l.dir);
        #endif

        // shadow the light
        l.color *= atten;
        return l;
    }

    UnityLight DummyLight ()
    {
        UnityLight l;
        l.color = 0;
        l.dir = half3 (0,1,0);
        return l;
    }

    UnityIndirect ZeroIndirect ()
    {
        UnityIndirect ind;
        ind.diffuse = 0;
        ind.specular = 0;
        return ind;
    }

    //-------------------------------------------------------------------------------------
    // Common fragment setup

    // deprecated
    half3 WorldNormal(half4 tan2world[3])
    {
        return normalize(tan2world[2].xyz);
    }

    // deprecated
    #ifdef _TANGENT_TO_WORLD
        half3x3 ExtractTangentToWorldPerPixel(half4 tan2world[3])
        {
            half3 t = tan2world[0].xyz;
            half3 b = tan2world[1].xyz;
            half3 n = tan2world[2].xyz;

        #if UNITY_TANGENT_ORTHONORMALIZE
            n = NormalizePerPixelNormal(n);

            // ortho-normalize Tangent
            t = normalize (t - n * dot(t, n));

            // recalculate Binormal
            half3 newB = cross(n, t);
            b = newB * sign (dot (newB, b));
        #endif

            return half3x3(t, b, n);
        }
    #else
        half3x3 ExtractTangentToWorldPerPixel(half4 tan2world[3])
        {
            return half3x3(0,0,0,0,0,0,0,0,0);
        }
    #endif

    float3 PerPixelWorldNormal(float4 i_tex, float4 tangentToWorld[3])
    {
    #ifdef _NORMALMAP
        half3 tangent = tangentToWorld[0].xyz;
        half3 binormal = tangentToWorld[1].xyz;
        half3 normal = tangentToWorld[2].xyz;

        #if UNITY_TANGENT_ORTHONORMALIZE
            normal = NormalizePerPixelNormal(normal);

            // ortho-normalize Tangent
            tangent = normalize (tangent - normal * dot(tangent, normal));

            // recalculate Binormal
            half3 newB = cross(normal, tangent);
            binormal = newB * sign (dot (newB, binormal));
        #endif

        half3 normalTangent = NormalInTangentSpace(i_tex);
        float3 normalWorld = NormalizePerPixelNormal(tangent * normalTangent.x + binormal * normalTangent.y + normal * normalTangent.z); // @TODO: see if we can squeeze this normalize on SM2.0 as well
    #else
        float3 normalWorld = normalize(tangentToWorld[2].xyz);
    #endif
        return normalWorld;
    }

    #ifdef _PARALLAXMAP
        #define IN_VIEWDIR4PARALLAX(i) NormalizePerPixelNormal(half3(i.tangentToWorldAndPackedData[0].w,i.tangentToWorldAndPackedData[1].w,i.tangentToWorldAndPackedData[2].w))
        #define IN_VIEWDIR4PARALLAX_FWDADD(i) NormalizePerPixelNormal(i.viewDirForParallax.xyz)
    #else
        #define IN_VIEWDIR4PARALLAX(i) half3(0,0,0)
        #define IN_VIEWDIR4PARALLAX_FWDADD(i) half3(0,0,0)
    #endif

    #if UNITY_REQUIRE_FRAG_WORLDPOS
        #if UNITY_PACK_WORLDPOS_WITH_TANGENT
            #define IN_WORLDPOS(i) half3(i.tangentToWorldAndPackedData[0].w,i.tangentToWorldAndPackedData[1].w,i.tangentToWorldAndPackedData[2].w)
        #else
            #define IN_WORLDPOS(i) i.posWorld
        #endif
        #define IN_WORLDPOS_FWDADD(i) i.posWorld
    #else
        #define IN_WORLDPOS(i) half3(0,0,0)
        #define IN_WORLDPOS_FWDADD(i) half3(0,0,0)
    #endif

    #define IN_LIGHTDIR_FWDADD(i) half3(i.tangentToWorldAndLightDir[0].w, i.tangentToWorldAndLightDir[1].w, i.tangentToWorldAndLightDir[2].w)

    #define FRAGMENT_SETUP(x) FragmentCommonData x = \
        FragmentSetup(i.tex, i.eyeVec.xyz, IN_VIEWDIR4PARALLAX(i), i.tangentToWorldAndPackedData, IN_WORLDPOS(i));

    #define FRAGMENT_SETUP_FWDADD(x) FragmentCommonData x = \
        FragmentSetup(i.tex, i.eyeVec.xyz, IN_VIEWDIR4PARALLAX_FWDADD(i), i.tangentToWorldAndLightDir, IN_WORLDPOS_FWDADD(i));


#endif

// 是Unity的FragmentCommonData
struct FragmentData{
    half3 diffColor, specColor;
    // Note: smoothness & oneMinusReflectivity for optimization purposes, mostly for DX9 SM2.0 level.
    // Most of the math is being done on these (1-x) values, and that saves a few precious ALU slots.
    half oneMinusReflectivity, smoothness;
    float3 normalWorld;
    float3 eyeVec;
    half alpha;
    float3 posWorld;

#if UNITY_STANDARD_SIMPLE
    half3 reflUVW;
#endif

#if UNITY_STANDARD_SIMPLE
    half3 tangentSpaceNormal;
#endif
};

// 把UnityStandardCore的FragmentCommonData 放入
struct FragmentCommonData
{
    half3 diffColor, specColor;
    // Note: smoothness & oneMinusReflectivity for optimization purposes, mostly for DX9 SM2.0 level.
    // Most of the math is being done on these (1-x) values, and that saves a few precious ALU slots.
    half oneMinusReflectivity, smoothness;
    float3 normalWorld;
    float3 eyeVec;
    half alpha;
    float3 posWorld;

#if UNITY_STANDARD_SIMPLE
    half3 reflUVW;
#endif

#if UNITY_STANDARD_SIMPLE
    half3 tangentSpaceNormal;
#endif
};
#ifndef UNITY_SETUP_BRDF_INPUT
    #define UNITY_SETUP_BRDF_INPUT SpecularSetup
#endif

inline FragmentCommonData SpecularSetup (float4 i_tex)
{
    half4 specGloss = SpecularGloss(i_tex.xy);
    half3 specColor = specGloss.rgb;
    half smoothness = specGloss.a;

    half oneMinusReflectivity;
    half3 diffColor = EnergyConservationBetweenDiffuseAndSpecular (Albedo(i_tex), specColor, /*out*/ oneMinusReflectivity);

    FragmentCommonData o = (FragmentCommonData)0;
    o.diffColor = diffColor;
    o.specColor = specColor;
    o.oneMinusReflectivity = oneMinusReflectivity;
    o.smoothness = smoothness;
    return o;
}
// --------

half2 MetallicGloss_FunDream(float2 uv)
{
    half2 mg;
#ifdef _METALLICGLOSSMAP
	half2 texCol = tex2D(_MetallicGlossMap, uv).rg; 
	mg.r = texCol.r * _Metallic;
	mg.g = texCol.g * _GlossMapScale;
#else
    mg.r = _Metallic;
    mg.g = _GlossMapScale;

#endif
    return mg;
}


half3 BlendNormalTS(half3 normalTangent, half3 detailNormalTangent, half mask){
    //#if _DETAIL_LERP
    //    normalTangent = lerp(
    //        normalTangent,
    //        detailNormalTangent,
    //        mask);
    //#else
        normalTangent = lerp(
            normalTangent,
            BlendNormals(normalTangent, detailNormalTangent),
            mask);
    //#endif
	return normalTangent;
}

// 这里设置worldNormal的值
inline FragmentData MetallicSetup_FunDream (half4 i_tex, half4 detailUV, float4 tangentToWorld[3])
{

	half2 uv = i_tex.xy;

    half2 metallicGloss = MetallicGloss_FunDream(uv);
    half metallic = metallicGloss.x;
    half smoothness = metallicGloss.y; // this is 1 minus the square root of real roughness m.

    half oneMinusReflectivity;
    half3 specColor;

	fixed4 mainTexCol = tex2D (_MainTex, i_tex.xy);

    // 切线空间Normal
	half3 outNormalTS = half3(0, 0, 1);
	#if _NORMALMAP
		outNormalTS = UnpackScaleNormal(tex2D (_BumpMap, i_tex.xy), _BumpScale);
	#endif

	fixed4 outCol = mainTexCol * _Color;
	half outMatal = metallic;
	half outSmoothness = smoothness;

	// init layer common values

	#if (_LAYER_BASE_TEX || _LAYER_BASE_NORMAL)
		half2 layerBaseSourceUV = GetLayerBaseTexcoord(i_tex, detailUV);
		half2 layerBaseUV = layerBaseSourceUV * _LayerBaseTex_ST.xy + _LayerBaseTex_ST.zw;		
		half layerBaseMask = GetLayerBaseMask(layerBaseSourceUV);	
	#endif

	#if (_LAYER_2_TEX || _LAYER_2_NORMAL)
		half2 layer2SourceUV = GetLayer2Texcoord(i_tex, detailUV);
		half2 layer2UV = layer2SourceUV * _Layer2Tex_ST.xy + _Layer2Tex_ST.zw;		
		half layer2Mask = GetLayer2Mask(layer2SourceUV);	
	#endif

	#if (_LAYER_3_TEX || _LAYER_3_NORMAL)
		half2 layer3SourceUV = GetLayer3Texcoord(i_tex, detailUV);
		half2 layer3UV = layer3SourceUV * _Layer3Tex_ST.xy + _Layer3Tex_ST.zw;		
		half layer3Mask = GetLayer3Mask(layer3SourceUV);	
	#endif

	#if (_LAYER_4_TEX || _LAYER_4_NORMAL)
		half2 layer4SourceUV = GetLayer4Texcoord(i_tex, detailUV);
		half2 layer4UV = layer4SourceUV * _Layer4Tex_ST.xy + _Layer4Tex_ST.zw;		
		half layer4Mask = GetLayer4Mask(layer4SourceUV);	
	#endif

	#if (_LAYER_5_TEX || _LAYER_5_NORMAL)
		half2 layer5SourceUV = GetLayer5Texcoord(i_tex, detailUV);
		half2 layer5UV = layer5SourceUV * _Layer5Tex_ST.xy + _Layer5Tex_ST.zw;		
		half layer5Mask = GetLayer5Mask(layer5SourceUV);	
	#endif

	#if (_LAYER_6_TEX || _LAYER_6_NORMAL)
		half2 layer6SourceUV = GetLayer6Texcoord(i_tex, detailUV);
		half2 layer6UV = layer6SourceUV * _Layer6Tex_ST.xy + _Layer6Tex_ST.zw;		
		half layer6Mask = GetLayer6Mask(layer6SourceUV);	
	#endif

	#if (_LAYER_7_TEX || _LAYER_7_NORMAL)
		half2 layer7SourceUV = GetLayer7Texcoord(i_tex, detailUV);
		half2 layer7UV = layer7SourceUV * _Layer7Tex_ST.xy + _Layer7Tex_ST.zw;		
		half layer7Mask = GetLayer7Mask(layer7SourceUV);	
	#endif

	#if (_LAYER_TOP_TEX || _LAYER_TOP_NORMAL)
		half2 layerTopSourceUV = GetLayerTopTexcoord(i_tex, detailUV);
		half2 layerTopUV = layerTopSourceUV * _LayerTopTex_ST.xy + _LayerTopTex_ST.zw;		
		half layerTopMask = GetLayerTopMask(layerTopSourceUV);	
	#endif


	// calulate layer color metallic smoothness and alpha

	#if _LAYER_BASE_TEX 
		half4 layerBaseTexCol = tex2D (_LayerBaseTex, layerBaseUV);
		#if _HAIR
			layerBaseTexCol.a = step(0, outCol.a - _Cutoff);
		#endif
		layerBaseTexCol = lerp(0, layerBaseTexCol, layerBaseMask);
		outCol = BlendColor_LayerBase(layerBaseTexCol * _LayerBaseColor, outCol);
		outMatal +=  _LayerBaseMetallic * layerBaseTexCol.a;
		outSmoothness += _LayerBaseSmoothness * layerBaseTexCol.a;
	#endif

	#if _LAYER_2_TEX 
		half4 layer2TexCol = tex2D (_Layer2Tex, layer2UV);
		#if _HAIR
			layer2TexCol.a = step(0, outCol.a - _Cutoff);
		#endif
		layer2TexCol = lerp(0, layer2TexCol, layer2Mask);
		outCol = BlendColor_Layer2(layer2TexCol * _Layer2Color, outCol);
		outMatal +=  _Layer2Metallic * layer2TexCol.a;
		outSmoothness += _Layer2Smoothness * layer2TexCol.a;
	#endif

	#if _LAYER_3_TEX 
		half4 layer3TexCol = tex2D (_Layer3Tex, layer3UV);
		layer3TexCol = lerp(0, layer3TexCol, layer3Mask);
		outCol = BlendColor_Layer3(layer3TexCol * _Layer3Color, outCol);
		outMatal +=  _Layer3Metallic * layer3TexCol.a;
		outSmoothness += _Layer3Smoothness * layer3TexCol.a;
	#endif
	
	#if _LAYER_4_TEX 
		half4 layer4TexCol = tex2D (_Layer4Tex, layer4UV);
		layer4TexCol = lerp(0, layer4TexCol, layer4Mask);
		outCol = BlendColor_Layer4(layer4TexCol * _Layer4Color, outCol);
		outMatal +=  _Layer4Metallic * layer4TexCol.a;
		outSmoothness += _Layer4Smoothness * layer4TexCol.a;
	#endif
	
	#if _LAYER_5_TEX 
		half4 layer5TexCol = tex2D (_Layer5Tex, layer5UV);
		layer5TexCol = lerp(0, layer5TexCol, layer5Mask);
		outCol = BlendColor_Layer5(layer5TexCol * _Layer5Color, outCol);
		outMatal +=  _Layer5Metallic * layer5TexCol.a;
		outSmoothness += _Layer5Smoothness * layer5TexCol.a;
	#endif

	#if _LAYER_6_TEX 
		half4 layer6TexCol = tex2D (_Layer6Tex, layer6UV);
		layer6TexCol = lerp(0, layer6TexCol, layer6Mask);
		outCol = BlendColor_Layer6(layer6TexCol * _Layer6Color, outCol);
		outMatal +=  _Layer6Metallic * layer6TexCol.a;
		outSmoothness += _Layer6Smoothness * layer6TexCol.a;
	#endif

	#if _LAYER_7_TEX 
		half4 layer7TexCol = tex2D (_Layer7Tex, layer7UV);
		layer7TexCol = lerp(0, layer7TexCol, layer7Mask);
		outCol = BlendColor_Layer7(layer7TexCol * _Layer7Color, outCol);
		outMatal +=  _Layer7Metallic * layer7TexCol.a;
		outSmoothness += _Layer7Smoothness * layer7TexCol.a;
	#endif

	#if _LAYER_TOP_TEX 
		half4 layerTopTexCol = tex2D (_LayerTopTex, layerTopUV);
		layerTopTexCol = lerp(0, layerTopTexCol, layerTopMask);
		outCol = BlendColor_LayerTop(layerTopTexCol * _LayerTopColor, outCol);
		outMatal +=  _LayerTopMetallic * layerTopTexCol.a;
		outSmoothness += _LayerTopSmoothness * layerTopTexCol.a;
	#endif

	// normal calculation


	#if _LAYER_BASE_NORMAL
		half3 layerBaseNormalTS = UnpackScaleNormal(tex2D (_LayerBaseNormal, layerBaseUV), _LayerBaseNormalScale);
		outNormalTS = BlendNormalTS(outNormalTS, layerBaseNormalTS, layerBaseMask);
	#endif

	#if _LAYER_2_NORMAL
		half3 layer2NormalTS = UnpackScaleNormal(tex2D (_Layer2Normal, layer2UV), _Layer2NormalScale);
		outNormalTS = BlendNormalTS(outNormalTS, layer2NormalTS, layer2Mask);
	#endif

	#if _LAYER_3_NORMAL
		half3 layer3NormalTS = UnpackScaleNormal(tex2D (_Layer3Normal, layer3UV), _Layer3NormalScale);
		outNormalTS = BlendNormalTS(outNormalTS, layer3NormalTS, layer3Mask);
	#endif

	#if _LAYER_4_NORMAL
		half3 layer4NormalTS = UnpackScaleNormal(tex2D (_Layer4Normal, layer4UV), _Layer4NormalScale);
		outNormalTS = BlendNormalTS(outNormalTS, layer4NormalTS, layer4Mask);
	#endif

	#if _LAYER_5_NORMAL
		half3 layer5NormalTS = UnpackScaleNormal(tex2D (_Layer5Normal, layer5UV), _Layer5NormalScale);
		outNormalTS = BlendNormalTS(outNormalTS, layer5NormalTS, layer5Mask);
	#endif

	#if _LAYER_6_NORMAL
		half3 layer6NormalTS = UnpackScaleNormal(tex2D (_Layer6Normal, layer6UV), _Layer6NormalScale);
		outNormalTS = BlendNormalTS(outNormalTS, layer6NormalTS, layer6Mask);
	#endif

	#if _LAYER_7_NORMAL
		half3 layer7NormalTS = UnpackScaleNormal(tex2D (_Layer7Normal, layer7UV), _Layer7NormalScale);
		outNormalTS = BlendNormalTS(outNormalTS, layer7NormalTS, layer7Mask);
	#endif

	#if _LAYER_TOP_NORMAL
		half3 layerTopNormalTS = UnpackScaleNormal(tex2D (_LayerTopNormal, layerTopUV), _LayerTopNormalScale);
		outNormalTS = BlendNormalTS(outNormalTS, layerTopNormalTS, layerTopMask);
	#endif


	
	// final output
	half3 diffColor = DiffuseAndSpecularFromMetallic (outCol.rgb, saturate(outMatal), /*out*/ specColor, /*out*/ oneMinusReflectivity);

	#if _NORMALMAP
		half3 tangent = tangentToWorld[0].xyz;
		half3 binormal = tangentToWorld[1].xyz;
		half3 normal = tangentToWorld[2].xyz;
        // outNormalTS 切线空间normal
		float3 normalWorld = NormalizePerPixelNormal(tangent * outNormalTS.x + binormal * outNormalTS.y + normal * outNormalTS.z); 
        // normalWorld 世界空间normal
	#else
		float3 normalWorld = normalize(tangentToWorld[2].xyz);
	#endif 

    FragmentData o = (FragmentData)0;
    o.diffColor = diffColor;
    o.specColor = specColor;
    o.oneMinusReflectivity = saturate(oneMinusReflectivity);
    o.smoothness = saturate(outSmoothness);
	o.normalWorld = normalWorld;
	o.alpha = saturate(outCol.a);

    return o;
}

// GI计算相关
inline UnityGI FragmentGI_FunDream (FragmentData s, half occlusion, half4 i_ambientOrLightmapUV, half atten, UnityLight light)
{
    UnityGIInput d;
    d.light = light;
    d.worldPos = s.posWorld;
    d.worldViewDir = -s.eyeVec;
    d.atten = atten;
    #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
        d.ambient = 0;
        d.lightmapUV = i_ambientOrLightmapUV;
    #else
        d.ambient = i_ambientOrLightmapUV.rgb;
        d.lightmapUV = 0;
    #endif

    d.probeHDR[0] = unity_SpecCube0_HDR;
    d.probeHDR[1] = unity_SpecCube1_HDR;
    #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
      d.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
    #endif
    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
      d.boxMax[0] = unity_SpecCube0_BoxMax;
      d.probePosition[0] = unity_SpecCube0_ProbePosition;
      d.boxMax[1] = unity_SpecCube1_BoxMax;
      d.boxMin[1] = unity_SpecCube1_BoxMin;
      d.probePosition[1] = unity_SpecCube1_ProbePosition;
    #endif

    Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.smoothness, -s.eyeVec, s.normalWorld, s.specColor);
    // Replace the reflUVW if it has been compute in Vertex shader.
    // Note: the compiler will optimize the calcul in UnityGlossyEnvironmentSetup itself
    #if UNITY_STANDARD_SIMPLE
        g.reflUVW = s.reflUVW;
    #endif

	UnityGI o_gi = UnityGI_Base(d, occlusion, s.normalWorld);
    o_gi.indirect.specular = UnityGI_IndirectSpecular (d, occlusion, g);

    return o_gi;

}
struct VertexOutputForwardBase_FunDream
{
    UNITY_POSITION(pos);
    float4 tex                            : TEXCOORD0;
    float4 eyeVec                         : TEXCOORD1;    // eyeVec.xyz | fogCoord
    float4 tangentToWorldAndPackedData[3] : TEXCOORD2;    // [3x3:tangentToWorld | 1x3:viewDirForParallax or worldPos]
    half4 ambientOrLightmapUV             : TEXCOORD5;    // SH or Lightmap UV
    UNITY_LIGHTING_COORDS(6,7)

    // next ones would not fit into SM2.0 limits, but they are always for SM3.0+
#if UNITY_REQUIRE_FRAG_WORLDPOS && !UNITY_PACK_WORLDPOS_WITH_TANGENT
    float3 posWorld                     : TEXCOORD8;
#endif

	half4 detailUV                      : TEXCOORD9; 

	//#if _FLASH
	//	half3 forwardDir                : TEXCOORD10; 
	//#endif 

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};


inline half4 VertexGIForward_FunDream(VertexInput_FunDream v, float3 posWorld, half3 normalWorld)
{
    half4 ambientOrLightmapUV = 0;
    // Static lightmaps
    #ifdef LIGHTMAP_ON
        ambientOrLightmapUV.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
        ambientOrLightmapUV.zw = 0;
    // Sample light probe for Dynamic objects only (no static or dynamic lightmaps)
    #elif UNITY_SHOULD_SAMPLE_SH
        #ifdef VERTEXLIGHT_ON
            // Approximated illumination from non-important point lights
            ambientOrLightmapUV.rgb = Shade4PointLights (
                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                unity_4LightAtten0, posWorld, normalWorld);
        #endif
		 
        ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, ambientOrLightmapUV.rgb);
    #endif

    #ifdef DYNAMICLIGHTMAP_ON
        ambientOrLightmapUV.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif

    return ambientOrLightmapUV;
}


//================================================================================================================================
// Core fragment functions (Forward Rendering)

FragmentData frag( half4 i_tex, half3 i_eyeVec, half3 i_viewDirForParallax, float4 tangentToWorld[3], half3 i_posWorld, half4 detailUV){
	//FragmentData s = FragmentSetup_FunDream(i.tex, i.eyeVec.xyz, IN_VIEWDIR4PARALLAX(i), i.tangentToWorldAndPackedData, IN_WORLDPOS(i));
    half2 offsets;
	half alpha;
		// Parallax
	// #if defined(_PARALLAXMAP) || (SHADER_TARGET > 30)
	// 	// Disable parallax on pre-SM3.0 shader target models
	// 	half h = tex2D (_ParallaxMap, i_tex.xy).g;
	// 	offsets = ParallaxOffset1Step (h, _Parallax, i_viewDirForParallax);
	// 	i_tex = float4(i_tex.xy + offsets, i_tex.zw + offsets);
	// 	#if _UV3_ON
	// 		detailUV.xy += offsets;
	// 	#endif
	// #endif

	// init data struct
	// albedo + specularColor + smoothness + metallic
    FragmentData o = MetallicSetup_FunDream (i_tex, detailUV, tangentToWorld);           
	alpha = o.alpha;
	//// normal
 //   o.normalWorld = PerPixelWorldNormal_FunDream(i_tex, tangentToWorld, detailUV);
 	// clip
	#if defined(_ALPHATEST_ON)
		clip (alpha - _Cutoff);
	#endif
	// eyeVec + posWorld
    o.eyeVec = NormalizePerPixelNormal(i_eyeVec);
    o.posWorld = i_posWorld;

    // NOTE: shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
    o.diffColor = PreMultiplyAlpha (o.diffColor, alpha, o.oneMinusReflectivity, /*out*/ o.alpha);
    return o;

}

// BaseVert Billball使用
VertexOutputForwardBase_FunDream vertForwardBase_Billboard_FunDream (VertexInput_FunDream v)
{
    UNITY_SETUP_INSTANCE_ID(v);
    VertexOutputForwardBase_FunDream o;
    UNITY_INITIALIZE_OUTPUT(VertexOutputForwardBase_FunDream, o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    // float4 posWorld = mul(unity_ObjectToWorld, v.vertex);

    // #if UNITY_REQUIRE_FRAG_WORLDPOS
    //     #if UNITY_PACK_WORLDPOS_WITH_TANGENT
    //         o.tangentToWorldAndPackedData[0].w = posWorld.x;
    //         o.tangentToWorldAndPackedData[1].w = posWorld.y;
    //         o.tangentToWorldAndPackedData[2].w = posWorld.z;
    //     #else
    //         o.posWorld = posWorld.xyz;
    //     #endif
    // #endif
    // o.pos = UnityObjectToClipPos(v.vertex);

    // 面片朝着相机，修改顶点和法线的位置
    // local space
	half4 centerPos = half4(0 ,0, 0, 1);					
	half4 centerPosWS = mul(unity_ObjectToWorld, centerPos);
    #if _LOCKROTATION_ON
        half4 forwardPos = 1;
        #if _LOCKAXIS_0
            forwardPos = half4(1, 0, 0, 1);
        #elif _LOCKAXIS_1
            forwardPos = half4(-1, 0, 0, 1);
        #elif _LOCKAXIS_2
            forwardPos = half4(0, 1, 0, 1);
        #elif _LOCKAXIS_3
            forwardPos = half4(0, -1, 0, 1);
        #endif
        half4 forwardPosWS = mul(unity_ObjectToWorld, forwardPos);
        half3 forwardDirWS = normalize(forwardPosWS.xyz - centerPosWS.xyz);
        half3 viewDirWS = normalize(centerPosWS - _WorldSpaceCameraPos);
        half3 rightDirWS = normalize(cross(viewDirWS, forwardPosWS));    
    #else
        half3 upDirWS = half3(0, 1, 0);
        half3 viewDirWS = normalize(_WorldSpaceCameraPos - centerPosWS);
        half3 rightDirWS = normalize(cross(upDirWS, viewDirWS));
        half3 forwardDirWS = normalize(cross(viewDirWS, rightDirWS));				
	#endif

    half3 offsetX = rightDirWS  * v.vertex.x * length(unity_ObjectToWorld[0].xyz) * 1; // _ScaleX
    half3 offsetY =  forwardDirWS * v.vertex.y * length(unity_ObjectToWorld[1].xyz) * 1;// _ScaleY

    float4 posWorld = 1;
	posWorld.xyz = centerPosWS.xyz + offsetX + offsetY;
    // o.posWorld = posWorld.xyz;
    // 需要修改后的WorldPos
    #if UNITY_REQUIRE_FRAG_WORLDPOS
        #if UNITY_PACK_WORLDPOS_WITH_TANGENT
            o.tangentToWorldAndPackedData[0].w = posWorld.x;
            o.tangentToWorldAndPackedData[1].w = posWorld.y;
            o.tangentToWorldAndPackedData[2].w = posWorld.z;
        #else
            o.posWorld = posWorld.xyz;
        #endif
    #endif
    o.pos = mul(UNITY_MATRIX_VP, posWorld);     
    o.eyeVec.xyz = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos);

    // --------------


    // 修改normal，此时normal朝着摄像机
    // float3 normalWorld = UnityObjectToWorldNormal(v.normal);
    half3 normalWorld = viewDirWS;
	normalWorld = normalize(normalWorld);
    
    #ifdef _TANGENT_TO_WORLD
        float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
        // 这块需要逆矩阵，转置矩阵的理解
        float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
        o.tangentToWorldAndPackedData[0].xyz = tangentToWorld[0];
        o.tangentToWorldAndPackedData[1].xyz = tangentToWorld[1];
        o.tangentToWorldAndPackedData[2].xyz = tangentToWorld[2];
    #else
        o.tangentToWorldAndPackedData[0].xyz = 0;
        o.tangentToWorldAndPackedData[1].xyz = 0;
        o.tangentToWorldAndPackedData[2].xyz = normalWorld;
    #endif

    //We need this for shadow receving
    UNITY_TRANSFER_LIGHTING(o, v.uv1);

    o.ambientOrLightmapUV = VertexGIForward_FunDream(v, posWorld, normalWorld);

    
    // #ifdef _PARALLAXMAP
    //     TANGENT_SPACE_ROTATION;
    //     half3 viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
    //     o.tangentToWorldAndPackedData[0].w = viewDirForParallax.x;
    //     o.tangentToWorldAndPackedData[1].w = viewDirForParallax.y;
    //     o.tangentToWorldAndPackedData[2].w = viewDirForParallax.z;
    // #endif
	
	o.tex = half4(TRANSFORM_TEX(v.uv0, _MainTex), v.uv1);

	// #if _UV3_ON && _UV4_ON
	// 	o.detailUV = half4(v.uv3, v.uv4);
	// #elif _UV3_ON
	// 	o.detailUV = half4(v.uv3, 0, 0);
	// #elif _UV4_ON
	// 	o.detailUV = half4(0, 0, v.uv4);
	// #else
	// 	o.detailUV = half4(0,0,0,0);
	// #endif

	//#if _FLASH
	//	o.forwardDir = normalize(mul( unity_ObjectToWorld, half4(1,0,0,0)).xyz);
	//#endif

    UNITY_TRANSFER_FOG_COMBINED_WITH_EYE_VEC(o,o.pos);
    return o;
}

// BaseVert
VertexOutputForwardBase_FunDream vertForwardBase_FunDream (VertexInput_FunDream v)
{
    UNITY_SETUP_INSTANCE_ID(v);
    VertexOutputForwardBase_FunDream o;
    UNITY_INITIALIZE_OUTPUT(VertexOutputForwardBase_FunDream, o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
    #if UNITY_REQUIRE_FRAG_WORLDPOS
        #if UNITY_PACK_WORLDPOS_WITH_TANGENT
            o.tangentToWorldAndPackedData[0].w = posWorld.x;
            o.tangentToWorldAndPackedData[1].w = posWorld.y;
            o.tangentToWorldAndPackedData[2].w = posWorld.z;
        #else
            o.posWorld = posWorld.xyz;
        #endif
    #endif
    o.pos = UnityObjectToClipPos(v.vertex);


    o.eyeVec.xyz = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos);
    float3 normalWorld = UnityObjectToWorldNormal(v.normal);
    #ifdef _TANGENT_TO_WORLD
        float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);

        float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
        o.tangentToWorldAndPackedData[0].xyz = tangentToWorld[0];
        o.tangentToWorldAndPackedData[1].xyz = tangentToWorld[1];
        o.tangentToWorldAndPackedData[2].xyz = tangentToWorld[2];
    #else
        o.tangentToWorldAndPackedData[0].xyz = 0;
        o.tangentToWorldAndPackedData[1].xyz = 0;
        o.tangentToWorldAndPackedData[2].xyz = normalWorld;
    #endif

    //We need this for shadow receving
    UNITY_TRANSFER_LIGHTING(o, v.uv1);

    o.ambientOrLightmapUV = VertexGIForward_FunDream(v, posWorld, normalWorld);

    #ifdef _PARALLAXMAP
        TANGENT_SPACE_ROTATION;
        half3 viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
        o.tangentToWorldAndPackedData[0].w = viewDirForParallax.x;
        o.tangentToWorldAndPackedData[1].w = viewDirForParallax.y;
        o.tangentToWorldAndPackedData[2].w = viewDirForParallax.z;
    #endif
	
	o.tex = half4(TRANSFORM_TEX(v.uv0, _MainTex), v.uv1);

	#if _UV3_ON && _UV4_ON
		o.detailUV = half4(v.uv3, v.uv4);
	#elif _UV3_ON
		o.detailUV = half4(v.uv3, 0, 0);
	#elif _UV4_ON
		o.detailUV = half4(0, 0, v.uv4);
	#else
		o.detailUV = half4(0,0,0,0);
	#endif

	//#if _FLASH
	//	o.forwardDir = normalize(mul( unity_ObjectToWorld, half4(1,0,0,0)).xyz);
	//#endif

    UNITY_TRANSFER_FOG_COMBINED_WITH_EYE_VEC(o,o.pos);
    return o;
}

// BaseFrag fragForwardBaseInternal
half4 fragForwardBaseInternal_FunDream(VertexOutputForwardBase_FunDream i)
{
    UNITY_SETUP_INSTANCE_ID(i)

    // 设置 s 包含posWorld,eyeVec,normalWorld的属性值
    // 对应Unity的FRAGMENT_SETUP(s)
	FragmentData s = frag(i.tex, i.eyeVec.xyz, IN_VIEWDIR4PARALLAX(i), i.tangentToWorldAndPackedData, IN_WORLDPOS(i), i.detailUV);

	#if UNITY_OPTIMIZE_TEXCUBELOD
			s.reflUVW = i.reflUVW;
	#endif

	UnityLight mainLight = MainLight(); // 这里需要使用本地的，而不能使用UnityCore的

	UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);

	// add flash
#if _FLASH
	fixed3 diffCol;
	fixed3 specColor;
	half oneM;
	half shapeMask;
	half edgeCtrl;

	half3 normal = i.tangentToWorldAndPackedData[2].xyz;
	half flashTerm = AddFlash(i.tex, i.detailUV, normal, mainLight.dir, -i.eyeVec, diffCol, shapeMask, edgeCtrl);
	diffCol = DiffuseAndSpecularFromMetallic (diffCol, _FlashMetallic, specColor, oneM);

	s.oneMinusReflectivity = lerp(s.oneMinusReflectivity, oneM, shapeMask);;
	s.smoothness = lerp(s.smoothness, _FlashSmoothness, shapeMask);
	s.normalWorld = lerp(s.normalWorld, normal, shapeMask);
	s.alpha = lerp(s.alpha, 1, shapeMask);

	s.diffColor = lerp(s.diffColor, diffCol,  shapeMask * flashTerm * edgeCtrl) ;
	s.specColor = lerp(s.specColor, specColor, shapeMask * flashTerm * edgeCtrl);
#endif

	half occlusion = Occlusion(i.tex.xy);
	UnityGI gi = FragmentGI_FunDream(s, occlusion, i.ambientOrLightmapUV, 1, mainLight);	//replaced atten with 1, atten is done in BRDF now
  
#if _ANISO
	fixed4 c =  AnisoLighting(s.specColor, s.diffColor, s.smoothness, s.alpha, s.normalWorld, -s.eyeVec, i.tangentToWorldAndPackedData, s.posWorld, i.ambientOrLightmapUV, i.tex, occlusion, mainLight, atten);
#else
	half4 c = TCP2_BRDF_PBS(s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect,
			_RampThreshold, _RampSmooth, _HColor, _SColor, _SpecSmooth, _SpecBlend, fixed3(_RimMin, _RimMax, _RimStrength), atten, s.alpha);
#endif

	c.rgb += Emission(i.tex.xy);
   
	UNITY_APPLY_FOG(i.fogCoord, c.rgb);

	return c;
}


//================================================================================================================================
//  Additive forward pass (one light per pass)
// Add结构体
struct VertexOutputForwardAdd_FunDream
{
    UNITY_POSITION(pos);
    float4 tex                          : TEXCOORD0;
    float4 eyeVec                       : TEXCOORD1;    // eyeVec.xyz | fogCoord
    float4 tangentToWorldAndLightDir[3] : TEXCOORD2;    // [3x3:tangentToWorld | 1x3:lightDir]
    float3 posWorld                     : TEXCOORD5;
    UNITY_LIGHTING_COORDS(6, 7)

    // next ones would not fit into SM2.0 limits, but they are always for SM3.0+
#if defined(_PARALLAXMAP)
    half3 viewDirForParallax            : TEXCOORD8;
#endif

	half4 detailUV						: TEXCOORD9;


	//#if _FLASH
	//	half3 forwardDir                : TEXCOORD10; 
	//#endif 

    UNITY_VERTEX_OUTPUT_STEREO
};
// VertAdd
VertexOutputForwardAdd_FunDream vertForwardAdd_FunDream (VertexInput_FunDream v)
{
    UNITY_SETUP_INSTANCE_ID(v);
    VertexOutputForwardAdd_FunDream o;
    UNITY_INITIALIZE_OUTPUT(VertexOutputForwardAdd_FunDream, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
    o.pos = UnityObjectToClipPos(v.vertex);


    // 原始 o.tex = TexCoords(v);这里没有用到TexCoord
    o.tex = half4(TRANSFORM_TEX(v.uv0, _MainTex), v.uv1);
    o.eyeVec.xyz = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos);
    o.posWorld = posWorld.xyz;
    float3 normalWorld = UnityObjectToWorldNormal(v.normal);
    #ifdef _TANGENT_TO_WORLD
        float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);

        float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
        o.tangentToWorldAndLightDir[0].xyz = tangentToWorld[0];
        o.tangentToWorldAndLightDir[1].xyz = tangentToWorld[1];
        o.tangentToWorldAndLightDir[2].xyz = tangentToWorld[2];
    #else
        o.tangentToWorldAndLightDir[0].xyz = 0;
        o.tangentToWorldAndLightDir[1].xyz = 0;
        o.tangentToWorldAndLightDir[2].xyz = normalWorld;
    #endif
    //We need this for shadow receiving and lighting
    UNITY_TRANSFER_LIGHTING(o, v.uv1);

    float3 lightDir = _WorldSpaceLightPos0.xyz - posWorld.xyz * _WorldSpaceLightPos0.w;
    #ifndef USING_DIRECTIONAL_LIGHT
        lightDir = NormalizePerVertexNormal(lightDir);
    #endif
    o.tangentToWorldAndLightDir[0].w = lightDir.x;
    o.tangentToWorldAndLightDir[1].w = lightDir.y;
    o.tangentToWorldAndLightDir[2].w = lightDir.z;

    #ifdef _PARALLAXMAP
        TANGENT_SPACE_ROTATION;
        o.viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
    #endif

	#if _UV3_ON
		o.detailUV = half4(v.uv3, 0,0);
	#else
		o.detailUV = half4(0,0,0,0);
	#endif


	//#if _FLASH
	//	o.forwardDir = normalize(mul( unity_ObjectToWorld, half4(1,0,0,0)).xyz);
	//#endif


    UNITY_TRANSFER_FOG_COMBINED_WITH_EYE_VEC(o, o.pos);
    return o;
}

// FragAdd
half4 fragForwardAddInternal_FunDream(VertexOutputForwardAdd_FunDream i)
{

    // 这里用的是Unity的FragmentCommonData，FRAGMENT_SETUP_FWDADD(s)
	FragmentCommonData s = frag(i.tex, i.eyeVec.xyz, IN_VIEWDIR4PARALLAX_FWDADD(i), i.tangentToWorldAndLightDir, IN_WORLDPOS_FWDADD(i), i.detailUV);
	#if UNITY_VERSION >= 560
	UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld)
	UnityLight light = AdditiveLight(IN_LIGHTDIR_FWDADD(i), atten);
#elif UNITY_VERSION >= 550
	UnityLight light = AdditiveLight(IN_LIGHTDIR_FWDADD(i), LIGHT_ATTENUATION(i));
#else
	UnityLight light = AdditiveLight(s.normalWorld, IN_LIGHTDIR_FWDADD(i), LIGHT_ATTENUATION(i));
#endif
	UnityIndirect noIndirect = ZeroIndirect();

#if _ANISO

	fixed4 c =  AnisoLightingAdd(s.specColor, s.diffColor, s.smoothness, s.alpha, s.normalWorld, -s.eyeVec, i.tangentToWorldAndLightDir, s.posWorld, i.tex, light, atten);
#else

	half4 c = TCP2_BRDF_PBS(s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, light, noIndirect,
			_RampThreshold, _RampSmoothAdd, _HColor, _SColor, _SpecSmooth, _SpecBlend, fixed3(_RimMin, _RimMax, _RimStrength), 1, s.alpha);
#endif


	UNITY_APPLY_FOG_COLOR(i.fogCoord, c.rgb, half4(0, 0, 0, 0)); // fog towards black in additive pass

	return c;

}

// -------------------------------------------------------------------
#endif // FUN_UNITY_STANDARD_CORE_INCLUDED