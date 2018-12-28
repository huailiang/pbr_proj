using UnityEditor;
using UnityEngine;


public class ExportCameraRT
{
    [MenuItem("Tools/ExportCameraRT")]
    static void ExportMesh()
    {
        var obj = Selection.activeObject;
        Debug.Log(obj.name);

        SkinnedMeshRenderer[] skms = (obj as GameObject).GetComponentsInChildren<SkinnedMeshRenderer>();
        for (int i = 0; i < skms.Length; i++)
        {
            Debug.Log(skms[i].name);
            var mesh = Object.Instantiate(skms[i].sharedMesh);
            AssetDatabase.CreateAsset(mesh, "Assets/Rendering/Art/Mesh/" + skms[i].name + ".asset");
        }
        AssetDatabase.Refresh();
        EditorUtility.DisplayDialog("tip", "export all mesh done", "ok");
    }


}
