

using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;


internal class FunDreamBaseShaderGUI_layer : ShaderGUI
{
    private enum WorkflowMode
    {
        Specular,
        Metallic,
        Dielectric
    }

    public enum BlendMode
    {
        Opaque,
        Cutout,
        Fade,       // Old school alpha-blending mode, fresnel does not affect amount of transparency
        Transparent // Physically plausible transparency mode, implemented as alpha pre-multiply
    }

    public enum SmoothnessMapChannel
    {
        SpecularMetallicAlpha,
        AlbedoAlpha,
    }

    private static class Styles
    {
        public static GUIStyle optionsButton = "PaneOptions";
        //public static GUIContent uvSetLabel = new GUIContent("UV Set");
        //public static GUIContent[] uvSetOptions = new GUIContent[] { new GUIContent("UV channel 0"), new GUIContent("UV channel 1") };

        public static string emptyTootip = "";
        public static GUIContent albedoText = new GUIContent("Albedo", "Albedo (RGB) and Transparency (A)");
        public static GUIContent alphaCutoffText = new GUIContent("Alpha Cutoff", "Threshold for alpha cutoff");
        public static GUIContent specularMapText = new GUIContent("Specular", "Specular (RGB) and Smoothness (A)");
        public static GUIContent metallicMapText = new GUIContent("Metallic (R)", "Metallic (R) and Smoothness (G)");
        public static GUIContent smoothnessText = new GUIContent("Smoothness", "Smoothness Value");
        public static GUIContent smoothnessScaleText = new GUIContent("Smoothness (G)", "Smoothness scale factor");
        public static GUIContent smoothnessMapChannelText = new GUIContent("Source", "Smoothness texture and channel");
        public static GUIContent highlightsText = new GUIContent("Specular Highlights", "Specular Highlights");
        public static GUIContent reflectionsText = new GUIContent("Reflections", "Glossy Reflections");
        public static GUIContent normalMapText = new GUIContent("Normal Map", "Normal Map");
        public static GUIContent heightMapText = new GUIContent("Height Map", "Height Map (G)");
        public static GUIContent occlusionText = new GUIContent("Occlusion", "Occlusion (G)");
        public static GUIContent emissionText = new GUIContent("Emission", "Emission (RGB)");

        public static string whiteSpaceString = " ";
        public static string primaryMapsText = "Main Maps";
        public static string secondaryMapsText = "Secondary Maps";
        public static string forwardText = "Forward Rendering Options";
        public static string renderingMode = "Rendering Mode";
        public static GUIContent emissiveWarning = new GUIContent("Emissive value is animated but the material has not been configured to support emissive. Please make sure the material itself has some amount of emissive.");
        public static GUIContent emissiveColorWarning = new GUIContent("Ensure emissive color is non-black for emission to have effect.");
        public static readonly string[] blendNames = Enum.GetNames(typeof(BlendMode));

        public static string tcp2_HeaderText = "FunDream BaseShader functions";
        public static string tcp2_highlightColorText = "Highlight Color";
        public static string tcp2_shadowColorText = "Shadow Color";
        public static GUIContent tcp2_rampText = new GUIContent("Ramp Texture", "Ramp 1D Texture (R)");
        public static GUIContent tcp2_rampThresholdText = new GUIContent("Threshold", "Threshold for the separation between shadows and highlights");
        public static GUIContent tcp2_rampSmoothText = new GUIContent("Main Light Smoothing", "Main Light smoothing of the separation between shadows and highlights");
        public static GUIContent tcp2_rampSmoothAddText = new GUIContent("Other Lights Smoothing", "Additional Lights smoothing of the separation between shadows and highlights");
        public static GUIContent tcp2_specSmoothText = new GUIContent("Specular Smoothing", "Stylized Specular smoothing");
        public static GUIContent tcp2_SpecBlendText = new GUIContent("Specular Blend", "Stylized Specular contribution over regular Specular");
        public static GUIContent tcp2_rimStrengthText = new GUIContent("Rim Strength", "Stylized Rim overall strength");
        public static GUIContent tcp2_rimMinText = new GUIContent("Rim Min", "Rim min ramp threshold");
        public static GUIContent tcp2_rimMaxText = new GUIContent("Rim Max", "Rim max ramp threshold");
        public static GUIContent tcp2_outlineColorText = new GUIContent("Outline Color", "Color of the outline");
        public static GUIContent tcp2_outlineWidthText = new GUIContent("Outline Width", "Width of the outline");

        // fun dream zone
        public static GUIContent reflectionMapText = new GUIContent("ReflectionMap", "Reflection cube map");
        public static GUIContent reflectBrightnessText = new GUIContent("Reflect Brightness", "Reflect Brightness");
        public static GUIContent rotationText = new GUIContent("Rotate Angle", "Cube map Rotate Angle");
        public static GUIContent rimColorText = new GUIContent("Rim Color(RGB)", "Rim Color(RGB)");
        public static GUIContent tempText = new GUIContent("temp", "temp");
        public static GUIContent cullingText = new GUIContent("Culling", "Culling front/back/off");
        public static GUIContent rimOffsetText = new GUIContent("RimOffset", "Rim Offset");
        public static GUIContent rimOffsetXText = new GUIContent("RimOffsetX", "Rim Offset X");
        public static GUIContent rimOffsetYText = new GUIContent("RimOffsetY", "Rim Offset Y");
        public static GUIContent rimOffsetZText = new GUIContent("RimOffsetZ", "Rim Offset Z");
        public static GUIContent realFresnelText = new GUIContent("Fresnel", "Real Fresnel");
        public static GUIContent thicknessText = new GUIContent("Thickness", "Real Fresnel Thickness");
        public static GUIContent gradientText = new GUIContent("Gradient", "Real Fresnel Gradient");
        public static GUIContent multiTranspText = new GUIContent("MultipleTransparent", "Multiple Transparent");
        public static GUIContent alphaScaleText = new GUIContent("AlphaScale", "Alpha Scale");

        // make up system
        public static GUIContent maskTexText = new GUIContent("MaskTex (RGBA)", "Mask Texture (RGBA)");

        public static GUIContent uv2Text = new GUIContent("UV2", "UV2 ON or OFF");
        public static GUIContent uv3Text = new GUIContent("UV3", "UV3 ON or OFF");

        public static GUIContent layerBaseTexText = new GUIContent("LayerBase", "LayerBase Texture");
        public static GUIContent layerBaseColorText = new GUIContent("LayerBaseColor", "LayerBase Color");
        public static GUIContent layerBaseSmoothnessText = new GUIContent("LayerBaseSmoothness", "LayerBase Smoothness");
        public static GUIContent layerBaseMetallicText = new GUIContent("LayerBaseMetallic", "LayerBase Metallic");
        public static GUIContent layerBaseUVSetText = new GUIContent("LayerBaseUVSet", "LayerBase UVSet");
        public static GUIContent layerBaseNormalText = new GUIContent("LayerBaseNormal", "LayerBase Normal Texture");
        public static GUIContent layerBaseBlendModeText = new GUIContent("LayerBaseBlendMode", "LayerBase Blend Mode");

        public static GUIContent layer2TexText = new GUIContent("Layer2", "Eye Shadow Texture");
        public static GUIContent layer2ColorText = new GUIContent("Layer2Color", "Eye Shadow Color");
        public static GUIContent layer2SmoothnessText = new GUIContent("Layer2Smoothness", "Layer2 Smoothness");
        public static GUIContent layer2MetallicText = new GUIContent("Layer2Metallic", "Layer2 Metallic");
        public static GUIContent layer2UVSetText = new GUIContent("Layer2UVSet", "Layer2 UVSet");
        public static GUIContent layer2NormalText = new GUIContent("Layer2Normal", "Layer2 Normal Texture");
        public static GUIContent layer2BlendModeText = new GUIContent("Layer2BlendMode", "Layer2 Blend Mode");

        public static GUIContent layer3TexText = new GUIContent("Layer3", "Eye Shadow2 Texture");
        public static GUIContent layer3ColorText = new GUIContent("Layer3Color", "Eye Shadow2 Color");
        public static GUIContent layer3SmoothnessText = new GUIContent("Layer3Smoothness", "Layer3 Smoothness");
        public static GUIContent layer3MetallicText = new GUIContent("Layer3Metallic", "Layer3 Metallic");
        public static GUIContent layer3UVSetText = new GUIContent("Layer3UVSet", "Layer3 UVSet");
        public static GUIContent layer3NormalText = new GUIContent("Layer3Normal", "Layer3 Normal Texture");
        public static GUIContent layer3BlendModeText = new GUIContent("Layer3BlendMode", "Layer3 Blend Mode");

