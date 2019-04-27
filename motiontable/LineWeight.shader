// Created By gatosyocora
// reference : http://foxcodex.html.xdomain.jp/index.html
Shader "Motionable/LineWeight"
{
	Properties
	{
		_LineColor ("LineCircle Color", Color) = (1, 1, 1, 1)
		_BgColor ("BackGround Color", Color) = (0, 0, 0, 1)
		_Radius ("Radius", Range(0, 0.5)) = 0.5
		_Width ("Line Width", Float) = 0.01
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
			float4 _BgColor;
			float _Radius;
			float _Width;
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
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// 線の幅を周期的に変化
				float lineWidth = cos(_Time.y * _Speed) * _Width;

				// 円を描画
				fixed4 col = lerp(lerp(_BgColor, _LineColor, distance(i.uv, float2(0.5, 0.5)) > (_Radius-lineWidth/2.0)), _BgColor, distance(i.uv, float2(0.5, 0.5)) > (_Radius+lineWidth/2.0));

				return col;
			}
			ENDCG
		}
	}
}
