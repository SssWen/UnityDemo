Shader "Hidden/SSS_Profile"
{	
	//Properties
	//{
	//	_Cutoff("Mask Clip Value", Float) = 0.5
	//}
	SubShader
	{
		//Tags { "RenderType"="SSS" }
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			half _Cutoff;
			#include "UnityCG.cginc"
			#include "UnityStandardUtils.cginc"
			#include "SSS_Common.hlsl"
			#pragma multi_compile _ ENABLE_ALPHA_TEST


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				
				float4 vertex : SV_POSITION;
			};	
			float4 _MainTex_ST;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_ProfileTex, i.uv) * _ProfileColor;
				fixed alpha = tex2D(_MainTex, i.uv).a;

				#ifdef ENABLE_ALPHA_TEST
				clip(alpha - _Cutoff);
				#endif

				return col;
			}
			ENDCG
		}
	}
		//Don't render anything else
		//Fallback "Legacy Shaders/VertexLit"
}
