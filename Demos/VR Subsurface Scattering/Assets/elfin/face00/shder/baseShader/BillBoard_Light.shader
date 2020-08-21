
Shader "Custom/billboard_light"
{

	Properties {
		_MainTex ("Color(RGB) Alpha(A)", 2D) = "white" {}
		_NormalMap ("_NormalMap", 2D) = "white" {}

		[ToggleOff] _LockRotation("LockRotation", float) = 0
		[Enum(X,0, MinusX,1, Y,2, MinusY,3)] _LockAxis ("Lock Which Axis ?", Float) = 0

		_Color("Color", color) = (1,1,1,1)
		_Specular("_Specular", color) = (1,1,1,1)
		_Cutoff ("Alpha cutOff", Range(0,1)) = 0.5
		_Gloss ("Gloss", Range(8.0, 256)) = 40

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
			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature _LOCKROTATION_ON
			#pragma shader_feature _LOCKAXIS_0 _LOCKAXIS_1 _LOCKAXIS_2 _LOCKAXIS_3			

			struct vertData {
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 vertex : POSITION;				
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;

			};

			struct v2f
			{
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;

			};

			sampler2D _MainTex;			
			float4 _MainTex_ST;
			sampler2D _NormalMap;
			fixed4 _Color;
			fixed4 _Specular;
			fixed _Cutoff;
			fixed _Gloss;
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



				half3 normal = viewDirWS;
				normal = normalize(normal);
				// fixed3 worldNormal = UnityObjectToWorldNormal(normal);
				fixed3 worldNormal = normal;
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent);
				fixed3 binormal = cross(worldNormal, worldTangent) * v.tangent.w; 
 
				o.TtoW0 = float4(worldTangent.x, binormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, binormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, binormal.z, worldNormal.z, worldPos.z);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);

				fixed4 col = tex2D(_MainTex, i.uv);
				clip(col.a - _Cutoff);

				col.rgb *= _Color.rgb;
				//-------
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
 
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
 
				fixed4 bumpColor = tex2D(_NormalMap, i.uv.xy);
				fixed3 tangentNormal;
//				tangentNormal.xy = (bumpColor.xy * 2 - 1) * _BumpScale;
//				tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
				tangentNormal = UnpackNormal(bumpColor);
				// tangentNormal.xy ;
				tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
 
				float3x3 t2wMatrix = float3x3(i.TtoW0.xyz, i.TtoW1.xyz, i.TtoW2.xyz);
				tangentNormal = normalize(half3(mul(t2wMatrix, tangentNormal)));
				// return float4(tangentNormal,1);
				fixed3 albedo = col.rgb;
 
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
 
				// fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, lightDir));
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0.4, dot(tangentNormal, lightDir));
 
				fixed3 halfDir = normalize(viewDir + lightDir);
				
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
 
				return fixed4(ambient + diffuse + specular, 1.0);
				return col;
			}

			ENDCG
		}
	}	
	CustomEditor "FunDream_billBoard"
}
