// Aaron Lanterman, June 30, 2020
// Cobbled together from numerous sources (including Catlike Coding & Unity docs)
Shader "GPU20/Textured" {
	Properties {
		_BaseTex ("Base (RGB)", 2D) = "white" {}
	}
	
    SubShader {
        Pass {
            HLSLPROGRAM

            #pragma vertex VertTextured
            #pragma fragment FragTextured
            #include "UnityCG.cginc"

           	sampler2D _BaseTex;
           
            void VertTextured(float4 positionOS:POSITION, float2 uv_in:TEXCOORD0,
                               out float2 uv_out:TEXCOORD0, out float4 sv:SV_POSITION) {
                float4 positionWS = mul(unity_ObjectToWorld, float4(positionOS.xyz, 1.0));
                sv = mul(unity_MatrixVP, positionWS);
                uv_out = uv_in;
            }

            float4 FragTextured(float2 uv:TEXCOORD0) : COLOR {
             	return(tex2D(_BaseTex, uv));
            }

            ENDHLSL
        }
    }
}