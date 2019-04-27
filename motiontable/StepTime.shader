// Created By gatosyocora
// reference : http://foxcodex.html.xdomain.jp/index.html
Shader "Motionable/StepTime"
{
	Properties
	{
		_LineColor ("Line Color", Color) = (1, 1, 1, 1)
		_ObjColor ("Object Color", Color) = (1, 0, 0, 1)
		_BgColor ("BackGround Color", Color) = (0, 0, 0, 1)
		_Radius ("Radius", Range(0, 0.5)) = 0.4
		_Width ("Line Width", Float) = 0.01
		_StepNum ("Step Numbers", int) = 24
		_Speed ("Speed", Float) = 1
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
			float4 _ObjColor;
			float4 _BgColor;
			float _Radius;
			float _Width;
			float _StepNum;
			float _Speed;

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

			// 空間を回転させる関数
			float2 rotateUV(float2 uv, float angle) {
				uv = uv - 0.5;
				float2x2 rotateMat = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
				uv = mul(rotateMat, uv);
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
				float a;
				float2 uv;
				float scale = _Radius*2;

				// 周りの円を描画
				fixed4 col = lerp(_BgColor, _LineColor, distance(i.uv, float2(0.5, 0.5)) <= (_Radius+_Width/2.0));
				col = lerp(col, _ObjColor, distance(i.uv, float2(0.5, 0.5)) <= (_Radius-_Width/2.0));

				// メモリを描画
				for (int n = 1; n <= _StepNum; n++) {
					a = 2 * UNITY_PI / _StepNum * n;
					uv = rotateUV(i.uv, a);
					// 空間が回転してるため、単純に0のところにメモリをふるように描く
					col = lerp(col, _LineColor, distance(0.5, uv.x) < _Width/2.0 && distance(0.5+_Radius-_Width*3*scale, uv.y) < _Width*3*scale);
				}

				// 中心の円の描画
				col = lerp(col, _LineColor, distance(float2(0.5, 0.5), i.uv) < _Width*3.0*scale);

				// 針の描画
				a = 2 * UNITY_PI / _StepNum * floor(frac(_Time.y/5.0 * _Speed)*_StepNum);
				uv = rotateUV(i.uv, a);
				// 空間が回転してるため、単純に0のところを示すように針を描く
				col = lerp(col, _LineColor, distance(0.5, uv.x) < _Width/2.0 && (uv.y - 0.5 <= _Radius && uv.y >= 0.5));

				return col;
			}
			ENDCG
		}
	}
}
