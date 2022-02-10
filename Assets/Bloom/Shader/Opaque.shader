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

	        UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture); //���ͼ����洢����NDC����
			
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
				o.screen = ComputeScreenPos(o.pos);//�������ϵ�µ���Ļ����ֵ���䷶ΧΪ[0, w]��������Ľ����Ϊ������ȷ�������Ҫ��ƬԪ��ɫ���н�����γ�����

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