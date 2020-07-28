// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'
 
Shader "Custom/MultiLights"
{
	Properties
	{
		_Gloss("Gloss", Range(8.0,256)) = 20
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
	}
	SubShader
	{
		//Opaque: 用于大多数着色器（法线着色器、自发光着色器、反射着色器以及地形的着色器）。
		//Transparent : 用于半透明着色器（透明着色器、粒子着色器、字体着色器、地形额外通道的着色器）。
		//TransparentCutout : 蒙皮透明着色器（Transparent Cutout，两个通道的植被着色器）。
		//Background : Skybox shaders.天空盒着色器。
		//Overlay : GUITexture, Halo, Flare shaders.光晕着色器、闪光着色器
		Tags { "RenderType" = "Opaque" }
 
		//Base Pass
		Pass
		{
			//用于向前渲染，该Pass会计算环境光，最重要的平行光，逐顶点/SH光源和LightMaps
			Tags{"LightMode" = "ForwardBase"}
 
			CGPROGRAM
 
			#pragma vertex vert
			#pragma fragment frag
			//multi_compile_fwdbase指令可以保证我们在shader中使用光照衰减等光照变量可以被正确赋值
			#pragma multi_compile_fwdbase
			#include "Lighting.cginc"
 
			float _Gloss;
			float4 _Diffuse;
			float4 _Specular;
 
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
 
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
			};
 
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}
 
			fixed4 frag(v2f i) : SV_Target
			{
				//获取世界空间下的法线的单位向量
				fixed3 worldNormal = normalize(i.worldNormal);
				//获取世界空间下的光照方向的单位向量
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				//获取世界空间下的视角方向的单位向量
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				//获取环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//漫反射光的计算公式
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));
				//环境光的计算公式
				fixed3 halfDir = normalize(worldLightDir + worldViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
 
				//平行光的距离永远为1,不存在光照衰减
				float atten = 1.0;
 
				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}
			ENDCG
		}
 
		//Addtional Pass
		Pass
		{
			//用于向前渲染，该模式代表除场景中最重要的平行光之外的额外光源的处理，每个光源会调用该pass一次
			Tags{"LightMode" = "ForwardAdd"}
 
			//混合模式，表示该Pass计算的光照结果可以在帧缓存中与之前的光照结果进行叠加，否则会覆盖之前的光照结果
			Blend One One
 
			CGPROGRAM
 
			#pragma vertex vert
			#pragma fragment frag
			//multi_compile_fwdadd指令可以保证我们在shader中使用光照衰减等光照变量可以被正确赋值
			#pragma multi_compile_fwdadd
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
 
			float _Gloss;
			float4 _Diffuse;
			float4 _Specular;
 
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
 
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
			};
 
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}
 
			fixed4 frag(v2f i) : SV_Target
			{
				//获取世界空间下的法线的单位向量
				fixed3 worldNormal = normalize(i.worldNormal);
				//获取世界空间下的视角方向的单位向量
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
 
				#ifdef USING_DIRECTIONAL_LIGHT  //平行光下可以直接获取世界空间下的光照方向
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else  //其他光源下_WorldSpaceLightPos0代表光源的世界坐标，与顶点的世界坐标的向量相减可得到世界空间下的光照方向
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif
 
				//漫反射光的计算公式
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));
 
				//环境光的计算公式
				fixed3 halfDir = normalize(worldLightDir + worldViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
 
				/*这段ifelse的代码可以直接使用unity内置宏UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				  但是该结果表示光照衰减和该物体接收来自其他物体的阴影纹理的效果，阴影在下一章节有讲。
				*/
				#ifdef USING_DIRECTIONAL_LIGHT  //平行光下不存在光照衰减，恒值为1
					fixed atten = 1.0;
				#else
					#if defined (POINT)    //点光源的光照衰减计算
						//unity_WorldToLight内置矩阵，世界空间到光源空间变换矩阵。与顶点的世界坐标相乘可得到光源空间下的顶点坐标
						float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
						//利用Unity内置函数tex2D对Unity内置纹理_LightTexture0进行纹理采样计算光源衰减，获取其衰减纹理，
						//再通过UNITY_ATTEN_CHANNEL得到衰减纹理中衰减值所在的分量，以得到最终的衰减值
						fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
					#elif defined (SPOT)   //聚光灯的光照衰减计算
						float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
						//(lightCoord.z > 0)：聚光灯的深度值小于等于0时，则光照衰减为0
						//_LightTextureB0：如果该光源使用了cookie，则衰减查找纹理则为_LightTextureB0
					fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
					#else
						fixed atten = 1.0;
					#endif
				#endif
 
				//这里不再计算环境光，在上个Base Pass中已做计算
				return fixed4((diffuse + specular) * atten, 1.0);
			}
				ENDCG
		}
	}
		FallBack "Diffuse"
}