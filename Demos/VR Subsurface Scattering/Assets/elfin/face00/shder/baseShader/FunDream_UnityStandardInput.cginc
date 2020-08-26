
#ifndef FUN_UNITY_STANDARD_INPUT_INCLUDED
#define FUN_UNITY_STANDARD_INPUT_INCLUDED


#include "UnityCG.cginc"
#include "UnityStandardConfig.cginc"
#include "FunDream_UnityStandardUtils.cginc"
//================================================================================================================================
// Inputs
#if (_LAYER_BASE_TEX || _LAYER_2_TEX || _LAYER_3_TEX || _LAYER_4_TEX || _LAYER_5_TEX || _LAYER_6_TEX || _LAYER_7_TEX || _LAYER_TOP_TEX)
	#define _LAYER_TEX 1
#endif

#if (_LAYER_BASE_NORMAL || _LAYER_2_NORMAL || _LAYER_3_NORMAL || _LAYER_4_NORMAL || _LAYER_5_NORMAL || _LAYER_6_NORMAL || _LAYER_7_NORMAL || _LAYER_TOP_NORMAL)
	#define _NORMALMAP 1
#endif

//#if (_LAYER_TEX || _LAYER_NORMAL)
//	#define _UV3_ON 1
//#endif

//#define _UV4_ON 1

fixed4 _HColor;
fixed4 _SColor;
sampler2D _Ramp;
fixed _RampThreshold;
fixed _RampSmooth;
fixed _RampSmoothAdd;

fixed _SpecSmooth;
fixed _SpecBlend;

fixed4 _RimColor;
fixed _RimStrength;
fixed _RimMin;
fixed _RimMax;

samplerCUBE _ReflectionMap;
half4 _ReflectionMap_HDR;
half _RimOffsetX;
half _RimOffsetY;
half _RimOffsetZ;
	

half _Rotation;
half _Brightness;
half _Thickness;
half _Gradient;

half _Temp;
half _AlphaScale;
sampler2D _MaskTex;

#if _ANISO
	//fixed4 _SpecColor;
	half _Gloss;
	half _XCurve;
	half _YCurve;
	sampler2D _NoiseTex;
	half4 _NoiseTex_ST;
	half _Offset;
	half _SpecNoise;

	#if _FUZZ		
		sampler2D _FuzzTex;
		half4 _FuzzTex_ST;
		fixed4 _FuzzColor;
		half _WrapDiffuse;
		half _FuzzRange;
		half _FuzzBias;
	#endif

	#if _LACQUER
		half _LacquerSmoothness;
		half _LacquerReflection;
	#endif

	#if _HAIR
		half _Smoothness2;
		half _Smoothness3;
		fixed4 _HairSpecCol;
		fixed4 _HairSpecCol2;
		fixed4 _HairSpecCol3;
		half _Offset2;
		half _Offset3;
	#endif


#endif

// layer system
// layer transform and scale 
#if (_LAYER_BASE_TEX || _LAYER_BASE_NORMAL)
	half4 _LayerBaseTex_ST;
#endif

#if (_LAYER_2_TEX || _LAYER_2_NORMAL)
	half4 _Layer2Tex_ST;
#endif

#if (_LAYER_3_TEX || _LAYER_3_NORMAL)
	half4 _Layer3Tex_ST;
#endif

#if (_LAYER_4_TEX || _LAYER_4_NORMAL)
	half4 _Layer4Tex_ST;
#endif

#if (_LAYER_5_TEX || _LAYER_5_NORMAL)
	half4 _Layer5Tex_ST;
#endif

#if (_LAYER_6_TEX || _LAYER_6_NORMAL)
	half4 _Layer6Tex_ST;
#endif

#if (_LAYER_7_TEX || _LAYER_7_NORMAL)
	half4 _Layer7Tex_ST;
#endif

#if (_LAYER_TOP_TEX || _LAYER_TOP_NORMAL)
	half4 _LayerTopTex_ST;
#endif


// layer texture
#if _LAYER_BASE_TEX 
	sampler2D _LayerBaseTex;
	fixed4 _LayerBaseColor;
	half _LayerBaseSmoothness;
	half _LayerBaseMetallic;
#endif

#if _LAYER_2_TEX 
	sampler2D _Layer2Tex;
	fixed4 _Layer2Color;
	half _Layer2Smoothness;
	half _Layer2Metallic;
#endif

#if _LAYER_3_TEX 
	sampler2D _Layer3Tex;
	fixed4 _Layer3Color;
	half _Layer3Smoothness;
	half _Layer3Metallic;
#endif

#if _LAYER_4_TEX 
	sampler2D _Layer4Tex;
	fixed4 _Layer4Color;
	half _Layer4Smoothness;
	half _Layer4Metallic;
#endif

#if _LAYER_5_TEX 
	sampler2D _Layer5Tex;
	fixed4 _Layer5Color;
	half _Layer5Smoothness;
	half _Layer5Metallic;
