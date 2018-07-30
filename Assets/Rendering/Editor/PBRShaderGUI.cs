using System;
using UnityEngine;

namespace UnityEditor
{
    public class PBRShaderGUI : ShaderGUI
    {

        public enum DebugMode
        {
            None,
            Diffuse,
            Specular,
            Normal
        }

        Material m_Material;
        MaterialProperty debugMode = null;

        DebugMode mode;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            base.OnGUI(materialEditor, props);
            m_Material = materialEditor.target as Material;
            if (debugMode == null) FindProperties(props);
            ShaderDebugGUI();
        }


        private void ShaderDebugGUI()
        {
            mode = (DebugMode)EditorGUILayout.Popup("Debug Mode", (int)mode, Enum.GetNames(typeof(DebugMode)));
            debugMode.floatValue = (float)mode;
        }

        private void FindProperties(MaterialProperty[] props)
        {
            Shader shader = m_Material.shader;
            debugMode = FindProperty("_DebugMode", props, false);
        }

    }
}