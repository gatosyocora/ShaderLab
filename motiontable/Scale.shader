// Created By gatosyocora
// reference : http://foxcodex.html.xdomain.jp/index.html
Shader "Motionable/Scale"
{
	Properties
	{
		_ObjColor ("Color", Color) = (1, 1, 1, 1)
		_BgColor ("BackGround Color", Color) = (0, 0, 0, 1)
		_MinScale ("1st Scale", Range(0, 1)) = 0.3
		_MaxScale ("2nd Scale", Range(0, 1)) = 0.7
		_Speed ("Speed", Float) = 0.25
		_StepNum ("Step Numbers", int) = 9
		_StartZeroToMinStep ("Start Zero To Min Step", int) = 1
		_StartMinTo2ndStep ("Start Min To 2nd Step", int) = 3
		_Start2ndToMaxStep ("Start 2nd To Max Step", int) = 5
		_StartMaxToZeroStep ("Start Max To Zero Step", int) = 7
		[KeywordEnum(X, Y)]_2ndScaleVector ("2nd Change Vector", Float) = 0

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

			float4 _ObjColor;
			float4 _BgColor;
			float _MaxScale;
			float _MinScale;
			float _Speed;
			int _StepNum;
			int _StartZeroToMinStep;
			int _StartMinTo2ndStep;
			int _Start2ndToMaxStep;
			int _StartMaxToZeroStep;
			float _2ndScaleVector;

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
				// 段階ごとのスケール
				float minScale = _MinScale/2.0+0.5;
				float maxScale = _MaxScale/2.0+0.5;
				float deltaScale = maxScale - minScale;

				// 各ステップごとのスケール変化のための波形(0から1の範囲)
				fixed4 col;
				float stepZeroToMin = clamp(frac(_Time.y * _Speed)*_StepNum-_StartZeroToMinStep, 0, 1); // スケールが0からminScaleまで1stepで変化するための波形
				float stepMinTo2nd = clamp(frac(_Time.y * _Speed)*_StepNum-_StartMinTo2ndStep, 0, 1); // xまたはyのスケールがminScaleからmaxScaleまで1stepで変化するための波形
				float step2ndToMax = clamp(frac(_Time.y * _Speed)*_StepNum-_Start2ndToMaxStep, 0, 1); // yまたはxのスケールがminScaleからmaxScaleまで1stepで変化するための波形
				float stepMaxToZero = -1 * clamp(frac(_Time.y * _Speed)*_StepNum-_StartMaxToZeroStep, 0, 1); // スケールがmaxScaleから0まで1stepで変化するための波形

				// x, y方向のスケールの変化
				float xScale = stepZeroToMin*minScale + stepMinTo2nd*deltaScale*(1-_2ndScaleVector) + step2ndToMax*deltaScale*_2ndScaleVector + stepMaxToZero; // x方向へのスケールの変化
				float yScale = stepZeroToMin*minScale + stepMinTo2nd*deltaScale*_2ndScaleVector + step2ndToMax*deltaScale*(1-_2ndScaleVector) + stepMaxToZero; // y方向へのスケールの変化

				col = lerp(_BgColor, _ObjColor, (i.uv.x < xScale && i.uv.x > 1-xScale) && (i.uv.y < yScale && i.uv.y > 1-yScale));

				return col;
			}
			ENDCG
		}
	}
}
