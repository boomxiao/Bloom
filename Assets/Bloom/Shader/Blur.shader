Shader "X/Blur"
{
	Properties
	{
		[HideInInspector] _MainTex ("", 2D) = "" {}
	}
	
	SubShader
	{
		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off
			Lighting Off
 
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
 
			
			#include "UnityCG.cginc"
			
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _MainTex_TexelSize;
			
			uniform float _BlurOffset;
			uniform half _HighlightingIntensity;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;

				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
			};
			
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				float2 uv = TRANSFORM_TEX(v.texcoord, _MainTex); 
				float2 offs = _BlurOffset * _MainTex_TexelSize.xy;


 

				// Diagonal
				o.uv0.x = uv.x - offs.x;
				o.uv0.y = uv.y - offs.y;

				o.uv0.z = uv.x + offs.x;
				o.uv0.w = uv.y - offs.y;

				o.uv1.x = uv.x + offs.x;
				o.uv1.y = uv.y + offs.y;

				o.uv1.z = uv.x - offs.x;
				o.uv1.w = uv.y + offs.y;



				return o;
			}
			
			half4 frag(v2f i) : SV_Target
			{
				half4 color1 = tex2D(_MainTex, i.uv0.xy);
				fixed4 color2;

 
				color2 = tex2D(_MainTex, i.uv0.zw);
				color1.rgb = max(color1.rgb, color2.rgb);
				color1.a += color2.a;

				color2 = tex2D(_MainTex, i.uv1.xy);
				color1.rgb = max(color1.rgb, color2.rgb);
				color1.a += color2.a;

				color2 = tex2D(_MainTex, i.uv1.zw);
				color1.rgb = max(color1.rgb, color2.rgb);
				color1.a += color2.a;
				
				color1.a *= .3;
				return color1;
			}
			ENDCG
		}
	}
	
	Fallback off
}