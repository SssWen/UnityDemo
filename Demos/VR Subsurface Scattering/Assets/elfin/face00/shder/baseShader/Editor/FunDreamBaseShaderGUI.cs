

using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;


internal class FunDreamBaseShaderGUI : ShaderGUI
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
        public static GUIContent uvSetLabel = new GUIContent("UV Set");
        public static GUIContent[] uvSetOptions = new GUIContent[] { new GUIContent("UV channel 0"), new GUIContent("UV channel 1") };

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

        public static GUIContent maskTexText = new GUIContent("MaskTex (RGB)", "Mask Texture (RGB)");

        public static GUIContent uv2Text = new GUIContent("UV2", "UV2 ON or OFF");
        public static GUIContent uv3Text = new GUIContent("UV3", "UV3 ON or OFF");

        public static GUIContent layerBaseTexText = new GUIContent("LayerBase", "LayerBase Texture");
        public static GUIContent layerBaseColorText = new GUIContent("LayerBaseColor", "LayerBase Color");
        public static GUIContent layerBaseSmoothnessText = new GUIContent("LayerBaseSmoothness", "LayerBase Smoothness");
        public static GUIContent layerBaseMetallicText = new GUIContent("LayerBaseMetallic", "LayerBase Metallic");
        public static GUIContent layerBaseUVSetText = new GUIContent("LayerBaseUVSet", "LayerBase UVSet");
        public static GUIContent layerBaseNormalText = new GUIContent("LayerBaseNormal", "LayerBase Normal Texture");
        public static GUIContent layerBaseMaskText = new GUIContent("layerBaseMask", "LayerBase Mask Channel");
        public static GUIContent layerBaseBlendModeText = new GUIContent("layerBaseBlendMode", "LayerBase Blend Mode");

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

    MaterialProperty alphaScale = null;

    MaterialProperty emissionColorForRendering = null;
    MaterialProperty emissionMap = null;

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
    MaterialProperty layerBaseMask = null;
    MaterialProperty layerBaseBlendMode = null;

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
            DoAlbedoArea(material);
            DoSpecularMetallicArea();
            m_MaterialEditor.TexturePropertySingleLine(Styles.normalMapText, bumpMap,
                                                        bumpMap.textureValue != null ? bumpScale : null);

            //m_MaterialEditor.TexturePropertySingleLine(Styles.heightMapText, heightMap,
            //                                           heightMap.textureValue != null ? heigtMapScale : null);


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

            // Real Fresnel
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


            //m_MaterialEditor.ShaderProperty(realFresnel, Styles.multiTranspText.text, 0);

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
        //m_MaterialEditor.ShaderProperty(temp, Styles.tempText);

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
            //hasGlossMap = metallicMap.textureValue != null;
            //m_MaterialEditor.TexturePropertySingleLine(Styles.metallicMapText, metallicMap, hasGlossMap ? null : metallic);
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

        //layer system
        SetKeyword(material, "_UV3_ON", material.GetFloat("_UV2") == 1);
        SetKeyword(material, "_UV4_ON", material.GetFloat("_UV3") == 1);

		SetKeyword(material, "_MASKTEX", material.GetTexture("_MaskTex"));

        SetKeyword(material, "_LAYER_BASE_TEX", material.GetTexture("_LayerBaseTex"));
        SetKeyword(material, "_LAYER_BASE_NORMAL", material.GetTexture("_LayerBaseNormal"));

        SetKeyword(material, "_LayerBaseUVSet_0", material.GetFloat("_LayerBaseUVSet") == 0);
        SetKeyword(material, "_LayerBaseUVSet_1", material.GetFloat("_LayerBaseUVSet") == 1);
        SetKeyword(material, "_LayerBaseUVSet_2", material.GetFloat("_LayerBaseUVSet") == 2);
        SetKeyword(material, "_LayerBaseUVSet_3", material.GetFloat("_LayerBaseUVSet") == 3);

        SetKeyword(material, "_LayerBase_Blend_Normal", material.GetFloat("_LayerBaseBlendMode") == 0);
        SetKeyword(material, "_LayerBase_Blend_Multiply", material.GetFloat("_LayerBaseBlendMode") == 1);
        SetKeyword(material, "_LayerBase_Blend_Darken", material.GetFloat("_LayerBaseBlendMode") == 2);

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
