using UnityEditor;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.SceneManagement;
using UnityEditorInternal;

[CustomEditor(typeof(SSS.SSS))]
[ExecuteInEditMode]
public class SSSEditor : Editor
{
    private LayerMask FieldToLayerMask(int field)
    {
        LayerMask mask = 0;
        var layers = InternalEditorUtility.layers;
        for (int c = 0; c < layers.Length; c++)
        {
            if ((field & (1 << c)) != 0)
            {
                mask |= 1 << LayerMask.NameToLayer(layers[c]);
            }
        }
        return mask;
    }
    // Converts a LayerMask to a field value
    private int LayerMaskToField(LayerMask mask)
    {
        int field = 0;
        var layers = InternalEditorUtility.layers;
        for (int c = 0; c < layers.Length; c++)
        {
            if ((mask & (1 << LayerMask.NameToLayer(layers[c]))) != 0)
            {
                field |= 1 << c;
            }
        }
        return field;
    }
    //string[] layerMaskName;
    //int layerMaskNameIndex = 0;
    SSS.SSS sss;

    #region tabs

    private bool DebugTab
    {
        get { return EditorPrefs.GetBool("SSS DebugTab" + " " + EditorSceneManager.GetActiveScene().name, true); }
        set { EditorPrefs.SetBool("SSS DebugTab" + " " + EditorSceneManager.GetActiveScene().name, value); }
    }

    private bool ReuseShadowsTab
    {
        get { return EditorPrefs.GetBool("SSS ReuseShadowsTab" + " " + EditorSceneManager.GetActiveScene().name, true); }
        set { EditorPrefs.SetBool("SSS ReuseShadowsTab" + " " + EditorSceneManager.GetActiveScene().name, value); }
    }

    private bool EdgeTestTab
    {
        get { return EditorPrefs.GetBool("SSS EdgeTestTab" + " " + EditorSceneManager.GetActiveScene().name, true); }
        set { EditorPrefs.SetBool("SSS EdgeTestTab" + " " + EditorSceneManager.GetActiveScene().name, value); }
    }

    private bool ResourcesTab
    {
        get { return EditorPrefs.GetBool("SSS ResourcesTab" + " " + EditorSceneManager.GetActiveScene().name, true); }
        set { EditorPrefs.SetBool("SSS ResourcesTab" + " " + EditorSceneManager.GetActiveScene().name, value); }
    }

    private bool BlurTab
    {
        get { return EditorPrefs.GetBool("SSS BlurTab" + " " + EditorSceneManager.GetActiveScene().name, true); }
        set { EditorPrefs.SetBool("SSS BlurTab" + " " + EditorSceneManager.GetActiveScene().name, value); }
    }

    private bool DitherTab
    {
        get { return EditorPrefs.GetBool("SSS DitherTab" + " " + EditorSceneManager.GetActiveScene().name, true); }
        set { EditorPrefs.SetBool("SSS DitherTab" + " " + EditorSceneManager.GetActiveScene().name, value); }
    }

    #endregion

    SerializedProperty ReuseShadows;
    SerializedProperty DirectionalLights;
    SerializedProperty ProfilePerObject;
    SerializedProperty ScatteringRadius;
    SerializedProperty ScatteringIterations;
    SerializedProperty sssColor;
    SerializedProperty ShaderIterations;
    SerializedProperty Downsampling;
    SerializedProperty Dither;
    SerializedProperty DitherIntensity;
    SerializedProperty DitherScale;
    //SerializedProperty DitherSpeed;
    SerializedProperty DepthTest;
    SerializedProperty NormalTest;
    SerializedProperty UseProfileTest;
    SerializedProperty ProfileColorTest;
    SerializedProperty ProfileRadiusTest;
    SerializedProperty LightingPassShader;
    SerializedProperty NoiseTexture;
    SerializedProperty toggleTexture;
    SerializedProperty ShowCameras;
    SerializedProperty ShowGUI;
    SerializedProperty AllowMSAA;
    SerializedProperty maxDistance;
    SerializedProperty DEBUG_DISTANCE;
    SerializedProperty EdgeOffset;
    SerializedProperty FixPixelLeaks;
    SerializedProperty DitherEdgeTest;
    //Camera cam;

