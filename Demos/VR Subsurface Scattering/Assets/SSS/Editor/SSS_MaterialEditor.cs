using UnityEngine;

namespace UnityEditor
{
    internal class SSS_MaterialEditor : ShaderGUI
    {
        Material material;
        #region Tabs

        private bool CoordsTab
        {
            get { return EditorPrefs.GetBool("CoordsTab" + material.name, false); }
            set { EditorPrefs.SetBool("CoordsTab" + material.name, value); }
        }

        private bool DiffuseTab
        {
            get { return EditorPrefs.GetBool("DiffuseTab" + material.name, false); }
            set { EditorPrefs.SetBool("DiffuseTab" + material.name, value); }
        }

        private bool TranslucencyTab
        {
            get { return EditorPrefs.GetBool("TranslucencyTab" + material.name, false); }
            set { EditorPrefs.SetBool("TranslucencyTab" + material.name, value); }
        }

        private bool AOTab
        {
            get { return EditorPrefs.GetBool("AOTab" + material.name, false); }
            set { EditorPrefs.SetBool("AOTab" + material.name, value); }
        }

        private bool SpecularTab
        {
            get { return EditorPrefs.GetBool("SpecularTab" + material.name, false); }
            set { EditorPrefs.SetBool("SpecularTab" + material.name, value); }
        }

        private bool BumpTab
        {
            get { return EditorPrefs.GetBool("BumpTab" + material.name, false); }
            set { EditorPrefs.SetBool("BumpTab" + material.name, value); }
        }

        private bool ProfileTab
        {
            get { return EditorPrefs.GetBool("ProfileTab" + material.name, false); }
            set { EditorPrefs.SetBool("ProfileTab" + material.name, value); }
        }
        bool isDeferred;
        //int ColorPickerSize = 60;
        #endregion
        #region ShaderProperties
        MaterialProperty _Color = null;
        MaterialProperty _MainTex = null;
        MaterialProperty ENABLE_ALPHA_TEST = null;
        MaterialProperty _AlbedoTile = null;
        MaterialProperty _AlbedoOpacity = null;
        MaterialProperty _SubsurfaceAlbedoOpacity = null;
        MaterialProperty _SubsurfaceAlbedo = null;
        MaterialProperty _ProfileColor = null;
        MaterialProperty _ProfileTex = null;
        MaterialProperty _Transmission = null;
        MaterialProperty _TransmissionColor = null;
        MaterialProperty _TransmissionMap = null;
        MaterialProperty TransmissionShadows = null;
        MaterialProperty TransmissionOcc = null;
        MaterialProperty TransmissionRange = null;
        MaterialProperty DynamicPassTransmission = null;
        MaterialProperty BasePassTransmission = null;
        MaterialProperty _OcclusionColor = null;
        MaterialProperty _OcclusionMap = null;
        MaterialProperty _SpecColor = null;
        MaterialProperty _SpecGlossMap = null;
        MaterialProperty _FresnelIntensity = null;
        MaterialProperty _Gloss = null;
        MaterialProperty _CavityMap = null;
        MaterialProperty _CavityStrength = null;
        MaterialProperty _BumpMap = null;
        MaterialProperty _BumpTile = null;
        MaterialProperty _BumpScale = null;
        MaterialProperty _DetailNormalMapScale = null;
        MaterialProperty _DetailNormalMap = null;
        MaterialProperty _DetailNormal = null;
        MaterialProperty _DetailNormalMapTile = null;
        MaterialProperty _Cutoff = null;

        MaterialProperty _SubsurfaceAlbedoSaturation = null;
        MaterialProperty _SubSurfaceParallax = null;
        MaterialProperty SUBSURFACE_ALBEDO = null;
        MaterialProperty SUBSURFACE_PARALLAX = null;
        //MaterialProperty _OcclusionStrength = null;
        #endregion
        MaterialEditor m_MaterialEditor;
        bool m_FirstTimeApply = true;

