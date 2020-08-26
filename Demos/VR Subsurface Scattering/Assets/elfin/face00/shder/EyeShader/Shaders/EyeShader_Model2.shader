// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "RRF_HumanShaders/EyeShaders/EyeShader_Model2"
{
	Properties
	{
		[NoScaleOffset]_IrisExtraDetail("IrisExtraDetail", 2D) = "white" {}
		[NoScaleOffset]_CustomPupil("CustomPupil", 2D) = "white" {}
		[NoScaleOffset]_EyeExtrasMask("EyeExtrasMask", 2D) = "white" {}
		[NoScaleOffset]_NormalMapBase("NormalMapBase", 2D) = "bump" {}
		_EyeBallColorGlossA("EyeBallColor-Gloss(A)", Color) = (1,1,1,0.878)
		_IrisBaseColor("IrisBaseColor", Color) = (0.8161765,0.4123098,0.1020221,0)
		_IrisExtraColorAmountA("IrisExtraColor-Amount(A)", Color) = (0.1470588,0.1024192,0.06812285,0.441)
		_EyeVeinColorAmountA("EyeVeinColor-Amount(A)", Color) = (0.375,0,0,0)
		_RingColorAmountA("RingColor-Amount(A)", Color) = (0,0,0,0)
		_IrisGlow("IrisGlow", Range( 0 , 10)) = 0
		_LensGloss("LensGloss", Range( 0 , 1)) = 0.98
		_LensPush("LensPush", Range( 0 , 1)) = 0.64
		_CausticPower("CausticPower", Range( 0 , 1)) = 0.3
		_CausticOffset("CausticOffset", Range( 0 , 5)) = 1
		_CausticScale("CausticScale", Range( 0 , 5)) = 1
		_IrisSize("IrisSize", Range( -20 , 20)) = 4.4
		_IrisRotateSpeed("IrisRotateSpeed", Range( -4 , 4)) = 0
		_PupilSize("PupilSize", Range( 0.001 , 89)) = 70
		_PupilHeight1Width1("Pupil Height>1/Width<1", Range( 0.01 , 10)) = 1
		_PupilSharpness("PupilSharpness", Range( 0.1 , 5)) = 5
		_BoostEyeWhite("BoostEyeWhite", Range( 1 , 2)) = 1
		[Toggle]_UseCustomPupil("UseCustomPupil?", Float) = 1
		[Toggle]_InvertCustomPupil("InvertCustomPupil?", Float) = 1
		_CustomPupilRotateSpeed("CustomPupilRotateSpeed", Range( -4 , 4)) = 0
		_PupilParallaxHeight("PupilParallaxHeight", Range( -4 , 8)) = 1.4
		_ParalaxH("ParalaxH", Float) = -0.2
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

		uniform sampler2D _NormalMapBase;
		uniform float _LensPush;
		uniform float _BoostEyeWhite;
		uniform sampler2D _EyeExtrasMask;
		uniform float _UseCustomPupil;
		uniform half _PupilSize;
		uniform float _PupilHeight1Width1;
		uniform float _ParalaxH;
		uniform float _PupilParallaxHeight;
		uniform float _PupilSharpness;
		uniform float _InvertCustomPupil;
		uniform sampler2D _CustomPupil;
		uniform float _CustomPupilRotateSpeed;
		uniform float4 _EyeBallColorGlossA;
		uniform float4 _EyeVeinColorAmountA;
		uniform float4 _IrisBaseColor;
		uniform sampler2D _IrisExtraDetail;
		uniform float _IrisSize;
		uniform float _IrisRotateSpeed;
		uniform float4 _IrisExtraColorAmountA;
		uniform float _CausticPower;
		uniform float _CausticScale;
		uniform float _CausticOffset;
		uniform float4 _RingColorAmountA;
		uniform float _IrisGlow;
		uniform float _LensGloss;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMapBase138 = i.uv_texcoord;
			float3 lerpResult139 = lerp( float3(0,0,1) , UnpackNormal( tex2D( _NormalMapBase, uv_NormalMapBase138 ) ) , _LensPush);
			o.Normal = lerpResult139;
			float2 uv_EyeExtrasMask166 = i.uv_texcoord;
			float4 tex2DNode166 = tex2D( _EyeExtrasMask, uv_EyeExtrasMask166 );
			float temp_output_151_0 = ( 100.0 - _PupilSize );
			float2 appendResult149 = (float2(( temp_output_151_0 / 2.0 ) , ( temp_output_151_0 / ( _PupilHeight1Width1 * 2.0 ) )));
			float4 appendResult152 = (float4(temp_output_151_0 , ( temp_output_151_0 / _PupilHeight1Width1 ) , 0.0 , 0.0));
			float2 paralaxOffset376 = ParallaxOffset( _ParalaxH , _PupilParallaxHeight , i.viewDir );
			float2 uv_TexCoord147 = i.uv_texcoord * appendResult152.xy + paralaxOffset376;
			float clampResult122 = clamp( pow( distance( appendResult149 , uv_TexCoord147 ) , ( _PupilSharpness * 7.0 ) ) , 0.0 , 1.0 );
			float4 temp_cast_1 = (clampResult122).xxxx;
			float temp_output_269_0 = ( 10.0 - (-20.0 + (_PupilSize - 0.0) * (20.0 - -20.0) / (84.0 - 0.0)) );
			float2 temp_cast_2 = (temp_output_269_0).xx;
			float2 temp_cast_3 = (( ( 1.0 - temp_output_269_0 ) / 2.0 )).xx;
			float2 uv_TexCoord267 = i.uv_texcoord * temp_cast_2 + temp_cast_3;
			float mulTime278 = _Time.y * _CustomPupilRotateSpeed;
			float cos274 = cos( mulTime278 );
			float sin274 = sin( mulTime278 );
			float2 rotator274 = mul( uv_TexCoord267 - float2( 0.5,0.5 ) , float2x2( cos274 , -sin274 , sin274 , cos274 )) + float2( 0.5,0.5 );
			float4 tex2DNode265 = tex2D( _CustomPupil, rotator274 );
			float4 temp_cast_4 = (_PupilSharpness).xxxx;
			float4 clampResult281 = clamp( pow( ( lerp(tex2DNode265,( 1.0 - tex2DNode265 ),_InvertCustomPupil) + ( 1.0 - tex2DNode166.b ) ) , temp_cast_4 ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 lerpResult304 = lerp( ( _EyeBallColorGlossA * ( 1.0 - tex2DNode166.b ) ) , _EyeVeinColorAmountA , ( _EyeVeinColorAmountA.a * tex2DNode166.g ));
			float4 lerpResult307 = lerp( lerpResult304 , _IrisBaseColor , tex2DNode166.b);
			float temp_output_260_0 = ( 10.0 - _IrisSize );
			float2 temp_cast_5 = (temp_output_260_0).xx;
			float2 temp_cast_6 = (( ( 1.0 - temp_output_260_0 ) / 2.0 )).xx;
			float2 uv_TexCoord190 = i.uv_texcoord * temp_cast_5 + temp_cast_6;
			float mulTime320 = _Time.y * _IrisRotateSpeed;
			float cos319 = cos( mulTime320 );
			float sin319 = sin( mulTime320 );
			float2 rotator319 = mul( uv_TexCoord190 - float2( 0.5,0.5 ) , float2x2( cos319 , -sin319 , sin319 , cos319 )) + float2( 0.5,0.5 );
			float4 tex2DNode185 = tex2D( _IrisExtraDetail, rotator319 );
			float temp_output_368_0 = pow( ( tex2DNode185.r * _IrisExtraColorAmountA.a * tex2DNode166.b ) , 2.0 );
			float4 lerpResult314 = lerp( lerpResult307 , ( tex2DNode185 * _IrisExtraColorAmountA ) , temp_output_368_0);
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float dotResult340 = dot( reflect( ase_worldlightDir , ase_worldViewDir ) , ase_vertexNormal );
			float clampResult343 = clamp( ( 1.0 - (dotResult340*_CausticScale + _CausticOffset) ) , 0.0 , 1.0 );
			float clampResult354 = clamp( ( _CausticPower * clampResult343 ) , 0.0 , 1.0 );
			float4 lerpResult310 = lerp( ( lerp(temp_cast_1,clampResult281,_UseCustomPupil) * lerpResult314 * ( lerpResult314 + ( temp_output_368_0 * clampResult354 ) ) ) , ( tex2DNode166.r * _RingColorAmountA ) , ( tex2DNode166.r * _RingColorAmountA.a ));
			o.Albedo = ( _BoostEyeWhite * ( 1.0 - tex2DNode166.b ) * lerpResult310 ).rgb;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 clampResult51 = clamp( ( tex2DNode166.b * clampResult354 * float4( ase_lightColor.rgb , 0.0 ) * ase_lightColor.a * lerpResult310 ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 lerpResult160 = lerp( clampResult51 , ( _IrisGlow * lerpResult310 * pow( tex2DNode166.b , 3.0 ) ) , ( _IrisGlow / 10.0 ));
			o.Emission = lerpResult160.rgb;
			float lerpResult135 = lerp( _EyeBallColorGlossA.a , ( tex2DNode166.b * _LensGloss ) , tex2DNode166.b);
			o.Smoothness = lerpResult135;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred 

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
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
7;236;1906;807;3491.366;2565.413;5.89639;True;True
Node;AmplifyShaderEditor.CommentaryNode;377;-1300.485,-1779.168;Float;False;1652.929;466.989;Size Control;9;274;267;278;277;270;268;269;271;91;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-1250.485,-1404.723;Half;False;Property;_PupilSize;PupilSize;17;0;Create;True;0;0;False;0;70;44.5;0.001;89;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;271;-937.5678,-1650.423;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;84;False;3;FLOAT;-20;False;4;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;269;-724.2214,-1610.505;Float;False;2;0;FLOAT;10;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;380;452.7032,-391.916;Float;False;1289.046;546.6973;Size and Iriz/Lens Control - Rotation FX;10;259;320;190;319;226;158;20;321;260;258;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;226;502.8837,-243.9664;Float;False;Property;_IrisSize;IrisSize;15;0;Create;True;0;0;False;0;4.4;5.8;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;268;-565.5194,-1710.454;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;165;126.0547,175.9008;Float;False;1788.775;596.6456;IrisConeCaustics - Fake caustic Effect;13;354;353;50;343;341;344;365;340;367;366;337;338;339;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;277;-615.8256,-1493.539;Float;False;Property;_CustomPupilRotateSpeed;CustomPupilRotateSpeed;23;0;Create;True;0;0;False;0;0;2.14;-4;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;270;-402.1608,-1649.605;Float;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;339;159.458,445.0288;Float;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;260;817.9438,-267.9163;Float;False;2;0;FLOAT;10;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;338;155.9428,248.1877;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;267;-244.3946,-1634.304;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;5,5;False;1;FLOAT2;0.5,0.5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;258;1007.382,-341.916;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;341;153.5406,616.7927;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;164;378.1715,-1420.241;Float;False;2247.17;550.2261;Pupil;14;151;156;153;157;148;154;152;149;147;146;155;122;213;214;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ReflectOpNode;337;419.892,337.7573;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;278;-326.0627,-1458.462;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;366;498.9249,569.83;Float;False;Property;_CausticScale;CausticScale;14;0;Create;True;0;0;False;0;1;1.68;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;259;1166.043,-317.7626;Float;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;378;526.427,-1771.338;Float;False;2122.931;336.1;Custom Pupil Switching;7;272;279;273;280;282;281;265;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;168;-361.9856,-847.0782;Float;False;803.1489;1005.685;Inputs;8;133;126;170;166;303;305;306;311;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;367;488.3008,660.276;Float;False;Property;_CausticOffset;CausticOffset;13;0;Create;True;0;0;False;0;1;1.47;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;151;783.0623,-1334.448;Float;False;2;0;FLOAT;100;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;372;-516.0597,-2177.189;Float;False;1316.846;355.723;Parralax;4;376;375;374;373;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RotatorNode;274;35.82745,-1643.017;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;321;511.783,39.78118;Float;False;Property;_IrisRotateSpeed;IrisRotateSpeed;16;0;Create;True;0;0;False;0;0;0.46;-4;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;340;674.9529,368.7878;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;156;445.1921,-1031.941;Float;False;Property;_PupilHeight1Width1;Pupil Height>1/Width<1;18;0;Create;True;0;0;False;0;1;6.17;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;190;1297.989,-249.0651;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;5,5;False;1;FLOAT2;0.5,0.5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;320;1014.779,-35.7908;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;365;886.8799,370.4568;Float;False;3;0;FLOAT;0;False;1;FLOAT;1.54;False;2;FLOAT;1.62;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;373;170.8089,-2044.893;Float;False;Property;_PupilParallaxHeight;PupilParallaxHeight;24;0;Create;True;0;0;False;0;1.4;1.45;-4;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;153;1035.486,-1301.668;Float;False;2;0;FLOAT;2;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;803.8835,-1004.653;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;374;-466.0598,-2005.466;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;265;576.427,-1721.338;Float;True;Property;_CustomPupil;CustomPupil;1;1;[NoScaleOffset];Create;True;0;0;False;0;af50dd7b02abcc04f9f1d88772c41b91;af50dd7b02abcc04f9f1d88772c41b91;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;375;229.5917,-2127.189;Float;False;Property;_ParalaxH;ParalaxH;25;0;Create;True;0;0;False;0;-0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;166;-358.276,-237.6519;Float;True;Property;_EyeExtrasMask;EyeExtrasMask;2;1;[NoScaleOffset];Create;True;0;0;False;0;d0431c3a16ed8b54c8d648bb79ca09a5;7279c4b0bec10f442a956ce8acc2046d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;170;-301.2955,-613.2215;Float;False;Property;_EyeVeinColorAmountA;EyeVeinColor-Amount(A);7;0;Create;True;0;0;False;0;0.375,0,0,0;0,0.5034485,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;305;17.00527,-702.1861;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;133;-291.8356,-797.0782;Float;False;Property;_EyeBallColorGlossA;EyeBallColor-Gloss(A);4;0;Create;True;0;0;False;0;1,1,1,0.878;0,0,0,0.116;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;379;1733.495,-835.0886;Float;False;659.4635;883.3157;Iris Color and mixing;7;307;312;313;186;315;185;187;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;344;1109.448,385.5598;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;154;1146.966,-1003.015;Float;False;2;0;FLOAT;2;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;152;1197.952,-1361.842;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;272;1132.713,-1661.383;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RotatorNode;319;1528.75,-142.6165;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;148;1109.383,-1160.573;Float;False;2;0;FLOAT;2;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxOffsetHlpNode;376;584.7862,-2038.779;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;50;1213.673,264.795;Float;False;Property;_CausticPower;CausticPower;12;0;Create;True;0;0;False;0;0.3;0.784;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;185;1792.22,-493.9084;Float;True;Property;_IrisExtraDetail;IrisExtraDetail;0;1;[NoScaleOffset];Create;True;0;0;False;0;7b7c97e104d9817418725e17f5ca2659;f6339c90c4ecdb345b2c589184d78f43;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;187;1783.495,-158.7729;Float;False;Property;_IrisExtraColorAmountA;IrisExtraColor-Amount(A);6;0;Create;True;0;0;False;0;0.1470588,0.1024192,0.06812285,0.441;0,0.6689661,1,0.666;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;303;24.12505,-570.8032;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;213;1646.353,-1007.836;Float;False;Property;_PupilSharpness;PupilSharpness;19;0;Create;True;0;0;False;0;5;0.82;0.1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;149;1383.024,-1104.371;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;147;1392.624,-1370.241;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;306;232.9371,-765.0026;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;273;1335.601,-1698.169;Float;False;Property;_InvertCustomPupil;InvertCustomPupil?;22;0;Create;True;0;0;False;0;1;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;343;1318.027,355.64;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;279;1342.691,-1545.552;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;315;2223.958,-237.1031;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;169;2555.364,-770.5315;Float;False;2125.866;921.7941;Mixing;16;159;160;161;51;18;26;134;135;103;181;284;285;286;310;314;368;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;304;888.5789,-728.1098;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;214;1944.353,-998.8357;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;7;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;146;1744.878,-1265.542;Float;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;126;-293.1781,-437.5083;Float;False;Property;_IrisBaseColor;IrisBaseColor;5;0;Create;True;0;0;False;0;0.8161765,0.4123098,0.1020221,0;0,0.2857506,0.8455882,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;280;1644.139,-1573.546;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;353;1506.526,349.3523;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;2211.849,-420.9293;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;354;1701.163,321.1096;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;307;2162.754,-785.0886;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;282;2118.971,-1568.238;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;368;2614.204,-385.5531;Float;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;155;2064.596,-1271.939;Float;True;2;0;FLOAT;0;False;1;FLOAT;12;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;281;2474.358,-1678.989;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;370;2905.442,-374.063;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;314;2720.434,-682.6896;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;122;2450.342,-1246.716;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;311;-331.7957,-30.74805;Float;False;Property;_RingColorAmountA;RingColor-Amount(A);8;0;Create;True;0;0;False;0;0,0,0,0;0,0.8758622,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;266;2774.695,-1510.021;Float;False;Property;_UseCustomPupil;UseCustomPupil?;21;0;Create;True;0;0;False;0;1;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;369;3071.548,-515.9788;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;312;2172.749,-652.2123;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;313;2202.901,-547.632;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;3275.843,-715.1325;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;26;2883.552,-23.85549;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;310;3565.142,-638.1;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;167;3144.018,-1401.414;Float;False;836.5276;442.498;FakewLens;4;138;141;139;140;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;20;509.524,-59.51176;Float;False;Property;_LensGloss;LensGloss;10;0;Create;True;0;0;False;0;0.98;0.934;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;158;502.7032,-147.7856;Float;False;Property;_IrisGlow;IrisGlow;9;0;Create;True;0;0;False;0;0;1.67;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;181;3424.897,-349.8592;Float;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;3742.013,-108.759;Float;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;138;3194.018,-1284.083;Float;True;Property;_NormalMapBase;NormalMapBase;3;1;[NoScaleOffset];Create;True;0;0;False;0;8ee6d0418eaa08e40ad667b400177c1c;8ee6d0418eaa08e40ad667b400177c1c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;3406.556,-233.4798;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;141;3194.092,-1079.333;Float;False;Property;_LensPush;LensPush;11;0;Create;True;0;0;False;0;0.64;0.74;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;51;4130.49,-141.9583;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;284;3929.797,-758.5461;Float;False;Property;_BoostEyeWhite;BoostEyeWhite;20;0;Create;True;0;0;False;0;1;1.326;1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;161;4124.88,-289.5872;Float;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;285;3928.111,-569.5947;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;140;3533.887,-1351.414;Float;False;Constant;_Vector0;Vector 0;10;0;Create;True;0;0;False;0;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;4100.319,-439.6207;Float;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;139;3796.54,-1114.917;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;135;3495.664,-138.4033;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;160;4497.228,-355.3222;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;286;4531.959,-735.1046;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;5091.913,-425.2085;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;RRF_HumanShaders/EyeShaders/EyeShader_Model2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;271;0;91;0
WireConnection;269;1;271;0
WireConnection;268;0;269;0
WireConnection;270;0;268;0
WireConnection;260;1;226;0
WireConnection;267;0;269;0
WireConnection;267;1;270;0
WireConnection;258;0;260;0
WireConnection;337;0;338;0
WireConnection;337;1;339;0
WireConnection;278;0;277;0
WireConnection;259;0;258;0
WireConnection;151;1;91;0
WireConnection;274;0;267;0
WireConnection;274;2;278;0
WireConnection;340;0;337;0
WireConnection;340;1;341;0
WireConnection;190;0;260;0
WireConnection;190;1;259;0
WireConnection;320;0;321;0
WireConnection;365;0;340;0
WireConnection;365;1;366;0
WireConnection;365;2;367;0
WireConnection;153;0;151;0
WireConnection;153;1;156;0
WireConnection;157;0;156;0
WireConnection;265;1;274;0
WireConnection;305;0;166;3
WireConnection;344;0;365;0
WireConnection;154;0;151;0
WireConnection;154;1;157;0
WireConnection;152;0;151;0
WireConnection;152;1;153;0
WireConnection;272;0;265;0
WireConnection;319;0;190;0
WireConnection;319;2;320;0
WireConnection;148;0;151;0
WireConnection;376;0;375;0
WireConnection;376;1;373;0
WireConnection;376;2;374;0
WireConnection;185;1;319;0
WireConnection;303;0;170;4
WireConnection;303;1;166;2
WireConnection;149;0;148;0
WireConnection;149;1;154;0
WireConnection;147;0;152;0
WireConnection;147;1;376;0
WireConnection;306;0;133;0
WireConnection;306;1;305;0
WireConnection;273;0;265;0
WireConnection;273;1;272;0
WireConnection;343;0;344;0
WireConnection;279;0;166;3
WireConnection;315;0;185;1
WireConnection;315;1;187;4
WireConnection;315;2;166;3
WireConnection;304;0;306;0
WireConnection;304;1;170;0
WireConnection;304;2;303;0
WireConnection;214;0;213;0
WireConnection;146;0;149;0
WireConnection;146;1;147;0
WireConnection;280;0;273;0
WireConnection;280;1;279;0
WireConnection;353;0;50;0
WireConnection;353;1;343;0
WireConnection;186;0;185;0
WireConnection;186;1;187;0
WireConnection;354;0;353;0
WireConnection;307;0;304;0
WireConnection;307;1;126;0
WireConnection;307;2;166;3
WireConnection;282;0;280;0
WireConnection;282;1;213;0
WireConnection;368;0;315;0
WireConnection;155;0;146;0
WireConnection;155;1;214;0
WireConnection;281;0;282;0
WireConnection;370;0;368;0
WireConnection;370;1;354;0
WireConnection;314;0;307;0
WireConnection;314;1;186;0
WireConnection;314;2;368;0
WireConnection;122;0;155;0
WireConnection;266;0;122;0
WireConnection;266;1;281;0
WireConnection;369;0;314;0
WireConnection;369;1;370;0
WireConnection;312;0;166;1
WireConnection;312;1;311;0
WireConnection;313;0;166;1
WireConnection;313;1;311;4
WireConnection;103;0;266;0
WireConnection;103;1;314;0
WireConnection;103;2;369;0
WireConnection;310;0;103;0
WireConnection;310;1;312;0
WireConnection;310;2;313;0
WireConnection;181;0;166;3
WireConnection;18;0;166;3
WireConnection;18;1;354;0
WireConnection;18;2;26;1
WireConnection;18;3;26;2
WireConnection;18;4;310;0
WireConnection;134;0;166;3
WireConnection;134;1;20;0
WireConnection;51;0;18;0
WireConnection;161;0;158;0
WireConnection;285;0;166;3
WireConnection;159;0;158;0
WireConnection;159;1;310;0
WireConnection;159;2;181;0
WireConnection;139;0;140;0
WireConnection;139;1;138;0
WireConnection;139;2;141;0
WireConnection;135;0;133;4
WireConnection;135;1;134;0
WireConnection;135;2;166;3
WireConnection;160;0;51;0
WireConnection;160;1;159;0
WireConnection;160;2;161;0
WireConnection;286;0;284;0
WireConnection;286;1;285;0
WireConnection;286;2;310;0
WireConnection;0;0;286;0
WireConnection;0;1;139;0
WireConnection;0;2;160;0
WireConnection;0;4;135;0
ASEEND*/
//CHKSM=8E7497A1DD39ECA96667AFE8BB0E40A4D2913BFB