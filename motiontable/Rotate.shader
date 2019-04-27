// Created By gatosyocora
// reference : http://foxcodex.html.xdomain.jp/index.html
Shader "Motionable/Rotate"
{
	Properties
	{
		_LineColor ("Line Color", Color) = (1, 1, 1, 1)
		_BgColor ("BackGround Color", Color) = (0, 0, 0, 1)
		_Radius ("Size", Range(0, 0.5)) = 0.4
		_Width ("Line Width", Float) = 0.08
		_Speed ("Speed", int) = 3
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
			int _Speed;

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

				float speed =_Speed*2-1*_Speed/abs(lerp(_Speed, 1, _Speed == 0));
				float angle = 2 * UNITY_PI * _Time.y/20 * speed; // 角度
				float quarterAngle = UNITY_PI/2.0 * speed; // 2頂点間の角度差

				float widthHalf = _Width/sqrt(2.0);

				// 四角形の4頂点
				float2 p1 = float2(0.5 - cos(angle) * _Radius, 0.5 + sin(angle) * _Radius); // 四角形の頂点1
				float2 p2 = float2(0.5 - cos(angle+quarterAngle) * _Radius, 0.5 + sin(angle+quarterAngle) * _Radius); // 四角形の頂点2
				float2 p3 = float2(0.5 - cos(angle+quarterAngle*2) * _Radius, 0.5 + sin(angle+quarterAngle*2) * _Radius); // 四角形の頂点3
				float2 p4 = float2(0.5 - cos(angle+quarterAngle*3) * _Radius, 0.5 + sin(angle+quarterAngle*3) * _Radius); // 四角形の頂点4

				// _LineColorで描かれた大きな四角形の4頂点
				float2 p1out = float2(0.5 -  cos(angle) * (_Radius + widthHalf), 0.5 +  sin(angle) * (_Radius + widthHalf));
				float2 p2out = float2(0.5 -  cos(angle+quarterAngle) * (_Radius + widthHalf), 0.5 +  sin(angle+quarterAngle) * (_Radius + widthHalf));
				float2 p3out = float2(0.5 -  cos(angle+quarterAngle*2) * (_Radius + widthHalf), 0.5 +  sin(angle+quarterAngle*2) * (_Radius + widthHalf));
				float2 p4out = float2(0.5 -  cos(angle+quarterAngle*3) * (_Radius + widthHalf), 0.5 +  sin(angle+quarterAngle*3) * (_Radius + widthHalf));

				// _BgColorで描かれた小さな四角形の4頂点
				float2 p1in = float2(0.5 -  cos(angle) * (_Radius - widthHalf), 0.5 +  sin(angle) * (_Radius - widthHalf));
				float2 p2in = float2(0.5 -  cos(angle+quarterAngle) * (_Radius - widthHalf), 0.5 +  sin(angle+quarterAngle) * (_Radius - widthHalf));
				float2 p3in = float2(0.5 -  cos(angle+quarterAngle*2) * (_Radius - widthHalf), 0.5 +  sin(angle+quarterAngle*2) * (_Radius - widthHalf));
				float2 p4in = float2(0.5 -  cos(angle+quarterAngle*3) * (_Radius - widthHalf), 0.5 +  sin(angle+quarterAngle*3) * (_Radius - widthHalf));

				// 各頂点の描画
				/*
				float radius = _Width/2.0;
				col = lerp(_LineColor, _BgColor, distance(i.uv, p1) > radius);
				col = lerp(_LineColor, col, distance(i.uv, p2) > radius);
				col = lerp(_LineColor, col, distance(i.uv, p3) > radius);
				col = lerp(_LineColor, col, distance(i.uv, p4) > radius);
				*/

				// _LineColorで描かれた大きな四角形の辺の各方程式
				float line12outX = (p2out.x - p1out.x)/(p2out.y - p1out.y)*(i.uv.y - p1out.y) + p1out.x;
				float line12outY = (p2out.y - p1out.y)/(p2out.x - p1out.x)*(i.uv.x - p1out.x) + p1out.y;
				float2 line12out = float2(line12outX, line12outY);
				float line23outX = (p3out.x - p2out.x)/(p3out.y - p2out.y)*(i.uv.y - p2out.y) + p2out.x;
				float line23outY = (p3out.y - p2out.y)/(p3out.x - p2out.x)*(i.uv.x - p2out.x) + p2out.y;
				float2 line23out = float2(line23outX, line23outY);
				float line34outX = (p4out.x - p3out.x)/(p4out.y - p3out.y)*(i.uv.y - p3out.y) + p3out.x;
				float line34outY = (p4out.y - p3out.y)/(p4out.x - p3out.x)*(i.uv.x - p3out.x) + p3out.y;
				float2 line34out = float2(line34outX, line34outY);
				float line41outX = (p1out.x - p4out.x)/(p1out.y - p4out.y)*(i.uv.y - p4out.y) + p4out.x;
				float line41outY = (p1out.y - p4out.y)/(p1out.x - p4out.x)*(i.uv.x - p4out.x) + p4out.y;
				float2 line41out = float2(line41outX, line41outY);

				// _BgColorで描かれた小さな四角形の辺の各方程式
				float line12inX = (p2in.x - p1in.x)/(p2in.y - p1in.y)*(i.uv.y - p1in.y) + p1in.x;
				float line12inY = (p2in.y - p1in.y)/(p2in.x - p1in.x)*(i.uv.x - p1in.x) + p1in.y;
				float2 line12in = float2(line12inX, line12inY);
				float line23inX = (p3in.x - p2in.x)/(p3in.y - p2in.y)*(i.uv.y - p2in.y) + p2in.x;
				float line23inY = (p3in.y - p2in.y)/(p3in.x - p2in.x)*(i.uv.x - p2in.x) + p2in.y;
				float2 line23in = float2(line23inX, line23inY);
				float line34inX = (p4in.x - p3in.x)/(p4in.y - p3in.y)*(i.uv.y - p3in.y) + p3in.x;
				float line34inY = (p4in.y - p3in.y)/(p4in.x - p3in.x)*(i.uv.x - p3in.x) + p3in.y;
				float2 line34in = float2(line34inX, line34inY);
				float line41inX = (p1in.x - p4in.x)/(p1in.y - p4in.y)*(i.uv.y - p4in.y) + p4in.x;
				float line41inY = (p1in.y - p4in.y)/(p1in.x - p4in.x)*(i.uv.x - p4in.x) + p4in.y;
				float2 line41in = float2(line41inX, line41inY);

				// _LineColorで描かれた大きな四角形を描画
				col = lerp(col, _LineColor, (line12out.x <= i.uv.x && line34out.x >= i.uv.x) && (line23out.y <= i.uv.y && line41out.y >= i.uv.y));
				col = lerp(col, _LineColor, (line12out.y <= i.uv.y && line34out.y >= i.uv.y) && (line23out.x <= i.uv.x && line41out.x >= i.uv.x));
				col = lerp(col, _LineColor, (line12out.x >= i.uv.x && line34out.x <= i.uv.x) && (line23out.y >= i.uv.y && line41out.y <= i.uv.y));
				col = lerp(col, _LineColor, (line12out.y >= i.uv.y && line34out.y <= i.uv.y) && (line23out.x >= i.uv.x && line41out.x <= i.uv.x));

				// _BgColorで描かれた小さな四角形を描画
				col = lerp(col, _BgColor, (line12in.x <= i.uv.x && line34in.x >= i.uv.x) && (line23in.y <= i.uv.y && line41in.y >= i.uv.y));
				col = lerp(col, _BgColor, (line12in.y <= i.uv.y && line34in.y >= i.uv.y) && (line23in.x <= i.uv.x && line41in.x >= i.uv.x));
				col = lerp(col, _BgColor, (line12in.x >= i.uv.x && line34in.x <= i.uv.x) && (line23in.y >= i.uv.y && line41in.y <= i.uv.y));
				col = lerp(col, _BgColor, (line12in.y >= i.uv.y && line34in.y <= i.uv.y) && (line23in.x >= i.uv.x && line41in.x <= i.uv.x));
				
				
				return col;
			}
			ENDCG
		}
	}
}
