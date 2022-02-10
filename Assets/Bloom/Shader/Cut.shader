Shader "X/Cut"
{
	Properties
	{
		[HideInInspector] _MainTex ("", 2D) = "" {}
		[HideInInspector] _FillAlpha ("", Range(0.0, 1.0)) = 1.0
	}

	SubShader
	{
		Lighting Off
		ZWrite Off
		ZTest Always
		Cull Back

		Pass
		{
			Stencil
			{
				Ref 1
				Comp NotEqual
				Pass Keep
				ZFail Keep
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform	float  _FillAlpha;
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				return tex2D(_MainTex, i.uv);
			}
			ENDCG
		}

		Pass
		{
			Stencil
			{
				Ref 1
				Comp Equal
				Pass Keep
				ZFail Keep
			}
			ColorMask A
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex : POSITION;
			};
			
			struct v2f
			{
				float4 pos : SV_POSITION;
			};

			uniform float _FillAlpha;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag() : SV_Target
			{
	 
				return fixed4(0, 0, 0, _FillAlpha);
			}
			ENDCG
		}
				

				
	}
	FallBack Off
}
