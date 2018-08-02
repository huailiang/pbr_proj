using System;
using UnityEngine;

namespace UnityEditor
{
    public class PBRShaderGUI : ShaderGUI
    {

        const string KEY_OPEN_SHADER_DEBUG = "OPEN_SHADER_DEBUG";
        const string KEY_USE_SPECIAL_RIM_COLOR = "USE_SPECIAL_RIM_COLOR";

        public enum DebugMode
        {
            None,
            Diffuse,
            Specular,
            Normal,
            Rim
        }

        Material m_Material;
        MaterialProperty matDebugMode;
        MaterialProperty matRimColor;

        bool initial = false;
        bool open_debug = true;
        bool use_special_rim = true;
        DebugMode mode;
        Color rimColor = Color.yellow;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            base.OnGUI(materialEditor, props);
            m_Material = materialEditor.target as Material;
            if (!initial)
            {
                FindProperties(props);
                initial = true;
            }
            ShaderDebugGUI();
        }


        private void ShaderDebugGUI()
        {
            EditorGUI.BeginChangeCheck();

            use_special_rim = EditorGUILayout.Toggle("SpecialRimColor", use_special_rim);
            if (use_special_rim)
            {
                rimColor = EditorGUILayout.ColorField("Rim Color", rimColor);
            }
            else
            {
                EditorGUILayout.LabelField("     rim color will be filled with base light color");
            }
            open_debug = EditorGUILayout.Toggle("OpenDebug", open_debug);
            if (EditorGUI.EndChangeCheck())
            {
                EnableMatKeyword(KEY_OPEN_SHADER_DEBUG, open_debug);
                EnableMatKeyword(KEY_USE_SPECIAL_RIM_COLOR, use_special_rim);
            }
            if (open_debug)
            {
                mode = (DebugMode)EditorGUILayout.Popup("Debug Mode", (int)mode, Enum.GetNames(typeof(DebugMode)));
                m_Material.SetFloat("_DebugMode", (float)mode);
            }
            if (use_special_rim)
            {
                matRimColor.colorValue = rimColor;
            }
        }


        private void FindProperties(MaterialProperty[] props)
        {
            Shader shader = m_Material.shader;
            matDebugMode = FindProperty("_DebugMode", props, false);
            matRimColor = FindProperty("_RimColor", props, false);
            Debug.Log("shader debugmode: "
                + (matDebugMode != null)
                + " rim: " + (matRimColor != null)
                );
        }


        private void EnableMatKeyword(string key, bool enable)
        {
            if (enable)
            {
                m_Material.EnableKeyword(key);
            }
            else
            {
                m_Material.DisableKeyword(key);
            }
        }
    }

}