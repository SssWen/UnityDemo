using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateForFlash : MonoBehaviour
{

    public Material[] FlashM;
    
    private Transform mtrans;


    private void Start()
    {
        mtrans = this.transform;
    }

    // Update is called once per frame
    void Update()
    {
        if (FlashM.Length>0)
        {
           float rotate =  mtrans.rotation.y;

            for (int i = 0; i < FlashM.Length; i++)
            {
                FlashM[i].SetFloat("_FlashRotate", rotate);
                //Debug.Log(rotate.ToString());
            }
        }


    }
}
