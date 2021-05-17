#ifndef UNIVERSAL_LIT_INPUT_INCLUDED
#define UNIVERSAL_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

struct F_SurfaceData
{
    half3 albedo;
    half3 specular;
    half  metallic;
    half  smoothness;
    half3 normalTS;
    half3 emission;
    half  occlusion;
    half  alpha;
};



// properties defined inside a concrete memory buffere instead of at the global level.
// constant buffer aren't surpported on all platforms eg:OpenGLES2.0
// use cbuffer_start macros instead.
CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
half4 _BaseColor;
half4 _SpecColor;
half4 _EmissionColor;
half _Cutoff;
half _Smoothness;
half _Metallic;
half _BumpScale;
half _OcclusionStrength;
CBUFFER_END

TEXTURE2D(_OcclusionMap);       SAMPLER(sampler_OcclusionMap);
TEXTURE2D(_MetallicGlossMap);   SAMPLER(sampler_MetallicGlossMap);
TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);
TEXTURE2D(_NormalMap);          SAMPLER(sampler_NormalMap); 
half _NormalMapScale;

// ----- Rim -------
    half _RimAlphaMin;
    half _RimAlphaMax;
    half _RimAlphaEnhance;
    half _Transparency;
    half _MinTransparency;
// ----- Rim -------
    half _RimLightMin;
    half _RimLightMax;
    half4 _RimLightColor;
// ----- Rim -------

// ----- TCP Rim -------    
    half4 _TCP_RimColor;
    half _TCP_RimStrength;
    half _TCP_RimMin;
    half _TCP_RimMax;

    
    half _TCP_RimOffsetX;
    half _TCP_RimOffsetY;
    half _TCP_RimOffsetZ;
// ----- TCP Rim -------

// -- SharpLight
    half4 _HighLightColor;
    half4 _ShadowLightColor;
    half _Threshold1;
    half _Threshold2;
    half _AttenuationControl;
// -- SharpLight

// ----- Anistropic -------
    half3 _SpecularColor;
    half _RoughnessX;
    half _RoughnessY;
    half _LightDirX;
    half _LightDirY;
    half _LightDirZ;

    half _ShiftX;
    half _ShiftY;
    half _Offset;
    half _Rotate;
    #if _ANIS_NOISE_TEX
        TEXTURE2D(_AnisNoiseTex);   SAMPLER(sampler_AnisNoiseTex);
        half4 _AnisNoiseTex_ST;  
    #endif
    
// ----- Anistropic -------

// ------Added Layer- TODO: need to decrease sample numbles----------------    
    #if _LAYER_0_TEX || _LAYER_0_NORMAL
        TEXTURE2D(_Layer0Tex);       SAMPLER(sampler_Layer0Tex);    
        half4 _Layer0Tex_ST;
        half4 _Layer0Color;
        half _Layer0Smoothness;
        half _Layer0Metallic;
        #if _LAYER_0_NORMAL
            TEXTURE2D(_Layer0Normal);   SAMPLER(sampler_Layer0Normal);
            half _Layer0NormalScale;
            half4 _Layer0Normal_ST;
        #endif
    #endif

    #if _LAYER_1_TEX || _LAYER_1_NORMAL
        TEXTURE2D(_Layer1Tex);       SAMPLER(sampler_Layer1Tex);    
        half4 _Layer1Tex_ST;
        half4 _Layer1Color;
        half _Layer1Smoothness;
        half _Layer1Metallic;
        #if _LAYER_1_NORMAL
            TEXTURE2D(_Layer1Normal);   SAMPLER(sampler_Layer1Normal);
            half _Layer1NormalScale;
            half4 _Layer1Normal_ST;
        #endif
        half _Layer1Cutoff;
    #endif


    #if _LAYER_2_TEX || _LAYER_2_NORMAL
        TEXTURE2D(_Layer2Tex);       SAMPLER(sampler_Layer2Tex);    
        half4 _Layer2Tex_ST;
        half4 _Layer2Color;
        half _Layer2Smoothness;
        half _Layer2Metallic;        
        #if _LAYER_2_NORMAL
            TEXTURE2D(_Layer2Normal);   SAMPLER(sampler_Layer2Normal);
            half _Layer2NormalScale;
            half4 _Layer2Normal_ST;
        #endif
    #endif
    
    #if _LAYER_3_TEX || _LAYER_3_NORMAL
        TEXTURE2D(_Layer3Tex);       SAMPLER(sampler_Layer3Tex);    
        half4 _Layer3Tex_ST;
        half4 _Layer3Color;
        half _Layer3Smoothness;
        half _Layer3Metallic;        
        #if _LAYER_3_NORMAL
            TEXTURE2D(_Layer3Normal);   SAMPLER(sampler_Layer3Normal);
            half _Layer3NormalScale;
            half4 _Layer3Normal_ST;
        #endif
    #endif

    #if _LAYER_4_TEX || _LAYER_4_NORMAL
        TEXTURE2D(_Layer4Tex);       SAMPLER(sampler_Layer4Tex);    
        half4 _Layer4Tex_ST;
        half4 _Layer4Color;
        half _Layer4Smoothness;
        half _Layer4Metallic;        

        #if _LAYER_4_NORMAL
            TEXTURE2D(_Layer4Normal);   SAMPLER(sampler_Layer4Normal);
            half _Layer4NormalScale;
            half4 _Layer4Normal_ST;
        #endif
    #endif

    #if _LAYER_5_TEX || _LAYER_5_NORMAL
        TEXTURE2D(_Layer5Tex);       SAMPLER(sampler_Layer5Tex);    
        half4 _Layer5Tex_ST;
        half4 _Layer5Color;
        half _Layer5Smoothness;
        half _Layer5Metallic;        
        #if _LAYER_5_NORMAL
            TEXTURE2D(_Layer5Normal);   SAMPLER(sampler_Layer5Normal);
            half _Layer5NormalScale;
            half4 _Layer5Normal_ST;
        #endif
    #endif

    #if _LAYER_6_TEX || _LAYER_6_NORMAL
        TEXTURE2D(_Layer6Tex);       SAMPLER(sampler_Layer6Tex);    
        half4 _Layer6Tex_ST;
        half4 _Layer6Color;
        half _Layer6Smoothness;
        half _Layer6Metallic;        
        #if _LAYER_6_NORMAL
            TEXTURE2D(_Layer6Normal);   SAMPLER(sampler_Layer6Normal);
            half _Layer6NormalScale;
            half4 _Layer6Normal_ST;
        #endif
    #endif

    #if _LAYER_7_TEX || _LAYER_7_NORMAL
        TEXTURE2D(_Layer7Tex);       SAMPLER(sampler_Layer7Tex);    
        half4 _Layer7Tex_ST;
        half4 _Layer7Color;
        half _Layer7Smoothness;
        half _Layer7Metallic;        
        #if _LAYER_7_NORMAL
            TEXTURE2D(_Layer7Normal);   SAMPLER(sampler_Layer7Normal);
            half _Layer7NormalScale;
            half4 _Layer7Normal_ST;
        #endif
    #endif


