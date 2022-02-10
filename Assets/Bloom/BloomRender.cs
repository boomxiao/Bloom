using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
public class BloomRender : MonoBehaviour
{

    public Color Color;
    [NonSerialized]
    public Renderer Renderer;

    private void Awake() {
        Renderer = this.GetComponent<Renderer>();
    }

    private void Start() {
        BloomController.Instance.AddRender(this);
    }



    private void OnDisable() {
        BloomController.Instance.RemoveRender(this);
    }






}