        public static GUIContent layer4TexText = new GUIContent("Layer4", "Eye Line Texture");
        public static GUIContent layer4ColorText = new GUIContent("Layer4Color", "Eye Line Color");
        public static GUIContent layer4SmoothnessText = new GUIContent("Layer4Smoothness", "Eye Line Smoothness");
        public static GUIContent layer4MetallicText = new GUIContent("Layer4Metallic", "Eye Line Metallic");
        public static GUIContent layer4UVSetText = new GUIContent("Layer4UVSet", "Layer4 UVSet");
        public static GUIContent layer4NormalText = new GUIContent("Layer4Normal", "Layer4 Normal Texture");
        public static GUIContent layer4BlendModeText = new GUIContent("Layer4BlendMode", "Layer4 Blend Mode");

        public static GUIContent layer5TexText = new GUIContent("Layer5", "Layer5 Texture");
        public static GUIContent layer5ColorText = new GUIContent("Layer5Color", "Layer5 Color");
        public static GUIContent layer5SmoothnessText = new GUIContent("Layer5Smoothness", "Layer5 Smoothness");
        public static GUIContent layer5MetallicText = new GUIContent("Layer5Metallic", "Layer5 Metallic");
        public static GUIContent layer5UVSetText = new GUIContent("Layer5UVSet", "Layer5 UVSet");
        public static GUIContent layer5NormalText = new GUIContent("Layer5Normal", "Layer5 Normal Texture");
        public static GUIContent layer5BlendModeText = new GUIContent("Layer5BlendMode", "Layer5 Blend Mode");

        public static GUIContent layer6TexText = new GUIContent("Layer6", "Layer6 Texture");
        public static GUIContent layer6ColorText = new GUIContent("Layer6Color", "Layer6 Color");
        public static GUIContent layer6SmoothnessText = new GUIContent("Layer6Smoothness", "Layer6 Smoothness");
        public static GUIContent layer6MetallicText = new GUIContent("Layer6Metallic", "Layer6 Metallic");
        public static GUIContent layer6UVSetText = new GUIContent("Layer6UVSet", "Layer6 UVSet");
        public static GUIContent layer6NormalText = new GUIContent("Layer6Normal", "Layer6 Normal Texture");
        public static GUIContent layer6BlendModeText = new GUIContent("Layer6BlendMode", "Layer6 Blend Mode");

        public static GUIContent layer7TexText = new GUIContent("Layer7", "Layer7 Texture");
        public static GUIContent layer7ColorText = new GUIContent("Layer7Color", "Layer7 Color");
        public static GUIContent layer7SmoothnessText = new GUIContent("Layer7Smoothness", "Layer7 Smoothness");
        public static GUIContent layer7MetallicText = new GUIContent("Layer7Metallic", "Layer7 Metallic");
        public static GUIContent layer7UVSetText = new GUIContent("Layer7UVSet", "Layer7 UVSet");
        public static GUIContent layer7NormalText = new GUIContent("Layer7Normal", "Layer7 Normal Texture");
        public static GUIContent layer7BlendModeText = new GUIContent("Layer7BlendMode", "Layer7 Blend Mode");

        public static GUIContent layerTopTexText = new GUIContent("LayerTop", "LayerTop Texture");
        public static GUIContent layerTopColorText = new GUIContent("LayerTopColor", "LayerTop Color");
        public static GUIContent layerTopSmoothnessText = new GUIContent("LayerTopSmoothness", "LayerTop Smoothness");
        public static GUIContent layerTopMetallicText = new GUIContent("LayerTopMetallic", "LayerTop Metallic");
        public static GUIContent layerTopUVSetText = new GUIContent("LayerTopUVSet", "LayerTop UVSet");
        public static GUIContent layerTopNormalText = new GUIContent("LayerTopNormal", "LayerTop Normal Texture");
        public static GUIContent layerTopBlendModeText = new GUIContent("LayerTopBlendMode", "LayerTop Blend Mode");



        public static string tcp2_TexLodText = "Outline Texture LOD";
        public static string tcp2_ZSmoothText = "ZSmooth Value";
        public static string tcp2_Offset1Text = "Offset Factor";
        public static string tcp2_Offset2Text = "Offset Units";
        public static string tcp2_srcBlendOutlineText = "Source Factor";
        public static string tcp2_dstBlendOutlineText = "Destination Factor";
        
    }

    MaterialProperty blendMode = null;
    MaterialProperty albedoMap = null;
    MaterialProperty albedoColor = null;
    MaterialProperty alphaCutoff = null;
    MaterialProperty specularMap = null;
    MaterialProperty specularColor = null;
    MaterialProperty metallicMap = null;
    MaterialProperty metallic = null;
    MaterialProperty smoothness = null;
    MaterialProperty smoothnessScale = null;
    MaterialProperty smoothnessMapChannel = null;
    MaterialProperty highlights = null;
    MaterialProperty reflections = null;
    MaterialProperty bumpScale = null;
    MaterialProperty bumpMap = null;
    MaterialProperty occlusionStrength = null;
    MaterialProperty occlusionMap = null;

    // fun dream zone
    MaterialProperty reflectionMap = null;
    MaterialProperty rimColor = null;
    MaterialProperty rimOffset = null;
    MaterialProperty rimOffsetX = null;
    MaterialProperty rimOffsetY = null;
    MaterialProperty rimOffsetZ = null;

    MaterialProperty reflectBrightness = null;
    MaterialProperty rotation = null;
    MaterialProperty temp = null;
    MaterialProperty culling = null;
    MaterialProperty realFresnel = null;
    MaterialProperty thickness = null;
    MaterialProperty gradient = null;
    MaterialProperty multiTrasp = null;

    MaterialProperty maskTex = null;

    MaterialProperty uv2 = null;
    MaterialProperty uv3 = null;

    MaterialProperty layerBaseTex = null;
    MaterialProperty layerBaseColor = null;
    MaterialProperty layerBaseSmoothness = null;
    MaterialProperty layerBaseMetallic = null;
    MaterialProperty layerBaseUVSet = null;
    MaterialProperty layerBaseNormal = null;
    MaterialProperty layerBaseNormalScale = null;
    MaterialProperty layerBaseBlendMode = null;

    MaterialProperty layer2Tex = null;
    MaterialProperty layer2Color = null;
    MaterialProperty layer2Smoothness = null;
    MaterialProperty layer2Metallic = null;
    MaterialProperty layer2UVSet = null;
    MaterialProperty layer2Normal = null;
    MaterialProperty layer2NormalScale = null;
    MaterialProperty layer2BlendMode = null;

    MaterialProperty layer3Tex = null;
    MaterialProperty layer3Color = null;
    MaterialProperty layer3Smoothness = null;
    MaterialProperty layer3Metallic = null;
    MaterialProperty layer3UVSet = null;
    MaterialProperty layer3Normal = null;
    MaterialProperty layer3NormalScale = null;
    MaterialProperty layer3BlendMode = null;

    MaterialProperty layer4Tex = null;
    MaterialProperty layer4Color = null;
    MaterialProperty layer4Smoothness = null;
    MaterialProperty layer4Metallic = null;
    MaterialProperty layer4UVSet = null;
    MaterialProperty layer4Normal = null;
    MaterialProperty layer4NormalScale = null;
    MaterialProperty layer4BlendMode = null;

    MaterialProperty layer5Tex = null;
    MaterialProperty layer5Color = null;
    MaterialProperty layer5Smoothness = null;
    MaterialProperty layer5Metallic = null;
    MaterialProperty layer5UVSet = null;
    MaterialProperty layer5Normal = null;
    MaterialProperty layer5NormalScale = null;
    MaterialProperty layer5BlendMode = null;

    MaterialProperty layer6Tex = null;
    MaterialProperty layer6Color = null;
    MaterialProperty layer6Smoothness = null;
    MaterialProperty layer6Metallic = null;
    MaterialProperty layer6UVSet = null;
    MaterialProperty layer6Normal = null;
    MaterialProperty layer6NormalScale = null;
    MaterialProperty layer6BlendMode = null;

    MaterialProperty layer7Tex = null;
    MaterialProperty layer7Color = null;
    MaterialProperty layer7Smoothness = null;
    MaterialProperty layer7Metallic = null;
    MaterialProperty layer7UVSet = null;
    MaterialProperty layer7Normal = null;
    MaterialProperty layer7NormalScale = null;
    MaterialProperty layer7BlendMode = null;

