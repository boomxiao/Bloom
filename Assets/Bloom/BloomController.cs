using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;



public class  PropertyID {
    public static int BloomBufferID = Shader.PropertyToID("_BloomBufferID");
    public static int ColorID = Shader.PropertyToID("_Color");
    
    public static int Blur1ID = Shader.PropertyToID("_Blur1ID");
    public static int FillAlphaID = Shader.PropertyToID("_FillAlpha");
    public static int Blur2ID = Shader.PropertyToID("_Blur2ID");
    public static int BlurOffset = Shader.PropertyToID("_BlurOffset");
    public static int OpaqueRenderColorID = Shader.PropertyToID("_Color");
}

public class BloomController : MonoBehaviour
{

    public static BloomController Instance;
    public List<BloomRender> BloomRenders;

    public Camera MainCamera;
    public CommandBuffer RenderBuffer;



    //id
    public RenderTargetIdentifier BloomBufferID;
    public RenderTargetIdentifier Blur1ID;
    public RenderTargetIdentifier Blur2ID;


    public RenderTextureDescriptor BloomBufferDescriptor;
    public RenderTexture BloomBuffer = null;
    //shader
    public Shader OpaqueRenderShader;
    public Shader CompositeShader;
    public Shader CutShader;
    public Shader BlurShader;

    private Material OpaqueRenderMaterial;
    private Material CompositeMaterial;
    private Material CutMaterial;
    private Material BlurMaterial;









    //propetry
    public int DownsampleFactor;//采样系数 越大越模糊
    public int Iterations;//迭代次数
    public float BlurMinSpread;//模糊扩散初始值
    public float BlurSpread;//模糊扩散系数
    public float BlurSize;
    [SerializeField]
    private float _fillAlpha;//中间部分的透明度

    public float FillAlpha {
        get { 
            return _fillAlpha;
        }
        set {
            value = Mathf.Clamp01(value);
            if(_fillAlpha != value) {
                _fillAlpha = value;
                if(CutMaterial!=null) {
                    CutMaterial.SetFloat(PropertyID.FillAlphaID, _fillAlpha);
                    Debug.LogError(CutMaterial.GetFloat(PropertyID.FillAlphaID));
                }
            }
        }
    }

 
    private void Awake() {
        Instance = this;
        BloomRenders = new List<BloomRender>();
     



        RenderBuffer = new CommandBuffer();
        RenderBuffer.name = "Bloom";

        MainCamera = this.GetComponent<Camera>();

        MainCamera.depthTextureMode |= DepthTextureMode.Depth;
        MainCamera.AddCommandBuffer(CameraEvent.BeforeImageEffectsOpaque, RenderBuffer);
        Blur1ID = new RenderTargetIdentifier(PropertyID.Blur1ID);
        Blur2ID = new RenderTargetIdentifier(PropertyID.Blur2ID);






        BloomBufferDescriptor = new RenderTextureDescriptor(MainCamera.pixelWidth, MainCamera.pixelHeight, RenderTextureFormat.ARGB32, 24);  // Overrides
        BloomBufferDescriptor.colorFormat = RenderTextureFormat.ARGB32;
        BloomBufferDescriptor.sRGB = QualitySettings.activeColorSpace == ColorSpace.Linear;
        BloomBufferDescriptor.useMipMap = false;


 

        OpaqueRenderMaterial = new Material(OpaqueRenderShader);
        CompositeMaterial = new Material(CompositeShader);
        CutMaterial = new Material(CutShader);
        CutMaterial.SetFloat(PropertyID.FillAlphaID, _fillAlpha);
        BlurMaterial = new Material(BlurShader);
    }

    private void OnPreRender() {
        if(BloomBuffer != null) {
            RenderTexture.ReleaseTemporary(BloomBuffer);
            BloomBuffer = null;
        }
        BloomBuffer = RenderTexture.GetTemporary(BloomBufferDescriptor);
        BloomBufferID = new RenderTargetIdentifier(BloomBuffer);
        BloomBuffer.filterMode = FilterMode.Point;
        BloomBuffer.wrapMode = TextureWrapMode.Clamp;

        CompositeMaterial.SetTexture(PropertyID.BloomBufferID, BloomBuffer);


        Draw();


    }



    private void Draw() {
        RenderBuffer.Clear();
        RenderBuffer.SetRenderTarget(BloomBufferID);
        RenderBuffer.ClearRenderTarget(true, true, Color.clear);

        for(int i = 0; i < this.BloomRenders.Count; i++) {
            RenderBuffer.SetGlobalColor(PropertyID.ColorID, this.BloomRenders[i].Color);
            RenderBuffer.DrawRenderer(this.BloomRenders[i].Renderer,OpaqueRenderMaterial);
        }




        RenderTextureDescriptor tempDesc = BloomBufferDescriptor;
        tempDesc.width = BloomBuffer.width ;
        tempDesc.height = BloomBuffer.height;
        tempDesc.depthBufferBits = 0;
        tempDesc.width = BloomBuffer.width / DownsampleFactor;
        tempDesc.height = BloomBuffer.height / DownsampleFactor;

        RenderBuffer.GetTemporaryRT(PropertyID.Blur1ID, tempDesc, FilterMode.Bilinear);
        RenderBuffer.GetTemporaryRT(PropertyID.Blur2ID, tempDesc, FilterMode.Bilinear);




        RenderBuffer.Blit(BloomBufferID, Blur1ID);
        bool oddEven = true;
        for(int i = 0; i < Iterations; i++) {
            float off = BlurMinSpread + BlurSpread * i;
            RenderBuffer.SetGlobalFloat(PropertyID.BlurOffset, off);

            if(oddEven) {
                RenderBuffer.Blit(Blur1ID, Blur2ID, BlurMaterial);
            } else {
                RenderBuffer.Blit(Blur2ID, Blur1ID, BlurMaterial);
            }
            oddEven = !oddEven;
        }
        RenderBuffer.Blit(oddEven ? Blur1ID : Blur2ID, BloomBufferID, CutMaterial);



        RenderBuffer.ReleaseTemporaryRT(PropertyID.Blur1ID);
        RenderBuffer.ReleaseTemporaryRT(PropertyID.Blur2ID);
 

    }


    private void OnRenderImage(RenderTexture source, RenderTexture destination) {
        Graphics.Blit(source,destination,CompositeMaterial);
    }




    #region
    public void AddRender(BloomRender render) {
        BloomRenders.Add(render);


    }


    public void RemoveRender(BloomRender render) {
        BloomRenders.Remove(render);

    }

    #endregion



}
