using System.Collections;
using System.Collections.Generic;
using UnityEngine;






public class Instancing_allMeshChild : MonoBehaviour
{

    public Mesh mesh;
    public Material mat;
    public Transform prarentBone;

    private Vector3 pos;
    private List<Matrix4x4> matrixs = new List<Matrix4x4>();
    private List<Transform> objs = new List<Transform>();
    private List<MeshRenderer> meshes = new List<MeshRenderer>();

    // Start is called before the first frame update
    void Start()
    {
        meshes = new List<MeshRenderer>(prarentBone.GetComponentsInChildren<MeshRenderer>());
        foreach (MeshRenderer s in meshes)
        {
            objs.Add(s.transform);
        }

    }

    // Update is called once per frame
    void Update()
    {

        foreach (Transform o in objs)
        {

            Vector3 scale = new Vector3(Mathf.Abs(o.localScale.x), Mathf.Abs(o.lossyScale.y), Mathf.Abs(o.lossyScale.z));

            var mat = Matrix4x4.TRS(o.position, o.rotation, scale);

            matrixs.Add(mat);

        }

        Graphics.DrawMeshInstanced(mesh, 0, mat, matrixs.ToArray());
        matrixs.Clear();
    }
}