        public void FindProperties(MaterialProperty[] properties)
        {

            _Color = FindProperty("_Color", properties);
            _MainTex = FindProperty("_MainTex", properties);
            ENABLE_ALPHA_TEST = FindProperty("ENABLE_ALPHA_TEST", properties);
            _SubsurfaceAlbedo = FindProperty("_SubsurfaceAlbedo", properties);
            _AlbedoOpacity = FindProperty("_AlbedoOpacity", properties);
            _AlbedoOpacity = FindProperty("_AlbedoOpacity", properties);
            _AlbedoTile = FindProperty("_AlbedoTile", properties);
            _AlbedoOpacity = FindProperty("_AlbedoOpacity", properties);
            _SubsurfaceAlbedoOpacity = FindProperty("_SubsurfaceAlbedoOpacity", properties);
            _SubsurfaceAlbedo = FindProperty("_SubsurfaceAlbedo", properties);
            _ProfileColor = FindProperty("_ProfileColor", properties);
            _ProfileTex = FindProperty("_ProfileTex", properties);
            _Transmission = FindProperty("_Transmission", properties);
            _TransmissionColor = FindProperty("_TransmissionColor", properties);
            _TransmissionMap = FindProperty("_TransmissionMap", properties);
            TransmissionShadows = FindProperty("TransmissionShadows", properties);
            TransmissionOcc = FindProperty("TransmissionOcc", properties);
            TransmissionRange = FindProperty("TransmissionRange", properties);
            DynamicPassTransmission = FindProperty("DynamicPassTransmission", properties);
            BasePassTransmission = FindProperty("BasePassTransmission", properties);
            _OcclusionColor = FindProperty("_OcclusionColor", properties);
            _OcclusionMap = FindProperty("_OcclusionMap", properties);
            _SpecColor = FindProperty("_SpecColor", properties);
            _SpecGlossMap = FindProperty("_SpecGlossMap", properties);
            _FresnelIntensity = FindProperty("_FresnelIntensity", properties);
            _Gloss = FindProperty("_Glossiness", properties);
            _CavityMap = FindProperty("_CavityMap", properties);
            _CavityStrength = FindProperty("_CavityStrength", properties);
            _BumpMap = FindProperty("_BumpMap", properties);
            _BumpTile = FindProperty("_BumpTile", properties);
            _BumpScale = FindProperty("_BumpScale", properties);
            _DetailNormalMapScale = FindProperty("_DetailNormalMapScale", properties);
            _DetailNormalMap = FindProperty("_DetailNormalMap", properties);
            _DetailNormal = FindProperty("_DetailNormal", properties);
            _DetailNormalMapTile = FindProperty("_DetailNormalMapTile", properties);
            _SubsurfaceAlbedoSaturation = FindProperty("_SubsurfaceAlbedoSaturation", properties);
            _SubSurfaceParallax = FindProperty("_SubSurfaceParallax", properties);
            SUBSURFACE_ALBEDO = FindProperty("SUBSURFACE_ALBEDO", properties);
            SUBSURFACE_PARALLAX = FindProperty("SUBSURFACE_PARALLAX", properties);
            _Cutoff = FindProperty("_Cutoff", properties);


            //

        }
        SSS.SSS sss;
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {

            FindProperties(properties); // MaterialProperties can be animated so we do not cache them but fetch them every event to ensure animated values are updated correctly

            m_MaterialEditor = materialEditor;
            material = materialEditor.target as Material;
            if (material.shader.name.Contains("deferred") || material.shader.name.Contains("Deferred"))
            {
                isDeferred = true;
                //Debug.Log(material.shader.name);
            }
            else
                isDeferred = false;

            //Debug.Log(isDeferred);
            if (m_FirstTimeApply)
            {
                if (GameObject.FindObjectOfType<SSS.SSS>())
                {
                    sss = GameObject.FindObjectOfType<SSS.SSS>();
                    if (GameObject.FindObjectOfType<SSS.SSS>().enabled == false)
                        Shader.EnableKeyword("SCENE_VIEW");



                }
                m_FirstTimeApply = false;
            }
            EditorGUI.BeginChangeCheck();
            GUILayout.Space(10);

            #region Coords

            if (GUILayout.Button("Coords", EditorStyles.toolbarButton))
                CoordsTab = !CoordsTab;

            if (CoordsTab)
            {
                GUILayout.BeginVertical("box");

                m_MaterialEditor.TextureScaleOffsetProperty(_MainTex);
                m_MaterialEditor.ShaderProperty(_AlbedoTile, "Albedo Tiling");
                m_MaterialEditor.ShaderProperty(_BumpTile, "Normal Tiling");
                GUILayout.EndVertical();
            }
            #endregion
            #region Diffuse
            if (GUILayout.Button("Albedo", EditorStyles.toolbarButton))
                DiffuseTab = !DiffuseTab;

            if (DiffuseTab)
            {
                GUILayout.BeginVertical("box");
                m_MaterialEditor.TexturePropertySingleLine(new GUIContent(_MainTex.displayName, "Base texture"), _MainTex, _Color);

                GUILayout.BeginVertical("box");
                {
                    m_MaterialEditor.ShaderProperty(ENABLE_ALPHA_TEST, ENABLE_ALPHA_TEST.displayName);
                    if (ENABLE_ALPHA_TEST.floatValue == 1)
                        m_MaterialEditor.ShaderProperty(_Cutoff, _Cutoff.displayName);
                }
                GUILayout.EndVertical();

                GUILayout.BeginVertical("box");
                {
                    m_MaterialEditor.ShaderProperty(SUBSURFACE_ALBEDO, new GUIContent( SUBSURFACE_ALBEDO.displayName, "Sample a color map in the lighting stage. Useful for subsurface features (moles, tattoos, veins, marble details...)"));

                    if (SUBSURFACE_ALBEDO.floatValue == 1)
                    {

                        m_MaterialEditor.ShaderProperty(_AlbedoOpacity, "Albedo Opacity");
                        m_MaterialEditor.ShaderProperty(_SubsurfaceAlbedoOpacity, "Subsurface Albedo opacity");

                        m_MaterialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent(_SubsurfaceAlbedo.displayName, "Will be sampled in the lighting stage thus affected by blur"), _SubsurfaceAlbedo);
                        m_MaterialEditor.ShaderProperty(_SubsurfaceAlbedoSaturation, _SubsurfaceAlbedoSaturation.displayName);
                        if (sss && sss.LightingPassShader.name == "Hidden/LightingPass ParallaxSubSurface Albedo")
                        {
                            GUILayout.BeginVertical("box");

                            m_MaterialEditor.ShaderProperty(SUBSURFACE_PARALLAX, SUBSURFACE_PARALLAX.displayName);


                            if (SUBSURFACE_PARALLAX.floatValue == 1)
                            {

                                m_MaterialEditor.ShaderProperty(_SubSurfaceParallax, _SubSurfaceParallax.displayName);
                            }


                            GUILayout.EndVertical();

                        }

                    }

                }
                GUILayout.EndVertical();



                GUILayout.EndVertical();
            }
            #endregion


