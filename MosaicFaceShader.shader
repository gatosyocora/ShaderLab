Shader "Unlit/MosaicFaceShader"
{
	// VRChatでの利用を想定
	// https://qiita.com/niusounds/items/2ed90d4fd74a167efd54
	Properties
	{
		_MirrorTex ("Mirror Texture", 2D) = "white" {} // MirrorReflectionレイヤーのみを表示するカメラのRenderTexture
		_LocalTex ("Local Texture", 2D) = "white" {} // PlayerLocalレイヤーのみを表示するカメラのRenderTexture
		_BgTex ("BackGround Texture", 2D) = "white" {}
		_TexSize ("Tex Size", Float) = 512 // RenderTextureの縦横のサイズ
		_BlockSize ("Block Size", Float) = 8
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
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
			};

			sampler2D _MirrorTex;
			float4 _MirrorTex_ST;
			sampler2D _LocalTex;
			float4 _LocalTex_ST;

			sampler2D _SiroGumiTex;
			float4 _SiroGumiTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MirrorTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = 0;

				// 顔だったら白く描画
				if (tex2D(_LocalTex, i.uv).r <= 0 && tex2D(_LocalTex, i.uv).g <= 0 && tex2D(_LocalTex, i.uv).b <= 0) {
					if (tex2D(_MirrorTex, i.uv).r > 0 || tex2D(_MirrorTex, i.uv).g > 0 || tex2D(_MirrorTex, i.uv).b > 0) {
						col = 1;
					}
				} 
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;

			}

			ENDCG
		}

		GrabPass{}

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

			sampler2D _BgTex;
			float4 _BgTex_ST;

			sampler2D _MirrorTex;
			float4 _MirrorTex_ST;

			sampler2D _LocalTex;
			float4 _LocalTex_ST;

			sampler2D _GrabTexture;
            float4 _GrabTexture_ST;

			float _TexSize;

			float _BlockSize;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _GrabTexture);
				o.screenPos = ComputeScreenPos(o.vertex); 
				//o.screenPos = ComputeGrabScreenPos(o.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				float2 grabUV = (i.screenPos.xy / i.screenPos.w);
				float isMosaic = tex2D(_GrabTexture, grabUV);

				if (isMosaic == 1.0) {
					float2 targetUV = i.uv;
					targetUV.x = floor((targetUV.x * _TexSize) / _BlockSize) * _BlockSize / _TexSize;
					targetUV.y = floor((targetUV.y * _TexSize) / _BlockSize) * _BlockSize / _TexSize;
					return tex2D(_MirrorTex, targetUV);
				} else {
					float4 playerLocal = tex2D(_LocalTex, i.uv);
					if (playerLocal.r > 0.0 || playerLocal.g > 0.0 || playerLocal.b > 0.0) {
						return tex2D(_LocalTex, i.uv);
					} else {
						return tex2D(_BgTex, i.uv);				
					} 
				}
			}
			ENDCG
		}

	}
}
