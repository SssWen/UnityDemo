
Shader "Custom/billboard"
{

	Properties {
		_MainTex ("Color(RGB) Alpha(A)", 2D) = "white" {}

		[ToggleOff] _LockRotation("LockRotation", float) = 0
		[Enum(X,0, MinusX,1, Y,2, MinusY,3)] _LockAxis ("Lock Which Axis ?", Float) = 0

		_Color("Color", color) = (1,1,1,1)
		_Cutoff ("Alpha cutOff", Range(0,1)) = 0.5

		_ScaleX("ScaleX", Range(0,3)) = 1
		_ScaleY("ScaleY", Range(0,3)) = 1

	}
	
	SubShader {
	
		Tags {"Queue"="Geometry" "IgnoreProjector"="True" "RenderType"="Geometry"}


		Pass {  
		
			Cull back
			ZWrite ON


			CGPROGRAM

			#pragma target 3.0
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			
			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature _LOCKROTATION_ON
			#pragma shader_feature _LOCKAXIS_0 _LOCKAXIS_1 _LOCKAXIS_2 _LOCKAXIS_3

			struct vertData {
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;

			};

			struct v2f
			{
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed _Cutoff;
			half _ScaleX;
			half _ScaleY;


			UNITY_INSTANCING_BUFFER_START(MyProperties)
			//UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
			UNITY_INSTANCING_BUFFER_END(MyProperties)


			v2f vert (vertData v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				// local space
				half4 centerPos = half4(0 ,0, 0, 1);				

				// world space 
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

				half3 offsetX = rightDirWS  * v.vertex.x * length(unity_ObjectToWorld[0].xyz) * _ScaleX;
				half3 offsetY =  forwardDirWS * v.vertex.y * length(unity_ObjectToWorld[1].xyz) * _ScaleY;

				half4 worldPos = 1;
				worldPos.xyz = centerPosWS.xyz + offsetX + offsetY;

				o.pos = mul(UNITY_MATRIX_VP, worldPos); 
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);

				fixed4 col = tex2D(_MainTex, i.uv);
				clip(col.a - _Cutoff);

				col.rgb *= _Color.rgb;

				return col;
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
	CustomEditor "FunDream_billBoard"
}