            #region Profile
            if (Shader.IsKeywordEnabled("SSS_PROFILES") || material.IsKeywordEnabled("SSS_PROFILES"))
            {
                if (GUILayout.Button("Profile", EditorStyles.toolbarButton))
                    ProfileTab = !ProfileTab;

                if (ProfileTab)
                {

                    GUILayout.BeginVertical("box");
                    m_MaterialEditor.TexturePropertySingleLine(new GUIContent(_ProfileTex.displayName, "Blur color texture. \nRGB: color\nA: radius"), _ProfileTex, _ProfileColor);


                    GUILayout.EndVertical();
                }
            }
            #endregion

            #region Transmission

            if (GUILayout.Button("Transmission", EditorStyles.toolbarButton))
                TranslucencyTab = !TranslucencyTab;

            if (TranslucencyTab)
            {
                GUILayout.BeginVertical("box");

                m_MaterialEditor.ShaderProperty(_Transmission, _Transmission.displayName);

                if (_Transmission.floatValue == 1)
                {

                    m_MaterialEditor.TexturePropertySingleLine(new GUIContent(_TransmissionMap.displayName,
                        "Transmission mask. Used red channel"), _TransmissionMap, _TransmissionColor);

                    m_MaterialEditor.ShaderProperty(TransmissionShadows, new GUIContent(TransmissionShadows.displayName, "Use shadows attenuation"));


                    m_MaterialEditor.ShaderProperty(TransmissionOcc, new GUIContent(TransmissionOcc.displayName, "Use ao to attenuate"));

                    m_MaterialEditor.ShaderProperty(TransmissionRange, new GUIContent(TransmissionRange.displayName, ""));

                    m_MaterialEditor.ShaderProperty(DynamicPassTransmission, new GUIContent(DynamicPassTransmission.displayName, "Dynamic pass intensity"));

                    m_MaterialEditor.ShaderProperty(BasePassTransmission, new GUIContent(BasePassTransmission.displayName, "Base pass intensity. Uses Unity's ambient"));

                }
                GUILayout.EndVertical();

                if (isDeferred)
                    EditorGUILayout.HelpBox("Deferred version: per-light transmission can't be displayed in scene view. Only ambient", MessageType.Info);
            }
            #endregion


            #region AO

            if (GUILayout.Button("Occlusion", EditorStyles.toolbarButton))
                AOTab = !AOTab;

            if (AOTab)
            {
                GUILayout.BeginVertical("box");
                
                GUILayout.BeginHorizontal();
                m_MaterialEditor.TexturePropertySingleLine(new GUIContent(_OcclusionMap.displayName, ""), _OcclusionMap, _OcclusionColor);
                EditorGUILayout.LabelField("Occlusion color", GUILayout.MinWidth(20));
                GUILayout.EndHorizontal();

                if (isDeferred)
                {
                    MaterialProperty _OcclusionStrength = FindProperty("_OcclusionStrength", properties);
                    m_MaterialEditor.ShaderProperty(_OcclusionStrength, new GUIContent("Occlusion strength", ""));
                    EditorGUILayout.HelpBox("Deferred version: color is still applied to the lighting pass. Strength only affects final pass (specular using Unity's BRDF functionality) and scene view", MessageType.Info);
                }
                else
                {

                }
                GUILayout.EndVertical();

                
            }

            #endregion