    MaterialProperty layerTopTex = null;
    MaterialProperty layerTopColor = null;
    MaterialProperty layerTopSmoothness = null;
    MaterialProperty layerTopMetallic = null;
    MaterialProperty layerTopUVSet = null;
    MaterialProperty layerTopNormal = null;
    MaterialProperty layerTopNormalScale = null;
    MaterialProperty layerTopBlendMode = null;

    MaterialProperty alphaScale = null;

    MaterialProperty emissionColorForRendering = null;
    MaterialProperty emissionMap = null;


    //TCP2
    MaterialProperty tcp2_highlightColor = null;
    MaterialProperty tcp2_shadowColor = null;
    MaterialProperty tcp2_TCP2_DISABLE_WRAPPED_LIGHT = null;
    MaterialProperty tcp2_TCP2_RAMPTEXT = null;
    MaterialProperty tcp2_ramp = null;
    MaterialProperty tcp2_rampThreshold = null;
    MaterialProperty tcp2_rampSmooth = null;
    MaterialProperty tcp2_rampSmoothAdd = null;
    MaterialProperty tcp2_SPEC_TOON = null;
    MaterialProperty tcp2_specSmooth = null;
    MaterialProperty tcp2_SpecBlend = null;
    MaterialProperty rim = null;
    MaterialProperty tcp2_rimStrength = null;
    MaterialProperty tcp2_rimMin = null;
    MaterialProperty tcp2_rimMax = null;
    MaterialProperty tcp2_outlineColor = null;
    MaterialProperty tcp2_outlineWidth = null;
    MaterialProperty tcp2_TCP2_OUTLINE_TEXTURED = null;
    MaterialProperty tcp2_TexLod = null;
    MaterialProperty tcp2_TCP2_OUTLINE_CONST_SIZE = null;
    MaterialProperty tcp2_TCP2_ZSMOOTH_ON = null;
    MaterialProperty tcp2_ZSmooth = null;
    MaterialProperty tcp2_Offset1 = null;
    MaterialProperty tcp2_Offset2 = null;
    MaterialProperty tcp2_srcBlendOutline = null;
    MaterialProperty tcp2_dstBlendOutline = null;

    readonly string[] outlineNormalsKeywords = new string[] { "TCP2_NONE", "TCP2_COLORS_AS_NORMALS", "TCP2_TANGENT_AS_NORMALS", "TCP2_UV2_AS_NORMALS" };

    MaterialEditor m_MaterialEditor;
    WorkflowMode m_WorkflowMode = WorkflowMode.Specular;
#if !UNITY_2018_1_OR_NEWER
	readonly ColorPickerHDRConfig m_ColorPickerHDRConfig = new ColorPickerHDRConfig(0f, 99f, 1/99f, 3f);
#endif

    bool m_FirstTimeApply = true;

    public void FindProperties(MaterialProperty[] props)
    {
        blendMode = FindProperty("_Mode", props);
        albedoMap = FindProperty("_MainTex", props);
        albedoColor = FindProperty("_Color", props);
        alphaCutoff = FindProperty("_Cutoff", props);
        specularMap = FindProperty("_SpecGlossMap", props, false);
        specularColor = FindProperty("_SpecColor", props, false);
        metallicMap = FindProperty("_MetallicGlossMap", props, false);
        metallic = FindProperty("_Metallic", props, false);
        if (specularMap != null && specularColor != null)
            m_WorkflowMode = WorkflowMode.Specular;
        else if (metallicMap != null && metallic != null)
            m_WorkflowMode = WorkflowMode.Metallic;
        else
            m_WorkflowMode = WorkflowMode.Dielectric;
        smoothnessScale = FindProperty("_GlossMapScale", props, false);
        smoothnessMapChannel = FindProperty("_SmoothnessTextureChannel", props, false);
        highlights = FindProperty("_SpecularHighlights", props, false);
        reflections = FindProperty("_GlossyReflections", props, false);
        bumpScale = FindProperty("_BumpScale", props);
        bumpMap = FindProperty("_BumpMap", props);

        // fun dream zone

        reflectionMap = FindProperty("_ReflectionMap", props);
        reflectBrightness = FindProperty("_Brightness", props);
        rotation = FindProperty("_Rotation", props);
        rimColor = FindProperty("_RimColor", props);
        temp = FindProperty("_Temp", props);
        culling = FindProperty("_Culling", props);
        rimOffset = FindProperty("_RimOffset", props);
        rimOffsetX = FindProperty("_RimOffsetX", props);
        rimOffsetY = FindProperty("_RimOffsetY", props);
        rimOffsetZ = FindProperty("_RimOffsetZ", props);
        realFresnel = FindProperty("_Real_Fresnel", props);
        thickness = FindProperty("_Thickness", props);
        gradient = FindProperty("_Gradient", props);
        alphaScale = FindProperty("_AlphaScale", props);

        maskTex = FindProperty("_MaskTex", props);

        uv2 = FindProperty("_UV2", props);
        uv3 = FindProperty("_UV3", props);

        layerBaseTex = FindProperty("_LayerBaseTex", props);
        layerBaseColor = FindProperty("_LayerBaseColor", props);
        layerBaseSmoothness = FindProperty("_LayerBaseSmoothness", props);
        layerBaseMetallic = FindProperty("_LayerBaseMetallic", props);
        layerBaseUVSet = FindProperty("_LayerBaseUVSet", props);
        layerBaseNormal = FindProperty("_LayerBaseNormal", props);
        layerBaseNormalScale = FindProperty("_LayerBaseNormalScale", props);
        layerBaseBlendMode = FindProperty("_LayerBaseBlendMode", props);

        layer2Tex = FindProperty("_Layer2Tex", props);
        layer2Color = FindProperty("_Layer2Color", props);
        layer2Smoothness = FindProperty("_Layer2Smoothness", props);
        layer2Metallic = FindProperty("_Layer2Metallic", props);
        layer2UVSet = FindProperty("_Layer2UVSet", props);
        layer2Normal = FindProperty("_Layer2Normal", props);
        layer2NormalScale = FindProperty("_Layer2NormalScale", props);
        layer2BlendMode = FindProperty("_Layer2BlendMode", props);

        layer3Tex = FindProperty("_Layer3Tex", props);
        layer3Color = FindProperty("_Layer3Color", props);
        layer3Smoothness = FindProperty("_Layer3Smoothness", props);
        layer3Metallic = FindProperty("_Layer3Metallic", props);
        layer3UVSet = FindProperty("_Layer3UVSet", props);
        layer3Normal = FindProperty("_Layer3Normal", props);
        layer3NormalScale = FindProperty("_Layer3NormalScale", props);
        layer3BlendMode = FindProperty("_Layer3BlendMode", props);

        layer4Tex = FindProperty("_Layer4Tex", props);
        layer4Color = FindProperty("_Layer4Color", props);
        layer4Smoothness = FindProperty("_Layer4Smoothness", props);
        layer4Metallic = FindProperty("_Layer4Metallic", props);
        layer4UVSet = FindProperty("_Layer4UVSet", props);
        layer4Normal = FindProperty("_Layer4Normal", props);
        layer4NormalScale = FindProperty("_Layer4NormalScale", props);
        layer4BlendMode = FindProperty("_Layer4BlendMode", props);

        layer5Tex = FindProperty("_Layer5Tex", props);
        layer5Color = FindProperty("_Layer5Color", props);
        layer5Smoothness = FindProperty("_Layer5Smoothness", props);
        layer5Metallic = FindProperty("_Layer5Metallic", props);
        layer5UVSet = FindProperty("_Layer5UVSet", props);
        layer5Normal = FindProperty("_Layer5Normal", props);
        layer5NormalScale = FindProperty("_Layer5NormalScale", props);
        layer5BlendMode = FindProperty("_Layer5BlendMode", props);

        layer6Tex = FindProperty("_Layer6Tex", props);
        layer6Color = FindProperty("_Layer6Color", props);
        layer6Smoothness = FindProperty("_Layer6Smoothness", props);
        layer6Metallic = FindProperty("_Layer6Metallic", props);
        layer6UVSet = FindProperty("_Layer6UVSet", props);
        layer6Normal = FindProperty("_Layer6Normal", props);
        layer6NormalScale = FindProperty("_Layer6NormalScale", props);
        layer6BlendMode = FindProperty("_Layer6BlendMode", props);

        layer7Tex = FindProperty("_Layer7Tex", props);
        layer7Color = FindProperty("_Layer7Color", props);
        layer7Smoothness = FindProperty("_Layer7Smoothness", props);
        layer7Metallic = FindProperty("_Layer7Metallic", props);
        layer7UVSet = FindProperty("_Layer7UVSet", props);
        layer7Normal = FindProperty("_Layer7Normal", props);
        layer7NormalScale = FindProperty("_Layer7NormalScale", props);
        layer7BlendMode = FindProperty("_Layer7BlendMode", props);

        layerTopTex = FindProperty("_LayerTopTex", props);
        layerTopColor = FindProperty("_LayerTopColor", props);
        layerTopSmoothness = FindProperty("_LayerTopSmoothness", props);
        layerTopMetallic = FindProperty("_LayerTopMetallic", props);
        layerTopUVSet = FindProperty("_LayerTopUVSet", props);
        layerTopNormal = FindProperty("_LayerTopNormal", props);
        layerTopNormalScale = FindProperty("_LayerTopNormalScale", props);
        layerTopBlendMode = FindProperty("_LayerTopBlendMode", props);


        occlusionStrength = FindProperty("_OcclusionStrength", props);
        occlusionMap = FindProperty("_OcclusionMap", props);
        emissionColorForRendering = FindProperty("_EmissionColor", props);
        emissionMap = FindProperty("_EmissionMap", props);


        //TCP2
        tcp2_highlightColor = FindProperty("_HColor", props);
        tcp2_shadowColor = FindProperty("_SColor", props);

        tcp2_rampThreshold = FindProperty("_RampThreshold", props);
        tcp2_rampSmooth = FindProperty("_RampSmooth", props);
        tcp2_rampSmoothAdd = FindProperty("_RampSmoothAdd", props);
        tcp2_TCP2_DISABLE_WRAPPED_LIGHT = FindProperty("_TCP2_DISABLE_WRAPPED_LIGHT", props);
        tcp2_TCP2_RAMPTEXT = FindProperty("_TCP2_RAMPTEXT", props);
        tcp2_ramp = FindProperty("_Ramp", props);

        tcp2_SPEC_TOON = FindProperty("_TCP2_SPEC_TOON", props);
        tcp2_specSmooth = FindProperty("_SpecSmooth", props);
        tcp2_SpecBlend = FindProperty("_SpecBlend", props);

        rim = FindProperty("_RIM", props);
        tcp2_rimStrength = FindProperty("_RimStrength", props);
        tcp2_rimMin = FindProperty("_RimMin", props);
        tcp2_rimMax = FindProperty("_RimMax", props);

        tcp2_outlineColor = FindProperty("_OutlineColor", props, false);
        tcp2_outlineWidth = FindProperty("_Outline", props, false);
        tcp2_TCP2_OUTLINE_TEXTURED = FindProperty("_TCP2_OUTLINE_TEXTURED", props, false);
        tcp2_TexLod = FindProperty("_TexLod", props, false);
        tcp2_TCP2_OUTLINE_CONST_SIZE = FindProperty("_TCP2_OUTLINE_CONST_SIZE", props, false);
        tcp2_TCP2_ZSMOOTH_ON = FindProperty("_TCP2_ZSMOOTH_ON", props, false);
        tcp2_ZSmooth = FindProperty("_ZSmooth", props, false);
        tcp2_Offset1 = FindProperty("_Offset1", props, false);
        tcp2_Offset2 = FindProperty("_Offset2", props, false);
        tcp2_srcBlendOutline = FindProperty("_SrcBlendOutline", props, false);
        tcp2_dstBlendOutline = FindProperty("_DstBlendOutline", props, false);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        FindProperties(props); // MaterialProperties can be animated so we do not cache them but fetch them every event to ensure animated values are updated correctly
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;

        // Make sure that needed setup (ie keywords/renderqueue) are set up if we're switching some existing
        // material to a standard shader.
        // Do this before any GUI code has been issued to prevent layout issues in subsequent GUILayout statements (case 780071)
        if (m_FirstTimeApply)
        {
            MaterialChanged(material, m_WorkflowMode);
            m_FirstTimeApply = false;
        }

        ShaderPropertiesGUI(material);

#if UNITY_5_5_OR_NEWER
        materialEditor.RenderQueueField();
#endif
#if UNITY_5_6_OR_NEWER
        materialEditor.EnableInstancingField();
#endif
        GUILayout.EndVertical();

    }

