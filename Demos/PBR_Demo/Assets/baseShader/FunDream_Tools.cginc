
half softLightMode(half b, half a) {
	half yes = 0.5 * a * b + b * b * (1 - 2 * a);
	half no = 0.5 * b * (1 - a) + sqrt(b) * (2 * a - 1);
	return (a <= 0.5) ? yes : no;

}


half random(half2 Seed, half2 seed2, half level, half Min, half Max)
{
	// simple version
	half randomno =  frac( sin( dot(Seed, seed2) ) * level );
	half outV = lerp(Min, Max, randomno);
	return outV;
}


fixed4 BlendColor_LayerBase(fixed4 srcCol, fixed4 outCol) {

	#if _LayerBase_Blend_Normal
		outCol.rgb = srcCol.rgb * srcCol.a + outCol.rgb * (1 - srcCol.a);
	#elif _LayerBase_Blend_Multiply
		outCol.rgb = lerp(outCol.rgb, srcCol.rgb * outCol.rgb, srcCol.a);
	#endif

	outCol.a += srcCol.a;
	return outCol;
}


fixed4 BlendColor_Layer2(fixed4 srcCol, fixed4 outCol) {

	#if _Layer2_Blend_Normal
		outCol.rgb = srcCol.rgb * srcCol.a + outCol.rgb * (1 - srcCol.a);
	#elif _Layer2_Blend_Multiply
		outCol.rgb = lerp(outCol.rgb, srcCol.rgb * outCol.rgb, srcCol.a);
	#endif

	outCol.a = saturate(outCol.a + srcCol.a);
	return outCol;
}


fixed4 BlendColor_Layer3(fixed4 srcCol, fixed4 outCol) {

#if _Layer3_Blend_Normal
	outCol.rgb = srcCol.rgb * srcCol.a + outCol.rgb * (1 - srcCol.a);
#elif _Layer3_Blend_Multiply
	outCol.rgb = lerp(outCol.rgb, srcCol.rgb * outCol.rgb, srcCol.a);
#endif

	outCol.a += srcCol.a;
	return outCol;
}


fixed4 BlendColor_Layer4(fixed4 srcCol, fixed4 outCol) {

#if _Layer4_Blend_Normal
	outCol.rgb = srcCol.rgb * srcCol.a + outCol.rgb * (1 - srcCol.a);
#elif _Layer4_Blend_Multiply
	outCol.rgb = lerp(outCol.rgb, srcCol.rgb * outCol.rgb, srcCol.a);
#endif

	outCol.a += srcCol.a;
	return outCol;
}


fixed4 BlendColor_Layer5(fixed4 srcCol, fixed4 outCol) {

#if _Layer5_Blend_Normal
	outCol.rgb = srcCol.rgb * srcCol.a + outCol.rgb * (1 - srcCol.a);
#elif _Layer5_Blend_Multiply
	outCol.rgb = lerp(outCol.rgb, srcCol.rgb * outCol.rgb, srcCol.a);
#endif

	outCol.a += srcCol.a;
	return outCol;
}


fixed4 BlendColor_Layer6(fixed4 srcCol, fixed4 outCol) {

#if _Layer6_Blend_Normal
	outCol.rgb = srcCol.rgb * srcCol.a + outCol.rgb * (1 - srcCol.a);
#elif _Layer6_Blend_Multiply
	outCol.rgb = lerp(outCol.rgb, srcCol.rgb * outCol.rgb, srcCol.a);
#endif

	outCol.a += srcCol.a;
	return outCol;
}



fixed4 BlendColor_Layer7(fixed4 srcCol, fixed4 outCol) {

#if _Layer7_Blend_Normal
	outCol.rgb = srcCol.rgb * srcCol.a + outCol.rgb * (1 - srcCol.a);
#elif _Layer7_Blend_Multiply
	outCol.rgb = lerp(outCol.rgb, srcCol.rgb * outCol.rgb, srcCol.a);
#endif

	outCol.a += srcCol.a;
	return outCol;
}


fixed4 BlendColor_LayerTop(fixed4 srcCol, fixed4 outCol) {

#if _LayerTop_Blend_Normal
	outCol.rgb = srcCol.rgb * srcCol.a + outCol.rgb * (1 - srcCol.a);
#elif _LayerTop_Blend_Multiply
	outCol.rgb = lerp(outCol.rgb, srcCol.rgb * outCol.rgb, srcCol.a);
#endif

	outCol.a += srcCol.a;
	return outCol;
}



half2 GetFlashTexcoord(half4 i_tex, half4 detailUV){
	#if _FlashUVSet_0
		return i_tex.xy;
	#elif _FlashUVSet_1
		return i_tex.zw;
	#elif _FlashUVSet_2
		return detailUV.xy;
	#elif _FlashUVSet_3
		return detailUV.zw;
	#else 
		return i_tex.xy;
	#endif
}



