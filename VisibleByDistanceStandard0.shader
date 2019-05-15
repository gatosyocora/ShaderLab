Shader "Gato/VisibleByDistanceStandard0" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_DissolveTex ("Dissolve Texture (Noise Texture)", 2D) = "white" {}
		[KeywordEnum(Visible, Clear)] _ChangeType ("Change Type", Float) = 0
		[KeywordEnum(Dissolve, Alpha)] _ChangeWay ("Change Way", Float) = 1
		[KeywordEnum(None, Xplus, Yplus, Zplus, Xminus, Yminus, Zminus)] _ChangeLimit ("Change Limit", Float) = 0
		_StartDist ("Start Distance", Float) = 10.0
		_EndDist ("End Distance", Float) = 2.0
	}
	SubShader {
		Tags { "RenderType"="Transparent" "Queue"="Transparent"}
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows
		#pragma multi_compile _CHANGEWAY_DISSOLVE _CHANGEWAY_ALPHA

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		uniform sampler2D _DissolveTex;
		uniform float _StartDist;
		uniform float _EndDist;

		uniform float _ChangeType;
		uniform float _ChangeLimit;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			
			fixed4 dissolveCol = tex2D(_DissolveTex, IN.uv_MainTex);
			float isDissolve = dissolveCol.r * 0.2 + dissolveCol.g * 0.7 + dissolveCol.b * 0.1;

			float alpha = 1.0;

			// カメラとの距離を調べる
			float4 objPos = mul(unity_ObjectToWorld, float4(0,0,0,1)); // オブジェクトの座標
			float4 camPos = float4(_WorldSpaceCameraPos, 1); // カメラの座標
			float dist = distance(objPos, camPos); // カメラとオブジェクトとの距離

			float4 distVectors = objPos-camPos; // ベクトルごとの距離

			
			// StartDistから変化が始まりEndDistで変化が終わる(StartDist->EndDist=>0->1)
			float level = saturate((dist-_EndDist)/(_StartDist-_EndDist));

			// 溶けるように変化するか透明になるか
			#ifdef _CHANGEWAY_DISSOLVE
			// 近づいたらDissolveで表示されていくor消えていく
			clip(lerp(isDissolve - level, level - isDissolve, _ChangeType));
			clip(lerp(lerp(lerp(1.0, 1-distVectors.z, _ChangeLimit == 3.0), 1-distVectors.y, _ChangeLimit == 2.0), 1-distVectors.x, _ChangeLimit == 1.0));
			clip(lerp(lerp(lerp(1.0, distVectors.z, _ChangeLimit == 6.0), distVectors.y, _ChangeLimit == 5.0), distVectors.x, _ChangeLimit == 4.0));
			#else
			alpha = lerp(1-level, level, _ChangeType);
			#endif


			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			c.a = c.a * alpha;
			clip(c.a);
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
