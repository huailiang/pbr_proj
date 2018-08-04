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
            GGX,
            SmithJoint,
            Frenel,
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
            None = 1 << 0,
            AlphaTest = 1 << 1,
            AlphaPrume = 1 << 2
        }

        Material material;
        MaterialProperty matDebugMode;
        MaterialProperty matRimColor;

        bool initial = false;
        bool open_debug = true;
        bool use_special_rim = true;
        DebugMode debugMode = DebugMode.None;
        BlendMode blendMode = BlendMode.Opaque;
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
            if (use_special_rim) rimColor = EditorGUILayout.ColorField("Rim Color", rimColor);
            blendMode = (BlendMode)EditorGUILayout.Popup("Blend Mode", (int)blendMode, Enum.GetNames(typeof(BlendMode)));
            open_debug = EditorGUILayout.Toggle("OpenDebug", open_debug);
            if (open_debug) debugMode = (DebugMode)EditorGUILayout.Popup("Debug Mode", (int)debugMode, Enum.GetNames(typeof(DebugMode)));

            if (EditorGUI.EndChangeCheck())
            {
                SetMatBlend(blendMode);
                EnableMatKeyword(KEY_OPEN_SHADER_DEBUG, open_debug);
                EnableMatKeyword(KEY_USE_SPECIAL_RIM_COLOR, use_special_rim);
                if (use_special_rim) matRimColor.colorValue = rimColor;
                if (open_debug) material.SetFloat("_DebugMode", (float)debugMode);
            }
        }


        private void FindProperties(MaterialProperty[] props)
        {
            Shader shader = material.shader;
            matDebugMode = FindProperty("_DebugMode", props, false);
            matRimColor = FindProperty("_RimColor", props, false);
            string rendertype = material.GetTag("RenderType", true);
            if (matRimColor != null)
            {
                rimColor = matRimColor.colorValue;
            }
            if (matDebugMode != null)
            {
                debugMode = (DebugMode)(matDebugMode.floatValue);
            }
            if (rendertype.Equals("TransparentCutout"))
            {
                blendMode = BlendMode.CutoutTransparent;
            }
            else if (rendertype.Equals("Transparent"))
            {
                blendMode = BlendMode.Transparent;
            }
            else if (material.renderQueue == (int)UnityEngine.Rendering.RenderQueue.Geometry)
            {
                blendMode = BlendMode.Opaque;
            }
            else
            {
                blendMode = BlendMode.Cutout;
            }
        }

        private void SetMatBlend(BlendMode mode)
        {
            switch (mode)
            {
                case BlendMode.Opaque:
                    SetMatBlend(UnityEngine.Rendering.BlendMode.One, UnityEngine.Rendering.BlendMode.Zero, AlphaMode.None, 1);
                    material.SetOverrideTag("RenderType", "Opaque");
                    material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Geometry;
                    break;
                case BlendMode.Cutout:
                    SetMatBlend(UnityEngine.Rendering.BlendMode.One, UnityEngine.Rendering.BlendMode.Zero, AlphaMode.AlphaTest, 1);
                    material.SetOverrideTag("RenderType", "Opaque");
                    material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                    break;
                case BlendMode.CutoutTransparent:
                    SetMatBlend(UnityEngine.Rendering.BlendMode.One, UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha, AlphaMode.AlphaTest | AlphaMode.AlphaPrume, 1);
                    material.SetOverrideTag("RenderType", "TransparentCutout");
                    material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    break;
                case BlendMode.Transparent:
                    SetMatBlend(UnityEngine.Rendering.BlendMode.One, UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha, AlphaMode.AlphaPrume, 0);
                    material.SetOverrideTag("RenderType", "Transparent");
                    material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    break;
                default:
                    //TO-DO 
                    break;
            }
        }

        private void SetMatBlend(UnityEngine.Rendering.BlendMode src, UnityEngine.Rendering.BlendMode dst, AlphaMode alp, int zwrite)
        {
            if (material.HasProperty("_SrcBlend"))
                material.SetInt("_SrcBlend", (int)src);
            if (material.HasProperty("_DstBlend"))
                material.SetInt("_DstBlend", (int)dst);
            if (material.HasProperty("_ZWrite"))
                material.SetInt("_ZWrite", zwrite);

            EnableMatKeyword(KEY_ALPHA_TEST, (alp & AlphaMode.AlphaTest) != 0);
            EnableMatKeyword(KEY_ALPHA_PREMULT, (alp & AlphaMode.AlphaPrume) != 0);
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