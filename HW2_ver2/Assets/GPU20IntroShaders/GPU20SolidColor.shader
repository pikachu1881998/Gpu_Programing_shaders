// Aaron Lanterman, June 30, 2020
// Cobbled together from numerous sources (including Catlike Coding & Unity docs)
Shader "GPU20/SolidColor" {
    SubShader {
        Pass {
            HLSLPROGRAM

            #pragma vertex VertSolidColor
            #pragma fragment FragSolidColor
            #include "UnityCG.cginc"

            float4 VertSolidColor(float4 positionOS:POSITION) : SV_POSITION {
                // float4 positionWS = mul(unity_ObjectToWorld, positionOS);
                float4 positionWS = mul(unity_ObjectToWorld, float4(positionOS.xyz, 1.0));
                return mul(unity_MatrixVP, positionWS);
            }

            float4 FragSolidColor() : COLOR {
                return float4(0.0,1.0,0.0,1.0);
            }

            ENDHLSL
        }
    }
}
