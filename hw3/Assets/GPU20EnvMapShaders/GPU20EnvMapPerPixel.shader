// Aaron Lanterman, original June 21, 2014
// Last updated July 16, 2020
// Cobbled together from numerous sources, particularly The Cg Turtorial

Shader "GPU20/EnvMapPerPixel" {
	Properties {
	    _BaseTex ("Base (RGB) diffuse", 2D) = "white" {}
		_BaseTex2 ("Base (RGB) Gloss (A)", 2D) = "white" {}
		_Cube ("Reflection Cubemap", CUBE) = "white" {}

	}
		
    SubShader {
        Pass {
        	HLSLPROGRAM

            #pragma vertex VertEnvMapperPixel
            #pragma fragment FragEnvMapperPixel
		    #include "UnityCG.cginc"

           	samplerCUBE _Cube;

           	sampler2D _BaseTex;
           	float4 _BaseTex_ST;

			sampler2D _BaseTex2;
			float4 _BaseTex2_ST;
           	           	
           	struct a2v {    			// application to vertex
           		float4 positionOS: POSITION;
           		float3 normalOS: NORMAL;
				float2 uv: TEXCOORD0;
           	};
           	
			struct v2f {				// vertex to fragment
           		float4 sv: SV_POSITION; 
				float2 uv:TEXCOORD0;
				float2 uv2:TEXCOORD1;
           		float3 positionWS: TEXCOORD2; 
				float3 normalWS: TEXCOORD3;

           	};

            v2f VertEnvMapperPixel(a2v input) {
                v2f output;
				float4 positionWS = mul(unity_ObjectToWorld, float4(input.positionOS.xyz, 1.0));
				output.sv = mul(unity_MatrixVP, positionWS); 
				output.positionWS = positionWS.xyz;
			   
			    // To transform normals, we want to use the inverse transpose of upper left 3x3
                // Putting input.n in first argument is like doing trans((float3x3)_World2Object) * input.n;
                output.normalWS = normalize(mul(input.normalOS, (float3x3) unity_WorldToObject));
				output.uv = TRANSFORM_TEX(input.uv, _BaseTex);
				output.uv2 = TRANSFORM_TEX(input.uv, _BaseTex2);
                return output;
            }

     		float4 FragEnvMapperPixel(v2f input) : COLOR {
     		    // incident is opposite the direction of eyeDir in our other programs
     		    float3 incidentWS = normalize(input.positionWS - _WorldSpaceCameraPos.xyz);
     		    float3 reflectWS = reflect(incidentWS, input.normalWS);

                float4 reflectColor = texCUBE(_Cube, reflectWS);
     		    float4 base = tex2D(_BaseTex, input.uv);
				float4 base2 = tex2D(_BaseTex2, input.uv);
                return(lerp(base, reflectColor, base2.a));
//                return base2;`
            }

            ENDHLSL
        }
    }
}
