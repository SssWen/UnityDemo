Shader "Custom/BaseShader_hair"
{
	Properties
	{
		[Enum(CullMode)] _Culling("Culling", float) = 2		//culloff : 0, cullfront : 1, cullback : 2
		_ReflectionMap("Reflection Map", CUBE) = ""{}
		_Brightness("Brightness", Range(0, 10)) = 1
		_Rotation("RotateAngle", Range(0, 360)) = 0

		_Temp("TempValue For Debug", Range(-1, 10)) = 1

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
		
		//[Enum(Standard,0, Anisotropic,1)] _SpecType("SpecType", float) = 0
		_NoiseTex("NoiseTex", 2D) = "white"{}
		_Gloss("Gloss", Range(0, 2)) = 1
		_XCurve("X_Curve", Range(0, 1)) = 0
		_YCurve("Y_Curve", Range(0, 1)) = 0
		_SpecNoise("SpecNoise", Range(0, 1)) = 0
		_HairSpecCol("HairSpecCol", Color) = (1,1,1,1)
		_Offset("Offset", Range(-3, 3)) = 0
		_HairSpecCol2("HairSpecCol2", Color) = (1,1,1,1)
		_Smoothness2("Smoothness2", Range(0,1)) = 0.5
		_Offset2("Offset2", Range(-3, 3)) = 0
		_HairSpecCol3("HairSpecCol3", Color) = (1,1,1,1)
		_Smoothness3("Smoothness3", Range(0,1)) = 0.5
		_Offset3("Offset3", Range(-3, 3)) = 0

		[ToggleOff] _FuzzON("Fuzz On or Off", Float) = 0
		_FuzzTex("FuzzTex", 2D) = "bump"{}
		_FuzzColor("FuzzColor", Color) = (1,1,1,1)
		_WrapDiffuse("WrapDiffuse", Range(0, 1)) = 0
		_FuzzRange("FuzzRange", Range(1, 5)) = 1
		_FuzzBias("FuzzBias", Range(0, 1)) = 0

		[ToggleOff] _LacquerON("Lacquer On or Off", Float) = 0
		_LacquerSmoothness("LacquerSmoothness", Range(0, 1)) = 0.5
		_LacquerReflection("LacquerReflection", Range(0, 1)) = 0.5


		_MaskTex("MaskTex", 2D) = "white" {}
		[ToggleOff] _UV2("_UV2", float) = 0
		[ToggleOff] _UV3("_UV3", float) = 0
		// layer controls
		_LayerBaseTex("LayerBaseTex", 2D) = "white"{}
		_LayerBaseNormal("LayerBaseNormal", 2D) = "bump"{}
		_LayerBaseNormalScale("LayerBaseNormalScale", float) = 1
		_LayerBaseColor("LayerBaseColor", Color) = (1,1,1,1)
		_LayerBaseSmoothness("LayerBaseSmoothness", Range(-1, 1)) = 0.3
		_LayerBaseMetallic("LayerBaseMetallic", Range(-1, 1)) = 0
		[Enum(UV0,0, UV1,1, UV2,2, UV3,3)] _LayerBaseUVSet("LayerBaseUVSet", float) = 0
		[Enum(Normal,0, Multiply,1)] _LayerBaseBlendMode("LayerBaseBlendMode", float) = 0

		_Layer2Tex("Layer2Tex", 2D) = "white"{}
		_Layer2Normal("Layer2Normal", 2D) = "bump"{}
		_Layer2NormalScale("Layer2NormalScale", float) = 1
		_Layer2Color("Layer2Color", Color) = (1,1,1,1)
		_Layer2Smoothness("Layer2Smoothness", Range(-1, 1)) = 0.3 
		_Layer2Metallic("Layer2Metallic", Range(-1, 1)) = 0
		[Enum(UV0,0, UV1,1, UV2,2, UV3,3)] _Layer2UVSet("Layer2UVSet", float) = 0
		[Enum(Normal,0, Multiply,1)] _Layer2BlendMode("LayerBaseBlendMode", float) = 0

		_Layer3Tex("Layer3Tex", 2D) = "white"{}
		_Layer3Normal("Layer3Normal", 2D) = "bump"{}
		_Layer3NormalScale("Layer3NormalScale", float) = 1
		_Layer3Color("Layer3Color", Color) = (1,1,1,1)
		_Layer3Smoothness("Layer3Smoothness", Range(-1, 1)) = 0.3 
		_Layer3Metallic("Layer3Metallic", Range(-1, 1)) = 0
		[Enum(UV0,0, UV1,1, UV2,2, UV3,3)] _Layer3UVSet("Layer3UVSet", float) = 0
		[Enum(Normal,0, Multiply,1)] _Layer3BlendMode("LayerBaseBlendMode", float) = 0

		_Layer4Tex("Layer4Tex", 2D) = "white"{}
		_Layer4Normal("Layer4Normal", 2D) = "bump"{}
		_Layer4NormalScale("Layer4NormalScale", float) = 1
		_Layer4Color("Layer4Color", Color) = (1,1,1,1)
		_Layer4Smoothness("Layer4Smoothness", Range(-1, 1)) = 0.3
		_Layer4Metallic("Layer4Metallic", Range(-1, 1)) = 0
		[Enum(UV0,0, UV1,1, UV2,2, UV3,3)] _Layer4UVSet("Layer4UVSet", float) = 0
		[Enum(Normal,0, Multiply,1)] _Layer4BlendMode("LayerBaseBlendMode", float) = 0

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

		[Toggle(RIM)] _RIM("Rim", Float) = 0
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
	}

	CGINCLUDE
		
	ENDCG


	SubShader
	{
		Tags { "RenderType"="Transparent" "PerformanceChecks"="False" }
		LOD 300


		Pass
		{
			Tags {"Queue"="Geometry" "RenderType"="Transparent"}

			ZWrite On
			Cull [_Cull]

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "FunDream_Main.cginc"
			#pragma target 3.0

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
		
			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;  
				float3 worldNormal : TEXCOORD2;  
				float4 pos : SV_POSITION;
			};

			v2f vert (appdata_full v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
				o.worldNormal = UnityObjectToWorldNormal(v.normal);  
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 texCol = tex2D(_MainTex, i.uv);
				clip(texCol.a -_Cutoff);

				fixed3 worldNormal = normalize(i.worldNormal);	
				float3 worldPos = i.worldPos;		
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				half NdotL = saturate(dot(worldNormal, worldLightDir)); 
				
				half4 c = half4(0, 0, 0, texCol.a);
				c.rgb = texCol.rgb * _Color.rgb * _LightColor0.rgb;
				return c;
			};
			ENDCG
		}



		// ------------------------------------------------------------------
		//  Base forward pass (directional light, emission, lightmaps, ...)
		Pass
		{
			Name "FRONT_FACES" 
			Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "LightMode" = "ForwardBase"}

			ZWrite off
			Cull off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma target 3.0
			
			// -------------------------------------
			#define UNITY_SPECCUBE_BOX_PROJECTION 1
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
			
			// fun dream zone
			
			//#pragma shader_feature RIM
			//#pragma shader_feature _RIMOFFSET
			//#pragma shader_feature _REAL_FRESNEL
			//#pragma shader_feature _MULTI_TRANSPARENT
			
			#pragma shader_feature _REFLECTIONMAP
			#pragma shader_feature _MASKTEX

			#pragma shader_feature _UV3_ON
			#pragma shader_feature _UV4_ON

			#pragma shader_feature _ANISO
			#pragma shader_feature _NOISE_TEX
			#pragma shader_feature _HAIR
			//#pragma shader_feature _FUZZ
			//#pragma shader_feature _FUZZ_TEX
			//#pragma shader_feature _LACQUER

			#pragma shader_feature _LAYER_BASE_TEX
			#pragma shader_feature _LAYER_2_TEX

			#pragma shader_feature _LAYER_BASE_NORMAL
			#pragma shader_feature _LAYER_2_NORMAL

			#pragma shader_feature _LayerBaseUVSet_0 _LayerBaseUVSet_1 _LayerBaseUVSet_2 _LayerBaseUVSet_3
			#pragma shader_feature _Layer2UVSet_0 _Layer2UVSet_1 _Layer2UVSet_2 _Layer2UVSet_3

			#pragma shader_feature _LayerBase_Blend_Normal _LayerBase_Blend_Multiply 
			#pragma shader_feature _Layer2_Blend_Normal _Layer2_Blend_Multiply 


			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
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
			//#pragma multi_compile_shadowcaster
			//#pragma multi_compile_instancing

			#pragma vertex vertShadowCaster_FunDream
			#pragma fragment fragShadowCaster_FunDream

			#include "FunDream_Shadow.cginc"
			ENDCG
		}

	}

	FallBack "VertexLit"
	CustomEditor "FunDreamBaseShaderGUI_hair"
}
