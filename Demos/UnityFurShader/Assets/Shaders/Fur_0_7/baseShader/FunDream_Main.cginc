

// FunDream_Main.cginc 


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



#include "UnityStandardConfig.cginc"
#include "UnityStandardCore.cginc"
#include "FunDream_UnityStandardBRDF.cginc"
#if _ANISO
	#include "FunDream_Aniso.cginc"
#endif
#if _SSS
	#include "FunDream_SSS.cginc"
#endif
// for layer options
#include "FunDream_Tools.cginc"




//================================================================================================================================
// vertex Shader


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

// todo
VertexOutputForwardBase_FunDream vertForwardBase_FunDream (VertexInput_FunDream v)
{
    UNITY_SETUP_INSTANCE_ID(v);
    VertexOutputForwardBase_FunDream o;
    UNITY_INITIALIZE_OUTPUT(VertexOutputForwardBase_FunDream, o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

#if _FUR
    half3 direction = lerp(v.normal, _Gravity * _GravityStrength + v.normal * (1 - _GravityStrength), FURSTEP);
	v.vertex.xyz += direction * _FurLength * FURSTEP;
#endif 

// #if _FUR
// 	// 毛发偏移计算,添加mask,最初计算公式:https://xbdev.net/directx3dx/specialX/Fur/
// 	// o.uv.xy = TRANSFORM_TEX(v.texcoord, _FurColorTex);
// 	// o.uv.zw = TRANSFORM_TEX(v.texcoord, _FurTex);     
	
// 	o.tex.xy = TRANSFORM_TEX(v.uv0, _MainTex); 	// MainTex和Mask共用UV0
// 	o.tex.zw = TRANSFORM_TEX(v.uv1, _LayerTex);     
	
		
//     float4 mask = tex2Dlod(_MaskTex,float4(o.tex.xy,0,0));    
// 	half3 direction = lerp(v.normal, _Gravity * _GravityStrength + v.normal * (1 - _GravityStrength),FURSTEP);	  	
// 	// half3 direction = lerp(v.normal, _Gravity.xyz * _GravityStrength + v.normal * (1 - _GravityStrength), half3(FURSTEP,FURSTEP,FURSTEP));
// 	float3 pos =  direction * _FurLength * FURSTEP;	
// 	v.vertex.xyz += pos * mask.r;
// #endif 

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
    // o.pos = UnityObjectToClipPos(float4(v.vertex.xyz,1.0));
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



//================================================================================================================================
//  UnityStandardCore.cginc
//  Fragment shaders sub-functions



struct FragmentData
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


inline FragmentData MetallicSetup_FunDream (half4 i_tex, half4 detailUV, float4 tangentToWorld[3])
{

	half2 uv = i_tex.xy;

    half2 metallicGloss = MetallicGloss_FunDream(uv);
    half metallic = metallicGloss.x;
    half smoothness = metallicGloss.y; // this is 1 minus the square root of real roughness m.

    half oneMinusReflectivity;
    half3 specColor;

	fixed4 mainTexCol = tex2D (_MainTex, i_tex.xy);

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
		float3 normalWorld = NormalizePerPixelNormal(tangent * outNormalTS.x + binormal * outNormalTS.y + normal * outNormalTS.z); 
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



//================================================================================================================================
// Replacement for UnityPBSLighting.cginc
// env lighting functions

float3 RotateAroundYInDegrees (float3 vect3, float degrees)
{
    float alpha = degrees * UNITY_PI / 180.0;
    float sina, cosa;
    sincos(alpha, sina, cosa);
    float2x2 m = float2x2(cosa, -sina, sina, cosa);
    return float3(mul(m, vect3.xz), vect3.y).xzy;
}



half3 Unity_GlossyEnvironment_FunDream (samplerCUBE tex, half4 hdr, Unity_GlossyEnvironmentData glossIn)
{
    half perceptualRoughness = glossIn.roughness;

    perceptualRoughness = perceptualRoughness*(1.7 - 0.7*perceptualRoughness);

    half mip = perceptualRoughnessToMipmapLevel(perceptualRoughness);  //UNITY_SPECCUBE_LOD_STEPS = 6
    half3 R = glossIn.reflUVW;

	#ifdef _REFLECTIONMAP 
		//#ifdef _ROTATION
			//R = mul(_Rotation, R);
			R = RotateAroundYInDegrees(R, _Rotation);
		//#endif
	#endif

	half4 rgbm = texCUBElod(tex, half4(R, mip));

	return DecodeHDR(rgbm, hdr) * unity_ColorSpaceDouble; 

}


inline half3 UnityGI_IndirectSpecular_FunDream(UnityGIInput data, half occlusion, Unity_GlossyEnvironmentData glossIn)
{
    half3 specular;

    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
        // we will tweak reflUVW in glossIn directly (as we pass it to Unity_GlossyEnvironment twice for probe0 and probe1), so keep original to pass into BoxProjectedCubemapDirection
        half3 originalReflUVW = glossIn.reflUVW;
        glossIn.reflUVW = BoxProjectedCubemapDirection (originalReflUVW, data.worldPos, data.probePosition[0], data.boxMin[0], data.boxMax[0]);
    #endif

    #ifdef _GLOSSYREFLECTIONS_OFF
        specular = unity_IndirectSpecColor.rgb;
    #else

		#ifdef _REFLECTIONMAP
			specular = lerp(0, Unity_GlossyEnvironment_FunDream(_ReflectionMap, _ReflectionMap_HDR, glossIn), _Brightness);
		#else
			specular = Unity_GlossyEnvironment (UNITY_PASS_TEXCUBE(unity_SpecCube0), data.probeHDR[0], glossIn);
		#endif

    #endif

    return specular * occlusion;
}


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
    // Replace the reflUVW if it has been compute in Vertex shader. Note: the compiler will optimize the calcul in UnityGlossyEnvironmentSetup itself
    #if UNITY_STANDARD_SIMPLE
        g.reflUVW = s.reflUVW;
    #endif

	UnityGI o_gi = UnityGI_Base(d, occlusion, s.normalWorld);
    o_gi.indirect.specular = UnityGI_IndirectSpecular_FunDream (d, occlusion, g);

    return o_gi;

}



//================================================================================================================================
// macro for choosing BRDF function

//Uncomment one of these lines to force a quality level regardless of target platform
#define TCP2_BRDF_PBS BRDF1_TCP2_PBS
//#define TCP2_BRDF_PBS BRDF2_TCP2_PBS
//#define TCP2_BRDF_PBS BRDF3_TCP2_PBS

#if !defined (TCP2_BRDF_PBS) // allow to explicitly override BRDF in custom shader
// still add safe net for low shader models, otherwise we might end up with shaders failing to compile
// the only exception is WebGL in 5.3 - it will be built with shader target 2.0 but we want it to get rid of constraints, as it is effectively desktop
	#if SHADER_TARGET < 30
		#define TCP2_BRDF_PBS BRDF3_TCP2_PBS
	#elif UNITY_PBS_USE_BRDF3
		#define TCP2_BRDF_PBS BRDF3_TCP2_PBS
	#elif UNITY_PBS_USE_BRDF2
		#define TCP2_BRDF_PBS BRDF2_TCP2_PBS
	#elif UNITY_PBS_USE_BRDF1
		#define TCP2_BRDF_PBS BRDF1_TCP2_PBS
	#elif defined(SHADER_TARGET_SURFACE_ANALYSIS)
		// we do preprocess pass during shader analysis and we dont actually care about brdf as we need only inputs/outputs
		#define TCP2_BRDF_PBS BRDF1_TCP2_PBS
	#else
		#error something broke in auto-choosing BRDF
	#endif
#endif

#ifndef TCP2_STANDARD_CORE_INCLUDED
#define TCP2_STANDARD_CORE_INCLUDED

#endif // TCP2_STANDARD_CORE_INCLUDED




//================================================================================================================================
// Core fragment functions (Forward Rendering)



FragmentData frag( half4 i_tex, half3 i_eyeVec, half3 i_viewDirForParallax, float4 tangentToWorld[3], half3 i_posWorld, half4 detailUV){
	//FragmentData s = FragmentSetup_FunDream(i.tex, i.eyeVec.xyz, IN_VIEWDIR4PARALLAX(i), i.tangentToWorldAndPackedData, IN_WORLDPOS(i));
    half2 offsets;
	half alpha;
		// Parallax
	#if defined(_PARALLAXMAP) || (SHADER_TARGET > 30)
		// Disable parallax on pre-SM3.0 shader target models
		half h = tex2D (_ParallaxMap, i_tex.xy).g;
		offsets = ParallaxOffset1Step (h, _Parallax, i_viewDirForParallax);
		i_tex = float4(i_tex.xy + offsets, i_tex.zw + offsets);
		#if _UV3_ON
			detailUV.xy += offsets;
		#endif
	#endif

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


#if _FLASH

	half AddFlash(half4 baseUV, half4 detailUV, half3 normalDir, half3 lightDir, half3 viewDir, out fixed3 diffCol, out half shapeMask, out half edgeCtrl){

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


		half rand = tex2D(_FlashNoiseTex, id/_FlashNoiseTex_TexelSize.zw).r;
		rand = lerp(1/_RadiusRandom, 1, rand);
		half rand2 = tex2D(_FlashNoiseTex, (id + 1 + _RandomSeed)/_FlashNoiseTex_TexelSize.zw).r;
		half rand3 = tex2D(_FlashNoiseTex, (id + 2 + _RandomSeed)/_FlashNoiseTex_TexelSize.zw).r;
		half rand4 = tex2D(_FlashNoiseTex, (id + 3 + _RandomSeed)/_FlashNoiseTex_TexelSize.zw).r;


		//half h = lightDir + viewDir;
		half nh_flash =  saturate(dot(normalize( lightDir + viewDir * _FlashZone), normalDir)) ;

		half deleteSmall = step(_DeleteSmall, 1 - rand);
		half deleteRand = step(_DeleteRandom, rand2 * 0.99);	
		half colorRand = step(_ColorRandom, rand3 * 0.99);		

		half uvScale = rand * _RadiusRandom;			
		half uvOffset = rand2 * (uvScale - 1) * lerp(_OffsetRandom, 0, 1/_RadiusRandom ); 
		half2 newEachUV = eachUV * uvScale - uvOffset;  

		half densityCtrl = 1;
		#if _DENSITY
			half rand5 = tex2D(_FlashNoiseTex, (id + 4 + _RandomSeed)/_FlashNoiseTex_TexelSize.zw).r;
			half2 densityUV = id/_FlashTex_ST.xy + _FlashTex_ST.zw;
			half densityMask = tex2D(_FlashNoiseTex, densityUV).b;
			densityCtrl = step(1 - densityMask, lerp(deleteRand, 0, _DensityCtrl) + rand5 * _DensitySmooth );
		#endif

		shapeMask = tex2D(_FlashTex, newEachUV).r * deleteSmall * deleteRand * densityCtrl;  
		edgeCtrl = pow(nh_flash, 2);
		diffCol = lerp(_FlashColor2.xyz, _FlashColor1.xyz, colorRand);

		//half viewRotate = abs(dot(half3(-1,0,-1), forwardDir));
		half flash = abs(sin( rand4 * 20 + _FlashRotate * _FlashSpeed * 10 ));
		flash = max(pow(flash, _DarkTime), _FlashMin);
	
		return flash;

	}

#endif   //#if _FLASH



// todo
half4 fragForwardBaseInternal_FunDream(VertexOutputForwardBase_FunDream i)
{
	// FRAGMENT_SETUP(s)
	FragmentData s = frag(i.tex, i.eyeVec.xyz, IN_VIEWDIR4PARALLAX(i), i.tangentToWorldAndPackedData, IN_WORLDPOS(i), i.detailUV);

	#if UNITY_OPTIMIZE_TEXCUBELOD
			s.reflUVW = i.reflUVW;
	#endif

	UnityLight mainLight = MainLight();

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

#if _SSS
	
#endif


#if _ANISO
	fixed4 c =  AnisoLighting(s.specColor, s.diffColor, s.smoothness, s.alpha, s.normalWorld, -s.eyeVec, i.tangentToWorldAndPackedData, s.posWorld, i.ambientOrLightmapUV, i.tex, occlusion, mainLight, atten);
#else
	half4 c = TCP2_BRDF_PBS(s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect,
			_RampThreshold, _RampSmooth, _HColor, _SColor, _SpecSmooth, _SpecBlend, fixed3(_RimMin, _RimMax, _RimStrength), atten, s.alpha);
#endif	
	c.rgb += Emission(i.tex.xy);

	UNITY_APPLY_FOG(i.fogCoord, c.rgb);

// #if _FUR // Only Change Alpha
//     // fixed alpha = tex2D(_LayerTex, TRANSFORM_TEX(i.tex.xy, _LayerTex)).r;
// 	// alpha = step(lerp(_CutoffStart, _CutoffEnd, FURSTEP), alpha);
//     // c.a = 1 - FURSTEP*FURSTEP;
// 	// c.a += dot(-s.eyeVec, s.normalWorld) - _EdgeFade;
// 	// c.a = max(0, c.a);
// 	// c.a *= alpha;
// 	// fixed alpha = tex2D(_LayerTex, TRANSFORM_TEX(i.tex.zw*_FurThinness, _LayerTex)).r;	
// 	fixed alpha = tex2D(_LayerTex, i.tex.zw * _FurThinness);
// 	// fixed3 noise = tex2D(_FurTex, i.uv.zw * _FurThinness).rgb;
// 	alpha = clamp(alpha - _FurAlpha - (FURSTEP * FURSTEP) * _FurDensity, 0, 1);  	
// 	c.a = max(0, c.a);
// 	c.a = alpha;    
// #endif
#if _FUR
    fixed alpha = tex2D(_LayerTex, TRANSFORM_TEX(i.tex.xy, _LayerTex)).r;
	alpha = step(lerp(_CutoffStart, _CutoffEnd, FURSTEP), alpha);	
    c.a = 1 - FURSTEP*FURSTEP;
	c.a += dot(-s.eyeVec, s.normalWorld) - _EdgeFade;
	c.a = max(0, c.a);
	c.a *= alpha;

    return c;
#endif
	return c;
}



//================================================================================================================================
//  Additive forward pass (one light per pass)

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



VertexOutputForwardAdd_FunDream vertForwardAdd_FunDream (VertexInput_FunDream v)
{
    UNITY_SETUP_INSTANCE_ID(v);
    VertexOutputForwardAdd_FunDream o;
    UNITY_INITIALIZE_OUTPUT(VertexOutputForwardAdd_FunDream, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
    o.pos = UnityObjectToClipPos(v.vertex);

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


half4 fragForwardAddInternal_FunDream(VertexOutputForwardAdd_FunDream i)
{

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

	// flash no need to suppport multiple lights maybe

	//#if _FLASH
	//	fixed3 diffCol;
	//	fixed3 specColor;
	//	half oneM;
	//	half shapeMask;
	//	half flashSmoothness;

	//	half flashTerm = AddFlash(i.tex.xy, i.tangentToWorldAndLightDir[2].xyz, light.dir, -i.eyeVec, i.forwardDir, diffCol, shapeMask, flashSmoothness);
	//	diffCol = DiffuseAndSpecularFromMetallic (diffCol, _FlashMetallic, specColor, oneM);

	//	s.oneMinusReflectivity = lerp(s.oneMinusReflectivity, oneM, shapeMask);;
	//	s.smoothness = lerp(s.smoothness, flashSmoothness * _FlashSmoothness, shapeMask);
	//	s.diffColor = lerp(s.diffColor, diffCol, flashTerm);
	//	s.specColor = lerp(s.specColor, specColor, flashTerm);
	//#endif


#if _ANISO

	fixed4 c =  AnisoLightingAdd(s.specColor, s.diffColor, s.smoothness, s.alpha, s.normalWorld, -s.eyeVec, i.tangentToWorldAndLightDir, s.posWorld, i.tex, light, atten);
#else

	half4 c = TCP2_BRDF_PBS(s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, light, noIndirect,
			_RampThreshold, _RampSmoothAdd, _HColor, _SColor, _SpecSmooth, _SpecBlend, fixed3(_RimMin, _RimMax, _RimStrength), 1, s.alpha);
#endif


	UNITY_APPLY_FOG_COLOR(i.fogCoord, c.rgb, half4(0, 0, 0, 0)); // fog towards black in additive pass


	return c;

}



//================================================================================================================================
//Entry functions

half4 fragForwardBase_FunDream(VertexOutputForwardBase_FunDream i) : SV_Target		// backward compatibility (this used to be the fragment entry function)
{
	return fragForwardBaseInternal_FunDream(i);
}


half4 fragForwardAdd_FunDream(VertexOutputForwardAdd_FunDream i) : SV_Target		// backward compatibility (this used to be the fragment entry function)
{
	return fragForwardAddInternal_FunDream(i);
}




//================================================================================================================================
// Main functions

VertexOutputForwardBase_FunDream vertBase (VertexInput_FunDream v) { return vertForwardBase_FunDream(v); }
half4 fragBase (VertexOutputForwardBase_FunDream i) : SV_Target { return fragForwardBaseInternal_FunDream(i); }

VertexOutputForwardAdd_FunDream vertAdd (VertexInput_FunDream v) { return vertForwardAdd_FunDream(v); }
half4 fragAdd (VertexOutputForwardAdd_FunDream i) : SV_Target { return fragForwardAddInternal_FunDream(i); }