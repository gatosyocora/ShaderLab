Shader "Unlit/LightChecker"
{
	Properties
	{
		_MainTex ("Exist Light Texture", 2D) = "white" {}
		_SubTex ("NotExist Light Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _SubTex;
			
			fixed4 _LightColor0;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				o.normal = v.normal;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				float isExistingDirectionalLight = !(_WorldSpaceLightPos0.x == 0 && _WorldSpaceLightPos0.y == 0 && _WorldSpaceLightPos0.z == 0);
				fixed4 col = lerp (tex2D(_SubTex, i.uv), tex2D(_MainTex, i.uv), isExistingDirectionalLight);
				col.rgb *= lerp(ShadeSH9(float4(i.normal, 1)), _LightColor0.rgb, isExistingDirectionalLight);
				return col;
			}
			ENDCG
		}
	}
}
