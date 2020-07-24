﻿#pragma target 3.0

#include "Lighting.cginc"
#include "UnityCG.cginc"

struct v2f
{
    float4 pos: SV_POSITION;
    half4 uv: TEXCOORD0;
    float3 worldNormal: TEXCOORD1;
    float3 worldPos: TEXCOORD2;
    float4 uv2: TEXCOORD3;
};

fixed4 _Color;

fixed4 _Specular;
half _Shininess;

// 毛皮固有色
sampler2D _MainTex;
half4 _MainTex_ST;

// 毛发遮罩
sampler2D _MaskTex;
half4 _MaskTex_ST;

// 毛发颜色
sampler2D _FurColorTex;
half4 _FurColorTex_ST;
fixed4 _FurColor;
fixed4 _FurColor2;

sampler2D _FurTex;
half4 _FurTex_ST;

fixed _FurLength;
fixed _FurAlpha;

fixed _FurDensity;
fixed _FurThinness;
fixed _FurShading;


float4 _ForceGlobal;
float4 _ForceLocal;



fixed4 _RimColor;
half _RimPower;

v2f vert_surface(appdata_base v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

    return o;
}

v2f vert_base(appdata_base v)
{
    v2f o;
    // float3 P = v.vertex.xyz + v.normal * _FurLength * FURSTEP;
    // P += clamp(mul(unity_WorldToObject, _ForceGlobal).xyz + _ForceLocal.xyz, -1, 1) * pow(FURSTEP, 3) * _FurLength;
    float3 P = v.vertex.xyz;
    float3 add1 = v.normal * _FurLength * FURSTEP; 
    float3 add2 = clamp(mul(unity_WorldToObject, _ForceGlobal).xyz + _ForceLocal.xyz, -1, 1) * pow(FURSTEP, 3) * _FurLength;
    // add2 = 0;
    // add mask calculate. 
    o.uv2.xy = TRANSFORM_TEX(v.texcoord, _MaskTex);
    o.uv2.zw = TRANSFORM_TEX(v.texcoord, _FurColorTex); 

    float4 mask = tex2Dlod(_MaskTex,float4(o.uv2.xy,0,0));    
    P = P + (add1 + add2) * mask.r;
    // P = P + (add1 + add2);
    
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    // float3 posY = v.normal*_FurDensityT*saturate(v.normal.y);
    // P = P + posY;
    o.pos = UnityObjectToClipPos(float4(P, 1.0));
    
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.uv.zw = TRANSFORM_TEX(v.texcoord, _FurTex);

    
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

    return o;
}

fixed4 frag_surface(v2f i): SV_Target
{
    
    fixed3 worldNormal = normalize(i.worldNormal);
    fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
    fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
    fixed3 worldHalf = normalize(worldView + worldLight);
    
    fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color;
    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
    fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLight));
    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, worldHalf)), _Shininess);

    fixed3 color = ambient + diffuse + specular;
    
    return fixed4(color, 1.0);
}

fixed4 frag_base(v2f i): SV_Target
{
    fixed3 worldNormal = normalize(i.worldNormal);
    fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
    fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
    fixed3 worldHalf = normalize(worldView + worldLight);

    // fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color;
    fixed3 albedo = tex2D(_FurColorTex, i.uv2.zw).rgb * _FurColor;
    albedo -= (pow(1 - FURSTEP, 3)) * _FurShading;
    half rim = 1.0 - saturate(dot(worldView, worldNormal));
    albedo += fixed4(_RimColor.rgb * pow(rim, _RimPower), 1.0);
    
    fixed3 noise = tex2D(_FurTex, i.uv.zw * _FurThinness).rgb;
    fixed3 noiseColor = _FurColor2*noise;
    albedo = lerp(albedo,albedo*noiseColor,noise.r);

    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
    fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLight));
    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, worldHalf)), _Shininess);

   
    
    
    fixed3 color = ambient + diffuse + specular;
    fixed alpha = clamp(noise - _FurAlpha- (FURSTEP * FURSTEP) * _FurDensity, 0, 1);
    
    return fixed4(color, alpha);
}