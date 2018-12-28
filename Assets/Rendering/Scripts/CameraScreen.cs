using UnityEngine;

public class CameraScreen : MonoBehaviour
{
    public Shader shader;

    private void Start()
    {
        GetComponent<Camera>().SetReplacementShader(shader, "IgnoreProjector");
    }

}