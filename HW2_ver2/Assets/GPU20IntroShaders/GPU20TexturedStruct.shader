// Aaron Lanterman, June 30, 2020
// Cobbled together from numerous sources (including Catlike Coding & Unity docs)
Shader "GPU20/TexturedStruct" {
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
			// uniform keyword optional
           	
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
                output.uv = input.uv;
                return output;
            }

     		float4 FragTexturedStruct(v2f input) : COLOR {
				float A = 1.0;
				float B = 1.0;
				float C = 1.0;
				float D = 5.0;
				float E = 5.0;
				float F = 5.0;
				input.uv.x += A * sin(B*input.uv.y)*sin(C*_Time.x);
				input.uv.y = D * sin(E*input.uv.x)*sin(F*_Time.x);
				return(tex2D(_BaseTex, input.uv));
            }

            ENDHLSL
        }
    }
}
