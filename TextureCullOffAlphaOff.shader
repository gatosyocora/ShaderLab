Shader "Unlit/TextureCullOffAlphaOff" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
}

SubShader {
	Tags { "Queue" = "Transparent" "RenderType"="Transparent" "IgnoreProjector"="True"}
	LOD 100

	Blend SrcAlpha OneMinusSrcAlpha 
	
	Pass {
		Lighting Off
		Cull Off

		Material {
             Diffuse [_Color]
         }
		SetTexture [_MainTex] { combine texture } 
	}
}
}