#pragma target 3.0

#include "Lighting.cginc"
#include "UnityCG.cginc"

struct v2f
{
    float4 pos: SV_POSITION;
    half4 uv: TEXCOORD0;
    float3 worldNormal: TEXCOORD1;
    float3 worldPos: TEXCOORD2;    
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


sampler2D _LayerTex;
half4 _LayerTex_ST;

sampler2D _LayerTexColor;
half4 _LayerTexColor_ST;

fixed _FurLength;
fixed _FurAlpha;

fixed _FurDensity;
fixed _FurThinness;
fixed _FurShading;

fixed4 _Gravity;
fixed _GravityStrength;

fixed4 _RimColor;
half _RimPower;

v2f vert_surface(appdata_base v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _FurColorTex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

    return o;
}

v2f vert_base(appdata_base v)
{
    v2f o;

    half3 direction = lerp(v.normal, _Gravity * _GravityStrength + v.normal * (1 - _GravityStrength), FURSTEP);
	float3 P =  direction * _FurLength * FURSTEP;
    // add mask calculate. 
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _FurColorTex); 
    o.uv.zw = TRANSFORM_TEX(v.texcoord, _LayerTex);

    float4 mask = tex2Dlod(_MaskTex,float4(o.uv.xy,0,0));    

    P =  v.vertex.xyz + P * mask.r;
    
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.pos = UnityObjectToClipPos(float4(P, 1.0));
    
    // o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
    

    
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

    return o;
}

fixed4 frag_surface(v2f i): SV_Target
{
    
    fixed3 worldNormal = normalize(i.worldNormal);
    fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
    fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
    fixed3 worldHalf = normalize(worldView + worldLight);
    
    // fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color;
    fixed3 albedo = _Color; // 表皮值包含固有色
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
    fixed3 albedo = tex2D(_FurColorTex, i.uv.xy).rgb * _FurColor;
    albedo -= (pow(1 - FURSTEP, 3)) * _FurShading;
    half rim = 1.0 - saturate(dot(worldView, worldNormal));
    albedo += fixed4(_RimColor.rgb * pow(rim, _RimPower), 1.0);
    
    fixed3 noise = tex2D(_LayerTex, i.uv.zw * _FurThinness).rgb;
    fixed3 layerColor = tex2D(_LayerTexColor, i.uv.zw * _FurThinness).rgb;
    fixed3 noiseColor = layerColor*noise;
    albedo = lerp(albedo,albedo*noiseColor,noise.r);

    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
    fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLight));
    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, worldHalf)), _Shininess);
    
    fixed3 color = ambient + diffuse + specular;
    fixed alpha = clamp(noise - _FurAlpha- (FURSTEP * FURSTEP) * _FurDensity, 0, 1);
    
    return fixed4(color, alpha);
}