            #region Specular

            if (GUILayout.Button("Specular", EditorStyles.toolbarButton))
                SpecularTab = !SpecularTab;

            if (SpecularTab)
            {
                GUILayout.BeginVertical("box");
                GUILayout.BeginHorizontal();


                m_MaterialEditor.TexturePropertySingleLine(
                    new GUIContent(_SpecGlossMap.displayName, "RGB: specular color\nA: smoothness"), _SpecGlossMap, _SpecColor);

                GUILayout.EndHorizontal();

                if(!isDeferred)
                m_MaterialEditor.ShaderProperty(_FresnelIntensity, new GUIContent("Fresnel effect", "1: 100% PBR\n0: Flat intensity"));

                m_MaterialEditor.ShaderProperty(_Gloss, new GUIContent("Smoothness", ""));

                if (!isDeferred)
                {
                    m_MaterialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent(_CavityMap.displayName, "Affects fresnel"), _CavityMap);
                    m_MaterialEditor.ShaderProperty(_CavityStrength, new GUIContent("Cavity strength", "Affects fresnel"));
                }
                /*MaterialProperty _UseSecondaryHighlight = FindProperty("_UseSecondaryHighlight", properties);
                GUILayout.BeginVertical("box");
                {
                    MaterialProperty _UseViewDependentSmoothness = FindProperty("_UseViewDependentSmoothness", properties);
                    m_MaterialEditor.ShaderProperty(_UseViewDependentSmoothness, new GUIContent(_UseViewDependentSmoothness.displayName,
                        "Use NdotV to increase smoothness at glancing angles"));

                    if (_UseViewDependentSmoothness.floatValue == 1)
                    {


                        MaterialProperty vdRange = FindProperty("vdRange", properties);
                        m_MaterialEditor.ShaderProperty(vdRange, new GUIContent("Range", "pow(NdotV, Range)"));
                    }



                }
                GUILayout.EndVertical();*/

                //variance gloss
                /* GUILayout.BeginVertical("box");
                 {
                     MaterialProperty _UseVarianceGloss = FindProperty("_UseVarianceGloss", properties);
                     m_MaterialEditor.ShaderProperty(_UseVarianceGloss, new GUIContent(_UseVarianceGloss.displayName,
                         "Use normal to vary gloss level"));

                     if (_UseVarianceGloss.floatValue == 1)
                     {


                         MaterialProperty _GlossVariance = FindProperty("_GlossVariance", properties);
                         m_MaterialEditor.ShaderProperty(_GlossVariance, new GUIContent("Variance", "Normal map influence"));

                         MaterialProperty _DetailFadeDistance = FindProperty("_DetailFadeDistance", properties);
                         m_MaterialEditor.ShaderProperty(_DetailFadeDistance, new GUIContent("Distance", "Camera position proximity to world position"));
                     }



                 }
                 GUILayout.EndVertical();

                 GUILayout.BeginVertical("box");
                 m_MaterialEditor.ShaderProperty(_UseSecondaryHighlight, new GUIContent(_UseSecondaryHighlight.displayName,
                     "Add a secondary specular. Only available in forward rendering"));

                 if (_UseSecondaryHighlight.floatValue == 1)
                 {
                     MaterialProperty _SecondaryGloss = FindProperty("_SecondaryGloss", properties);
                     m_MaterialEditor.ShaderProperty(_SecondaryGloss, new GUIContent(_SecondaryGloss.displayName,
                         "Smoothness for secondary gloss"));
                 }
                 GUILayout.EndVertical();
*/
                GUILayout.EndVertical();
            }

            #endregion



            #region Bump

            if (GUILayout.Button("Bump", EditorStyles.toolbarButton))
                BumpTab = !BumpTab;

            if (BumpTab)
            {
                GUILayout.BeginVertical("box");

                m_MaterialEditor.TexturePropertySingleLine(new GUIContent(_BumpMap.displayName, ""), _BumpMap, _BumpScale);
                
                //m_MaterialEditor.ShaderProperty(_BumpTile, "Tiling");
                //m_MaterialEditor.ShaderProperty(_BumpScale, "Tiling");
                m_MaterialEditor.ShaderProperty(_DetailNormal, _DetailNormalMap.displayName);

                if (_DetailNormal.floatValue == 1)
                {
                    GUILayout.BeginVertical("box");
                    m_MaterialEditor.TexturePropertySingleLine(new GUIContent(_DetailNormalMap.displayName, ""), _DetailNormalMap, _DetailNormalMapScale);

                    m_MaterialEditor.ShaderProperty(_DetailNormalMapTile, _DetailNormalMapTile.displayName);

                    GUILayout.EndVertical();
                }
                GUILayout.EndVertical();
            }
            #endregion

            m_MaterialEditor.EnableInstancingField();

        }

    }
}