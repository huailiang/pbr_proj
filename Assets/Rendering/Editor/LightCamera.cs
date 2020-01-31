using UnityEngine;
using UnityEditor;

public class LightCamera : EditorWindow
{
    private Light light;
    private int resolution;
    private Camera lightCamera;
    private GameObject player;
    private RenderTexture rt_2d;
    private Shader shadowCaster;
    private float strength, bias;
    private const string s_cam = "Directional Light Camera";

    private void OnEnable()
    {
        if (light == null) light = GameObject.FindObjectOfType<Light>();
        if (player == null) player = GameObject.FindWithTag("Player");
        if (resolution == 0) resolution = 256;
        if (bias == 0) bias = 0.005f;
        if (strength == 0) strength = 0.5f;
        if (shadowCaster == null) shadowCaster = Shader.Find("CustomShadow/Caster");
        CreateDirLightCamera();
    }

    private void OnGUI()
    {
        light = (Light)EditorGUILayout.ObjectField("light", light, typeof(Light), true);
        resolution = EditorGUILayout.IntField("resolution", resolution);
        player = (GameObject)EditorGUILayout.ObjectField("player", player, typeof(GameObject), true);
        if (light && player && lightCamera)
        {
            lightCamera.transform.rotation = light.transform.rotation;
            lightCamera.transform.position = player.transform.position - 2 * light.transform.forward;
        }

        strength = EditorGUILayout.Slider("light strength", strength, 0, 1);
        bias = EditorGUILayout.Slider("Shadow Bias", bias, 0.001f, 0.01f);
        Shader.SetGlobalFloat("_gShadowStrength", strength);
        Shader.SetGlobalFloat("_gShadowBias", bias);
        EditorGUILayout.ObjectField("caster", shadowCaster, typeof(Shader), false);
        EditorGUILayout.ObjectField("lightmap", rt_2d, typeof(RenderTexture), true);
        if (lightCamera && lightCamera.enabled) lightCamera.enabled = false;

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Generate RT")) Create2DTextureFor();
        if (GUILayout.Button("Select Camera")) Selection.activeObject = lightCamera.gameObject;
        GUILayout.EndHorizontal();
    }

    private void OnDestroy()
    {
        while (true)
        {
            var go = GameObject.Find(s_cam);
            if (go != null) GameObject.DestroyImmediate(go);
            else break;
        }

        if (rt_2d) rt_2d.Release();
    }

    private void CreateDirLightCamera()
    {
        var go = GameObject.Find(s_cam);
        if (go != null) GameObject.DestroyImmediate(go);
        GameObject goLightCamera = new GameObject(s_cam);
        lightCamera = goLightCamera.AddComponent<Camera>();
        lightCamera.backgroundColor = Color.white;
        lightCamera.clearFlags = CameraClearFlags.SolidColor;
        lightCamera.orthographic = true;
        lightCamera.orthographicSize = 1.6f;
        lightCamera.nearClipPlane = 0.0f;
        lightCamera.farClipPlane = 3;
        lightCamera.enabled = false;
        lightCamera.cullingMask = (1 << 8) | (1 << 11);
        lightCamera.SetReplacementShader(shadowCaster, "");
        Selection.activeObject = goLightCamera;
    }

    private void Create2DTextureFor()
    {
        RenderTextureFormat rtFormat = RenderTextureFormat.Default;
        if (!SystemInfo.SupportsRenderTextureFormat(rtFormat))
            rtFormat = RenderTextureFormat.Default;
        if (rt_2d == null)
        {
            rt_2d = new RenderTexture(resolution, resolution, 24, rtFormat);
            rt_2d.hideFlags = HideFlags.DontSave;
            rt_2d.useMipMap = false;
        }
        Shader.SetGlobalTexture("_gShadowMapTexture", rt_2d);
        Shader.SetGlobalFloat("_gShadowBias", 0.005f);
        Shader.SetGlobalFloat("_gShadowStrength", strength);

        if (lightCamera)
        {
            lightCamera.enabled = true;
            // lightCamera.RenderWithShader(shadowCaster, "");
            lightCamera.targetTexture = rt_2d;
            Matrix4x4 projectionMatrix = GL.GetGPUProjectionMatrix(lightCamera.projectionMatrix, false);
            Shader.SetGlobalMatrix("_gWorldToShadow", projectionMatrix * lightCamera.worldToCameraMatrix);
            lightCamera.Render();
        }
    }


    [MenuItem("Tools/LightShadow")]
    static void CreateShdow()
    {
        var win = GetWindow<LightCamera>();
        win.ShowPopup();
    }
}