using System;
using UnityEngine;


namespace UnityEditor
{
    public class PBRShaderGUI : ShaderGUI
    {

        const string KEY_OPEN_SHADER_DEBUG = "OPEN_SHADER_DEBUG";
        const string KEY_USE_SPECIAL_RIM_COLOR = "USE_SPECIAL_RIM_COLOR";
        const string KEY_ALPHA_TEST = "ALPHA_TEST";
        const string KEY_ALPHA_PREMULT = "ALPHA_PREMULT";

        internal enum DebugMode
        {
            None,
            Diffuse,
            Specular,
            Normal,
            Rim
        }


        internal enum BlendMode
        {
            Opaque,
            Cutout,
            CutoutTransparent,
            Transparent
        }

        internal enum AlphaMode
        {
            None,
            AlphaTest,
            AlphaPrume
        }

        Material material;
        MaterialProperty matDebugMode;
        MaterialProperty matRimColor;

        bool initial = false;
        bool open_debug = true;
        bool use_special_rim = true;
        DebugMode debugMode = DebugMode.None;
        BlendMode blendMode = BlendMode.Opaque;
        AlphaMode alphaMode = AlphaMode.None;
        Color rimColor = Color.blue;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            base.OnGUI(materialEditor, props);
            material = materialEditor.target as Material;
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
            blendMode = (BlendMode)EditorGUILayout.Popup("Blend Mode", (int)blendMode, Enum.GetNames(typeof(BlendMode)));
            SetMatBlend(blendMode);
            alphaMode = (AlphaMode)EditorGUILayout.Popup("Alpha Mode", (int)alphaMode, Enum.GetNames(typeof(AlphaMode)));
            open_debug = EditorGUILayout.Toggle("OpenDebug", open_debug);
            if (EditorGUI.EndChangeCheck())
            {
                EnableMatKeyword(KEY_OPEN_SHADER_DEBUG, open_debug);
                EnableMatKeyword(KEY_USE_SPECIAL_RIM_COLOR, use_special_rim);
                EnableMatKeyword(KEY_ALPHA_TEST, alphaMode == AlphaMode.AlphaTest);
                EnableMatKeyword(KEY_ALPHA_PREMULT, alphaMode == AlphaMode.AlphaPrume);
            }
            if (open_debug)
            {
                debugMode = (DebugMode)EditorGUILayout.Popup("Debug Mode", (int)debugMode, Enum.GetNames(typeof(DebugMode)));
                material.SetFloat("_DebugMode", (float)debugMode);
            }
            if (use_special_rim)
            {
                matRimColor.colorValue = rimColor;
            }
        }


        private void FindProperties(MaterialProperty[] props)
        {
            Shader shader = material.shader;
            matDebugMode = FindProperty("_DebugMode", props, false);
            matRimColor = FindProperty("_RimColor", props, false);
            if (matDebugMode == null || matRimColor == null)
            {
                Debug.LogError("shader error property is nil");
            }
        }

        private void SetMatBlend(BlendMode mode)
        {
            switch (mode)
            {
                case BlendMode.Opaque:
                    SetMatBlend(UnityEngine.Rendering.BlendMode.One, UnityEngine.Rendering.BlendMode.Zero, 1);
                    material.SetOverrideTag("RenderType", "Opaque");
                    material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Geometry;
                    break;
                case BlendMode.Cutout:
                    SetMatBlend(UnityEngine.Rendering.BlendMode.One, UnityEngine.Rendering.BlendMode.Zero, 1);
                    material.SetOverrideTag("RenderType", "TransparentCutout");
                    material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                    break;
                case BlendMode.CutoutTransparent:
                    SetMatBlend(UnityEngine.Rendering.BlendMode.One, UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha, 1);
                    material.SetOverrideTag("RenderType", "TransparentCutout");
                    material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                    break;
                case BlendMode.Transparent:
                    SetMatBlend(UnityEngine.Rendering.BlendMode.One, UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha, 0);
                    material.SetOverrideTag("RenderType", "Transparent");
                    material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    break;
                default:
                    //TO-DO 
                    break;
            }
        }

        private void SetMatBlend(UnityEngine.Rendering.BlendMode src, UnityEngine.Rendering.BlendMode dst, int z)
        {
            if (material.HasProperty("_SrcBlend"))
                material.SetInt("_SrcBlend", (int)src);
            if (material.HasProperty("_DstBlend"))
                material.SetInt("_DstBlend", (int)dst);
            if (material.HasProperty("_ZWrite"))
                material.SetInt("_ZWrite", z);
        }


        private void EnableMatKeyword(string key, bool enable)
        {
            if (enable)
            {
                material.EnableKeyword(key);
            }
            else
            {
                material.DisableKeyword(key);
            }
        }
    }
}