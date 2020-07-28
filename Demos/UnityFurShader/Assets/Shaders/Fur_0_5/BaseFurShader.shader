Shader "Fur/BaseFurShader"
{
    Properties
    {
        
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Shininess ("Shininess", Range(0.01, 256.0)) = 8.0
        
        _MainTex ("BaseTexture[毛皮]", 2D) = "white" { }
        _Color ("BaseColor[毛皮]", Color) = (1, 1, 1, 1)
        _MaskTex ("Mask", 2D) = "white" { }
        _FurColorTex ("FurColorTex[毛发]", 2D) = "white" { }
        _FurColor ("FurColor[毛发]", Color) = (1, 1, 1, 1)
        _FurColor2 ("FurColor2[毛发]", Color) = (1, 1, 1, 1)
        
        _FurTex ("Fur Pattern", 2D) = "white" { }
        
        _FurLength ("Fur Length", Range(0.0, 1)) = 0.5

        _FurAlpha ("Fur Alpha", Range(0.0, 0.5)) = 0.1
        
        _FurDensity ("Fur Density", Range(0, 4)) = 0.11
        _FurThinness ("Fur Thinness", Range(0.01, 10)) = 1
        _FurShading ("Fur Shading", Range(0.0, 1)) = 0.25

        _ForceGlobal ("Force Global", Vector) = (0, 0, 0, 0)
        _ForceLocal ("Force Local", Vector) = (0, 0, 0, 0)
        
         

        _RimColor ("Rim Color", Color) = (0, 0, 0, 1)
        _RimPower ("Rim Power", Range(0.0, 8.0)) = 6.0
    }
    
    Category
    {

        Tags { "RenderType" = "Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent" }
        Cull Off
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha
        
        SubShader
        {
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_surface
                #pragma fragment frag_surface
                #define FURSTEP 0.00
                #include "BaseFurHelper.cginc"
                
                ENDCG
                
            }

            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.05
                #include "BaseFurHelper.cginc"                
                ENDCG
                
            }
            
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.10
                #include "BaseFurHelper.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.15
                #include "BaseFurHelper.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.20
                #include "BaseFurHelper.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.25
                #include "BaseFurHelper.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.30
                #include "BaseFurHelper.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.35
                #include "BaseFurHelper.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.40
                #include "BaseFurHelper.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.45
                #include "BaseFurHelper.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.50
                #include "BaseFurHelper.cginc"
                
                ENDCG                
            }


    
            // Pass
            // {  
            //     Tags {
            //         "LightMode"="ForwardAdd"
            //     }
            //     Blend One One            
                
            //     CGPROGRAM          
            //     #include "UnityCG.cginc"
            //     #include "AutoLight.cginc"            
            //     #pragma target 3.0
            //     #define FURSTEP 0.05 
            //     #include "BaseFurHelper.cginc"
            //     #pragma vertex vert
            //     #pragma fragment frag
            //     ENDCG
            // }

            //  Pass
            // {  
            //     Tags {
            //         "LightMode"="ForwardAdd"
            //     }
            //     Blend One One            
                
            //     CGPROGRAM          
            //     #include "UnityCG.cginc"
            //     #include "AutoLight.cginc"            
            //     #pragma target 3.0
            //     #define FURSTEP 0.10 
            //     #include "BaseFurHelper.cginc"
            //     #pragma vertex vert
            //     #pragma fragment frag
            //     ENDCG
            // }

            //  Pass
            // {  
            //     Tags {
            //         "LightMode"="ForwardAdd"
            //     }
            //     Blend One One            
                
            //     CGPROGRAM          
            //     #include "UnityCG.cginc"
            //     #include "AutoLight.cginc"            
            //     #pragma target 3.0
            //     #define FURSTEP 0.15
            //     #include "BaseFurHelper.cginc"
            //     #pragma vertex vert
            //     #pragma fragment frag
            //     ENDCG
            // }

            //  Pass
            // {  
            //     Tags {
            //         "LightMode"="ForwardAdd"
            //     }
            //     Blend One One            
                
            //     CGPROGRAM          
            //     #include "UnityCG.cginc"
            //     #include "AutoLight.cginc"            
            //     #pragma target 3.0
            //     #define FURSTEP 0.20 
            //     #include "BaseFurHelper.cginc"
            //     #pragma vertex vert
            //     #pragma fragment frag
            //     ENDCG
            // }

            //  Pass
            // {  
            //     Tags {
            //         "LightMode"="ForwardAdd"
            //     }
            //     Blend One One            
                
            //     CGPROGRAM          
            //     #include "UnityCG.cginc"
            //     #include "AutoLight.cginc"            
            //     #pragma target 3.0
            //     #define FURSTEP 0.25
            //     #include "BaseFurHelper.cginc"
            //     #pragma vertex vert
            //     #pragma fragment frag
            //     ENDCG
            // }

            //  Pass
            // {  
            //     Tags {
            //         "LightMode"="ForwardAdd"
            //     }
            //     Blend One One            
                
            //     CGPROGRAM          
            //     #include "UnityCG.cginc"
            //     #include "AutoLight.cginc"            
            //     #pragma target 3.0
            //     #define FURSTEP 0.30
            //     #include "BaseFurHelper.cginc"
            //     #pragma vertex vert
            //     #pragma fragment frag
            //     ENDCG
            // }


            //  Pass
            // {  
            //     Tags {
            //         "LightMode"="ForwardAdd"
            //     }
            //     Blend One One            
                
            //     CGPROGRAM          
            //     #include "UnityCG.cginc"
            //     #include "AutoLight.cginc"            
            //     #pragma target 3.0
            //     #define FURSTEP 0.35 
            //     #include "BaseFurHelper.cginc"
            //     #pragma vertex vert
            //     #pragma fragment frag
            //     ENDCG
            // }

            //  Pass
            // {  
            //     Tags {
            //         "LightMode"="ForwardAdd"
            //     }
            //     Blend One One            
                
            //     CGPROGRAM          
            //     #include "UnityCG.cginc"
            //     #include "AutoLight.cginc"            
            //     #pragma target 3.0
            //     #define FURSTEP 0.4
            //     #include "BaseFurHelper.cginc"
            //     #pragma vertex vert
            //     #pragma fragment frag
            //     ENDCG
            // }

            //  Pass
            // {  
            //     Tags {
            //         "LightMode"="ForwardAdd"
            //     }
            //     Blend One One            
                
            //     CGPROGRAM          
            //     #include "UnityCG.cginc"
            //     #include "AutoLight.cginc"            
            //     #pragma target 3.0
            //     #define FURSTEP 0.45
            //     #include "BaseFurHelper.cginc"
            //     #pragma vertex vert
            //     #pragma fragment frag
            //     ENDCG
            // }

            //  Pass
            // {  
            //     Tags {
            //         "LightMode"="ForwardAdd"
            //     }
            //     Blend One One            
                
            //     CGPROGRAM          
         
            //     #pragma target 3.0
            //     #define FURSTEP 0.5
            //     #include "BaseFurHelper.cginc"
            //     #pragma vertex vert
            //     #pragma fragment frag
            //     ENDCG
            // }

           
            
            
        }
    }
     FallBack "Diffuse"
}


