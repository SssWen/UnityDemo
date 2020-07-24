Shader "Fur/BaseFurShader_6"
{
    Properties
    {
        
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Shininess ("Shininess", Range(0.01, 256.0)) = 8.0
                
        _Color ("BaseColor[底层毛皮]", Color) = (1, 1, 1, 1)

        _FurColorTex ("FurColorTex[毛发]", 2D) = "white" { }
        _FurColor ("FurColor[毛发]", Color) = (1, 1, 1, 1)

        _MaskTex ("Mask", 2D) = "white" { }
        
        
        _FurTex ("Fur Pattern", 2D) = "white" { }        
        _FurPatternColor ("PatternColor[斑点]", Color) = (1, 1, 1, 1)

        _FurLength ("Fur Length", Range(0.0, 1)) = 0.5

        _FurAlpha ("Fur Alpha", Range(0.0, 0.5)) = 0.1
        
        _FurDensity ("Fur Density", Range(0, 4)) = 0.11
        _FurThinness ("Fur Thinness", Range(0.01, 10)) = 1
        _FurShading ("Fur Shading", Range(0.0, 1)) = 0.25
        
        _Gravity("Gravity Direction[重力方向]", Vector) = (0,-1,0,0)
		_GravityStrength("Gravity Strength", Range(0,1)) = 0.25

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
                #include "BaseFurHelper_6.cginc"
                
                ENDCG
                
            }

            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.05
                #include "BaseFurHelper_6.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.10
                #include "BaseFurHelper_6.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.15
                #include "BaseFurHelper_6.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.20
                #include "BaseFurHelper_6.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.25
                #include "BaseFurHelper_6.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.30
                #include "BaseFurHelper_6.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.35
                #include "BaseFurHelper_6.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.40
                #include "BaseFurHelper_6.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.45
                #include "BaseFurHelper_6.cginc"
                
                ENDCG
                
            }
            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.50
                #include "BaseFurHelper_6.cginc"
                
                ENDCG
                
            }
            
            // Pass
            // {
            //     CGPROGRAM
                
            //     #pragma vertex vert_base
            //     #pragma fragment frag_base
            //     #define FURSTEP 0.55
            //     #include "BaseFurHelper_6.cginc"
                
            //     ENDCG
                
            // }
            
            // Pass
            // {
            //     CGPROGRAM
                
            //     #pragma vertex vert_base
            //     #pragma fragment frag_base
            //     #define FURSTEP 0.60
            //     #include "BaseFurHelper_6.cginc"
                
            //     ENDCG
                
            // }
            
            // Pass
            // {
            //     CGPROGRAM
                
            //     #pragma vertex vert_base
            //     #pragma fragment frag_base
            //     #define FURSTEP 0.65
            //     #include "BaseFurHelper_6.cginc"
                
            //     ENDCG
                
            // }
            
            // Pass
            // {
            //     CGPROGRAM
                
            //     #pragma vertex vert_base
            //     #pragma fragment frag_base
            //     #define FURSTEP 0.70
            //     #include "BaseFurHelper_6.cginc"
                
            //     ENDCG
                
            // }
            
            // Pass
            // {
            //     CGPROGRAM
                
            //     #pragma vertex vert_base
            //     #pragma fragment frag_base
            //     #define FURSTEP 0.75
            //     #include "BaseFurHelper_6.cginc"
                
            //     ENDCG
                
            // }
            
            // Pass
            // {
            //     CGPROGRAM
                
            //     #pragma vertex vert_base
            //     #pragma fragment frag_base
            //     #define FURSTEP 0.80
            //     #include "BaseFurHelper_6.cginc"
                
            //     ENDCG
                
            // }
            
            // Pass
            // {
            //     CGPROGRAM
                
            //     #pragma vertex vert_base
            //     #pragma fragment frag_base
            //     #define FURSTEP 0.85
            //     #include "BaseFurHelper_6.cginc"
                
            //     ENDCG
                
            // }
            
            // Pass
            // {
            //     CGPROGRAM
                
            //     #pragma vertex vert_base
            //     #pragma fragment frag_base
            //     #define FURSTEP 0.90
            //     #include "BaseFurHelper_6.cginc"
                
            //     ENDCG
                
            // }
            
            // Pass
            // {
            //     CGPROGRAM
                
            //     #pragma vertex vert_base
            //     #pragma fragment frag_base
            //     #define FURSTEP 0.95
            //     #include "BaseFurHelper_6.cginc"
                
            //     ENDCG
                
            // }

            // Pass
            // {
            //     CGPROGRAM
                
            //     #pragma vertex vert_base
            //     #pragma fragment frag_base
            //     #define FURSTEP 1.00
            //     #include "BaseFurHelper_6.cginc"
                
            //     ENDCG
                
            // }
        }
    }
}