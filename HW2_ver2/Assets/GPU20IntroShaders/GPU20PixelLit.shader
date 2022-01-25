// Aaron Lanterman, June 30, 2020
// Cobbled together from numerous sources (including Catlike Coding & Unity docs)
Shader "GPU20/TexturedPixelLit" {
	Properties {
		_BaseTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
        _AttenFactor ("Atten Factor", float) = 1
	}

    SubShader {
        Tags { "LightMode" = "ForwardAdd" } // Use for point light
        // Tags { "LightMode" = "ForwardBase" } // Use for directional light
    	 
        Pass {
        	HLSLPROGRAM

            #pragma vertex VertPixelLit
            #pragma fragment FragPixelLit
            #include "UnityCG.cginc"
            
           	sampler2D _BaseTex;	
           	float4 _BaseTex_ST;

            float _AttenFactor;

            float4 _LightColor0; // Unity fills for us
           	
           	struct a2v {    			
           		float4 positionOS: POSITION;
           		float3 normalOS: NORMAL;
           		float2 uv: TEXCOORD0;	
           	};
           	
			struct v2f {				
           		float4 sv: SV_POSITION;
           		float2 uv: TEXCOORD0;   
           		float3 positionWS: TEXCOORD1;     
           		float3 normalWS: TEXCOORD2;  
           	};
 
            v2f VertPixelLit(a2v input) {
                v2f output;           

                float4 positionWS = mul(unity_ObjectToWorld, float4(input.positionOS.xyz, 1.0));
                output.sv = mul(unity_MatrixVP, positionWS);
				output.positionWS = positionWS.xyz;
               
                // To transform normals, we want to use the inverse transpose of upper left 3x3
                // Putting input.n in first argument is like doing trans((float3x3)_World2Object) * input.n;
                output.normalWS = normalize(mul(input.normalOS, (float3x3) unity_WorldToObject));
				output.uv = TRANSFORM_TEX(input.uv, _BaseTex);
                return output;
            }

     		float4 FragPixelLit(v2f input) : COLOR {
     			// Unity light position convention is:
                // w = 0, directional light, with x y z pointing in opposite of light direction 
                // w = 1, point light, with x y z indicating position coordinates
                float3 unNormLightDir = _WorldSpaceLightPos0.xyz - input.positionWS * _WorldSpaceLightPos0.w;
                float3 lightDir = normalize(unNormLightDir);
   				// renormalizing because the GPU's interpolator doesn't know this is a unit vector
   				float3 n = normalize(input.normalWS);
   				
   				float lengthSq = dot(unNormLightDir,unNormLightDir);

   				float atten = 1.0 / (1.0 + lengthSq * _AttenFactor * _WorldSpaceLightPos0.w);
   				
				
				float3 diffAlmost = _LightColor0.rgb * max(0, dot(n, lightDir)) * atten;
				float3 output = lerp(float3(1.0, 1.0, 0.0), float3(0.0, 0.0, 1.0), ((1.0 + dot(n, lightDir)) / 2.0));
     			return(float4(output,1)); 
            }

            ENDHLSL
        }
    }
}
