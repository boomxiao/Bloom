Shader "X/Opaque"
{
	Properties
	{
		//[HideInInspector] _Color ("", Color) = (1, 1, 1, 1)
	}
	
	SubShader
	{
		Lighting Off
		Fog { Mode Off }
		ZWrite Off			// Manual depth test
		ZTest Always		// Manual depth test

		Pass
		{
			Stencil
			{
				Ref 1
				Comp Always
				Pass Replace
				ZFail Keep
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			uniform fixed4 _Color;

	        UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture); //深度图里面存储的是NDC坐标
			
			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;

				float4 screen : TEXCOORD0;
			};
			
			v2f vert(appdata v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.screen = ComputeScreenPos(o.pos);//齐次坐标系下的屏幕坐标值，其范围为[0, w]，计算出的结果不为最终正确结果。需要在片元着色器中进行齐次除法。

				COMPUTE_EYEDEPTH(o.screen.z);
			

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float z = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screen));
		     	float perspZ = LinearEyeDepth(z);
				float orthoZ = _ProjectionParams.y + z * (_ProjectionParams.z - _ProjectionParams.y);	// near + z * (far - near)
				float sceneZ = lerp(perspZ, orthoZ, unity_OrthoParams.w);
				clip(sceneZ - i.screen.z + 0.01);


				return _Color;
			}
			ENDCG
		}
	}
	Fallback Off
}