// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "RRF_HumanShaders/EyeShaders/EyeShader_Model1"
{
	Properties
	{
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		[NoScaleOffset]_EyeExtras("EyeExtras", 2D) = "white" {}
		[NoScaleOffset]_IrisExtraDetail("IrisExtraDetail", 2D) = "white" {}
		[NoScaleOffset]_NormalMapBase("NormalMapBase", 2D) = "bump" {}
		_EyeBallColorGlossA("EyeBallColor-Gloss(A)", Color) = (1,1,1,0.853)
		_IrisColorCausticLerpA("IrisColor-CausticLerp(A)", Color) = (0.4482759,1,0,0)
		_IrisExtraColorAmountA("IrisExtraColor-Amount(A)", Color) = (0.08088237,0.07573904,0.04698314,0.591)
		_RingColorAmount("RingColor-Amount", Color) = (0,0,0,0)
		_EyeSize("EyeSize", Range( 0 , 2)) = 1
		_IrisSize("IrisSize", Range( 0 , 10)) = 1
		_IrisGlow("IrisGlow", Range( 0 , 10)) = 0
		_LensGloss("LensGloss", Range( 0 , 1)) = 0.98
		_LensPush("LensPush", Range( 0 , 1)) = 0.64
		_CausticPower("CausticPower", Range( 0 , 5)) = 0.3
		_CausticOffset("CausticOffset", Range( 0 , 5)) = 1
		_CausticScale("CausticScale", Range( 0 , 5)) = 1
		_PupilSize("PupilSize", Range( 0.001 , 89)) = 70
		_PupilHeight1Width1("Pupil Height>1/Width<1", Range( 0.01 , 10)) = 1
		_PupilSharpness("PupilSharpness", Range( 0.1 , 5)) = 5
		_Veins("Veins", Range( 0 , 1)) = 0
		_BoostEyeWhite("BoostEyeWhite", Range( 1 , 2)) = 1
		_GlobalEmissive("GlobalEmissive", Range( 0 , 2)) = 0.5
		_PupilParallaxHeight("PupilParallaxHeight", Range( -4 , 8)) = 1.4
		_ParalaxH("ParalaxH", Float) = -0.2
		_SSS("SSS", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			INTERNAL_DATA
			float3 worldPos;
			float3 worldNormal;
		};

		struct SurfaceOutputStandardCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Translucency;
		};

		uniform sampler2D _NormalMapBase;
		uniform float _EyeSize;
		uniform float _LensPush;
		uniform float _BoostEyeWhite;
		uniform sampler2D _EyeExtras;
		uniform half _PupilSize;
		uniform float _PupilHeight1Width1;
		uniform float _ParalaxH;
		uniform float _PupilParallaxHeight;
		uniform float _PupilSharpness;
		uniform float4 _EyeBallColorGlossA;
		uniform float _CausticPower;
		uniform float _CausticScale;
		uniform float _CausticOffset;
		uniform float4 _IrisColorCausticLerpA;
		uniform float4 _RingColorAmount;
		uniform float _Veins;
		uniform sampler2D _IrisExtraDetail;
		uniform float _IrisSize;
		uniform float4 _IrisExtraColorAmountA;
		uniform float _IrisGlow;
		uniform float _GlobalEmissive;
		uniform float _LensGloss;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;
		uniform float _SSS;

		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			#if !DIRECTIONAL
			float3 lightAtten = gi.light.color;
			#else
			float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, _TransShadow );
			#endif
			half3 lightDir = gi.light.dir + s.Normal * _TransNormalDistortion;
			half transVdotL = pow( saturate( dot( viewDir, -lightDir ) ), _TransScattering );
			half3 translucency = lightAtten * (transVdotL * _TransDirect + gi.indirect.diffuse * _TransAmbient) * s.Translucency;
			half4 c = half4( s.Albedo * translucency * _Translucency, 0 );

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + c;
		}

		inline void LightingStandardCustom_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			float2 temp_cast_0 = (_EyeSize).xx;
			float2 temp_cast_1 = (( ( 1.0 - _EyeSize ) / 2.0 )).xx;
			float2 uv_TexCoord264 = i.uv_texcoord * temp_cast_0 + temp_cast_1;
			float3 lerpResult139 = lerp( float3(0,0,1) , UnpackNormal( tex2D( _NormalMapBase, uv_TexCoord264 ) ) , _LensPush);
			o.Normal = lerpResult139;
			float4 tex2DNode166 = tex2D( _EyeExtras, uv_TexCoord264 );
			float temp_output_151_0 = ( 100.0 - _PupilSize );
			float2 appendResult149 = (float2(( temp_output_151_0 / 2.0 ) , ( temp_output_151_0 / ( _PupilHeight1Width1 * 2.0 ) )));
			float4 appendResult152 = (float4(temp_output_151_0 , ( temp_output_151_0 / _PupilHeight1Width1 ) , 0.0 , 0.0));
			float2 paralaxOffset255 = ParallaxOffset( _ParalaxH , _PupilParallaxHeight , i.viewDir );
			float2 uv_TexCoord147 = i.uv_texcoord * appendResult152.xy + paralaxOffset255;
			float clampResult122 = clamp( ( pow( distance( appendResult149 , uv_TexCoord147 ) , ( _PupilSharpness * 7.0 ) ) + ( 1.0 - tex2DNode166.b ) ) , 0.0 , 1.0 );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float dotResult226 = dot( reflect( ase_worldlightDir , ase_worldViewDir ) , ase_vertexNormal );
			float clampResult229 = clamp( (dotResult226*_CausticScale + _CausticOffset) , 0.0 , 1.0 );
			float clampResult232 = clamp( ( _CausticPower * clampResult229 ) , 0.0 , 1.0 );
			float4 lerpResult291 = lerp( ( clampResult232 * _IrisColorCausticLerpA ) , _IrisColorCausticLerpA , _IrisColorCausticLerpA.a);
			float4 lerpResult127 = lerp( _EyeBallColorGlossA , ( tex2DNode166.b * lerpResult291 ) , tex2DNode166.b);
			float4 lerpResult184 = lerp( lerpResult127 , ( _RingColorAmount * tex2DNode166.r ) , ( _RingColorAmount.a * tex2DNode166.r ));
			float4 color170 = IsGammaSpace() ? float4(0.375,0,0,0) : float4(0.1160161,0,0,0);
			float4 lerpResult177 = lerp( lerpResult184 , ( color170 * tex2DNode166.g ) , ( _Veins * tex2DNode166.g ));
			float2 temp_cast_3 = (_IrisSize).xx;
			float2 uv_TexCoord190 = i.uv_texcoord * temp_cast_3 + ( ( paralaxOffset255 * float2( 0.1,0.1 ) ) + ( ( 1.0 - _IrisSize ) / 2.0 ) );
			float4 tex2DNode185 = tex2D( _IrisExtraDetail, uv_TexCoord190 );
			float4 temp_output_212_0 = ( tex2DNode185 * ( _IrisExtraColorAmountA.a * 2.0 ) * tex2DNode166.b );
			float4 lerpResult211 = lerp( lerpResult177 , ( ( tex2DNode185 * _IrisExtraColorAmountA ) + ( temp_output_212_0 * clampResult232 ) ) , temp_output_212_0);
			float4 temp_output_103_0 = ( clampResult122 * lerpResult184 * lerpResult211 );
			float4 temp_output_216_0 = ( _BoostEyeWhite * ( 1.0 - tex2DNode166.b ) * temp_output_103_0 );
			o.Albedo = temp_output_216_0.rgb;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 clampResult51 = clamp( ( tex2DNode166.b * clampResult232 * float4( ase_lightColor.rgb , 0.0 ) * ase_lightColor.a * temp_output_103_0 ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 lerpResult160 = lerp( clampResult51 , ( _IrisGlow * temp_output_103_0 * pow( tex2DNode166.b , 3.0 ) ) , ( _IrisGlow / 10.0 ));
			o.Emission = ( ( temp_output_216_0 + lerpResult160 ) * _GlobalEmissive ).rgb;
			float lerpResult135 = lerp( _EyeBallColorGlossA.a , ( tex2DNode166.b * _LensGloss ) , tex2DNode166.b);
			o.Smoothness = lerpResult135;
			float3 temp_cast_7 = (_SSS).xxx;
			o.Translucency = temp_cast_7;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustom keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandardCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16204
7;236;1906;807;3021.416;2815.73;6.239728;True;True
Node;AmplifyShaderEditor.CommentaryNode;219;-456.8235,203.5645;Float;False;2546.831;732.6423;IrisConeCaustics;15;232;231;229;227;226;225;224;223;220;50;290;291;221;222;126;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;221;-422.1765,429.9774;Float;True;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;220;-425.0949,270.5084;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ReflectOpNode;223;-79.0856,298.3011;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;222;-393.1745,669.2433;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;226;184.3642,360.0952;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;225;-5.398302,587.6693;Float;False;Property;_CausticScale;CausticScale;21;0;Create;True;0;0;False;0;1;2.5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;224;4.006065,718.6566;Float;False;Property;_CausticOffset;CausticOffset;20;0;Create;True;0;0;False;0;1;2.18;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;298;-205.7515,-1779.411;Float;False;1316.846;355.723;Parralax;4;257;256;259;255;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;227;368.1605,488.9672;Float;False;3;0;FLOAT;0;False;1;FLOAT;1.54;False;2;FLOAT;1.62;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;299;-1235.127,-257.868;Float;False;1546.065;389.3438;Size and RGB control;5;266;265;264;166;267;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;168;463.7572,-851.6978;Float;False;803.1489;1005.685;Inputs;9;133;158;20;170;179;182;183;247;249;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;267;-1185.127,-207.868;Float;False;Property;_EyeSize;EyeSize;14;0;Create;True;0;0;False;0;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;980.6463,470.0244;Float;False;Property;_CausticPower;CausticPower;19;0;Create;True;0;0;False;0;0.3;2.24;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;229;754.3712,495.7002;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;256;-155.7515,-1607.688;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;257;481.1172,-1647.115;Float;False;Property;_PupilParallaxHeight;PupilParallaxHeight;28;0;Create;True;0;0;False;0;1.4;0;-4;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;247;486.2794,-246.3401;Float;False;Property;_IrisSize;IrisSize;15;0;Create;True;0;0;False;0;1;5.75;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;164;379.8337,-1375.361;Float;False;2247.17;550.2261;Pupil;16;91;151;156;153;157;148;154;152;149;147;146;155;213;214;285;286;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;259;539.9,-1729.411;Float;False;Property;_ParalaxH;ParalaxH;29;0;Create;True;0;0;False;0;-0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;266;-890.6987,-66.62741;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;231;1360.488,253.4962;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;218;1286.445,-840.8356;Float;False;1193.157;961.5587;IrisFunk;16;125;190;127;185;180;187;210;184;175;177;212;251;261;250;283;284;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ParallaxOffsetHlpNode;255;895.0944,-1641.001;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;249;1000.997,-337.0559;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;429.8337,-1268.59;Half;False;Property;_PupilSize;PupilSize;22;0;Create;True;0;0;False;0;70;11.1;0.001;89;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;232;1605.908,348.4679;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;284;1392.947,-482.0075;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.1,0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;156;446.8543,-987.0623;Float;False;Property;_PupilHeight1Width1;Pupil Height>1/Width<1;23;0;Create;True;0;0;False;0;1;6.21;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;250;1192.376,-329.3226;Float;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;151;784.7245,-1289.568;Float;False;2;0;FLOAT;100;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;126;312.4452,261.8859;Float;False;Property;_IrisColorCausticLerpA;IrisColor-CausticLerp(A);11;0;Create;True;0;0;False;0;0.4482759,1,0,0;1,0.8068966,0,0.934;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;265;-662.8491,-72.2561;Float;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;264;-374.8492,-120.2561;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;6,6;False;1;FLOAT2;-2.5,-2.5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;153;1037.148,-1256.788;Float;False;2;0;FLOAT;2;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;805.5457,-959.7744;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;283;1375.066,-390.3073;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;290;1008.214,360.8691;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;166;-10.0615,-98.52415;Float;True;Property;_EyeExtras;EyeExtras;7;1;[NoScaleOffset];Create;True;0;0;False;0;d0431c3a16ed8b54c8d648bb79ca09a5;d0431c3a16ed8b54c8d648bb79ca09a5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;291;776.5474,239.524;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;148;1111.045,-1115.693;Float;False;2;0;FLOAT;2;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;190;1518.348,-321.9586;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;6,6;False;1;FLOAT2;-2.5,-2.5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;154;1148.628,-958.1364;Float;False;2;0;FLOAT;2;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;152;1199.614,-1316.963;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;187;1470.249,-97.25425;Float;False;Property;_IrisExtraColorAmountA;IrisExtraColor-Amount(A);12;0;Create;True;0;0;False;0;0.08088237,0.07573904,0.04698314,0.591;1,0.7993914,0.3676471,0.803;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;147;1446.926,-1352.734;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;1294.371,-580.3928;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;185;1762.989,-349.6219;Float;True;Property;_IrisExtraDetail;IrisExtraDetail;8;1;[NoScaleOffset];Create;True;0;0;False;0;7b7c97e104d9817418725e17f5ca2659;7b7c97e104d9817418725e17f5ca2659;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;251;1973.598,-8.451658;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;213;1648.015,-962.9574;Float;False;Property;_PupilSharpness;PupilSharpness;24;0;Create;True;0;0;False;0;5;0.43;0.1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;133;548.1866,-797.3047;Float;False;Property;_EyeBallColorGlossA;EyeBallColor-Gloss(A);10;0;Create;True;0;0;False;0;1,1,1,0.853;0.9287465,0.9779412,0.7550281,0.891;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;149;1384.686,-1059.491;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;182;841.4723,-756.5477;Float;False;Property;_RingColorAmount;RingColor-Amount;13;0;Create;True;0;0;False;0;0,0,0,0;0.7573529,0.1280817,0.1280817,0.684;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;261;1362.131,-706.0457;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;1159.741,-694.2678;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;179;763.1091,-175.6612;Float;False;Property;_Veins;Veins;25;0;Create;True;0;0;False;0;0;0.734;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;127;1541.502,-790.8356;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;212;2269.312,-104.9449;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;170;524.4473,-617.8412;Float;False;Constant;_EyeVeinColorAmountA;EyeVeinColor-Amount(A);12;0;Create;True;0;0;False;0;0.375,0,0,0;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;169;2513.791,-819.8705;Float;False;2125.866;921.7941;Mixing;16;159;160;161;51;18;26;134;135;103;181;215;217;211;246;245;216;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;214;1946.015,-953.9571;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;7;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;146;1746.54,-1220.662;Float;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;285;2333.083,-909.7061;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;155;2066.258,-1227.059;Float;True;2;0;FLOAT;0;False;1;FLOAT;12;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;210;2150.731,-383.4299;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;1878.082,-587.0409;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;184;1859.063,-780.4681;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;1882.64,-481.08;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;246;2547.968,-408.5809;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;177;2241.192,-641.3635;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;245;2747.727,-569.4694;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;286;2508.24,-1109.957;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;211;3019.525,-652.8688;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;122;2714.136,-951.641;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;26;2615.167,-41.84431;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;3378.247,-731.1182;Float;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;181;3383.324,-399.1982;Float;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;158;803.1615,-84.68832;Float;False;Property;_IrisGlow;IrisGlow;16;0;Create;True;0;0;False;0;0;7.79;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;3736.22,-91.6116;Float;False;5;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;215;3667.23,-740.4073;Float;False;Property;_BoostEyeWhite;BoostEyeWhite;26;0;Create;True;0;0;False;0;1;1.01;1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;161;4083.307,-338.9263;Float;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;51;4145.942,-161.2845;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;217;3740.518,-592.8753;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;4083.297,-474.6382;Float;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;160;4433.033,-329.2557;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;167;3144.018,-1401.414;Float;False;836.5276;442.498;FakewLens;4;138;141;139;140;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;20;824.8633,36.09259;Float;False;Property;_LensGloss;LensGloss;17;0;Create;True;0;0;False;0;0.98;0.652;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;216;4377.033,-700.0588;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;138;3194.018,-1284.083;Float;True;Property;_NormalMapBase;NormalMapBase;9;1;[NoScaleOffset];Create;True;0;0;False;0;8ee6d0418eaa08e40ad667b400177c1c;8ee6d0418eaa08e40ad667b400177c1c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;140;3533.887,-1351.414;Float;False;Constant;_Vector0;Vector 0;10;0;Create;True;0;0;False;0;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;3364.983,-282.8188;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;141;3194.092,-1079.333;Float;False;Property;_LensPush;LensPush;18;0;Create;True;0;0;False;0;0.64;0.426;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;252;4778.718,-346.1298;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;254;4657.472,-41.69465;Float;False;Property;_GlobalEmissive;GlobalEmissive;27;0;Create;True;0;0;False;0;0.5;0.1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;139;3796.54,-1114.917;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;135;3399.614,-182.554;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;253;5009.6,-183.0875;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;288;4746.598,50.94391;Float;False;Property;_SSS;SSS;30;0;Create;True;0;0;False;0;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;5798.091,-204.7162;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;RRF_HumanShaders/EyeShaders/EyeShader_Model1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;0;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;223;0;220;0
WireConnection;223;1;221;0
WireConnection;226;0;223;0
WireConnection;226;1;222;0
WireConnection;227;0;226;0
WireConnection;227;1;225;0
WireConnection;227;2;224;0
WireConnection;229;0;227;0
WireConnection;266;0;267;0
WireConnection;231;0;50;0
WireConnection;231;1;229;0
WireConnection;255;0;259;0
WireConnection;255;1;257;0
WireConnection;255;2;256;0
WireConnection;249;0;247;0
WireConnection;232;0;231;0
WireConnection;284;0;255;0
WireConnection;250;0;249;0
WireConnection;151;1;91;0
WireConnection;265;0;266;0
WireConnection;264;0;267;0
WireConnection;264;1;265;0
WireConnection;153;0;151;0
WireConnection;153;1;156;0
WireConnection;157;0;156;0
WireConnection;283;0;284;0
WireConnection;283;1;250;0
WireConnection;290;0;232;0
WireConnection;290;1;126;0
WireConnection;166;1;264;0
WireConnection;291;0;290;0
WireConnection;291;1;126;0
WireConnection;291;2;126;4
WireConnection;148;0;151;0
WireConnection;190;0;247;0
WireConnection;190;1;283;0
WireConnection;154;0;151;0
WireConnection;154;1;157;0
WireConnection;152;0;151;0
WireConnection;152;1;153;0
WireConnection;147;0;152;0
WireConnection;147;1;255;0
WireConnection;125;0;166;3
WireConnection;125;1;291;0
WireConnection;185;1;190;0
WireConnection;251;0;187;4
WireConnection;149;0;148;0
WireConnection;149;1;154;0
WireConnection;261;0;182;4
WireConnection;261;1;166;1
WireConnection;183;0;182;0
WireConnection;183;1;166;1
WireConnection;127;0;133;0
WireConnection;127;1;125;0
WireConnection;127;2;166;3
WireConnection;212;0;185;0
WireConnection;212;1;251;0
WireConnection;212;2;166;3
WireConnection;214;0;213;0
WireConnection;146;0;149;0
WireConnection;146;1;147;0
WireConnection;285;0;166;3
WireConnection;155;0;146;0
WireConnection;155;1;214;0
WireConnection;210;0;185;0
WireConnection;210;1;187;0
WireConnection;175;0;170;0
WireConnection;175;1;166;2
WireConnection;184;0;127;0
WireConnection;184;1;183;0
WireConnection;184;2;261;0
WireConnection;180;0;179;0
WireConnection;180;1;166;2
WireConnection;246;0;212;0
WireConnection;246;1;232;0
WireConnection;177;0;184;0
WireConnection;177;1;175;0
WireConnection;177;2;180;0
WireConnection;245;0;210;0
WireConnection;245;1;246;0
WireConnection;286;0;155;0
WireConnection;286;1;285;0
WireConnection;211;0;177;0
WireConnection;211;1;245;0
WireConnection;211;2;212;0
WireConnection;122;0;286;0
WireConnection;103;0;122;0
WireConnection;103;1;184;0
WireConnection;103;2;211;0
WireConnection;181;0;166;3
WireConnection;18;0;166;3
WireConnection;18;1;232;0
WireConnection;18;2;26;1
WireConnection;18;3;26;2
WireConnection;18;4;103;0
WireConnection;161;0;158;0
WireConnection;51;0;18;0
WireConnection;217;0;166;3
WireConnection;159;0;158;0
WireConnection;159;1;103;0
WireConnection;159;2;181;0
WireConnection;160;0;51;0
WireConnection;160;1;159;0
WireConnection;160;2;161;0
WireConnection;216;0;215;0
WireConnection;216;1;217;0
WireConnection;216;2;103;0
WireConnection;138;1;264;0
WireConnection;134;0;166;3
WireConnection;134;1;20;0
WireConnection;252;0;216;0
WireConnection;252;1;160;0
WireConnection;139;0;140;0
WireConnection;139;1;138;0
WireConnection;139;2;141;0
WireConnection;135;0;133;4
WireConnection;135;1;134;0
WireConnection;135;2;166;3
WireConnection;253;0;252;0
WireConnection;253;1;254;0
WireConnection;0;0;216;0
WireConnection;0;1;139;0
WireConnection;0;2;253;0
WireConnection;0;4;135;0
WireConnection;0;7;288;0
ASEEND*/
//CHKSM=5C2221BF3D4F212DD27ACFE5864AECE0166D2C12