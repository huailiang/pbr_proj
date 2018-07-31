using System;
using UnityEngine;

namespace UnityEditor
{
    public class F4Vector : MaterialPropertyDrawer
    {
        private readonly string label0;
        private readonly float min0;
        private readonly float max0;
        private readonly string label1;
        private readonly float min1;
        private readonly float max1;
        private readonly string label2;
        private readonly float min2;
        private readonly float max2;
        private readonly string label3;
        private readonly float min3;
        private readonly float max3;

        public F4Vector(string label0, float min0, float max0,
        string label1, float min1, float max1,
        string label2, float min2, float max2,
        string label3, float min3, float max3)
        {
            if (label0 != "E")
            {
                this.label0 = min0 < max0 ? string.Format(" {0}({1}-{2})", label0, min0, max0) : label0;
                this.min0 = min0;
                this.max0 = max0;
            }
            else
            {
                this.label0 = null;
            }
            if (label1 != "E")
            {
                this.label1 = min1 < max1 ? string.Format(" {0}({1}-{2})", label1, min1, max1) : label1;
                this.min1 = min1;
                this.max1 = max1;
            }
            else
            {
                this.label1 = null;
            }
            if (label2 != "E")
            {
                this.label2 = min2 < max2 ? string.Format(" {0}({1}-{2})", label2, min2, max2) : label2;
                this.min2 = min2;
                this.max2 = max2;
            }
            else
            {
                this.label2 = null;
            }
            if (label3 != "E")
            {
                this.label3 = min3 < max3 ? string.Format(" {0}({1}-{2})", label3, min3, max3) : label3;
                this.min3 = min3;
                this.max3 = max3;
            }
            else
            {
                this.label3 = null;
            }
        }

        void DrawSlider(ref Rect position, string label, float min, float max, ref Vector4 value, int index)
        {
            if (!string.IsNullOrEmpty(label))
            {
                if (min < max)
                {
                    value[index] = EditorGUI.Slider(position, label, value[index], min, max);
                }
                else
                {
                    bool beforeEnable = value[index] > 0;
                    bool afterEnable = EditorGUI.Toggle(position, label, value[index] > 0);
                    if (beforeEnable != afterEnable)
                        value[index] = afterEnable ? 1.0f : 0.0f;
                }
                position.y += 17.0f;
            }
        }

        public override void OnGUI(Rect position, MaterialProperty prop, String label, MaterialEditor editor)
        {
            EditorGUI.LabelField(position, label, EditorStyles.boldLabel);
            position.y += 17.0f;
            Vector4 value = prop.vectorValue;

            EditorGUI.BeginChangeCheck();
            float oldLabelWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = 0f;
            DrawSlider(ref position, label0, min0, max0, ref value, 0);
            DrawSlider(ref position, label1, min1, max1, ref value, 1);
            DrawSlider(ref position, label2, min2, max2, ref value, 2);
            DrawSlider(ref position, label3, min3, max3, ref value, 3);
            EditorGUIUtility.labelWidth = oldLabelWidth;
            EditorGUI.showMixedValue = false;
            if (EditorGUI.EndChangeCheck())
            {
                prop.vectorValue = value;
            }
            GUILayout.Space(64);
        }
    }
}