half2 GetLayerBaseTexcoord(half4 i_tex, half4 detailUV){
	#if _LayerBaseUVSet_0
		return i_tex.xy;
	#elif _LayerBaseUVSet_1
		return i_tex.zw;
	#elif _LayerBaseUVSet_2
		return detailUV.xy;
	#elif _LayerBaseUVSet_3
		return detailUV.zw;
	#else 
		return i_tex.xy;
	#endif
}


half2 GetLayer2Texcoord(half4 i_tex, half4 detailUV){
	#if _Layer2UVSet_0
		return i_tex.xy;
	#elif _Layer2UVSet_1
		return i_tex.zw;
	#elif _Layer2UVSet_2
		return detailUV.xy;
	#elif _Layer2UVSet_3
		return detailUV.zw;
	#else 
		return i_tex.xy;
	#endif
}


half2 GetLayer3Texcoord(half4 i_tex, half4 detailUV){
	#if _Layer3UVSet_0
		return i_tex.xy;
	#elif _Layer3UVSet_1
		return i_tex.zw;
	#elif _Layer3UVSet_2
		return detailUV.xy;
	#elif _Layer3UVSet_3
		return detailUV.zw;
	#else 
		return i_tex.xy;
	#endif
}


half2 GetLayer4Texcoord(half4 i_tex, half4 detailUV){
	#if _Layer4UVSet_0
		return i_tex.xy;
	#elif _Layer4UVSet_1
		return i_tex.zw;
	#elif _Layer4UVSet_2
		return detailUV.xy;
	#elif _Layer4UVSet_3
		return detailUV.zw;
	#else 
		return i_tex.xy;
	#endif
}


half2 GetLayer5Texcoord(half4 i_tex, half4 detailUV){
	#if _Layer5UVSet_0
		return i_tex.xy;
	#elif _Layer5UVSet_1
		return i_tex.zw;
	#elif _Layer5UVSet_2
		return detailUV.xy;
	#elif _Layer5UVSet_3
		return detailUV.zw;
	#else 
		return i_tex.xy;
	#endif
}


half2 GetLayer6Texcoord(half4 i_tex, half4 detailUV){
	#if _Layer6UVSet_0
		return i_tex.xy;
	#elif _Layer6UVSet_1
		return i_tex.zw;
	#elif _Layer6UVSet_2
		return detailUV.xy;
	#elif _Layer6UVSet_3
		return detailUV.zw;
	#else 
		return i_tex.xy;
	#endif
}


half2 GetLayer7Texcoord(half4 i_tex, half4 detailUV){
	#if _Layer7UVSet_0
		return i_tex.xy;
	#elif _Layer7UVSet_1
		return i_tex.zw;
	#elif _Layer7UVSet_2
		return detailUV.xy;
	#elif _Layer7UVSet_3
		return detailUV.zw;
	#else 
		return i_tex.xy;
	#endif
}


half2 GetLayerTopTexcoord(half4 i_tex, half4 detailUV){
	#if _LayerTopUVSet_0
		return i_tex.xy;
	#elif _LayerTopUVSet_1
		return i_tex.zw;
	#elif _LayerTopUVSet_2
		return detailUV.xy;
	#elif _LayerTopUVSet_3
		return detailUV.zw;
	#else 
		return i_tex.xy;
	#endif
}


// get layer mask
half GetLayerBaseMask(half2 layerBaseUV){
	#if  _MASKTEX
		return tex2D(_MaskTex, layerBaseUV).r;
	#else
		return 1;
	#endif
}


half GetLayer2Mask(half2 layer2UV){
	#if  _MASKTEX
		return tex2D(_MaskTex, layer2UV).r;
	#else
		return 1;
	#endif
}


half GetLayer3Mask(half2 layer3UV){
	#if  _MASKTEX
		return tex2D(_MaskTex, layer3UV).g;
	#else
		return 1;
	#endif
}


half GetLayer4Mask(half2 layer4UV){
	#if  _MASKTEX
		return tex2D(_MaskTex, layer4UV).g;
	#else
		return 1;
	#endif
}

half GetLayer5Mask(half2 layer5UV){
	#if  _MASKTEX
		return tex2D(_MaskTex, layer5UV).b;
	#else
		return 1;
	#endif
}

half GetLayer6Mask(half2 layer6UV){
	#if  _MASKTEX
		return tex2D(_MaskTex, layer6UV).b;
	#else
		return 1;
	#endif
}

half GetLayer7Mask(half2 layer7UV){
	#if  _MASKTEX
		return tex2D(_MaskTex, layer7UV).a;
	#else
		return 1;
	#endif
}

half GetLayerTopMask(half2 layerTopUV){
	#if  _MASKTEX
		return tex2D(_MaskTex, layerTopUV).a;
	#else
		return 1;
	#endif
}