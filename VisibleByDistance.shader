// created by gatosyocora
Shader "Gato/VisibleByDistance"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DissolveTex ("Dissolve Texture (Noise Texture)", 2D) = "white" {}
		[KeywordEnum(Visible, Clear)] _ChangeType ("Change Type", Float) = 0
		[KeywordEnum(Dissolve, Alpha)] _ChangeWay ("Change Way", Float) = 1
		_StartDist ("Start Distance", Float) = 10.0
		_EndDist ("End Distance", Float) = 2.0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent"}
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _CHANGEWAY_DISSOLVE _CHANGEWAY_ALPHA
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			uniform sampler2D _DissolveTex;
			uniform float _StartDist;
			uniform float _EndDist;

			uniform float _ChangeType;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 dissolveCol = tex2D(_DissolveTex, i.uv);
				float isDissolve = dissolveCol.r * 0.2 + dissolveCol.g * 0.7 + dissolveCol.b * 0.1;

				float alpha = 1.0;

				// カメラとの距離を調べる
				float4 objPos = mul(unity_ObjectToWorld, float4(0,0,0,1)); // オブジェクトの座標
				float4 camPos = float4(_WorldSpaceCameraPos, 1); // カメラの座標
				float dist = distance(objPos, camPos); // カメラとオブジェクトとの距離

				 // StartDistから変化が始まりEndDistで変化が終わる(StartDist->EndDist=>0->1)
				float level = saturate((dist-_EndDist)/(_StartDist-_EndDist));

				// 溶けるように変化するか透明になるか
				#ifdef _CHANGEWAY_DISSOLVE
				// 近づいたらDissolveで表示されていくor消えていく
				clip(lerp(isDissolve - level, level - isDissolve, _ChangeType));
				#else
				alpha = lerp(1-level, level, _ChangeType);
				#endif

				fixed4 col = tex2D(_MainTex, i.uv);
				col.a = col.a * alpha;
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
