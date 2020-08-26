

using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;


internal class FunDream_billBoard : ShaderGUI
{


    MaterialProperty mainTex = null;
    MaterialProperty NormalMapTex = null;
    MaterialProperty bumpScale = null;

    MaterialProperty lockRotation = null;
    MaterialProperty lockAxis = null;

    MaterialProperty color = null;
    MaterialProperty Gloss = null;
    MaterialProperty cutoff = null;
    MaterialProperty scaleX = null;
    MaterialProperty scaleY = null;
    MaterialEditor m_MaterialEditor;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        FindProperties(props);
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;

        ShaderPropertiesGUI(material);

        SetMaterialKeywords(material);

        GUILayout.EndVertical();

        #if UNITY_5_5_OR_NEWER
                materialEditor.RenderQueueField();
        #endif
        #if UNITY_5_6_OR_NEWER
                materialEditor.EnableInstancingField();
        #endif
    }

    private static class Styles
    {
  
        public static GUIContent mainTexText = new GUIContent("MainTex", "MainTex");
        public static GUIContent NormalMapText = new GUIContent("NormalMap", "NormalMap");
        public static GUIContent lockRotationText = new GUIContent("LockRotation", "Lock Rotation");
        public static GUIContent lockAxisText = new GUIContent("LockAixs", "Lock Which Aixs ?");

        public static GUIContent colorText = new GUIContent("Color", "Color");
        public static GUIContent cutoffText = new GUIContent("CutOff", "Cut Off");
        public static GUIContent GlossText = new GUIContent("Gloss", "Gloss");
        public static GUIContent scaleXText = new GUIContent("ScaleX", "Scale X");
        public static GUIContent scaleYText = new GUIContent("ScaleY", "Scale Y");

        public static string primaryMapsText = " ";
        public static string forwardText = " ";
    }


    public void FindProperties(MaterialProperty[] props)
    {
        mainTex = FindProperty("_MainTex", props);
        NormalMapTex = FindProperty("_NormalMap", props);

        lockRotation = FindProperty("_LockRotation", props);
        lockAxis = FindProperty("_LockAxis", props);

        color = FindProperty("_Color", props);
        cutoff = FindProperty("_Cutoff", props);
        Gloss = FindProperty("_Gloss", props);
        scaleX = FindProperty("_ScaleX", props);
        scaleY = FindProperty("_ScaleY", props);

    }



    public void ShaderPropertiesGUI(Material material)
    {
        EditorGUIUtility.labelWidth = 0f;

        EditorGUI.BeginChangeCheck();
        {
            GUILayout.Space(8f);
            //Background
            Rect vertRect = EditorGUILayout.BeginVertical();
            vertRect.xMax += 2;
            vertRect.xMin--;
            //GUILayout.Space(4f);

            // Primary properties
            GUILayout.Label(Styles.primaryMapsText, EditorStyles.boldLabel);

            m_MaterialEditor.TexturePropertySingleLine(Styles.mainTexText, mainTex);
            m_MaterialEditor.TextureScaleOffsetProperty(mainTex);

            GUILayout.Label(Styles.primaryMapsText, EditorStyles.boldLabel);
            m_MaterialEditor.TexturePropertySingleLine(Styles.NormalMapText, NormalMapTex);
            m_MaterialEditor.TextureScaleOffsetProperty(NormalMapTex);

            GUILayout.Label(Styles.forwardText, EditorStyles.boldLabel);

            m_MaterialEditor.ShaderProperty(lockRotation, Styles.lockRotationText.text, 0);
            if(material.GetFloat("_LockRotation") == 1)
            {
                m_MaterialEditor.ShaderProperty(lockAxis, Styles.lockAxisText.text, 1);

            }

            GUILayout.Space(9f);

            m_MaterialEditor.ColorProperty(color, Styles.colorText.text);
            m_MaterialEditor.ShaderProperty(cutoff, Styles.cutoffText.text, 0);
            m_MaterialEditor.ShaderProperty(Gloss, Styles.GlossText.text, 0);
            m_MaterialEditor.ShaderProperty(scaleX, Styles.scaleXText.text, 0);
            m_MaterialEditor.ShaderProperty(scaleY, Styles.scaleYText.text, 0);
           // EditorGUILayout.EndVertical();

        }

        
    }

    

    static void SetMaterialKeywords(Material material)
    {
        SetKeyword(material, "_LOCKROTATION_ON", material.GetFloat("_LockRotation") == 1);

        SetKeyword(material, "_LOCKAXIS_0", material.GetFloat("_LockAxis") == 0);
        SetKeyword(material, "_LOCKAXIS_1", material.GetFloat("_LockAxis") == 1);
        SetKeyword(material, "_LOCKAXIS_2", material.GetFloat("_LockAxis") == 2);
        SetKeyword(material, "_LOCKAXIS_3", material.GetFloat("_LockAxis") == 3);

    }
    

    static void SetKeyword(Material m, string keyword, bool state)
    {
        if (state)
            m.EnableKeyword(keyword);
        else
            m.DisableKeyword(keyword);
    }

}
