// Aaron Lanterman, June 30, 2020
// Cobbled together from numerous sources (including Catlike Coding & Unity docs)
Shader "GPU20/VertexColor" {
    SubShader {
        Pass {
            HLSLPROGRAM

            #pragma vertex VertGeomColor
            #pragma fragment FragGeomColor
            #include "UnityCG.cginc"

            void VertGeomColor(float4 positionOS:POSITION, 
                               out float4 c:COLOR0, out float4 sv:SV_POSITION) {
                float4 positionWS = mul(unity_ObjectToWorld, float4(positionOS.xyz, 1.0));
                sv = mul(unity_MatrixVP, positionWS);
                c = float4(positionOS.xyz, 1);
            }

            float4 FragGeomColor(float4 c:COLOR0) : COLOR {
                return float4(c); 
            }

            ENDHLSL
        }
    }
}
