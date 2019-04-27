// Created By gatosyocora
// reference : http://foxcodex.html.xdomain.jp/index.html
Shader "Motionable/MaskWipe"
{
	Properties
	{
		_CircleColor ("Circle Color", Color) = (1, 1, 1, 1)
		_BgColor ("BackGround Color", Color) = (0, 0, 0, 1)
		_Radius ("Radius", Range(0, 0.5)) = 0.4
		_Speed ("Speed", Float) = 0.3
		_StepNum ("Step Numbers", int) = 8
		_StartMaskStep ("Start Mask Step", int) = 4
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

			float4 _CircleColor;
			float4 _BgColor;
			float _Radius;
			float _Speed;
			int _StepNum;
			int _StartMaskStep;

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

				// 初めに出てくる円を描画
				fixed4 col = lerp(_BgColor, _CircleColor, distance(i.uv, float2(0.5, 0.5)) > _Radius * clamp(frac(_Time.y * _Speed)*_StepNum, 0, 1));
				
				//後から出てくる円を描画
				col = lerp(_CircleColor, col, distance(i.uv, float2(0.5, 0.5)) > _Radius * clamp(frac(_Time.y * _Speed)*_StepNum-_StartMaskStep, 0, 1));

				return col;
			}
			ENDCG
		}
	}
}
