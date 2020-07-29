Shader "Fur/BaseFurShader"
{
    Properties
    {
        
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Shininess ("Shininess", Range(0.01, 256.0)) = 8.0
        
        _MainTex ("MainTex[毛皮]", 2D) = "white" { }
        _Color ("BaseColor[毛皮]", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_MaskTex ("Mask", 2D) = "white" { }        
        _FurColor ("FurColor[毛发]", Color) = (1, 1, 1, 1)
        // [HideInInspector] _FurColor2 ("FurColor2[毛发]", Color) = (1, 1, 1, 1)
                
        _LayerTex ("FurLayter", 2D) = "white" { }
        [NoScaleOffset]_LayerTexColor ("FurLayerColor", 2D) = "white" { }
        
        _FurLength ("Fur Length", Range(0.0, 1)) = 0.5

        _FurAlpha ("Fur Alpha", Range(0.0, 0.5)) = 0.1

        _FurDensity ("Fur Density", Range(0, 4)) = 0.11
        _FurThinness ("Fur Thinness", Range(0.01, 10)) = 1
        _FurShading ("Fur Shading", Range(0.0, 1)) = 0.25
        

        _ForceGlobal ("Force Global", Vector) = (0, 0, 0, 0)
        _ForceLocal ("Force Local", Vector) = (0, 0, 0, 0)
        // _GravityStrength ("_GravityStrength", Range(0.0, 2)) = 0.25
        
         

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
            
            // Pass
            // {  
            //     Tags {
            //         "LightMode"="ForwardAdd"
            //     }
            //     // Blend One OneMinusSrcColor                                                                    
            //     Blend One One                                                                    
            //     CGPROGRAM          
            //     #include "UnityCG.cginc"
            //     #include "AutoLight.cginc"            
            //     #pragma target 3.0
            //     #define FURSTEP 0.05 
            //     #include "BaseFurHelper.cginc"
            //     #pragma vertex vert_add
            //     #pragma fragment frag_add
            //     ENDCG
            // }

             Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.1
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
                #define FURSTEP 0.2
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
                #define FURSTEP 0.3
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
                #define FURSTEP 0.4
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
                #define FURSTEP 0.5
                #include "BaseFurHelper.cginc"                
                ENDCG
                
            }

  
     
   
            // Pass
            // {  
            //     Tags {
            //         "LightMode"="ForwardAdd"
            //     }
            //     // Blend  OneMinusSrcColor  One                                                                  
            //     Blend One One                                                                    
            //     CGPROGRAM          
            //     #include "UnityCG.cginc"
            //     #include "AutoLight.cginc"            
            //     #pragma target 3.0
            //     #define FURSTEP 0.45
            //     #include "BaseFurHelper.cginc"
            //     #pragma vertex vert_add
            //     #pragma fragment frag_add
            //     ENDCG
            // }
            //  Pass
            // {  
            //     Tags {
            //         "LightMode"="ForwardAdd"
            //     }
            //     // Blend  OneMinusSrcColor  One                                                                  
            //     Blend One One                                                                    
            //     CGPROGRAM          
            //     #include "UnityCG.cginc"
            //     #include "AutoLight.cginc"            
            //     #pragma target 3.0
            //     #define FURSTEP 0.4
            //     #include "BaseFurHelper.cginc"
            //     #pragma vertex vert_add
            //     #pragma fragment frag_add
            //     ENDCG
            // }

            // Pass
            // {  
            //     Tags {
            //         "LightMode"="ForwardAdd"
            //     }
            //     // Blend  OneMinusSrcColor  One                                                                  
            //     Blend One One                                                                    
            //     CGPROGRAM          
            //     #include "UnityCG.cginc"
            //     #include "AutoLight.cginc"            
            //     #pragma target 3.0
            //     #define FURSTEP 0.45
            //     #include "BaseFurHelper.cginc"
            //     #pragma vertex vert_add
            //     #pragma fragment frag_add
            //     ENDCG
            // }
            //  Pass
            // {  
            //     Tags {
            //         "LightMode"="ForwardAdd"
            //     }
            //     // Blend  OneMinusSrcColor  One                                                                  
            //     Blend One One                                                                    
            //     CGPROGRAM          
            //     #include "UnityCG.cginc"
            //     #include "AutoLight.cginc"            
            //     #pragma target 3.0
            //     #define FURSTEP 0.5
            //     #include "BaseFurHelper.cginc"
            //     #pragma vertex vert_add
            //     #pragma fragment frag_add
            //     ENDCG
            // }
           
            
            
        }
    }
    //  FallBack "Diffuse"
}