//             Pass {
//             Name "FORWARD_DELTA"
//             Tags {
//                 "LightMode"="ForwardAdd"
//             }
//             Blend One One            
            
//             CGPROGRAM
//             #pragma vertex vert
//             #pragma fragment frag            
//             #include "UnityCG.cginc"
//             #include "AutoLight.cginc"            
//             #pragma target 3.0
//             uniform float4 _LightColor0;
//             uniform float4 _Color;
//             struct VertexInput {
//                 float4 vertex : POSITION;
//                 float3 normal : NORMAL;
//             };
//             struct VertexOutput {
//                 float4 pos : SV_POSITION;
//                 float4 posWorld : TEXCOORD0;
//                 float3 normalDir : TEXCOORD1;
//                 LIGHTING_COORDS(2,3)                
//             };
//             VertexOutput vert (VertexInput v) {
//                 VertexOutput o = (VertexOutput)0;
//                 o.normalDir = UnityObjectToWorldNormal(v.normal);
//                 o.posWorld = mul(unity_ObjectToWorld, v.vertex);
//                 float3 lightColor = _LightColor0.rgb;
//                 o.pos = UnityObjectToClipPos( v.vertex );
                                
//                 return o;
//             }
//             float4 frag(VertexOutput i) : COLOR {
//                 i.normalDir = normalize(i.normalDir);
//                 float3 normalDirection = i.normalDir;
//                 float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
//                 float3 lightColor = _LightColor0.rgb;
// ////// Lighting:
//                 float attenuation = LIGHT_ATTENUATION(i);
//                 float3 attenColor = attenuation * _LightColor0.xyz;
// /////// Diffuse:
//                 float NdotL = max(0.0,dot( normalDirection, lightDirection ));
//                 float3 directDiffuse = max( 0.0, NdotL) * attenColor;
//                 float3 diffuseColor = _Color.rgb;
//                 float3 diffuse = directDiffuse * diffuseColor;
// /// Final Color:
//                 float3 finalColor = diffuse;
//                 fixed4 finalRGBA = fixed4(finalColor * 1,0);
                
//                 return finalRGBA;
//             }
//             ENDCG
//         }


//  Pass
//             {  
//                 Tags {
//                     "LightMode"="ForwardAdd"
//                 }
//                 Blend One One            
                
//                 CGPROGRAM          
//                 #include "UnityCG.cginc"
//                 #include "AutoLight.cginc"            
//                 #pragma target 3.0
//                 #define FURSTEP 0.00 
//                 #include "BaseFurHelper.cginc"
//                 #pragma vertex vert
//                 #pragma fragment frag
//                 ENDCG
//             }