
#ifndef FUN_MAIN
#define FUN_MAIN



// #include "UnityStandardCore.cginc"


#include "FunDream_UnityStandardCore.cginc"
// #include "FunDream_UnityStandardBRDF.cginc"



//================================================================================================================================
// vertex Shader




//================================================================================================================================
//  UnityStandardCore.cginc
//  Fragment shaders sub-functions


//================================================================================================================================
// Replacement for UnityPBSLighting.cginc
// env lighting functions








inline half3 UnityGI_IndirectSpecular_FunDream(UnityGIInput data, half occlusion, Unity_GlossyEnvironmentData glossIn)
{
    half3 specular;

    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
        // we will tweak reflUVW in glossIn directly (as we pass it to Unity_GlossyEnvironment twice for probe0 and probe1), so keep original to pass into BoxProjectedCubemapDirection
        half3 originalReflUVW = glossIn.reflUVW;
        glossIn.reflUVW = BoxProjectedCubemapDirection (originalReflUVW, data.worldPos, data.probePosition[0], data.boxMin[0], data.boxMax[0]);
    #endif

    #ifdef _GLOSSYREFLECTIONS_OFF
        specular = unity_IndirectSpecColor.rgb;
    #else

		#ifdef _REFLECTIONMAP
			specular = lerp(0, Unity_GlossyEnvironment_FunDream(_ReflectionMap, _ReflectionMap_HDR, glossIn), _Brightness);
		#else
			specular = Unity_GlossyEnvironment (UNITY_PASS_TEXCUBE(unity_SpecCube0), data.probeHDR[0], glossIn);
		#endif

    #endif

    return specular * occlusion;
}

//================================================================================================================================
// macro for choosing BRDF function

// 这里强制使用最高品质的BRDF,如果注释，使用Unity进行选择，TODO:以后进行修改
#define TCP2_BRDF_PBS BRDF1_TCP2_PBS
//#define TCP2_BRDF_PBS BRDF2_TCP2_PBS
//#define TCP2_BRDF_PBS BRDF3_TCP2_PBS

// 不执行Unity的选择
#if !defined (TCP2_BRDF_PBS) // allow to explicitly override BRDF in custom shader
// still add safe net for low shader models, otherwise we might end up with shaders failing to compile
// the only exception is WebGL in 5.3 - it will be built with shader target 2.0 but we want it to get rid of constraints, as it is effectively desktop
	#if SHADER_TARGET < 30
		#define TCP2_BRDF_PBS BRDF3_TCP2_PBS
	#elif UNITY_PBS_USE_BRDF3
		#define TCP2_BRDF_PBS BRDF3_TCP2_PBS
	#elif UNITY_PBS_USE_BRDF2
		#define TCP2_BRDF_PBS BRDF2_TCP2_PBS
	#elif UNITY_PBS_USE_BRDF1
		#define TCP2_BRDF_PBS BRDF1_TCP2_PBS
	#elif defined(SHADER_TARGET_SURFACE_ANALYSIS)
		// we do preprocess pass during shader analysis and we dont actually care about brdf as we need only inputs/outputs
		#define TCP2_BRDF_PBS BRDF1_TCP2_PBS
	#else
		#error something broke in auto-choosing BRDF
	#endif
#endif

#ifndef TCP2_STANDARD_CORE_INCLUDED
#define TCP2_STANDARD_CORE_INCLUDED

#endif // TCP2_STANDARD_CORE_INCLUDED




//================================================================================================================================
//Entry functions 特殊功能Shader，调用这里,eg:hair,layer,multiTrasp等shader

// ---------vert-------------------------
// Billball Vert
VertexOutputForwardBase_FunDream vertBase_Billboard (VertexInput_FunDream v) 
{
	return vertForwardBase_Billboard_FunDream(v); 
}


// ---------frag-------------------------
half4 fragForwardBase_FunDream(VertexOutputForwardBase_FunDream i) : SV_Target		// backward compatibility (this used to be the fragment entry function)
{
	return fragForwardBaseInternal_FunDream(i);
}

half4 fragForwardAdd_FunDream(VertexOutputForwardAdd_FunDream i) : SV_Target		// backward compatibility (this used to be the fragment entry function)
{
	return fragForwardAddInternal_FunDream(i);
}

//================================================================================================================================
// Main functions ，目前Base Shader走这里

VertexOutputForwardBase_FunDream vertBase (VertexInput_FunDream v) { return vertForwardBase_FunDream(v); }
half4 fragBase (VertexOutputForwardBase_FunDream i) : SV_Target { return fragForwardBaseInternal_FunDream(i); }

VertexOutputForwardAdd_FunDream vertAdd (VertexInput_FunDream v) { return vertForwardAdd_FunDream(v); }
half4 fragAdd (VertexOutputForwardAdd_FunDream i) : SV_Target { return fragForwardAddInternal_FunDream(i); }


#endif // FUN_MAIN