    public void ShaderPropertiesGUI(Material material)
    {
        // Use default labelWidth
        EditorGUIUtility.labelWidth = 0f;

        // Detect any changes to the material
        EditorGUI.BeginChangeCheck();
        {
            BlendModePopup();

            GUILayout.Space(8f);

            //Background
            Rect vertRect = EditorGUILayout.BeginVertical();
            vertRect.xMax += 2;
            vertRect.xMin--;
            GUI.Box(vertRect, "", (GUIStyle)"RL Background");
            GUILayout.Space(4f);
            
            // Primary properties
            GUILayout.Label(Styles.primaryMapsText, EditorStyles.boldLabel);

            DoReflectionArea(material);

            //m_MaterialEditor.ShaderProperty(temp, Styles.tempText);

            DoAlbedoArea(material);
            DoSpecularMetallicArea();
            m_MaterialEditor.TexturePropertySingleLine(Styles.normalMapText, bumpMap,
                                                        bumpMap.textureValue != null ? bumpScale : null);



            m_MaterialEditor.TexturePropertySingleLine(Styles.occlusionText, occlusionMap,
                                                        occlusionMap.textureValue != null ? occlusionStrength : null);
            DoEmissionArea(material);
            //m_MaterialEditor.TexturePropertySingleLine(Styles.detailMaskText, detailMask);
            EditorGUI.BeginChangeCheck();
            m_MaterialEditor.TextureScaleOffsetProperty(albedoMap);
            if (EditorGUI.EndChangeCheck())
                emissionMap.textureScaleAndOffset = albedoMap.textureScaleAndOffset;
            // Apply the main texture scale and offset to the emission texture as well, for Enlighten's sake

            EditorGUILayout.Space();


            // Third properties
            GUILayout.Label(Styles.forwardText, EditorStyles.boldLabel);
            if (highlights != null)
                m_MaterialEditor.ShaderProperty(highlights, Styles.highlightsText);
            if (reflections != null)
                m_MaterialEditor.ShaderProperty(reflections, Styles.reflectionsText);

            GUILayout.Space(8f);


            //----------------------------------------------------------------
            // additional properties

            GUILayout.Label("Base Properties", EditorStyles.boldLabel);
            m_MaterialEditor.ColorProperty(tcp2_highlightColor, Styles.tcp2_highlightColorText);
            m_MaterialEditor.ColorProperty(tcp2_shadowColor, Styles.tcp2_shadowColorText);

            // Wrapped Lighting
            m_MaterialEditor.ShaderProperty(tcp2_TCP2_DISABLE_WRAPPED_LIGHT, "Disable Wrapped Lighting");

            // Ramp Texture / Threshold
            m_MaterialEditor.ShaderProperty(tcp2_TCP2_RAMPTEXT, "Use Ramp Texture");
            if (tcp2_TCP2_RAMPTEXT.floatValue > 0)
            {
                EditorGUI.indentLevel++;
                m_MaterialEditor.ShaderProperty(tcp2_ramp, Styles.tcp2_rampText);
                //m_MaterialEditor.TexturePropertySingleLine(Styles.tcp2_rampText, tcp2_ramp);
                EditorGUI.indentLevel--;
            }
            else
            {
                m_MaterialEditor.ShaderProperty(tcp2_rampThreshold, Styles.tcp2_rampThresholdText.text, 1);
                m_MaterialEditor.ShaderProperty(tcp2_rampSmooth, Styles.tcp2_rampSmoothText.text, 1);
                m_MaterialEditor.ShaderProperty(tcp2_rampSmoothAdd, Styles.tcp2_rampSmoothAddText.text, 1);
            }


            // Stylized Specular
            m_MaterialEditor.ShaderProperty(tcp2_SPEC_TOON, "Stylized Specular");
            if (tcp2_SPEC_TOON.floatValue > 0)
            {
                m_MaterialEditor.ShaderProperty(tcp2_specSmooth, Styles.tcp2_specSmoothText.text, 1);
                m_MaterialEditor.ShaderProperty(tcp2_SpecBlend, Styles.tcp2_SpecBlendText.text, 1);

                EditorGUILayout.Space();
            }

            //Stylized Fresnel
            m_MaterialEditor.ShaderProperty(rim, "Rim");
            if (rim.floatValue > 0)
            {
                m_MaterialEditor.ShaderProperty(rimColor, Styles.rimColorText.text, 1);
                m_MaterialEditor.ShaderProperty(tcp2_rimStrength, Styles.tcp2_rimStrengthText.text, 1);
                m_MaterialEditor.ShaderProperty(tcp2_rimMin, Styles.tcp2_rimMinText.text, 1);
                m_MaterialEditor.ShaderProperty(tcp2_rimMax, Styles.tcp2_rimMaxText.text, 1);
                m_MaterialEditor.ShaderProperty(rimOffset, Styles.rimOffsetText.text, 1);
                if (rimOffset.floatValue > 0) { 
                    m_MaterialEditor.ShaderProperty(rimOffsetX, Styles.rimOffsetXText.text, 1);
                    m_MaterialEditor.ShaderProperty(rimOffsetY, Styles.rimOffsetYText.text, 1);
                    m_MaterialEditor.ShaderProperty(rimOffsetZ, Styles.rimOffsetZText.text, 1);
                }
                EditorGUILayout.Space();
            }

            //// Real Fresnel
            m_MaterialEditor.ShaderProperty(realFresnel, Styles.realFresnelText.text, 0);
            if (realFresnel.floatValue > 0 && (BlendMode)material.GetFloat("_Mode") == BlendMode.Fade ||
                realFresnel.floatValue > 0 && (BlendMode)material.GetFloat("_Mode") == BlendMode.Transparent)
            {   
                m_MaterialEditor.ShaderProperty(thickness, Styles.thicknessText.text, 1);
                m_MaterialEditor.ShaderProperty(gradient, Styles.gradientText.text, 1);
            }

            // layer system
            GUILayout.Label("Mask", EditorStyles.boldLabel);
            m_MaterialEditor.TexturePropertySingleLine(Styles.maskTexText, maskTex);


            GUILayout.Label("Layers", EditorStyles.boldLabel);
            m_MaterialEditor.ShaderProperty(uv2, Styles.uv2Text.text, 0);
            m_MaterialEditor.ShaderProperty(uv3, Styles.uv3Text.text, 0);

            // layerBase
            m_MaterialEditor.TexturePropertySingleLine(Styles.layerBaseTexText, layerBaseTex);
            m_MaterialEditor.TexturePropertySingleLine(Styles.layerBaseNormalText, layerBaseNormal, layerBaseNormalScale);
            if (material.GetTexture("_LayerBaseTex"))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(layerBaseTex);
                m_MaterialEditor.ShaderProperty(layerBaseColor, Styles.layerBaseColorText.text, 2);
                m_MaterialEditor.ShaderProperty(layerBaseSmoothness, Styles.layerBaseSmoothnessText.text, 2);
                m_MaterialEditor.ShaderProperty(layerBaseMetallic, Styles.layerBaseMetallicText.text, 2);
                m_MaterialEditor.ShaderProperty(layerBaseUVSet, Styles.layerBaseUVSetText.text, 2);
                m_MaterialEditor.ShaderProperty(layerBaseBlendMode, Styles.layerBaseBlendModeText.text, 2);
                if (material.GetTexture("_MaskTex"))
                    GUILayout.Label("       LayerBaseMask: MaskTex(R)");
            }
            else if (material.GetTexture("_LayerBaseNormal"))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(layerBaseTex);
                m_MaterialEditor.ShaderProperty(layerBaseUVSet, Styles.layerBaseUVSetText.text, 2);
                if (material.GetTexture("_MaskTex"))
                    GUILayout.Label("       LayerBaseMask: MaskTex(R)");
            }