#endif

#if _LAYER_6_TEX 
	sampler2D _Layer6Tex;
	fixed4 _Layer6Color;
	half _Layer6Smoothness;
	half _Layer6Metallic;
#endif

#if _LAYER_7_TEX 
	sampler2D _Layer7Tex;
	fixed4 _Layer7Color;
	half _Layer7Smoothness;
	half _Layer7Metallic;
#endif

#if _LAYER_TOP_TEX 
	sampler2D _LayerTopTex;
	fixed4 _LayerTopColor;
	half _LayerTopSmoothness;
	half _LayerTopMetallic;
#endif

// layer normal
#if _LAYER_BASE_NORMAL
	sampler2D _LayerBaseNormal;
	half _LayerBaseNormalScale;
#endif

#if _LAYER_2_NORMAL
	sampler2D _Layer2Normal;
	half _Layer2NormalScale;
#endif

#if _LAYER_3_NORMAL
	sampler2D _Layer3Normal;
	half _Layer3NormalScale;
#endif

#if _LAYER_4_NORMAL
	sampler2D _Layer4Normal;
	half _Layer4NormalScale;
#endif

#if _LAYER_5_NORMAL
	sampler2D _Layer5Normal;
	half _Layer5NormalScale;
#endif

#if _LAYER_6_NORMAL
	sampler2D _Layer6Normal;
	half _Layer6NormalScale;
#endif

#if _LAYER_7_NORMAL
	sampler2D _Layer7Normal;
	half _Layer7NormalScale;
#endif

#if _LAYER_TOP_NORMAL
	sampler2D _LayerTopNormal;
	half _LayerTopNormalScale;
#endif

#if _FLASH
	fixed4 _FlashColor1;
	fixed4 _FlashColor2;
	sampler2D _FlashTex;
	half4 _FlashTex_ST;

	sampler2D _FlashNoiseTex;
	half4 _FlashNoiseTex_TexelSize;

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

	#if _DENSITY
		sampler2D _DensityTex;
		half _DensitySmooth;
		half _DensityCtrl;
	#endif

#endif







//---------------------------------------
// Directional lightmaps & Parallax require tangent space too
#if (_NORMALMAP || DIRLIGHTMAP_COMBINED || _PARALLAXMAP)
    #define _TANGENT_TO_WORLD 1
#endif

#if (_DETAIL_MULX2 || _DETAIL_MUL || _DETAIL_ADD || _DETAIL_LERP)
    #define _DETAIL 1
#endif

//---------------------------------------
half4       _Color;
half        _Cutoff;

sampler2D   _MainTex;
float4      _MainTex_ST;

sampler2D   _DetailAlbedoMap;
float4      _DetailAlbedoMap_ST;

sampler2D   _BumpMap;
half        _BumpScale;

sampler2D   _DetailMask;
sampler2D   _DetailNormalMap;
half        _DetailNormalMapScale;

sampler2D   _SpecGlossMap;
sampler2D   _MetallicGlossMap;
half        _Metallic;
float       _Glossiness;
float       _GlossMapScale;

sampler2D   _OcclusionMap;
half        _OcclusionStrength;

sampler2D   _ParallaxMap;
half        _Parallax;
half        _UVSec;

half4       _EmissionColor;
sampler2D   _EmissionMap;

