// Created By gatosyocora
// reference : http://foxcodex.html.xdomain.jp/index.html
Shader "Motionable/Sin"
{
	Properties
	{
		_MainTex ("MiniObject Texture", 2D) = "white" {}
		_MainColor ("MainObject Color", Color) = (1, 1, 1, 1)
		_BgColor ("BackGround Color", Color) = (0, 0, 0, 1)
		_Radius ("Radius", Range(0, 0.5)) = 0.5
		_Width ("Line Width", Float) = 0.01
		_MiniRadius ("MiniObject Size", Float) = 0.05
		_Speed ("Speed", Float) = 1
		[KeywordEnum(Sin, Cos)]_WaveType ("Wave Type", Float) = 0
		_Frequency ("Frequency", Float) = 1
		_Amplitude ("Amplitude", Range(0, 1)) = 1
		_xOffset ("OffSet X", Range(-0.5, 0.5)) = 0
		_yOffset ("OffSet Y", Range(-0.5, 0.5)) = 0
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

			float4 _MainColor;
			float4 _BgColor;
			float _Radius;
			float _Width;
			float _MiniRadius;
			float _Speed;
			float _Amplitude;
			float _Frequency;
			float _xOffset;
			float _yOffset;
			float _WaveType;

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
				float sinY = sin((i.uv.x+_xOffset) * _Frequency)/2 * _Amplitude + 0.5 + _yOffset;

				float cosY = cos((i.uv.x+_xOffset) * _Frequency)/2 * _Amplitude + 0.5 + _yOffset;

				float y = lerp(sinY, cosY, _WaveType);

				float lineTop = y + _Width/2.0;
				float lineBottom = y - _Width/2.0;

				// sin波を描画
				fixed4 col = lerp(_BgColor, _MainColor, (i.uv.y <= lineTop && i.uv.y >= lineBottom));

				// 時間経過で描画していく
				col = lerp(_BgColor, lerp(_BgColor, col, 1-1*clamp(frac(_Time.y * _Speed)*2-1+_xOffset, 0, 1)), i.uv.x < clamp(frac(_Time.y * _Speed)*2, 0, 1));

				float lineY = sin((frac(_Time.y * _Speed)*2+_xOffset) * _Frequency)/2 * _Amplitude + 0.5 + _yOffset;

				// 上下するラインの描画
				col = lerp(col, _MainColor, i.uv.y <= lineY + _Width/2.0 && i.uv.y >= lineY - _Width/2.0);

				// 上下するライン上の円の描画
				col = lerp(col, _MainColor, distance(i.uv, float2(0.5, lineY)) <= _Radius);

				return col;
			}
			ENDCG
		}
	}
}
