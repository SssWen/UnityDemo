Shader "Custom/BaseShader_BillBoard"
{
	Properties
	{
		[Enum(CullMode)] _Culling("Culling", float) = 2		//culloff : 0, cullfront : 1, cullback : 2
		_ReflectionMap("Reflection Map", CUBE) = ""{}
		_Brightness("Brightness", Range(0, 10)) = 1
		_Rotation("RotateAngle", Range(0, 360)) = 0

		_Temp("TempValue For Debug", Range(0, 2)) = 1

		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		
		_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

		_MetallicGlossMap("Metallic", 2D) = "white" {}
		
		[Gamma] _Metallic("Metallic(R)", Range(0, 2)) = 0

        _GlossMapScale("Smoothness Scale", Range(0.0, 2)) = 1.0

		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

		_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Range(0, 2)) = 1.0

		_OcclusionMap("Occlusion", 2D) = "white" {}
		_OcclusionStrength("Occlusion Strength", Range(0.0, 1.0)) = 1.0

		_EmissionMap("Emission", 2D) = "white" {}
		_EmissionColor("Emission Color", Color) = (0,0,0)
		
		_MaskTex("MaskTex", 2D) = "white" {}
		
		// layer controls
		[ToggleOff] _UV2("_UV2", float) = 0
		[ToggleOff] _UV3("_UV3", float) = 0

		_LayerBaseTex("LayerBaseTex", 2D) = "white"{}
		_LayerBaseNormal("LayerBaseNormal", 2D) = "bump"{}
		_LayerBaseNormalScale("LayerBaseNormalScale", float) = 1
		_LayerBaseColor("LayerBaseColor", Color) = (1,1,1,1)
		_LayerBaseSmoothness("LayerBaseSmoothness", Range(-1, 1)) = 0.3
		_LayerBaseMetallic("LayerBaseMetallic", Range(-1, 1)) = 0
		[Enum(UV0,0, UV1,1, UV2,2, UV3,3)] _LayerBaseUVSet("LayerBaseUVSet", float) = 0
		[Enum(Normal,0, Multiply,1)] _LayerBaseBlendMode("LayerBaseBlendMode", float) = 0

		// Blending state
		[HideInInspector] _Mode("__mode", Float) = 0.0
		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0

		//TOONY COLORS PRO 2 ----------------------------------------------------------------
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


		[ToggleOff] _LockRotation("LockRotation", float) = 0
		[Enum(X,0, MinusX,1, Y,2, MinusY,3)] _LockAxis ("Lock Which Axis ?", Float) = 0
	}

	CGINCLUDE
		
	ENDCG


	SubShader
	{
		// Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }
		Tags {"Queue"="Geometry" "IgnoreProjector"="True" "RenderType"="Geometry"}
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
			//#define TCP2_DISABLE_WRAPPED_LIGHT

			#pragma shader_feature _NORMALMAP
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _EMISSION
			#pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature _ _GLOSSYREFLECTIONS_OFF

			// #pragma multi_compile_fwdbase
			// #pragma multi_compile_fog
			#pragma multi_compile_instancing

			// #pragma shader_feature TCP2_DISABLE_WRAPPED_LIGHT
			// #pragma shader_feature TCP2_RAMPTEXT
			// #pragma shader_feature TCP2_SPEC_TOON
			// #pragma shader_feature RIM
			
			// fun dream zone
			#pragma shader_feature _REFLECTIONMAP
			#pragma shader_feature _RIMOFFSET
			// #pragma shader_feature _REAL_FRESNEL
			#pragma shader_feature _LOCKROTATION_ON
			#pragma shader_feature _LOCKAXIS_0 _LOCKAXIS_1 _LOCKAXIS_2 _LOCKAXIS_3	


			#pragma vertex vertBase_Billboard
			// #pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
		
			#include "FunDream_Main.cginc"


			ENDCG
		}
				
		Pass
		{
			Name "META" 
			Tags { "LightMode"="Meta" }

			Cull Off

			CGPROGRAM
			#pragma vertex vert_meta
			#pragma fragment frag_meta

			#pragma shader_feature _EMISSION
			#pragma shader_feature _METALLICGLOSSMAP

			#include "FunDream_UnityStandardMeta.cginc"
			ENDCG
		}

	}
	
	CustomEditor "FunDreamBaseShaderGUI_Billboard"
}
