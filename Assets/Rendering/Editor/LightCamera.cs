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
    private float strength;
    private const string s_cam = "Directional Light Camera";

    private void OnEnable()
    {
        if (light == null) light = GameObject.FindObjectOfType<Light>();
        if (player == null) player = GameObject.FindWithTag("Player");
        if (resolution == 0) resolution = 512;
        if (strength == 0) strength = 0.5f;
        if (shadowCaster == null) shadowCaster = Shader.Find("CustomShadow/Caster");
        CreateDirLightCamera();
    }

    private void OnGUI()
    {
        light = (Light) EditorGUILayout.ObjectField("light", light, typeof(Light), true);
        resolution = EditorGUILayout.IntField("resolution", resolution);
        player = (GameObject) EditorGUILayout.ObjectField("player", player, typeof(GameObject), true);
        if (light)
        {
            if (player && lightCamera)
            {
                lightCamera.transform.rotation = light.transform.rotation;
                lightCamera.transform.position = player.transform.position - 4 * light.transform.forward;
            }
        }
        strength = EditorGUILayout.Slider("light strength", strength, 0, 1);
        EditorGUILayout.ObjectField("caster", shadowCaster, typeof(Shader), false);
        EditorGUILayout.ObjectField("lightmap", rt_2d, typeof(RenderTexture), true);
        if (lightCamera.enabled) lightCamera.enabled = false;
        
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
        if (GameObject.Find(s_cam)) return;
        GameObject goLightCamera = new GameObject(s_cam);
        lightCamera = goLightCamera.AddComponent<Camera>();
        lightCamera.backgroundColor = Color.white;
        lightCamera.clearFlags = CameraClearFlags.SolidColor;
        lightCamera.orthographic = true;
        lightCamera.orthographicSize = 2f;
        lightCamera.nearClipPlane = 0.3f;
        lightCamera.farClipPlane = 20;
        lightCamera.enabled = false;
        // lightCamera.RenderWithShader(shadowCaster, "");
        lightCamera.SetReplacementShader(shadowCaster,"");
        Selection.activeObject = goLightCamera;
    }


    private void Create2DTextureFor()
    {
        RenderTextureFormat rtFormat = RenderTextureFormat.Default;
        if (!SystemInfo.SupportsRenderTextureFormat(rtFormat))
            rtFormat = RenderTextureFormat.Default;
        rt_2d = new RenderTexture(resolution, resolution, 24, rtFormat);
        rt_2d.hideFlags = HideFlags.DontSave;
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
    
    
    [MenuItem("Tools/LightCameraShadow")]
    static void CreateShdow()
    {
        var win = GetWindow<LightCamera>();
        win.ShowPopup();
    }
}