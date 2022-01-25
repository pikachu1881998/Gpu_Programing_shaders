// Aaron Lanterman, June 30, 2020
// Cobbled together from numerous sources (including Catlike Coding & Unity docs)
Shader "GPU20/TexturedTileCorrectly" {
	Properties {
		_BaseTex ("Base (RGB)", 2D) = "white" {}
	}
		
    SubShader {
        Pass {
        	HLSLPROGRAM

            #pragma vertex VertTexturedStruct
            #pragma fragment FragTexturedStruct
            #include "UnityCG.cginc"
            
           	sampler2D _BaseTex;
           	float4 _BaseTex_ST;     // Unity provides this 

           	struct a2v {    			// application to vertex
           		float4 positionOS: POSITION;
           		float2 uv: TEXCOORD0;	// not same as TEXCOORD0 below
           	};
           	
			struct v2f {				// vertex to fragment
           		float4 sv: SV_POSITION;
           		float2 uv: TEXCOORD0;   // not same as TEXCOORD0 above
           	};
 
            v2f VertTexturedStruct(a2v input) {
                v2f output;  
                float4 positionWS = mul(unity_ObjectToWorld, float4(input.positionOS.xyz, 1.0));
                output.sv = mul(unity_MatrixVP, positionWS);
				// Make sure you TRANSFORM_TEX in the vertex shader, not the fragment shader!
                output.uv = TRANSFORM_TEX(input.uv, _BaseTex);
                return output;
            }

     		float4 FragTexturedStruct(v2f input) : COLOR {
                  return(tex2D(_BaseTex, input.uv));
            }

            ENDHLSL
        }
    }
}
