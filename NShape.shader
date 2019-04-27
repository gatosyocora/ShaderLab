// Created By gatosyocora
// reference : http://foxcodex.html.xdomain.jp/index.html
Shader "Gato/NShape"
{
	Properties
	{
		_LineColor ("Line Color", Color) = (1, 1, 1, 1)
		_BgColor ("BackGround Color", Color) = (0, 0, 0, 1)
		_Radius ("Size", Range(0, 0.5)) = 0.4
		_Width ("Line Width", Float) = 0.08
		_Speed ("Speed", Float) = 1
		_N ("N", Float) = 6.0
		[IntRange]_RotOffset ("Rotation Offset", Range(0, 360)) = 180
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent"}
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			float4 _LineColor;
			float4 _BgColor;
			float _Radius;
			float _Width;
			float _Speed;
			float _N;
			int _RotOffset;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			float2 rotateUV(float2 uv, float angle) {
				uv = uv - 0.5;
				float2x2 rotateMat = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
				uv = mul(rotateMat, uv);
				uv = uv + 0.5;
				return uv;
			}

			float2 scaleUV(float2 uv, float scale) {
				float2x2 scaleMat = float2x2(1/scale, 0, 0, 1/scale);
				uv = uv - 0.5;
				uv = mul(scaleMat, uv);
				uv = uv + 0.5;
				return uv;
			}

			float2 scaleUV(float2 uv, float2 scale) {
				float2x2 scaleMat = float2x2(1/scale.x, 0, 0, 1/scale.y);
				uv = uv - 0.5;
				uv = mul(scaleMat, uv);
				uv = uv + 0.5;
				return uv;
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = _BgColor;
				float a;
				float2 uv;
				float n = _N;
				float r = lerp(_Radius, _Radius-0.11, n <= 3);

				// 線を描画
				for(int k = 0; k < n; k++) {
					uv = i.uv;
					a = 2 * UNITY_PI /360 * (360/n * k + ((180 * n-2)/n-45) + _RotOffset);
					uv = rotateUV(uv, a);
					uv += r;
					//col = lerp(col, _LineColor, uv.x >= 0.5 && uv.y >= 0.5 && abs(-abs(uv.x-0.5)+1.0-uv.y) < _Width/2.0);
					col = lerp(col, _LineColor, uv.x >= 0.5 && uv.y >= 0.5 && -abs(uv.x-0.5)+1.0 > uv.y - _Width/2.0);
				}

				// 外側に出た線を消す
				/*for(int k = 0; k < n; k++) {
					uv = i.uv;
					a = 2 * UNITY_PI /360 * (360/n * k + ((180 * n-2)/n-45) + _RotOffset);
					uv = rotateUV(uv, a);
					uv += r;
					col = lerp(_BgColor, col, uv.x >= 0.5 && uv.y >= 0.5 && -abs(uv.x-0.5)+1.0 < uv.y + _Width/2.0);
				}*/

				return col;
			}
			ENDCG
		}
	}
}
