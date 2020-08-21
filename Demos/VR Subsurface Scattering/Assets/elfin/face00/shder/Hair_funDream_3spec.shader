
Shader "Custom/hair_funDream_3spec_0925" 
{
	Properties 
	{
		[Header(Reflection)][Toggle(_REFLECTMAP_ON)]_Reflect("Reflect ON ?", float) = 1
		
		[Space(10)][NoScaleOffset]_ReflectMap("Reflect Map", CUBE) = "black"{}
		_ReflectColor("Reflect Color", Color) = (1,1,1,1)
		_Brightness("Brightness", Range(0, 1)) = 0.5
		[IntRange]_Rotation("Rotation", Range(0, 360)) = 0
		_Blur("Blur", Range(0, 1)) = 1

		[Header(Main Property)][Space(5)]_MainTex ("Diffuse (RGB) Alpha (A)", 2D) = "white" {}
        _NormalTex ("Normal Map", 2D) = "Black" {}
		_AnisoDir ("SpecShift(G),Spec Mask (B)", 2D) = "white" {}

		[Space(5)][Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Float) = 2
		_MainColor ("Main Color", Color) = (1,1,1,1)
		_NormalScale("Normal Scale", Range(0, 10)) = 1
		_Specular ("Specular Amount", Range(0, 5)) = 1.0 
        _Cutoff ("Alpha Cut-Off Threshold", Range(0, 1)) = 0.5

		[Header(Spec1)]_SpecularColor ("Specular1 Color", Color) = (1,1,1,1)
		_SpecularMultiplier ("Specular1 Power", float) = 100.0	
		_PrimaryShift ( "Specular1 Shift", float) = 0.0

		[Header(Spec2)]_SpecularColor2 ("Specular2 Color", Color) = (0.5,0.5,0.5,1)
		_SpecularMultiplier2 ("Specular2 Power", float) = 100.0
		_SecondaryShift ( "Specular2 Shift", float) = .7

		[Header(Spec3)]_SpecularColor3 ("Specular3 Color", Color) = (0.5,0.5,0.5,1)
		_SpecularMultiplier3 ("Specular3 Power", float) = 100.0
		_ThirdShift ( "Specular3 Shift", float) = .7

	}
	
		SubShader
	{
		Tags {"Queue"="Transparent"}
		CGINCLUDE
		
		fixed4 _ReflectColor;
		samplerCUBE _ReflectMap;
		half _Rotation;
		half _Brightness;
		half _Blur;

		sampler2D _MainTex;
		float4 _MainTex_ST;
		half4 _MainColor;
		half _NormalScale;
		half _Cutoff;
		
		#pragma target 3.0

		float3 RotateAroundYInDegrees (float3 vect3, float degrees)
		{
			float alpha = degrees * 3.1415926 / 180.0;
			float sina, cosa;
			sincos(alpha, sina, cosa);
			float2x2 m = float2x2(cosa, -sina, sina, cosa);
			return float3(mul(m, vect3.xz), vect3.y).xzy;
		}


		ENDCG


		//该Pass也写入被遮挡像素的颜色
		Pass
		{
			Tags {"Queue"="Geometry" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}

			ZWrite On
			Cull [_Cull]
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"	
			#include "AutoLight.cginc"	

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
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata_full v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
				o.worldNormal = UnityObjectToWorldNormal(v.normal);  
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 albedo = tex2D(_MainTex, i.uv);
				clip(albedo.a -_Cutoff);

				fixed3 worldNormal = normalize(i.worldNormal);	
				float3 worldPos = i.worldPos;		
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				half NdotL = saturate(dot(worldNormal, worldLightDir)); 
				
				//计算灯光衰减
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				half4 finalColor = half4(0, 0, 0, albedo.a);
				finalColor.rgb += (albedo.rgb * _MainColor.rgb) * _LightColor0.rgb;
				return finalColor;
			};
			ENDCG
		}



		Pass
		{
			Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="TransparentCutout" "LightMode" = "ForwardBase"}

			ZWrite Off
			Cull [_Cull]
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"	

			#pragma shader_feature _REFLECTMAP_ON

			sampler2D _AnisoDir,_NormalTex;
			float4 _AnisoDir_ST,_NormalTex_ST;

			half _SpecularMultiplier, _PrimaryShift, _ThirdShift, _Specular, _SecondaryShift, _SpecularMultiplier2, _SpecularMultiplier3;
			half4 _SpecularColor, _SpecularColor2, _SpecularColor3;
			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
		
			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;  
				float4 TtoW1 : TEXCOORD2;  
				float4 TtoW2 : TEXCOORD3;
				float4 vertex : SV_POSITION;
			};

			//获取头发高光
			fixed StrandSpecular ( fixed3 T, fixed3 V, fixed3 L, fixed exponent)
			{
				fixed3 H = normalize(L + V);
				fixed dotTH = dot(T, H);
				fixed sinTH = sqrt(1 - dotTH * dotTH);
				fixed dirAtten = smoothstep(-1, 0, dotTH);
				return dirAtten * pow(sinTH, exponent);
			}
			
			//沿着法线方向调整Tangent方向
			fixed3 ShiftTangent ( fixed3 T, fixed3 N, fixed shift)
			{
				return normalize(T + shift * N);
			}

			v2f vert (appdata_full v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _NormalTex);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 albedo = tex2D(_MainTex, i.uv);
				half3 diffuseColor = albedo.rgb * _MainColor.rgb;			

				//法线相关
				fixed3 bump = UnpackScaleNormal(tex2D(_NormalTex, i.uv.zw),_NormalScale);
				fixed3 worldNormal = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 worldTangent = normalize(half3(i.TtoW0.x, i.TtoW1.x, i.TtoW2.x));
				fixed3 worldBinormal = normalize(half3(i.TtoW0.y, i.TtoW1.y, i.TtoW2.y));			

				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));

				fixed3 spec = tex2D(_AnisoDir, i.uv).rgb;

				//计算切线方向的偏移度
				half shiftTex = spec.g;
				half3 t1 = ShiftTangent(worldBinormal, worldNormal, _PrimaryShift + shiftTex);
				half3 t2 = ShiftTangent(worldBinormal, worldNormal, _SecondaryShift + shiftTex);
				half3 t3 = ShiftTangent(worldBinormal, worldNormal, _ThirdShift + shiftTex);

				//计算高光强度
				half3 spec1 = StrandSpecular(t1, worldViewDir, worldLightDir, _SpecularMultiplier)* _SpecularColor;
				half3 spec2 = StrandSpecular(t2, worldViewDir, worldLightDir, _SpecularMultiplier2)* _SpecularColor2;
				half3 spec3 = StrandSpecular(t3, worldViewDir, worldLightDir, _SpecularMultiplier3)* _SpecularColor3;

				fixed4 finalColor = 0;
				finalColor.rgb = diffuseColor + spec1 * _Specular;//第一层高光
				finalColor.rgb += spec2 * _SpecularColor2 * spec.b * _Specular;//第二层高光，spec.b用于添加噪点
				finalColor.rgb += spec3 * spec.b * _Specular;//第三层高光
				finalColor.rgb *= _LightColor0.rgb;//受灯光影响
				finalColor.a = albedo.a;

				#if _REFLECTMAP_ON
					//env color
					half3 R = reflect(-worldViewDir, worldNormal);
					R = RotateAroundYInDegrees(R, _Rotation);
					fixed3 envTexCol = texCUBElod(_ReflectMap, half4(R, _Blur * UNITY_SPECCUBE_LOD_STEPS)).rgb; 
					envTexCol = lerp(fixed3(0, 0, 0), envTexCol, _Brightness);
					finalColor.rgb += envTexCol * _ReflectColor;
				#endif

				return finalColor;
			};
			ENDCG
		}

		Pass
        {
            Tags {"LightMode"="ShadowCaster" "Queue" = "Geometry"}

            CGPROGRAM

            #pragma vertex vert_shadow
            #pragma fragment frag_shadow
            #pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"


            struct v2f_shadow { 
				half2 uv : TEXCCORD0;
                V2F_SHADOW_CASTER;
            };

            v2f_shadow vert_shadow(appdata_base v)
            {
                v2f_shadow o;
				o.uv = v.texcoord.xy;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag_shadow(v2f_shadow i) : SV_Target
            {
				fixed alpha = tex2D(_MainTex, i.uv).a;
				clip(alpha - _Cutoff + 0.1);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }

	}

	FallBack "Mobile/VertexLit"
}