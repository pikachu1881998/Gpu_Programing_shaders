// Aaron Lanterman, July 23, 2021
// Cobbled together from numerous sources
Shader "Hidden/GPU21OutlinerBuiltInDIYShader" {
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
         
        sampler2D _MainTex;
        float _Speed;
         
        float4 frag (v2f_img i) : COLOR {	
        	float4 original = tex2D(_MainTex, i.uv);

        	float4 original_left = tex2D(_MainTex, i.uv - float2(1.0 / _ScreenParams.x,0));
        	float4 original_right = tex2D(_MainTex, i.uv + float2(1.0 / _ScreenParams.x,0));
        	float4 original_up = tex2D(_MainTex, i.uv - float2(0,1.0 / _ScreenParams.y));
        	float4 original_down = tex2D(_MainTex, i.uv + float2(0,1.0 / _ScreenParams.y));
        	float3 horiz_diff = original_left.rgb - original_right.rgb;
        	float3 vert_diff = original_up.rgb - original_down.rgb;
        	float3 outline = abs(horiz_diff) + abs(vert_diff);
        	return(float4(lerp(outline,original,0.5*(sin(_Speed * _Time.y) + 1)),1));
        	
        }
    ENDCG

	}
}

Fallback off
}