//-------------------------------------------------------------------------------------
struct VertexInput_FunDream
{
    float4 vertex   : POSITION;
    half3 normal    : NORMAL;
    float2 uv0      : TEXCOORD0;
    float2 uv1      : TEXCOORD1;

#if _UV3_ON
	float2 uv3      : TEXCOORD2;
#endif

#if _UV4_ON
	float2 uv4      : TEXCOORD3;
#endif

#if defined(DYNAMICLIGHTMAP_ON) || defined(UNITY_PASS_META)
    float2 uv2      : TEXCOORD4;
#endif

#ifdef _TANGENT_TO_WORLD
    half4 tangent   : TANGENT;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
// 以下是Unity自带的方法
struct VertexInput
{
    float4 vertex   : POSITION;
    half3 normal    : NORMAL;
    float2 uv0      : TEXCOORD0;
    float2 uv1      : TEXCOORD1;
#if defined(DYNAMICLIGHTMAP_ON) || defined(UNITY_PASS_META)
    float2 uv2      : TEXCOORD2;
#endif
#ifdef _TANGENT_TO_WORLD
    half4 tangent   : TANGENT;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

float4 TexCoords(VertexInput_FunDream v)
{
    float4 texcoord;
    texcoord.xy = TRANSFORM_TEX(v.uv0, _MainTex); // Always source from uv0
    texcoord.zw = TRANSFORM_TEX(((_UVSec == 0) ? v.uv0 : v.uv1), _DetailAlbedoMap);
    return texcoord;
}

half DetailMask(float2 uv)
{
    return tex2D (_DetailMask, uv).a;
}

half3 Albedo(float4 texcoords)
{
    half3 albedo = _Color.rgb * tex2D (_MainTex, texcoords.xy).rgb;
#if _DETAIL
    #if (SHADER_TARGET < 30)
        // SM20: instruction count limitation
        // SM20: no detail mask
        half mask = 1;
    #else
        half mask = DetailMask(texcoords.xy);
    #endif
    half3 detailAlbedo = tex2D (_DetailAlbedoMap, texcoords.zw).rgb;
    #if _DETAIL_MULX2
        albedo *= LerpWhiteTo (detailAlbedo * unity_ColorSpaceDouble.rgb, mask);
    #elif _DETAIL_MUL
        albedo *= LerpWhiteTo (detailAlbedo, mask);
    #elif _DETAIL_ADD
        albedo += detailAlbedo * mask;
    #elif _DETAIL_LERP
        albedo = lerp (albedo, detailAlbedo, mask);
    #endif
#endif
    return albedo;
}

half Alpha(float2 uv)
{
#if defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)
    return _Color.a;
#else
    return tex2D(_MainTex, uv).a * _Color.a;
#endif
}

half Occlusion(float2 uv)
{
#if (SHADER_TARGET < 30)
    // SM20: instruction count limitation
    // SM20: simpler occlusion
    return tex2D(_OcclusionMap, uv).g;
#else
    half occ = tex2D(_OcclusionMap, uv).g;
    return LerpOneTo (occ, _OcclusionStrength);
#endif
}

half4 SpecularGloss(float2 uv)
{
    half4 sg;
#ifdef _SPECGLOSSMAP
    #if defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)
        sg.rgb = tex2D(_SpecGlossMap, uv).rgb;
        sg.a = tex2D(_MainTex, uv).a;
    #else
        sg = tex2D(_SpecGlossMap, uv);
    #endif
    sg.a *= _GlossMapScale;
#else
    // sg.rgb = _SpecColor.rgb;
    sg.rgb = half3(1,1,1); // 临时修改 TODO:
    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        sg.a = tex2D(_MainTex, uv).a * _GlossMapScale;
    #else
        sg.a = _Glossiness;
    #endif
#endif
    return sg;
}

half2 MetallicGloss(float2 uv)
{
    half2 mg;

#ifdef _METALLICGLOSSMAP
    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        mg.r = tex2D(_MetallicGlossMap, uv).r;
        mg.g = tex2D(_MainTex, uv).a;
    #else
        mg = tex2D(_MetallicGlossMap, uv).ra;
    #endif
    mg.g *= _GlossMapScale;
#else
    mg.r = _Metallic;
    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        mg.g = tex2D(_MainTex, uv).a * _GlossMapScale;
    #else
        mg.g = _Glossiness;
    #endif
#endif
    return mg;
}

half2 MetallicRough(float2 uv)
{
    half2 mg;
#ifdef _METALLICGLOSSMAP
    mg.r = tex2D(_MetallicGlossMap, uv).r;
#else
    mg.r = _Metallic;
#endif

#ifdef _SPECGLOSSMAP
    mg.g = 1.0f - tex2D(_SpecGlossMap, uv).r;
#else
    mg.g = 1.0f - _Glossiness;
#endif
    return mg;
}

half3 Emission(float2 uv)
{
#ifndef _EMISSION
    return 0;
#else
    return tex2D(_EmissionMap, uv).rgb * _EmissionColor.rgb;
#endif
}

#ifdef _NORMALMAP
half3 NormalInTangentSpace(float4 texcoords)
{
    half3 normalTangent = UnpackScaleNormal(tex2D (_BumpMap, texcoords.xy), _BumpScale);

#if _DETAIL && defined(UNITY_ENABLE_DETAIL_NORMALMAP)
    half mask = DetailMask(texcoords.xy);
    half3 detailNormalTangent = UnpackScaleNormal(tex2D (_DetailNormalMap, texcoords.zw), _DetailNormalMapScale);
    #if _DETAIL_LERP
        normalTangent = lerp(
            normalTangent,
            detailNormalTangent,
            mask);
    #else
        normalTangent = lerp(
            normalTangent,
            BlendNormals(normalTangent, detailNormalTangent),
            mask);
    #endif
#endif

    return normalTangent;
}
#endif

float4 Parallax (float4 texcoords, half3 viewDir)
{
#if !defined(_PARALLAXMAP) || (SHADER_TARGET < 30)
    // Disable parallax on pre-SM3.0 shader target models
    return texcoords;
#else
    half h = tex2D (_ParallaxMap, texcoords.xy).g;
    float2 offset = ParallaxOffset1Step (h, _Parallax, viewDir);
    return float4(texcoords.xy + offset, texcoords.zw + offset);
#endif

}
#endif // FUN_UNITY_STANDARD_INPUT_INCLUDED
