using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GPUInstancing : MonoBehaviour
{
    [System.Serializable]
    public class GUPInsCell
    {
        public Mesh mesh;
        public Material mat;
        public Vector2[] uv;
        public List<Transform> trans = new List<Transform>();

    }

    public List<GUPInsCell> cells = new List<GUPInsCell>();
    private List<Matrix4x4> matrixs = new List<Matrix4x4>();


    // Start is called before the first frame update
    void Start()
    {
        
    }

    private void LateUpdate()
    {
        foreach (GUPInsCell cell in cells)
        {
            foreach (Transform o in cell.trans)
            {
                SkinnedMeshRenderer smr = o.GetComponent<SkinnedMeshRenderer>();
                if (smr != null)
                {
                    Vector3 scale = new Vector3(Mathf.Abs(smr.transform.localScale.x), Mathf.Abs(smr.transform.lossyScale.y), Mathf.Abs(smr.transform.lossyScale.z));
                    var mt = Matrix4x4.TRS(smr.bounds.center, smr.transform.rotation, scale);
                    matrixs.Add(mt);
                }
                else
                {
                    Vector3 scale = new Vector3(Mathf.Abs(o.localScale.x), Mathf.Abs(o.lossyScale.y), Mathf.Abs(o.lossyScale.z));
                    var mt = Matrix4x4.TRS(o.position, o.rotation, scale);
                    matrixs.Add(mt);
                }
            }

            Graphics.DrawMeshInstanced(cell.mesh, 0, cell.mat, matrixs.ToArray());

            matrixs.Clear();
        }
    }

}
