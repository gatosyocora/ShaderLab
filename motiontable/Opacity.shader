// Created By gatosyocora
// reference : http://foxcodex.html.xdomain.jp/index.html
Shader "Motionable/Opacity"
{
	Properties
	{
		_MainTex ("MiniObject Texture", 2D) = "white" {}
		_ObjectColor ("Object Color", Color) = (1, 1, 1, 1)
		_BgColor ("BackGround Color", Color) = (0, 0, 0, 1)
		_Radius ("Radius", Range(0, 0.5)) = 0.3
		_Speed ("Speed", Float) = 1.5
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

			float4 _ObjectColor;
			float4 _BgColor;
			float _Radius;
			float _Speed;
			sampler2D _MainTex;
			float _MiniObjShape;

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

				float alpha = abs(sin(_Time.y * _Speed)); // 円の透明度の変化
				fixed4 objColor = _ObjectColor * _ObjectColor.a*alpha + _BgColor * _BgColor.a*(1-alpha); // 円の位置の描画色

				// circle
				fixed4 circleCol = lerp(_BgColor, objColor, distance(i.uv, float2(0.5, 0.5)) <= _Radius);

				// rect
				fixed4 rectCol = lerp(_BgColor, objColor, (abs(i.uv.x - 0.5) <= _Radius) && (abs(i.uv.y - 0.5) <= _Radius));

				// Texture
				fixed4 tex = tex2D(_MainTex, abs(i.uv-float2(0.5 -_Radius, 0.5 -_Radius))/(_Radius*2.0));
				fixed4 texCol = lerp(_BgColor, tex*(tex.w*alpha) + _BgColor*(1-(tex.w*alpha)), (abs(i.uv.x - 0.5) <= _Radius) && (abs(i.uv.y - 0.5) <= _Radius));

				fixed4 col = lerp(lerp(texCol, rectCol, _MiniObjShape == 1), circleCol, _MiniObjShape == 0);

				return col;

			}
			ENDCG
		}
	}
}
