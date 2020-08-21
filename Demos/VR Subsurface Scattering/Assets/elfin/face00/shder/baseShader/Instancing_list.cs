using System.Collections;
using System.Collections.Generic;
using UnityEngine;






public class Instancing_list : MonoBehaviour
{

    public Mesh mesh;
    public Material mat;
    public Transform[] InstanceObjects;

    private List<Matrix4x4> matrixs = new List<Matrix4x4>();



    // Update is called once per frame
    void Update()
    {

        foreach (Transform o in InstanceObjects)
        {

            Vector3 scale = new Vector3(Mathf.Abs(o.localScale.x), Mathf.Abs(o.lossyScale.y), Mathf.Abs(o.lossyScale.z));

            var mat = Matrix4x4.TRS(o.position, o.rotation, scale);

            matrixs.Add(mat);

        }

        Graphics.DrawMeshInstanced(mesh, 0, mat, matrixs.ToArray());
        matrixs.Clear();
    }
}