            //EditorGUILayout.Space();
            GUILayout.Label("--------------------------------");

            // layer2
            m_MaterialEditor.TexturePropertySingleLine(Styles.layer2TexText, layer2Tex);
            m_MaterialEditor.TexturePropertySingleLine(Styles.layer2NormalText, layer2Normal, layer2NormalScale);
            if (material.GetTexture("_Layer2Tex"))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(layer2Tex);
                m_MaterialEditor.ShaderProperty(layer2Color, Styles.layer2ColorText.text, 2);
                m_MaterialEditor.ShaderProperty(layer2Smoothness, Styles.layer2SmoothnessText.text, 2);
                m_MaterialEditor.ShaderProperty(layer2Metallic, Styles.layer2MetallicText.text, 2);
                m_MaterialEditor.ShaderProperty(layer2UVSet, Styles.layer2UVSetText.text, 2);
                m_MaterialEditor.ShaderProperty(layer2BlendMode, Styles.layer2BlendModeText.text, 2);
                if (material.GetTexture("_MaskTex"))
                    GUILayout.Label("       Layer2Mask: MaskTex(R)");
            }
            else if (material.GetTexture("_Layer2Normal"))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(layer2Tex);
                m_MaterialEditor.ShaderProperty(layer2UVSet, Styles.layer2UVSetText.text, 2);
                if (material.GetTexture("_MaskTex"))
                    GUILayout.Label("       Layer2Mask: MaskTex(R)");
            }

            GUILayout.Label("--------------------------------");

            // layer3
            m_MaterialEditor.TexturePropertySingleLine(Styles.layer3TexText, layer3Tex);
            m_MaterialEditor.TexturePropertySingleLine(Styles.layer3NormalText, layer3Normal, layer3NormalScale);
            if (material.GetTexture("_Layer3Tex"))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(layer3Tex);
                m_MaterialEditor.ShaderProperty(layer3Color, Styles.layer3ColorText.text, 2);
                m_MaterialEditor.ShaderProperty(layer3Smoothness, Styles.layer3SmoothnessText.text, 2);
                m_MaterialEditor.ShaderProperty(layer3Metallic, Styles.layer3MetallicText.text, 2);
                m_MaterialEditor.ShaderProperty(layer3UVSet, Styles.layer3UVSetText.text, 2);
                m_MaterialEditor.ShaderProperty(layer3BlendMode, Styles.layer3BlendModeText.text, 2);
                if (material.GetTexture("_MaskTex"))
                    GUILayout.Label("       Layer3Mask: MaskTex(G)");
            }
            else if (material.GetTexture("_Layer3Normal"))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(layer3Tex);
                m_MaterialEditor.ShaderProperty(layer3UVSet, Styles.layer3UVSetText.text, 2);
                if (material.GetTexture("_MaskTex"))
                    GUILayout.Label("       Layer3Mask: MaskTex(G)");
            }

            GUILayout.Label("--------------------------------");

            // layer4
            m_MaterialEditor.TexturePropertySingleLine(Styles.layer4TexText, layer4Tex);
            m_MaterialEditor.TexturePropertySingleLine(Styles.layer4NormalText, layer4Normal, layer4NormalScale);
            if (material.GetTexture("_Layer4Tex"))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(layer4Tex);
                m_MaterialEditor.ShaderProperty(layer4Color, Styles.layer4ColorText.text, 2);
                m_MaterialEditor.ShaderProperty(layer4Smoothness, Styles.layer4SmoothnessText.text, 2);
                m_MaterialEditor.ShaderProperty(layer4Metallic, Styles.layer4MetallicText.text, 2);
                m_MaterialEditor.ShaderProperty(layer4UVSet, Styles.layer4UVSetText.text, 2);
                m_MaterialEditor.ShaderProperty(layer4BlendMode, Styles.layer4BlendModeText.text, 2);
                if (material.GetTexture("_MaskTex"))
                    GUILayout.Label("       Layer4Mask: MaskTex(G)");
            }
            else if (material.GetTexture("_Layer4Normal"))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(layer4Tex);
                m_MaterialEditor.ShaderProperty(layer4UVSet, Styles.layer4UVSetText.text, 2);
                if (material.GetTexture("_MaskTex"))
                    GUILayout.Label("       Layer4Mask: MaskTex(G)");
            }

            GUILayout.Label("--------------------------------");

            // layer5
            m_MaterialEditor.TexturePropertySingleLine(Styles.layer5TexText, layer5Tex);
            m_MaterialEditor.TexturePropertySingleLine(Styles.layer5NormalText, layer5Normal, layer5NormalScale);
            if (material.GetTexture("_Layer5Tex"))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(layer5Tex);
                m_MaterialEditor.ShaderProperty(layer5Color, Styles.layer5ColorText.text, 2);
                m_MaterialEditor.ShaderProperty(layer5Smoothness, Styles.layer5SmoothnessText.text, 2);
                m_MaterialEditor.ShaderProperty(layer5Metallic, Styles.layer5MetallicText.text, 2);
                m_MaterialEditor.ShaderProperty(layer5UVSet, Styles.layer5UVSetText.text, 2);
                m_MaterialEditor.ShaderProperty(layer5BlendMode, Styles.layer5BlendModeText.text, 2);
                if (material.GetTexture("_MaskTex"))
                    GUILayout.Label("       Layer5Mask: MaskTex(B)");
            }
            else if (material.GetTexture("_Layer5Normal"))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(layer5Tex);
                m_MaterialEditor.ShaderProperty(layer5UVSet, Styles.layer5UVSetText.text, 2);
                if (material.GetTexture("_MaskTex"))
                    GUILayout.Label("       Layer5Mask: MaskTex(B)");
            }

            GUILayout.Label("--------------------------------");

            // layer6
            m_MaterialEditor.TexturePropertySingleLine(Styles.layer6TexText, layer6Tex);
            m_MaterialEditor.TexturePropertySingleLine(Styles.layer6NormalText, layer6Normal, layer6NormalScale);
            if (material.GetTexture("_Layer6Tex"))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(layer6Tex);
                m_MaterialEditor.ShaderProperty(layer6Color, Styles.layer6ColorText.text, 2);
                m_MaterialEditor.ShaderProperty(layer6Smoothness, Styles.layer6SmoothnessText.text, 2);
                m_MaterialEditor.ShaderProperty(layer6Metallic, Styles.layer6MetallicText.text, 2);
                m_MaterialEditor.ShaderProperty(layer6UVSet, Styles.layer6UVSetText.text, 2);
                m_MaterialEditor.ShaderProperty(layer6BlendMode, Styles.layer6BlendModeText.text, 2);
                if (material.GetTexture("_MaskTex"))
                    GUILayout.Label("       Layer6Mask: MaskTex(B)");
            }
            else if (material.GetTexture("_Layer6Normal"))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(layer6Tex);
                m_MaterialEditor.ShaderProperty(layer6UVSet, Styles.layer6UVSetText.text, 2);
                if (material.GetTexture("_MaskTex"))
                    GUILayout.Label("       Layer6Mask: MaskTex(B)");
            }

            GUILayout.Label("--------------------------------");

            // layer7
            m_MaterialEditor.TexturePropertySingleLine(Styles.layer7TexText, layer7Tex);
            m_MaterialEditor.TexturePropertySingleLine(Styles.layer7NormalText, layer7Normal, layer7NormalScale);
            if (material.GetTexture("_Layer7Tex"))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(layer7Tex);
                m_MaterialEditor.ShaderProperty(layer7Color, Styles.layer7ColorText.text, 2);
                m_MaterialEditor.ShaderProperty(layer7Smoothness, Styles.layer7SmoothnessText.text, 2);
                m_MaterialEditor.ShaderProperty(layer7Metallic, Styles.layer7MetallicText.text, 2);
                m_MaterialEditor.ShaderProperty(layer7UVSet, Styles.layer7UVSetText.text, 2);
                m_MaterialEditor.ShaderProperty(layer7BlendMode, Styles.layer7BlendModeText.text, 2);
                if (material.GetTexture("_MaskTex"))
                    GUILayout.Label("       Layer7Mask: MaskTex(A)");
            }
            else if (material.GetTexture("_Layer7Normal"))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(layer7Tex);
                m_MaterialEditor.ShaderProperty(layer7UVSet, Styles.layer7UVSetText.text, 2);
                if (material.GetTexture("_MaskTex"))
                    GUILayout.Label("       Layer7Mask: MaskTex(A)");
            }

            GUILayout.Label("--------------------------------");

            // layerTop
            m_MaterialEditor.TexturePropertySingleLine(Styles.layerTopTexText, layerTopTex);
            m_MaterialEditor.TexturePropertySingleLine(Styles.layerTopNormalText, layerTopNormal, layerTopNormalScale);
            if (material.GetTexture("_LayerTopTex"))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(layerTopTex);
                m_MaterialEditor.ShaderProperty(layerTopColor, Styles.layerTopColorText.text, 2);
                m_MaterialEditor.ShaderProperty(layerTopSmoothness, Styles.layerTopSmoothnessText.text, 2);
                m_MaterialEditor.ShaderProperty(layerTopMetallic, Styles.layerTopMetallicText.text, 2);
                m_MaterialEditor.ShaderProperty(layerTopUVSet, Styles.layerTopUVSetText.text, 2);
                m_MaterialEditor.ShaderProperty(layerTopBlendMode, Styles.layerTopBlendModeText.text, 2);
                if (material.GetTexture("_MaskTex")) 
                    GUILayout.Label("       LayerTopMask: MaskTex(A)");
            }
            else if (material.GetTexture("_LayerTopNormal"))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(layerTopTex);
                m_MaterialEditor.ShaderProperty(layerTopUVSet, Styles.layerTopUVSetText.text, 2);
                if (material.GetTexture("_MaskTex"))
                    GUILayout.Label("       LayerTopMask: MaskTex(A)");
                    
            }

            GUILayout.Label("--------------------------------");
            //GUILayout.EndVertical();
        }

        if (EditorGUI.EndChangeCheck())
        {
            foreach (var obj in blendMode.targets)
                MaterialChanged((Material)obj, m_WorkflowMode);
        }

        
    }

    void UpdateOutlineNormalsKeyword(int index)
    {
        string selectedKeyword = outlineNormalsKeywords[index];

        foreach (var obj in m_MaterialEditor.targets)
        {
            if (obj is Material)
            {
                Material m = obj as Material;
                foreach (var kw in outlineNormalsKeywords)
                    m.DisableKeyword(kw);
                m.EnableKeyword(selectedKeyword);
            }
        }
    }

    internal void DetermineWorkflow(MaterialProperty[] props)
    {
        if (FindProperty("_SpecGlossMap", props, false) != null && FindProperty("_SpecColor", props, false) != null)
            m_WorkflowMode = WorkflowMode.Specular;
        else if (FindProperty("_MetallicGlossMap", props, false) != null && FindProperty("_Metallic", props, false) != null)
            m_WorkflowMode = WorkflowMode.Metallic;
        else
            m_WorkflowMode = WorkflowMode.Dielectric;
    }

    public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
    {
        // _Emission property is lost after assigning Standard shader to the material
        // thus transfer it before assigning the new shader
        if (material.HasProperty("_Emission"))
        {
            material.SetColor("_EmissionColor", material.GetColor("_Emission"));
        }

        base.AssignNewShaderToMaterial(material, oldShader, newShader);

        if (oldShader == null || !oldShader.name.Contains("Legacy Shaders/"))
        {
            SetupMaterialWithBlendMode(material, (BlendMode)material.GetFloat("_Mode"));
            return;
        }

        BlendMode blendMode = BlendMode.Opaque;
        if (oldShader.name.Contains("/Transparent/Cutout/"))
        {
            blendMode = BlendMode.Cutout;
        }
        else if (oldShader.name.Contains("/Transparent/"))
        {
            // NOTE: legacy shaders did not provide physically based transparency
            // therefore Fade mode
            blendMode = BlendMode.Fade;
        }
        material.SetFloat("_Mode", (float)blendMode);

        DetermineWorkflow(MaterialEditor.GetMaterialProperties(new Material[] { material }));
        MaterialChanged(material, m_WorkflowMode);
    }

    void BlendModePopup()
    {
        EditorGUI.showMixedValue = blendMode.hasMixedValue;
        var mode = (BlendMode)blendMode.floatValue;

        EditorGUI.BeginChangeCheck();
        mode = (BlendMode)EditorGUILayout.Popup(Styles.renderingMode, (int)mode, Styles.blendNames);
        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("Rendering Mode");
            blendMode.floatValue = (float)mode;
        }

        EditorGUI.showMixedValue = false;
    }


    // fun dream added
    void DoReflectionArea(Material material)
    {
        m_MaterialEditor.ShaderProperty(culling, Styles.cullingText);

        m_MaterialEditor.TexturePropertySingleLine(Styles.reflectionMapText, reflectionMap);
        if (material.GetTexture("_ReflectionMap"))
        {
            m_MaterialEditor.ShaderProperty(reflectBrightness, Styles.reflectBrightnessText, 2);
            m_MaterialEditor.ShaderProperty(rotation, Styles.rotationText, 2);

            //float angle = material.GetFloat("_Rotation");
            //if ( angle > 0)
            //{
            //    Quaternion rot = Quaternion.Euler (0, angle, 0);
            //    Matrix4x4 m = new Matrix4x4();
            //    m.SetTRS(Vector3.zero, rot, new Vector3(1, 1, 1));
            //    material.SetMatrix("_Rotation", m);
            //}
        }
    }


    void DoAlbedoArea(Material material)
    {
        m_MaterialEditor.TexturePropertySingleLine(Styles.albedoText, albedoMap, albedoColor);
        if (((BlendMode)material.GetFloat("_Mode") == BlendMode.Cutout))
        {
            m_MaterialEditor.ShaderProperty(alphaCutoff, Styles.alphaCutoffText.text, MaterialEditor.kMiniTextureFieldLabelIndentLevel + 0);
        }
        m_MaterialEditor.ShaderProperty(alphaScale, Styles.alphaScaleText.text, 2);

    }

    void DoEmissionArea(Material material)
    {
        bool showHelpBox = !HasValidEmissiveKeyword(material);

        bool hadEmissionTexture = emissionMap.textureValue != null;

        // Texture and HDR color controls
#if !UNITY_2018_1_OR_NEWER
		m_MaterialEditor.TexturePropertyWithHDRColor(Styles.emissionText, emissionMap, emissionColorForRendering, m_ColorPickerHDRConfig, false);
#else
        m_MaterialEditor.TexturePropertyWithHDRColor(Styles.emissionText, emissionMap, emissionColorForRendering, false);
#endif

        // If texture was assigned and color was black set color to white
        float brightness = emissionColorForRendering.colorValue.maxColorComponent;
        if (emissionMap.textureValue != null && !hadEmissionTexture && brightness <= 0f)
            emissionColorForRendering.colorValue = Color.white;

        // Emission for GI?
        m_MaterialEditor.LightmapEmissionProperty(MaterialEditor.kMiniTextureFieldLabelIndentLevel + 0);

        if (showHelpBox)
        {
            EditorGUILayout.HelpBox(Styles.emissiveWarning.text, MessageType.Warning);
        }
    }

    void DoSpecularMetallicArea()
    {
        bool hasGlossMap = false;
        if (m_WorkflowMode == WorkflowMode.Specular)
        {
            hasGlossMap = specularMap.textureValue != null;
            m_MaterialEditor.TexturePropertySingleLine(Styles.specularMapText, specularMap, hasGlossMap ? null : specularColor);
        }
        else if (m_WorkflowMode == WorkflowMode.Metallic)
        {
            m_MaterialEditor.TexturePropertySingleLine(Styles.metallicMapText, metallicMap, metallic);
        }

        bool showSmoothnessScale = true;


        int indentation = 2; // align with labels of texture properties
        m_MaterialEditor.ShaderProperty(showSmoothnessScale ? smoothnessScale : smoothness, showSmoothnessScale ? Styles.smoothnessScaleText : Styles.smoothnessText, indentation);

    }

    public static void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
    {
        switch (blendMode)
        {
            case BlendMode.Opaque:
                material.SetOverrideTag("RenderType", "");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                material.DisableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = -1;
                break;
            case BlendMode.Cutout:
                material.SetOverrideTag("RenderType", "TransparentCutout");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                material.EnableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                break;
            case BlendMode.Fade:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                material.DisableKeyword("_ALPHATEST_ON");
                material.EnableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
            case BlendMode.Transparent:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                material.DisableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
        }
    }

    static SmoothnessMapChannel GetSmoothnessMapChannel(Material material)
    {
        int ch = (int)material.GetFloat("_SmoothnessTextureChannel");
        if (ch == (int)SmoothnessMapChannel.AlbedoAlpha)
            return SmoothnessMapChannel.AlbedoAlpha;
        else
            return SmoothnessMapChannel.SpecularMetallicAlpha;
    }

    static bool ShouldEmissionBeEnabled(Material mat, Color color)
    {
        var realtimeEmission = (mat.globalIlluminationFlags & MaterialGlobalIlluminationFlags.RealtimeEmissive) > 0;
        return color.maxColorComponent > 0.1f / 255.0f || realtimeEmission;
    }

    static void SetMaterialKeywords(Material material, WorkflowMode workflowMode)
    {
        // Note: keywords must be based on Material value not on MaterialProperty due to multi-edit & material animation
        // (MaterialProperty value might come from renderer material property block)
        SetKeyword(material, "_NORMALMAP", material.GetTexture("_BumpMap") || material.GetTexture("_DetailNormalMap"));
        if (workflowMode == WorkflowMode.Specular)
            SetKeyword(material, "_SPECGLOSSMAP", material.GetTexture("_SpecGlossMap"));
        else if (workflowMode == WorkflowMode.Metallic)
            SetKeyword(material, "_METALLICGLOSSMAP", material.GetTexture("_MetallicGlossMap"));

        bool shouldEmissionBeEnabled = ShouldEmissionBeEnabled(material, material.GetColor("_EmissionColor"));
        SetKeyword(material, "_EMISSION", shouldEmissionBeEnabled);


        // fun dream zone
        SetKeyword(material, "_REFLECTIONMAP", material.GetTexture("_ReflectionMap"));
        SetKeyword(material, "_RIMOFFSET", material.GetFloat("_RimOffset") > 0);

        SetKeyword(material, "_REAL_FRESNEL", material.GetFloat("_Real_Fresnel") > 0 && (BlendMode)material.GetFloat("_Mode") == BlendMode.Fade ||
        material.GetFloat("_Real_Fresnel") > 0 && (BlendMode)material.GetFloat("_Mode") == BlendMode.Transparent);

        // layer system
        SetKeyword(material, "_UV3_ON", material.GetFloat("_UV2") == 1);
        SetKeyword(material, "_UV4_ON", material.GetFloat("_UV3") == 1);

        SetKeyword(material, "_MASKTEX", material.GetTexture("_MaskTex"));

        SetKeyword(material, "_LAYER_BASE_TEX",  material.GetTexture("_LayerBaseTex") );
        SetKeyword(material, "_LAYER_2_TEX", material.GetTexture("_Layer2Tex"));
        SetKeyword(material, "_LAYER_3_TEX", material.GetTexture("_Layer3Tex"));
        SetKeyword(material, "_LAYER_4_TEX", material.GetTexture("_Layer4Tex"));
        SetKeyword(material, "_LAYER_5_TEX", material.GetTexture("_Layer5Tex"));
        SetKeyword(material, "_LAYER_6_TEX", material.GetTexture("_Layer6Tex"));
        SetKeyword(material, "_LAYER_7_TEX", material.GetTexture("_Layer7Tex"));
        SetKeyword(material, "_LAYER_TOP_TEX", material.GetTexture("_LayerTopTex"));

        SetKeyword(material, "_LAYER_BASE_NORMAL", material.GetTexture("_LayerBaseNormal"));
        SetKeyword(material, "_LAYER_2_NORMAL", material.GetTexture("_Layer2Normal"));
        SetKeyword(material, "_LAYER_3_NORMAL", material.GetTexture("_Layer3Normal"));
        SetKeyword(material, "_LAYER_4_NORMAL", material.GetTexture("_Layer4Normal"));
        SetKeyword(material, "_LAYER_5_NORMAL", material.GetTexture("_Layer5Normal"));
        SetKeyword(material, "_LAYER_6_NORMAL", material.GetTexture("_Layer6Normal"));
        SetKeyword(material, "_LAYER_7_NORMAL", material.GetTexture("_Layer7Normal"));
        SetKeyword(material, "_LAYER_TOP_NORMAL", material.GetTexture("_LayerTopNormal"));

        // set key for layer uv set
        SetKeyword(material, "_LayerBaseUVSet_0", material.GetFloat("_LayerBaseUVSet")==0);
        SetKeyword(material, "_LayerBaseUVSet_1", material.GetFloat("_LayerBaseUVSet") == 1);
        SetKeyword(material, "_LayerBaseUVSet_2", material.GetFloat("_LayerBaseUVSet") == 2);
        SetKeyword(material, "_LayerBaseUVSet_3", material.GetFloat("_LayerBaseUVSet") == 3);

        SetKeyword(material, "_Layer2UVSet_0", material.GetFloat("_Layer2UVSet") == 0);
        SetKeyword(material, "_Layer2UVSet_1", material.GetFloat("_Layer2UVSet") == 1);
        SetKeyword(material, "_Layer2UVSet_2", material.GetFloat("_Layer2UVSet") == 2);
        SetKeyword(material, "_Layer2UVSet_3", material.GetFloat("_Layer2UVSet") == 3);

        SetKeyword(material, "_Layer3UVSet_0", material.GetFloat("_Layer3UVSet") == 0);
        SetKeyword(material, "_Layer3UVSet_1", material.GetFloat("_Layer3UVSet") == 1);
        SetKeyword(material, "_Layer3UVSet_2", material.GetFloat("_Layer3UVSet") == 2);
        SetKeyword(material, "_Layer3UVSet_3", material.GetFloat("_Layer3UVSet") == 3);

        SetKeyword(material, "_Layer4UVSet_0", material.GetFloat("_Layer4UVSet") == 0);
        SetKeyword(material, "_Layer4UVSet_1", material.GetFloat("_Layer4UVSet") == 1);
        SetKeyword(material, "_Layer4UVSet_2", material.GetFloat("_Layer4UVSet") == 2);
        SetKeyword(material, "_Layer4UVSet_3", material.GetFloat("_Layer4UVSet") == 3);

        SetKeyword(material, "_Layer5UVSet_0", material.GetFloat("_Layer5UVSet") == 0);
        SetKeyword(material, "_Layer5UVSet_1", material.GetFloat("_Layer5UVSet") == 1);
        SetKeyword(material, "_Layer5UVSet_2", material.GetFloat("_Layer5UVSet") == 2);
        SetKeyword(material, "_Layer5UVSet_3", material.GetFloat("_Layer5UVSet") == 3);

        SetKeyword(material, "_Layer6UVSet_0", material.GetFloat("_Layer6UVSet") == 0);
        SetKeyword(material, "_Layer6UVSet_1", material.GetFloat("_Layer6UVSet") == 1);
        SetKeyword(material, "_Layer6UVSet_2", material.GetFloat("_Layer6UVSet") == 2);
        SetKeyword(material, "_Layer6UVSet_3", material.GetFloat("_Layer6UVSet") == 3);

        SetKeyword(material, "_Layer7UVSet_0", material.GetFloat("_Layer7UVSet") == 0);
        SetKeyword(material, "_Layer7UVSet_1", material.GetFloat("_Layer7UVSet") == 1);
        SetKeyword(material, "_Layer7UVSet_2", material.GetFloat("_Layer7UVSet") == 2);
        SetKeyword(material, "_Layer7UVSet_3", material.GetFloat("_Layer7UVSet") == 3);

        SetKeyword(material, "_LayerTopUVSet_0", material.GetFloat("_LayerTopUVSet") == 0);
        SetKeyword(material, "_LayerTopUVSet_1", material.GetFloat("_LayerTopUVSet") == 1);
        SetKeyword(material, "_LayerTopUVSet_2", material.GetFloat("_LayerTopUVSet") == 2);
        SetKeyword(material, "_LayerTopUVSet_3", material.GetFloat("_LayerTopUVSet") == 3);

        // set key for layer Blend Mode
        SetKeyword(material, "_LayerBase_Blend_Normal", material.GetFloat("_LayerBaseBlendMode") == 0);
        SetKeyword(material, "_LayerBase_Blend_Multiply", material.GetFloat("_LayerBaseBlendMode") == 1);

        SetKeyword(material, "_Layer2_Blend_Normal", material.GetFloat("_Layer2BlendMode") == 0);
        SetKeyword(material, "_Layer2_Blend_Multiply", material.GetFloat("_Layer2BlendMode") == 1);

        SetKeyword(material, "_Layer3_Blend_Normal", material.GetFloat("_Layer3BlendMode") == 0);
        SetKeyword(material, "_Layer3_Blend_Multiply", material.GetFloat("_Layer3BlendMode") == 1);

        SetKeyword(material, "_Layer4_Blend_Normal", material.GetFloat("_Layer4BlendMode") == 0);
        SetKeyword(material, "_Layer4_Blend_Multiply", material.GetFloat("_Layer4BlendMode") == 1);

        SetKeyword(material, "_Layer5_Blend_Normal", material.GetFloat("_Layer5BlendMode") == 0);
        SetKeyword(material, "_Layer5_Blend_Multiply", material.GetFloat("_Layer5BlendMode") == 1);

        SetKeyword(material, "_Layer6_Blend_Normal", material.GetFloat("_Layer6BlendMode") == 0);
        SetKeyword(material, "_Layer6_Blend_Multiply", material.GetFloat("_Layer6BlendMode") == 1);

        SetKeyword(material, "_Layer7_Blend_Normal", material.GetFloat("_Layer7BlendMode") == 0);
        SetKeyword(material, "_Layer7_Blend_Multiply", material.GetFloat("_Layer7BlendMode") == 1);

        SetKeyword(material, "_LayerTop_Blend_Normal", material.GetFloat("_LayerTopBlendMode") == 0);
        SetKeyword(material, "_LayerTop_Blend_Multiply", material.GetFloat("_LayerTopBlendMode") == 1);


        // Setup lightmap emissive flags
        MaterialGlobalIlluminationFlags flags = material.globalIlluminationFlags;
        if ((flags & (MaterialGlobalIlluminationFlags.BakedEmissive | MaterialGlobalIlluminationFlags.RealtimeEmissive)) != 0)
        {
            flags &= ~MaterialGlobalIlluminationFlags.EmissiveIsBlack;
            if (!shouldEmissionBeEnabled)
                flags |= MaterialGlobalIlluminationFlags.EmissiveIsBlack;

            material.globalIlluminationFlags = flags;
        }
    }

    bool HasValidEmissiveKeyword(Material material)
    {
        // Material animation might be out of sync with the material keyword.
        // So if the emission support is disabled on the material, but the property blocks have a value that requires it, then we need to show a warning.
        // (note: (Renderer MaterialPropertyBlock applies its values to emissionColorForRendering))
        bool hasEmissionKeyword = material.IsKeywordEnabled("_EMISSION");
        if (!hasEmissionKeyword && ShouldEmissionBeEnabled(material, emissionColorForRendering.colorValue))
            return false;
        else
            return true;
    }

    static void MaterialChanged(Material material, WorkflowMode workflowMode)
    {
        SetupMaterialWithBlendMode(material, (BlendMode)material.GetFloat("_Mode"));

        SetMaterialKeywords(material, workflowMode);
    }

    static void SetKeyword(Material m, string keyword, bool state)
    {
        if (state)
            m.EnableKeyword(keyword);
        else
            m.DisableKeyword(keyword);
    }

    //TCP2 Tools

    int GetOutlineNormalsIndex()
    {
        if (m_MaterialEditor.target == null || !(m_MaterialEditor.target is Material))
            return 0;

        for (int i = 0; i < outlineNormalsKeywords.Length; i++)
        {
            if ((m_MaterialEditor.target as Material).IsKeywordEnabled(outlineNormalsKeywords[i]))
                return i;
        }
        return 0;
    }

    void SetTCP2Shader(bool useOutline, bool blendedOutline)
    {
        bool specular = m_WorkflowMode == WorkflowMode.Specular;
        string shaderPath = null;

        if (!useOutline)
        {
            if (specular)
                shaderPath = "Toony Colors Pro 2/Standard PBS (Specular)";
            else
                shaderPath = "Toony Colors Pro 2/Standard PBS";
        }
        else if (blendedOutline)
        {
            if (specular)
                shaderPath = "Hidden/Toony Colors Pro 2/Standard PBS Outline Blended (Specular)";
            else
                shaderPath = "Hidden/Toony Colors Pro 2/Standard PBS Outline Blended";
        }
        else
        {
            if (specular)
                shaderPath = "Hidden/Toony Colors Pro 2/Standard PBS Outline (Specular)";
            else
                shaderPath = "Hidden/Toony Colors Pro 2/Standard PBS Outline";
        }

        Shader shader = Shader.Find(shaderPath);
        if (shader != null)
        {
            if ((m_MaterialEditor.target as Material).shader != shader)
            {
                m_MaterialEditor.SetShader(shader, false);
            }

            foreach (var obj in m_MaterialEditor.targets)
            {
                if (obj is Material)
                {
                    if (blendedOutline)
                        (obj as Material).EnableKeyword("OUTLINE_BLENDING");
                    else
                        (obj as Material).DisableKeyword("OUTLINE_BLENDING");

                    if (useOutline)
                        (obj as Material).EnableKeyword("OUTLINES");
                    else
                        (obj as Material).DisableKeyword("OUTLINES");
                }
            }

            m_MaterialEditor.Repaint();
            SceneView.RepaintAll();
        }
        else
        {
            EditorApplication.Beep();
            Debug.LogError("Toony Colors Pro 2: Couldn't find the following shader:\n\"" + shaderPath + "\"");
        }
    }
}
