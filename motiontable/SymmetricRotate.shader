// Created By gatosyocora
// reference : http://foxcodex.html.xdomain.jp/index.html
Shader "Motionable/SymmetricRotate"
{
	Properties
	{
		_LineColor ("Line Color", Color) = (1, 1, 1, 1)
		_BgColor ("BackGround Color", Color) = (0, 0, 0, 1)
		_Radius ("Between", Range(0, 0.5)) = 0.4
		_ObjSize ("Size", Range(0, 1)) = 0.1
		_Speed ("Speed", float) = 1
		_Value ("Test", Range(-1, 1)) = 0.0
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
			float _ObjSize;
			float _Speed;
			float _Value;

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

				float a = _Time.y * _Speed * lerp(-1, 1, cos(_Time.y * _Speed) > 0);

				float2 uv = i.uv - 0.5;
				float2x2 rotateMat = float2x2(cos(a), -sin(a), sin(a), cos(a));
				uv = mul(rotateMat, uv);

				col = lerp(_BgColor, _LineColor, (uv.x >= -_ObjSize/2.0 - _Radius && uv.x <= _ObjSize/2.0 + _Radius &&( uv.x <= _ObjSize/2.0 - _Radius || uv.x >= - _ObjSize/2.0 + _Radius)) && (uv.y >= -_ObjSize/2.0 && uv.y <= _ObjSize/2.0));

				return col;
			}
			ENDCG
		}
	}
}
