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

        bool open_debug = true;
        DebugMode mode;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            base.OnGUI(materialEditor, props);
            m_Material = materialEditor.target as Material;
            if (debugMode == null)
            {
                FindProperties(props);
            }

            ShaderDebugGUI();
        }


        private void ShaderDebugGUI()
        {
            EditorGUI.BeginChangeCheck();
            open_debug = EditorGUILayout.Toggle("OpenDebug", open_debug);
            if (EditorGUI.EndChangeCheck())
            {
                if (open_debug)
                {
                    m_Material.EnableKeyword("OPEN_SHADER_DEBUG");
                }
                else
                {
                    m_Material.DisableKeyword("OPEN_SHADER_DEBUG");
                }
            }
            if (open_debug)
            {
                mode = (DebugMode)EditorGUILayout.Popup("Debug Mode", (int)mode, Enum.GetNames(typeof(DebugMode)));
                debugMode.floatValue = (float)mode;
            }
        }

        private void FindProperties(MaterialProperty[] props)
        {
            Shader shader = m_Material.shader;
            debugMode = FindProperty("_DebugMode", props, false);
        }

    }
}