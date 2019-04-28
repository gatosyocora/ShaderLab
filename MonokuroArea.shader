Shader "Unlit/MonokuroArea"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent+10" }
		LOD 100

		ZWrite Off
		ZTest Always
		Blend SrcAlpha OneMinusSrcAlpha

		GrabPass {}

		Cull Off
		Pass
		{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 screenPos : TEXCOORD1;
			};

			sampler2D _GrabTexture;
			float4 _GrabTexture_ST;
			float _P;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _GrabTexture);
				o.screenPos = ComputeScreenPos(o.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 grabUV = (i.screenPos.xy / i.screenPos.w);
				
				// モノクロに変換 
				fixed4 texColor = tex2D(_GrabTexture, grabUV);
				float color = (texColor.r+texColor.g+texColor.b) / 3.0;
				fixed4 col = fixed4(color, color, color, 1);

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}

	}
}
