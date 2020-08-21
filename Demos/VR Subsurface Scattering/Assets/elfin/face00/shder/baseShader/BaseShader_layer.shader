Shader "Custom/BaseShader_layer"
{
	Properties
	{
		[Enum(CullMode)] _Culling("Culling", float) = 2		//culloff : 0, cullfront : 1, cullback : 2
		_ReflectionMap("Reflection Map", CUBE) = ""{}
		_Brightness("Brightness", Range(0, 10)) = 1
		_Rotation("RotateAngle", Range(0, 360)) = 0

		_Temp("TempValue For Debug", Range(-4, 4)) = 1

		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		
		_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

		_MetallicGlossMap("Metallic", 2D) = "white" {}
		
		[Gamma] _Metallic("Metallic(R)", Range(0, 2)) = 0

        _GlossMapScale("Smoothness Scale", Range(0.0, 2)) = 1.0

		_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Range(0, 2)) = 1.0

		_OcclusionMap("Occlusion", 2D) = "white" {}
		_OcclusionStrength("Occlusion Strength", Range(0.0, 1.0)) = 1.0

		_EmissionMap("Emission", 2D) = "white" {}
		_EmissionColor("Emission Color", Color) = (0,0,0)
		
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

		// Blending state
		[HideInInspector] _Mode("__mode", Float) = 0.0
		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0

		_HColor("Highlight Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_SColor("Shadow Color", Color) = (0.25, 0.25, 0.25, 1.0)
		
		[Toggle(TCP2_DISABLE_WRAPPED_LIGHT)] _TCP2_DISABLE_WRAPPED_LIGHT("Disable Wrapped Lighting", Float) = 1
		[Toggle(TCP2_RAMPTEXT)] _TCP2_RAMPTEXT ("Ramp Texture", Float) = 0
		[TCP2Gradient] _Ramp("Toon Ramp (RGB)", 2D) = "gray" {}
		_RampThreshold("Threshold", Range(0,1)) = 0.5
		_RampSmooth("ML Smoothing", Range(0,1)) = 0.2
		_RampSmoothAdd("AL Smoothing", Range(0,1)) = 0.75

		[Toggle(TCP2_SPEC_TOON)] _TCP2_SPEC_TOON("Stylized Specular", Float) = 0
		_SpecSmooth("Specular Smoothing", Range(0,1)) = 1.0
		_SpecBlend("Stylized Specular Blending", Range(0,1)) = 1.0

		[Toggle(RIM)] _RIM("Stylized Fresnel", Float) = 0
		_RimColor("Rim Color (RGB)", Color) = (1,1,1,1)
		[PowerSlider(3)] _RimStrength("Rim Strength", Range(0, 2)) = 0.5
		_RimMin("Rim Min", Range(0, 0.99)) = 0.6
		_RimMax("Rim Max", Range(0, 0.99)) = 0.7
		
		[Toggle] _Real_Fresnel("Real Fresnel", float) = 0
		_Thickness("Thickness", Range(0, 2)) = 0.5
		_Gradient("Gradient", Range(0, 2)) = 0.5

		[ToggleOff] _RimOffset("Light Offset", float) = 0
		_RimOffsetX("Rim OffsetX", Range(-1, 1)) = 0
		_RimOffsetY("Rim OffsetY", Range(-1, 1)) = 0
		_RimOffsetZ("Rim OffsetZ", Range(-1, 1)) = 0
		
		_AlphaScale("Alpha Scale", Range(0, 3)) = 1
		_MaskTex("MaskTex", 2D) = "white" {}
		
		// layer controls
		[ToggleOff] _UV2("_UV2", float) = 0
		[ToggleOff] _UV3("_UV3", float) = 0

		_LayerBaseTex("LayerBaseTex", 2D) = "black"{}
		_LayerBaseNormal("LayerBaseNormal", 2D) = "bump"{}
		_LayerBaseNormalScale("LayerBaseNormalScale", float) = 1
		_LayerBaseColor("LayerBaseColor", Color) = (1,1,1,1)
		_LayerBaseSmoothness("LayerBaseSmoothness", Range(-1, 1)) = 0.3
		_LayerBaseMetallic("LayerBaseMetallic", Range(-1, 1)) = 0
		[Enum(UV0,0, UV1,1, UV2,2, UV3,3)] _LayerBaseUVSet("LayerBaseUVSet", float) = 0
		[Enum(Normal,0, Multiply,1)] _LayerBaseBlendMode("LayerBaseBlendMode", float) = 0

		_Layer2Tex("Layer2Tex", 2D) = "black"{}
		_Layer2Normal("Layer2Normal", 2D) = "bump"{}
		_Layer2NormalScale("Layer2NormalScale", float) = 1
		_Layer2Color("Layer2Color", Color) = (1,1,1,1)
		_Layer2Smoothness("Layer2Smoothness", Range(-1, 1)) = 0.3 
		_Layer2Metallic("Layer2Metallic", Range(-1, 1)) = 0
		[Enum(UV0,0, UV1,1, UV2,2, UV3,3)] _Layer2UVSet("Layer2UVSet", float) = 0
		[Enum(Normal,0, Multiply,1)] _Layer2BlendMode("LayerBaseBlendMode", float) = 0

		_Layer3Tex("Layer3Tex", 2D) = "black"{}
		_Layer3Normal("Layer3Normal", 2D) = "bump"{}
		_Layer3NormalScale("Layer3NormalScale", float) = 1
		_Layer3Color("Layer3Color", Color) = (1,1,1,1)
		_Layer3Smoothness("Layer3Smoothness", Range(-1, 1)) = 0.3 
		_Layer3Metallic("Layer3Metallic", Range(-1, 1)) = 0
		[Enum(UV0,0, UV1,1, UV2,2, UV3,3)] _Layer3UVSet("Layer3UVSet", float) = 0
		[Enum(Normal,0, Multiply,1)] _Layer3BlendMode("LayerBaseBlendMode", float) = 0

		_Layer4Tex("Layer4Tex", 2D) = "black"{}
		_Layer4Normal("Layer4Normal", 2D) = "bump"{}
		_Layer4NormalScale("Layer4NormalScale", float) = 1
		_Layer4Color("Layer4Color", Color) = (1,1,1,1)
		_Layer4Smoothness("Layer4Smoothness", Range(-1, 1)) = 0.3
		_Layer4Metallic("Layer4Metallic", Range(-1, 1)) = 0
		[Enum(UV0,0, UV1,1, UV2,2, UV3, 3)] _Layer4UVSet("Layer4UVSet", float) = 0
		[Enum(Normal,0, Multiply,1)] _Layer4BlendMode("LayerBaseBlendMode", float) = 0

		_Layer5Tex("Layer5Tex", 2D) = "black"{}
		_Layer5Normal("Layer5Normal", 2D) = "bump"{}
		_Layer5NormalScale("Layer5NormalScale", float) = 1
		_Layer5Color("Layer5Color", Color) = (1,1,1,1)
		_Layer5Smoothness("Layer5Smoothness", Range(-1, 1)) = 0.3
		_Layer5Metallic("Layer5Metallic", Range(-1, 1)) = 0
		[Enum(UV0,0, UV1,1, UV2,2, UV3, 3)] _Layer5UVSet("Layer5UVSet", float) = 0
		[Enum(Normal,0, Multiply,1)] _Layer5BlendMode("LayerBaseBlendMode", float) = 0

		_Layer6Tex("Layer6Tex", 2D) = "black"{}
		_Layer6Normal("Layer6Normal", 2D) = "bump"{}
		_Layer6NormalScale("Layer6NormalScale", float) = 1
		_Layer6Color("Layer6Color", Color) = (1,1,1,1)
		_Layer6Smoothness("Layer6Smoothness", Range(-1, 1)) = 0.3
		_Layer6Metallic("Layer6Metallic", Range(-1, 1)) = 0
		[Enum(UV0,0, UV1,1, UV2,2, UV3, 3)] _Layer6UVSet("Layer6UVSet", float) = 0
		[Enum(Normal,0, Multiply,1)] _Layer6BlendMode("LayerBaseBlendMode", float) = 0

		_Layer7Tex("Layer7Tex", 2D) = "black"{}
		_Layer7Normal("Layer7Normal", 2D) = "bump"{}
		_Layer7NormalScale("Layer7NormalScale", float) = 1
		_Layer7Color("Layer7Color", Color) = (1,1,1,1)
		_Layer7Smoothness("Layer7Smoothness", Range(-1, 1)) = 0.3
		_Layer7Metallic("Layer7Metallic", Range(-1, 1)) = 0
		[Enum(UV0,0, UV1,1, UV2,2, UV3, 3)] _Layer7UVSet("Layer7UVSet", float) = 0
		[Enum(Normal,0, Multiply,1)] _Layer7BlendMode("LayerBaseBlendMode", float) = 0

		_LayerTopTex("LayerTopTex", 2D) = "black"{}
		_LayerTopNormal("LayerTopNormal", 2D) = "bump"{}
		_LayerTopNormalScale("LayerTopNormalScale", float) = 1
		_LayerTopColor("LayerTopColor", Color) = (1,1,1,1)
		_LayerTopSmoothness("LayerTopSmoothness", Range(-1, 1)) = 0.3
		_LayerTopMetallic("LayerTopMetallic", Range(-1, 1)) = 0
		[Enum(UV0,0, UV1,1, UV2,2, UV3, 3)] _LayerTopUVSet("LayerTopUVSet", float) = 0
		[Enum(Normal,0, Multiply,1)] _LayerTopBlendMode("LayerBaseBlendMode", float) = 0

	}

	CGINCLUDE
		
	ENDCG

	SubShader
	{
		Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }
		LOD 300
	

		// ------------------------------------------------------------------
		//  Base forward pass (directional light, emission, lightmaps, ...)
		Pass
		{
			Name "FORWARD" 
			Tags { "LightMode" = "ForwardBase" }

			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]
			Cull [_Culling]

			CGPROGRAM
			#pragma target 3.0
			
			// -------------------------------------

			#pragma shader_feature _NORMALMAP
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _EMISSION
			#pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature _ _GLOSSYREFLECTIONS_OFF


			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile_instancing

			#pragma shader_feature TCP2_DISABLE_WRAPPED_LIGHT
			#pragma shader_feature TCP2_RAMPTEXT
			#pragma shader_feature TCP2_SPEC_TOON
			#pragma shader_feature RIM
			
			// fun dream zone
			#pragma shader_feature _RIMOFFSET
			#pragma shader_feature _REFLECTIONMAP
			#pragma shader_feature _REAL_FRESNEL


			#pragma shader_feature _MASKTEX

			#pragma shader_feature _UV3_ON
			#pragma shader_feature _UV4_ON

			#pragma shader_feature _LAYER_BASE_TEX
			#pragma shader_feature _LAYER_2_TEX
			#pragma shader_feature _LAYER_3_TEX
			#pragma shader_feature _LAYER_4_TEX
			#pragma shader_feature _LAYER_5_TEX
			#pragma shader_feature _LAYER_6_TEX
			#pragma shader_feature _LAYER_7_TEX
			#pragma shader_feature _LAYER_TOP_TEX

			#pragma shader_feature _LAYER_BASE_NORMAL
			#pragma shader_feature _LAYER_2_NORMAL
			#pragma shader_feature _LAYER_3_NORMAL
			#pragma shader_feature _LAYER_4_NORMAL
			#pragma shader_feature _LAYER_5_NORMAL
			#pragma shader_feature _LAYER_6_NORMAL
			#pragma shader_feature _LAYER_7_NORMAL
			#pragma shader_feature _LAYER_TOP_NORMAL

			#pragma shader_feature _LayerBaseUVSet_0 _LayerBaseUVSet_1 _LayerBaseUVSet_2 _LayerBaseUVSet_3
			#pragma shader_feature _Layer2UVSet_0 _Layer2UVSet_1 _Layer2UVSet_2 _Layer2UVSet_3
			#pragma shader_feature _Layer3UVSet_0 _Layer3UVSet_1 _Layer3UVSet_2 _Layer3UVSet_3
			#pragma shader_feature _Layer4UVSet_0 _Layer4UVSet_1 _Layer4UVSet_2 _Layer4UVSet_3
			#pragma shader_feature _Layer5UVSet_0 _Layer5UVSet_1 _Layer5UVSet_2 _Layer5UVSet_3
			#pragma shader_feature _Layer6UVSet_0 _Layer6UVSet_1 _Layer6UVSet_2 _Layer6UVSet_3
			#pragma shader_feature _Layer7UVSet_0 _Layer7UVSet_1 _Layer7UVSet_2 _Layer7UVSet_3
			#pragma shader_feature _LayerTopUVSet_0 _LayerTopUVSet_1 _LayerTopUVSet_2 _LayerTopUVSet_3

			#pragma shader_feature _LayerBase_Blend_Normal _LayerBase_Blend_Multiply  
			#pragma shader_feature _Layer2_Blend_Normal _Layer2_Blend_Multiply  
			#pragma shader_feature _Layer3_Blend_Normal _Layer3_Blend_Multiply  
			#pragma shader_feature _Layer4_Blend_Normal _Layer4_Blend_Multiply  
			#pragma shader_feature _Layer5_Blend_Normal _Layer5_Blend_Multiply  
			#pragma shader_feature _Layer6_Blend_Normal _Layer6_Blend_Multiply 
			#pragma shader_feature _Layer7_Blend_Normal _Layer7_Blend_Multiply  
			#pragma shader_feature _LayerTop_Blend_Normal _LayerTop_Blend_Multiply  

			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			#include "FunDream_Main.cginc"


			ENDCG
		}

		Pass
		{
			Name "FORWARD_DELTA"
			Tags { "LightMode" = "ForwardAdd" }

			Blend [_SrcBlend] One

			Fog { Color (0,0,0,0) } // in additive pass fog should be black
			ZWrite Off
			ZTest LEqual

			CGPROGRAM
			#pragma target 3.0
			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_fog

			// -------------------------------------
			
			#pragma shader_feature _NORMALMAP
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF

			//TCP2
			#pragma shader_feature TCP2_DISABLE_WRAPPED_LIGHT
			#pragma shader_feature TCP2_RAMPTEXT
			#pragma shader_feature TCP2_SPEC_TOON
			#pragma shader_feature TCP2_STYLIZED_FRESNEL
			
			
			// fun dream zone
			#pragma shader_feature RIM
			#pragma shader_feature _REFLECTIONMAP
			#pragma shader_feature _RIMOFFSET
			#pragma shader_feature _REAL_FRESNEL

			#pragma shader_feature _MASKTEX

			#pragma shader_feature _UV3_ON
			#pragma shader_feature _UV4_ON

			#pragma shader_feature _LAYER_BASE_TEX
			#pragma shader_feature _LAYER_2_TEX
			#pragma shader_feature _LAYER_3_TEX
			#pragma shader_feature _LAYER_4_TEX
			#pragma shader_feature _LAYER_5_TEX
			#pragma shader_feature _LAYER_6_TEX
			#pragma shader_feature _LAYER_7_TEX
			#pragma shader_feature _LAYER_TOP_TEX

			#pragma shader_feature _LAYER_BASE_NORMAL
			#pragma shader_feature _LAYER_2_NORMAL
			#pragma shader_feature _LAYER_3_NORMAL
			#pragma shader_feature _LAYER_4_NORMAL
			#pragma shader_feature _LAYER_5_NORMAL
			#pragma shader_feature _LAYER_6_NORMAL
			#pragma shader_feature _LAYER_7_NORMAL
			#pragma shader_feature _LAYER_TOP_NORMAL

			#pragma shader_feature _LayerBaseUVSet_0 _LayerBaseUVSet_1 _LayerBaseUVSet_2 _LayerBaseUVSet_3
			#pragma shader_feature _Layer2UVSet_0 _Layer2UVSet_1 _Layer2UVSet_2 _Layer2UVSet_3
			#pragma shader_feature _Layer3UVSet_0 _Layer3UVSet_1 _Layer3UVSet_2 _Layer3UVSet_3
			#pragma shader_feature _Layer4UVSet_0 _Layer4UVSet_1 _Layer4UVSet_2 _Layer4UVSet_3
			#pragma shader_feature _Layer5UVSet_0 _Layer5UVSet_1 _Layer5UVSet_2 _Layer5UVSet_3
			#pragma shader_feature _Layer6UVSet_0 _Layer6UVSet_1 _Layer6UVSet_2 _Layer6UVSet_3
			#pragma shader_feature _Layer7UVSet_0 _Layer7UVSet_1 _Layer7UVSet_2 _Layer7UVSet_3
			#pragma shader_feature _LayerTopUVSet_0 _LayerTopUVSet_1 _LayerTopUVSet_2 _LayerTopUVSet_3

			#pragma shader_feature _LayerBase_Blend_Normal _LayerBase_Blend_Multiply  
			#pragma shader_feature _Layer2_Blend_Normal _Layer2_Blend_Multiply  
			#pragma shader_feature _Layer3_Blend_Normal _Layer3_Blend_Multiply  
			#pragma shader_feature _Layer4_Blend_Normal _Layer4_Blend_Multiply  
			#pragma shader_feature _Layer5_Blend_Normal _Layer5_Blend_Multiply  
			#pragma shader_feature _Layer6_Blend_Normal _Layer6_Blend_Multiply 
			#pragma shader_feature _Layer7_Blend_Normal _Layer7_Blend_Multiply  
			#pragma shader_feature _LayerTop_Blend_Normal _LayerTop_Blend_Multiply  

			#pragma vertex vertAdd
			#pragma fragment fragAdd
			#include "FunDream_Main.cginc"

			ENDCG
		}
	
		// ------------------------------------------------------------------
		//  Shadow rendering pass
		Pass {
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
			
			ZWrite On ZTest LEqual

			CGPROGRAM
			#pragma target 3.0
			
			// -------------------------------------


			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma multi_compile_shadowcaster
			#pragma multi_compile_instancing

			#pragma vertex vertShadowCaster_FunDream
			#pragma fragment fragShadowCaster_FunDream

			#include "FunDream_Shadow.cginc"
			ENDCG
		}


	}


	FallBack "VertexLit"
	CustomEditor "FunDreamBaseShaderGUI_layer"
}