    void OnEnable()
    {
        sss = (SSS.SSS)target;
        ReuseShadows = serializedObject.FindProperty("ReuseShadows");
        DirectionalLights = serializedObject.FindProperty("DirectionalLights");
        ProfilePerObject = serializedObject.FindProperty("ProfilePerObject");
        ScatteringRadius = serializedObject.FindProperty("ScatteringRadius");
        ScatteringIterations = serializedObject.FindProperty("ScatteringIterations");
        sssColor = serializedObject.FindProperty("sssColor");
        ShaderIterations = serializedObject.FindProperty("ShaderIterations");
        Downsampling = serializedObject.FindProperty("Downsampling");
        Dither = serializedObject.FindProperty("Dither");
        DitherIntensity = serializedObject.FindProperty("DitherIntensity");
        DitherScale = serializedObject.FindProperty("DitherScale");
        //DitherSpeed = serializedObject.FindProperty("DitherSpeed");
        DepthTest = serializedObject.FindProperty("DepthTest");
        NormalTest = serializedObject.FindProperty("NormalTest");
        UseProfileTest = serializedObject.FindProperty("UseProfileTest");
        ProfileColorTest = serializedObject.FindProperty("ProfileColorTest");
        ProfileRadiusTest = serializedObject.FindProperty("ProfileRadiusTest");
        LightingPassShader = serializedObject.FindProperty("LightingPassShader");
        NoiseTexture = serializedObject.FindProperty("NoiseTexture");
        toggleTexture = serializedObject.FindProperty("toggleTexture");
        ShowCameras = serializedObject.FindProperty("ShowCameras");
        ShowGUI = serializedObject.FindProperty("ShowGUI");
        AllowMSAA = serializedObject.FindProperty("AllowMSAA");
        maxDistance = serializedObject.FindProperty("maxDistance");
        DEBUG_DISTANCE = serializedObject.FindProperty("DEBUG_DISTANCE");
        EdgeOffset = serializedObject.FindProperty("EdgeOffset");
        FixPixelLeaks = serializedObject.FindProperty("FixPixelLeaks");
        DitherEdgeTest = serializedObject.FindProperty("DitherEdgeTest");

        //List<string> layerMaskList = new List<string>();
        //for (int i = 0; i < 32; i++)
        //{
        //    string layerName = LayerMask.LayerToName(i);
        //    if (layerName != "")
        //    {
        //        if (layerName == sss.SSS_LayerName)
        //            layerMaskNameIndex = layerMaskList.Count;
        //        layerMaskList.Add(layerName);
        //    }
        //}
        //layerMaskName = layerMaskList.ToArray();

        //cam = FindObjectOfType<SSS>().gameObject.GetComponent<Camera>();
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();
        //EditorGUI.BeginChangeCheck();       

        GUILayout.Space(5);

        #region Blur
        if (GUILayout.Button("Blur", EditorStyles.toolbarButton))
            BlurTab = !BlurTab;

        if (BlurTab)
        {
            GUILayout.BeginVertical("box");
            {

                EditorGUILayout.PropertyField(ProfilePerObject, new GUIContent("Profile per object", "Allows to assign a different scattering color and radius per object.\nNo the that this requires to render the object once more"));
                if (!sss.ProfilePerObject) EditorGUILayout.PropertyField(sssColor, new GUIContent("Scattering color", ""));
                //  if (cam.renderingPath == RenderingPath.Forward)
                EditorGUILayout.PropertyField(AllowMSAA, new GUIContent("Allow MSAA", "Perform MSAA if enabled in this camera\n" +
                    "Note that VRAM cost is high."));
                EditorGUILayout.PropertyField(ScatteringRadius, new GUIContent("Radius", ""));
                EditorGUILayout.PropertyField(ScatteringIterations, new GUIContent("Iterations", "PostProcess iterations"));

                EditorGUILayout.PropertyField(ShaderIterations, new GUIContent("Shader Iterations", "Shader iterations per pass"));
                EditorGUILayout.PropertyField(Downsampling, new GUIContent("Downscale factor", ""));
                EditorGUILayout.PropertyField(maxDistance, new GUIContent("Max Distance", "Stop the process when a pixel is further than this distance"));
                EditorGUILayout.PropertyField(DEBUG_DISTANCE, new GUIContent("Debug Distance", "Convolved pixels are tinted in green. Red when they are far enough to be discarded and black for all non processed"));

                GUILayout.BeginVertical("box");
                {
                    GUILayout.BeginHorizontal();
                    {
                        EditorGUILayout.LabelField(new GUIContent("Layers", "Layers to be rendered in this stage"), GUILayout.MaxWidth(185));
                        //int newLayerMaskNameIndex = EditorGUILayout.Popup(layerMaskNameIndex, layerMaskName);

                        //if (newLayerMaskNameIndex != layerMaskNameIndex)
                        //{
                        //    layerMaskNameIndex = newLayerMaskNameIndex;
                        //    sss.SSS_LayerName = layerMaskName[layerMaskNameIndex];

                        //}
                        EditorGUI.BeginChangeCheck();
                        var layersSelection = EditorGUILayout.MaskField("", LayerMaskToField(sss.SSS_Layer), InternalEditorUtility.layers);
                        if (EditorGUI.EndChangeCheck())
                        {
                            Undo.RecordObject(sss, "SSS layer edit");
                            sss.SSS_Layer = FieldToLayerMask(layersSelection);
                        }
                    }
                    GUILayout.EndHorizontal();
                }
                GUILayout.EndVertical();
            }

            GUILayout.EndVertical();

        }
        #endregion

        //#region Reuse Shadows
        //if (GUILayout.Button("Reuse Shadows", EditorStyles.toolbarButton))
        //    ReuseShadowsTab = !ReuseShadowsTab;

        //if (ReuseShadowsTab)
        //{
        //    GUILayout.BeginVertical("box");
        //    {
        //        EditorGUILayout.PropertyField(ReuseShadows, new GUIContent("Enable", ""));
        //        EditorGUI.indentLevel++;
        //        //GUILayout.BeginHorizontal("box");
        //        EditorGUILayout.PropertyField(DirectionalLights, new GUIContent("Light list", "Only directional"),true);
        //        EditorGUI.indentLevel--;

        //        if (GUILayout.Button("Update list", EditorStyles.miniButton))
        //            sss.UpdateLightList();
        //        //EditorGUILayout.EndHorizontal();

        //    }
        //    EditorGUILayout.EndVertical();

        //}
        //#endregion

        #region Edge Test
        if (GUILayout.Button("Edge test", EditorStyles.toolbarButton))
            EdgeTestTab = !EdgeTestTab;

        if (EdgeTestTab)
        {
            GUILayout.BeginVertical("box");
            {
                //EditorGUILayout.LabelField("Edge Test", EditorStyles.boldLabel);
                EditorGUILayout.PropertyField(DepthTest, new GUIContent("Depth Test",
                 "Use the depth buffer discontinuities to avoid blurring edges"));
                EditorGUILayout.PropertyField(NormalTest, new GUIContent("Normal Test",
                    "Use the normals buffer discontinuities to avoid blurring edges"));

                if (sss.Dither)
                {

                    EditorGUILayout.PropertyField(DitherEdgeTest, new GUIContent("Apply edge test to dither noise",
                        ""));
                }
                GUILayout.BeginVertical("box");
                {
                    EditorGUILayout.PropertyField(FixPixelLeaks, new GUIContent("Fix pixel leaks", "Correct pixel leaks"));
                    if (sss.FixPixelLeaks)
                    {
                        EditorGUILayout.PropertyField(EdgeOffset, new GUIContent("Search distance", "Performs another edge test pass with wider offset"));
                    }
                }
                EditorGUILayout.EndVertical();

                GUILayout.BeginVertical("box");
                {
                    EditorGUILayout.PropertyField(UseProfileTest, new GUIContent("Profile Test",
                        "Use the profile buffer discontinuities to avoid blurring edges"));

                    if (sss.ProfilePerObject && sss.UseProfileTest)
                    {
                        EditorGUILayout.PropertyField(ProfileColorTest, new GUIContent("Profile Color Test",
                    "Use the profile buffer discontinuities to avoid blurring edges"));
                        EditorGUILayout.PropertyField(ProfileRadiusTest, new GUIContent("Profile radius Test",
                            "Use the profile buffer discontinuities to avoid blurring edges"));
                    }
                }
            }
            EditorGUILayout.EndVertical();
            EditorGUILayout.EndVertical();
        }
        #endregion

        #region Dither
        if (GUILayout.Button("Dither", EditorStyles.toolbarButton))
            DitherTab = !DitherTab;

        if (DitherTab)
        {
            GUILayout.BeginVertical("box");
            {
                EditorGUILayout.PropertyField(Dither, new GUIContent("Dither", "Apply random rotation using the noise texture"));
                if (sss.Dither)
                {
                    EditorGUILayout.PropertyField(DitherIntensity, new GUIContent("Dither Intensity", ""));
                    EditorGUILayout.PropertyField(DitherScale, new GUIContent("Dither Scale", ""));
                    //EditorGUILayout.PropertyField(DitherSpeed, new GUIContent("Dither Speed", ""));
                }
                GUILayout.EndVertical();

            }
        }
        #endregion

        #region Resources

        if (GUILayout.Button("Resources", EditorStyles.toolbarButton))
            ResourcesTab = !ResourcesTab;

        if (ResourcesTab)
        {
            GUILayout.BeginVertical("box");
            //sss.LightingPassShader = (Shader)EditorGUILayout.ObjectField("Light pass shader", sss.LightingPassShader, typeof(Shader), false);
            EditorGUILayout.PropertyField(LightingPassShader, new GUIContent("Light pass shader", ""));
            EditorGUILayout.PropertyField(NoiseTexture, new GUIContent("Noise texture", ""));

            EditorGUILayout.EndVertical();
        }
        #endregion

        #region Debug

        if (GUILayout.Button("Debug", EditorStyles.toolbarButton))
            DebugTab = !DebugTab;

        if (DebugTab)
        {
            GUILayout.BeginVertical("box");

            GUILayout.BeginHorizontal();
            //EditorGUILayout.LabelField(new GUIContent("View buffer", "Isolate the generated buffer for debug"));
            //sss.toggleTexture = (SSS.ToggleTexture)EditorGUILayout.EnumPopup(sss.toggleTexture);
            EditorGUILayout.PropertyField(toggleTexture, new GUIContent("View Buffer", "Blit buffers to screen"));
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.PropertyField(ShowCameras, new GUIContent("Show Cameras", ""));
            EditorGUILayout.PropertyField(ShowGUI, new GUIContent("Show Screen controls", ""));
            EditorGUILayout.EndVertical();

        }
        #endregion

        if (GUILayout.Button("Documentation", EditorStyles.toolbarButton))
            Application.OpenURL("https://docs.google.com/document/d/1kegpUbfR1KzMH9XIW_QMzS4n6UtPtTk72sLhoJ_C54A");

        EditorGUILayout.HelpBox("v1.5 November 2019", MessageType.None);


        //if (GUI.changed)
        //{
        //    EditorUtility.SetDirty(target);
        //}

        serializedObject.ApplyModifiedProperties();
    }
}