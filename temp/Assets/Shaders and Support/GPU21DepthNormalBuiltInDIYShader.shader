// Aaron Lanterman, July 23, 2021
// Cobbled together from numerous sources
Shader "Hidden/GPU21DepthNormalBuiltInDIYShader" {
 
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_Speed ("Speed", float) = 1
}
 
SubShader {
	Pass {
		ZTest Always Cull Off ZWrite Off
 
CGPROGRAM
#pragma vertex vert_img
#pragma fragment frag
#include "UnityCG.cginc"
 
sampler2D _CameraDepthNormalsTexture;
sampler2D _MainTex;
float _Speed;
 
float4 frag (v2f_img i) : COLOR {	
	float4 original = tex2D(_MainTex, i.uv);
	float4 enc = tex2D(_CameraDepthNormalsTexture, i.uv);

	float depth;
	float3 n, display_n;
    DecodeDepthNormal(enc, /* out */  depth, /* out */ n);
	
	display_n = 0.5 * (1 + n);
    return(float4(lerp(display_n,float3(1,1,1)* depth,0.5*(cos(_Speed * _Time.y) + 1)),1));
	
}
ENDCG

	}
}

Fallback off
}