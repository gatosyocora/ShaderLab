// Created By gatosyocora
// reference : http://foxcodex.html.xdomain.jp/index.html
Shader "Motionable/Rotate2"
{
	Properties
	{
		_LineColor ("Line Color", Color) = (1, 1, 1, 1)
		_BgColor ("BackGround Color", Color) = (0, 0, 0, 1)
		_Radius ("Size", Range(0, 0.5)) = 0.4
		_Width ("Line Width", Float) = 0.08
		_Speed ("Speed", float) = 1
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
				fixed4 col = _BgColor;

				float a = _Time.y * _Speed;

				float2 uv = i.uv - 0.5;
				float2x2 rotateMat = float2x2(cos(a), -sin(a), sin(a), cos(a));
				uv = mul(rotateMat, uv);

				col = lerp(_BgColor, _LineColor, uv.x >= 0.5-_Radius-_Width/2.0-0.5 && uv.x <= 0.5+_Radius+_Width/2.0-0.5 && uv.y >= 0.5-_Radius-_Width/2.0-0.5 && uv.y <= 0.5+_Radius+_Width/2.0-0.5);
				col = lerp(col, _BgColor, uv.x >= 0.5-_Radius+_Width/2.0-0.5 && uv.x <= 0.5+_Radius-_Width/2.0-0.5 && uv.y >= 0.5-_Radius+_Width/2.0-0.5 && uv.y <= 0.5+_Radius-_Width/2.0-0.5);

				return col;
			}
			ENDCG
		}
	}
}