// ------Added Layer-----------------    


// ------ sparkle ---------------
    TEXTURE2D(_SparkleNoiseTex);       SAMPLER(sampler_SparkleNoiseTex);
    half4 _SparkleNoiseTex_TexelSize;
    #if 1 // TODO:
        half4 _FlashColor1;
        half4 _FlashColor2;        
        TEXTURE2D(_FlashTex);       SAMPLER(sampler_FlashTex);
        half4 _FlashTex_ST;
        
        // TEXTURE2D(_SparkleNoiseTex);       SAMPLER(sampler_SparkleNoiseTex);
        // half4 _SparkleNoiseTex_TexelSize;

        half _RadiusRandom;
        half _DeleteSmall;
        half _DeleteRandom;
        half _ColorRandom;
        half _OffsetRandom;

        half _FlashSpeed;
        half _DarkTime;
        half _FlashZone;
        half _FlashMin;
        half _FlashRotate;

        half _FlashMetallic;
        half _FlashSmoothness;
        half _RandomSeed;

    #endif
// ------ sparkle ---------------

// ------ reflection -----------
// samplerCUBE _ReflectionTex;
TEXTURECUBE(_ReflectionTex);    SAMPLER(sampler_ReflectionTex);
half _Brightness;
half _Rotation;
half _YRotation;
// ------ reflection -----------

#ifdef _SPECULAR_SETUP
    #define SAMPLE_METALLICSPECULAR(uv) SAMPLE_TEXTURE2D(_SpecGlossMap, sampler_SpecGlossMap, uv)
#else
    #define SAMPLE_METALLICSPECULAR(uv) SAMPLE_TEXTURE2D(_MetallicGlossMap, sampler_MetallicGlossMap, uv)
#endif

half4 SampleMetallicSpecGloss(float2 uv, half albedoAlpha)
{
    half4 specGloss;

#ifdef _METALLICSPECGLOSSMAP
    specGloss = SAMPLE_METALLICSPECULAR(uv);
    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        specGloss.a = albedoAlpha * _Smoothness;
    #else
        specGloss.a *= _Smoothness;
    #endif
#else // _METALLICSPECGLOSSMAP
    #if _SPECULAR_SETUP
        specGloss.rgb = _SpecColor.rgb;
    #else
        specGloss.rgb = _Metallic.rrr;
    #endif

    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        specGloss.a = albedoAlpha * _Smoothness;
    #else
        specGloss.a = _Smoothness;
    #endif
#endif

    return specGloss;
}

half SampleOcclusion(float2 uv)
{
#ifdef _OCCLUSIONMAP
// TODO: Controls things like these by exposing SHADER_QUALITY levels (low, medium, high)
#if defined(SHADER_API_GLES)
    return SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv).g;
#else
    half occ = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv).g;
    return LerpWhiteTo(occ, _OcclusionStrength);
#endif
#else
    return 1.0;
#endif
}

inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
{
    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    outSurfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);

    half4 specGloss = SampleMetallicSpecGloss(uv, albedoAlpha.a);
    outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;

#if _SPECULAR_SETUP
    outSurfaceData.metallic = 1.0h;
    outSurfaceData.specular = specGloss.rgb;
#else
    outSurfaceData.metallic = specGloss.r;
    outSurfaceData.specular = half3(0.0h, 0.0h, 0.0h);
#endif

    outSurfaceData.smoothness = specGloss.a;
    outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
    outSurfaceData.occlusion = SampleOcclusion(uv);
    outSurfaceData.emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
}

#endif // UNIVERSAL_INPUT_SURFACE_PBR_INCLUDED
