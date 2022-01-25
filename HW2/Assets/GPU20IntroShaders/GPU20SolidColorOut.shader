// Aaron Lanterman, June 30, 2020
// Cobbled together from numerous sources (including Catlike Coding & Unity docs)
Shader "GPU20/SolidColorOut" {
    SubShader {
        Pass {
            HLSLPROGRAM

            #pragma vertex VertSolidColorOut
            #pragma fragment FragSolidColorOut
            #include "UnityCG.cginc"
 
            void VertSolidColorOut(float4 positionOS:POSITION, out float4 sv:SV_POSITION) {
                // float4 worldPos = mul(unity_ObjectToWorld, positionOS);
                float4 positionWS = mul(unity_ObjectToWorld, float4(positionOS.xyz, 1.0));
                sv = mul(unity_MatrixVP, positionWS);
            }

            float4 FragSolidColorOut() : COLOR {
                return float4(1.0,0.0,0.0,1.0);
            }

            ENDHLSL
        }
    }
}
