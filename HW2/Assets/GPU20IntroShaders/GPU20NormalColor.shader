// Aaron Lanterman, June 30, 2020
// Cobbled together from numerous sources (including Catlike Coding & Unity docs)
Shader "GPU20/NormalColor" {
    SubShader {
        Pass {
            HLSLPROGRAM

            #pragma vertex VertNormalColor
            #pragma fragment FragNormalColor
            #include "UnityCG.cginc"

            void VertNormalColor(float4 positionOS:POSITION, float3 normalOS:NORMAL,
                                 out float4 c:COLOR0, out float4 sv:SV_POSITION) {;
                float4 positionWS = mul(unity_ObjectToWorld, float4(positionOS.xyz, 1.0));
                sv = mul(unity_MatrixVP, positionWS);
                c = float4((normalOS.xyz + 1) / 2, 1);
            }

            float4 FragNormalColor(float4 c:COLOR0) : COLOR {
                return float4(c); 
            }

            ENDHLSL
        }
    }
}
