sampler2D _MainTex, 
_OcclusionMap, 
_SpecGlossMap,
_CavityMap,
_TransmissionMap,
_ProfileTex,
_SubsurfaceAlbedo,
_BumpMap, 
_DetailNormalMap,
LightingTexBlurred, 
LightingTexBlurredR,
_ScreenSpaceShadow;

half _Glossiness,
_AlbedoTile,
_OcclusionStrength,
_BumpTile,
_BumpScale,
_DetailNormalMapScale,
_DetailNormalMapTile,
SSS_shader,
_AlbedoOpacity,
_SubSurfaceParallax,
_SubsurfaceAlbedoOpacity,
_SubsurfaceAlbedoSaturation,
DynamicPassTransmission,
BasePassTransmission,
TransmissionShadows,
TransmissionOcc,
_CavityStrength,
TransmissionRange,
_FresnelIntensity;		
fixed4 _Color,_TransmissionColor, _OcclusionColor;
float4 //_SubsurfaceColor, 
_ProfileColor,
LightingTexBlurred_ST
;
int _DetailNormal;
#if defined (__INTELLISENSE__)
    #define ENABLE_DETAIL_NORMALMAP
    #endif
float3 BumpMap(float2 uv)
{
    float4 BaseNormalSample = tex2D(_BumpMap, uv * _BumpTile);
    float3 BaseNormal = UnpackScaleNormal(BaseNormalSample, _BumpScale);
    #ifdef ENABLE_DETAIL_NORMALMAP
    float4 DetailNormalSample = tex2D(_DetailNormalMap, uv * _DetailNormalMapTile);
    float3 DetailNormal = UnpackScaleNormal(DetailNormalSample, _DetailNormalMapScale);
     

    return BlendNormals(BaseNormal, DetailNormal);
    #else
    return BaseNormal;
    #endif
}

float Jimenez_SpecularOcclusion(float NdotV, float AO)
{
	float sAO = saturate(-0.3f + NdotV * NdotV);
	return lerp(pow(AO, 8.00f), 1.0f, sAO);
}

float3 WrappedDiffuse(half NdotL, half _Wrap)
{
	return saturate((NdotL + _Wrap) / ((1 + _Wrap) * (1 + _Wrap)));
}

float3 TransmissionDynamic(float3 color, float3 L, float3 N, float3 E, float NdotL, fixed atten)
{    
    color = 1.0 - exp(-color);
    half blV = saturate (dot(-E, (L + N))) * 2;
    half bnL = saturate (dot(N, -L ) * TransmissionRange + TransmissionRange);
    //bnL = bnL * (NdotL/* * 0.5 + 0.5*/);
    
    half3 light = bnL + blV;
    half3 Subsurface = color * light * 10;
    Subsurface /= 1.0 -  color;
	Subsurface = 1.0 - exp(-Subsurface);						
	Subsurface = Subsurface * light * lerp(1.0, atten, TransmissionShadows) * 10 * color * DynamicPassTransmission;
    return Subsurface;

}

#define BASE_TRANSMISSION \
fixed3 t = tex2D(_TransmissionMap, uv).rgb * lerp(1.0, Occlusion, TransmissionOcc) * _TransmissionColor.rgb;\
o.Transmission = t;\
Emission += t * ShadeSH9(float4(WorldNormalVector (IN, -o.Normal), 1.0)) * BasePassTransmission;\

#define BASE_TRANSMISSION_DEFERRED \
fixed3 t = tex2D(_TransmissionMap, uv).rgb * lerp(1.0, Occlusion, TransmissionOcc) * _TransmissionColor.rgb;\
/*o.Transmission = t;*/\
Emission += t * ShadeSH9(float4(WorldNormalVector (IN, -o.Normal), 1.0)) * BasePassTransmission;\

#define ADDITIVE_PASS_TRANSMISSION TransmissionDynamic(s.Transmission, lightDir, s.Normal, viewDir, NdotL, atten) * _LightColor0.rgb;

#define SSS_OCCLUSION \
half3 Occlusion = tex2D(_OcclusionMap, uv).rgb;\
half3 OcclusionColored = lerp(_OcclusionColor.rgb, 1.0, Occlusion.r);\
o.Occlusion = OcclusionColored;\

#define ALPHA_TEST \
clip(Albedo.a - _Cutoff);\