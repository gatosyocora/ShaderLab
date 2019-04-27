// Created By gatosyocora
// reference : http://foxcodex.html.xdomain.jp/index.html
Shader "Motionable/Orbit"
{
	Properties
	{
		_MainTex ("MiniObject Texture", 2D) = "white" {}
		_MiniColor ("MiniObject Color", Color) = (1, 1, 1, 1)
		_LineColor ("LineCircle Color", Color) = (1, 1, 1, 1)
		_BgColor ("BackGround Color", Color) = (0, 0, 0, 1)
		_Radius ("Radius", Range(0, 0.5)) = 0.5
		_Width ("Line Width", Float) = 0.01
		_MiniRadius ("MiniObject Size", Float) = 0.05
		_Speed ("Speed", Float) = 1
		[KeywordEnum(Circle, Rect, Texture)]_MiniObjShape ("MiniObject Shape", Float) = 0
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

			float4 _MiniColor;
			float4 _LineColor;
			float4 _BgColor;
			float _Radius;
			float _Width;
			float _MiniRadius;
			float _Speed;
			float _MiniObjShape;
			sampler2D _MainTex;

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
				// 円運動する道のりを描画
				fixed4 col = lerp(lerp(_BgColor, _LineColor, distance(i.uv, float2(0.5, 0.5)) > (_Radius-_Width/2.0)), _BgColor, distance(i.uv, float2(0.5, 0.5)) > (_Radius+_Width/2.0));
				
				float px = 0.5 - cos(_Time.y*_Speed)*_Radius; // 円運動してる図形の中心のx座標
				float py = 0.5 + sin(_Time.y*_Speed)*_Radius; // 円運動してる図形の中心のy座標

				// circle
				fixed4 circleCol = lerp(_MiniColor, col, distance(i.uv, float2(px, py)) > _MiniRadius);
				//fixed cricleCol = lerp(col, _MiniColor, sqrt(pow(abs(i.uv.x-px), 2) + pow(abs(i.uv.y-py), 2)) <= _MiniRadius);

				// rect
				fixed4 rectCol = lerp(col, _MiniColor, (abs(i.uv.x - px) <= _MiniRadius) && (abs(i.uv.y - py) <= _MiniRadius));

				// Texture
				fixed4 tex = tex2D(_MainTex, abs(i.uv-float2(px-_MiniRadius, py-_MiniRadius))/(_MiniRadius*2.0));
				fixed4 texCol = lerp(col, col*(1-tex.w) + tex*tex.w, (abs(i.uv.x - px) <= _MiniRadius) && (abs(i.uv.y - py) <= _MiniRadius));

				// star (つくれなかった...)

				// 円運動する図形を選択
				col = lerp(lerp(texCol, rectCol, _MiniObjShape == 1), circleCol, _MiniObjShape == 0);

				return col;
			}
			ENDCG
		}
	}
}
