
Shader "Custom/BaseShader_Fur"
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

		// _Gravity("Gravity Direction[重力方向]", Vector) = (0,-1,0,0)
		// _GravityStrength("Gravity Strength", Range(0,1)) = 0.25
		// _FurLength("_FurLength", Range(0,1)) = 0.25
		// _FurAlpha(" _FurAlpha", Range(0,1)) = 0.1
		// _FurDensity(" _FurDensity", Range(0,1)) = 0.1
		// _FurThinness(" _FurThinness", Range(0,10)) = 0.1


		[Space(20)]
		_FabricScatterColor("Fabric Scatter Color", Color) = (1,1,1,1)
		_FabricScatterScale("Fabric Scatter Scale", Range(0, 1)) = 0
		
		[Space(20)]
		_LayerTex("Layer", 2D) = "white" {}
		_FurLength("Fur Length", Range(.0002, 1)) = .25
		_Cutoff("Alpha Cutoff", Range(0,1)) = 0.5 // how "thick"
		_CutoffEnd("Alpha Cutoff end", Range(0,1)) = 0.5 // how thick they are at the end
		_EdgeFade("Edge Fade", Range(0,1)) = 0.4
		_Gravity("Gravity Direction", Vector) = (0,-1,0,0)
		_GravityStrength("Gravity Strength", Range(0,1)) = 0.25

		// Blending state
		[HideInInspector] _Mode("__mode", Float) = 0.0
		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0


		//TOONY COLORS PRO 2 ----------------------------------------------------------------
		_HColor("Highlight Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_SColor("Shadow Color", Color) = (0.25, 0.25, 0.25, 1.0)

		
		// [HideInInspector]_AlphaScale("Alpha Scale", Range(0, 3)) = 1
	}

	SubShader
	{
		
		Tags { "RenderType" = "Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent" }
        Cull Off
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha
		LOD 300

		CGINCLUDE
			#pragma target 3.0
			// #define UNITY_SETUP_BRDF_INPUT MetallicSetup
			#define _NORMALMAP 1
			#define _FABRIC 1
			// #define _ANISO 1
			#define _FUR 1
			
			// #pragma shader_feature _ANISO

			half3 _FabricScatterColor;
			half  _FabricScatterScale;
			half _CutoffStart;
			half _CutoffEnd;
			half _EdgeFade;

			sampler2D _LayerTex;
			float4 _LayerTex_ST;
			half _FurLength;	
			half3 _Gravity;
			half _GravityStrength;

		ENDCG
		// ------------------------------------------------------------------
		//  Base forward pass (directional light, emission, lightmaps, ...)
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert_surface
			#pragma fragment frag_surface			
			#include "UnityCG.cginc"														
			sampler2D _MainTex;
			half4 _MainTex_ST;
			struct appdata
			{
				float3 vertex : POSITION;			
				half4 uv: TEXCOORD0;		
			};
			struct v2f
			{
				float2 uv : TEXCOORD0;							
				float4 pos : SV_POSITION;				
			};

			v2f vert_surface(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			fixed4 frag_surface(v2f i): SV_Target
			{				
				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb ;
				return fixed4(albedo.xyz, 1.0);
			}
			ENDCG
		}

		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM					
			#define FURSTEP 0.05			
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream					
			#include "FunDream_Main.cginc"
			ENDCG
		}

		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			
			#define FURSTEP 0.10
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}

		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			
			#define FURSTEP 0.15
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			
			#define FURSTEP 0.20
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			
			#define FURSTEP 0.25
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			
			#define FURSTEP 0.30
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			
			#define FURSTEP 0.35
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM			
			#define FURSTEP 0.40
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM			
			#define FURSTEP 0.50
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM		
			#define FURSTEP 0.55
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM		
			#define FURSTEP 0.60
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM		
			#define FURSTEP 0.65
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM		
			#define FURSTEP 0.70
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM		
			#define FURSTEP 0.75
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}	
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM		
			#define FURSTEP 0.80
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM		
			#define FURSTEP 0.85
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM		
			#define FURSTEP 0.90
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM		
			#define FURSTEP 0.95
			#pragma vertex vertBase
			#pragma fragment fragForwardBase_FunDream
			
			#include "FunDream_Main.cginc"
			ENDCG
		}

		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM		
			#define FURSTEP 1.00
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
}
