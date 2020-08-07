using System.Collections;
using System.Collections.Generic;
using UnityEngine;






public class Instancing_allMeshChild : MonoBehaviour
{

    public Mesh mesh;
    public Material mat;
    public Transform parentObject;

    private Vector3 pos;
    private List<Matrix4x4> matrixs = new List<Matrix4x4>();
    private List<Transform> meshTrans = new List<Transform>();
    private List<MeshRenderer> meshes = new List<MeshRenderer>();

    private List<SkinnedMeshRenderer> skinMeshes = new List<SkinnedMeshRenderer>();

    // Start is called before the first frame update
    void Start()
    {
        meshes = new List<MeshRenderer>(parentObject.GetComponentsInChildren<MeshRenderer>());
        skinMeshes = new List<SkinnedMeshRenderer>(parentObject.GetComponentsInChildren<SkinnedMeshRenderer>());
        if(meshes.Count > 0)
        {
            foreach (MeshRenderer m in meshes)
            {
                meshTrans.Add(m.transform);
            }
        }


    }

    // Update is called once per frame
    void Update()
    {
        if (meshTrans.Count > 0)
        {
            foreach (Transform o in meshTrans)
            {

                Vector3 scale = new Vector3(Mathf.Abs(o.localScale.x), Mathf.Abs(o.lossyScale.y), Mathf.Abs(o.lossyScale.z));

                var mat = Matrix4x4.TRS(o.position, o.rotation, scale);

                matrixs.Add(mat);

            }
        }

        if (skinMeshes.Count > 0){

            foreach (SkinnedMeshRenderer s in skinMeshes)
            {
                Vector3 scale = new Vector3(Mathf.Abs(s.transform.localScale.x), Mathf.Abs(s.transform.lossyScale.y), Mathf.Abs(s.transform.lossyScale.z));

                var mat = Matrix4x4.TRS(s.bounds.center, s.transform.rotation, scale);

                matrixs.Add(mat);
            }

        }


        Graphics.DrawMeshInstanced(mesh, 0, mat, matrixs.ToArray());
        matrixs.Clear();
    }
}
