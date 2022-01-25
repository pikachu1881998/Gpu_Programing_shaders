// Aaron Lanterman, June 16, 2019
// Last updated July 16, 2020
// Cobbled together from numerous sources, particularly "The Cg Tutorial"

Shader "GPU20/ProjectTexture" {
	Properties {
		_BaseTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
		_ProjTex ("Projected (RGB)", 2D) = "white" {}
	    _SpotPower ("Spotlightiness", Range(0.01,1)) = 0.7
	}
		
    SubShader {
        // Only use this shader with a point light  
        Tags { "LightMode" = "ForwardAdd" }
    	 
        Pass {
        	HLSLPROGRAM
			
            #pragma vertex VertProjectTexture
            #pragma fragment FragProjectTexture

	        #include "UnityCG.cginc"
			
           	sampler2D _BaseTex;	
           	float4 _BaseTex_ST;
           	sampler2D _ProjTex;
            
           	float _SpotPower;

           	float4x4 _myProjectorMatrixVP;
           	float3 _spotlightDir;

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
           		float4 positionProjected: TEXCOORD3;
           	};
 
            v2f VertProjectTexture(a2v input)  {
                v2f output;
                float4 positionWS = mul(unity_ObjectToWorld, float4(input.positionOS.xyz, 1.0));
                output.sv = mul(unity_MatrixVP, positionWS);
				output.positionWS = positionWS.xyz;

                // To transform normals, we want to use the inverse transpose of upper left 3x3
                // Putting input.n in first argument is like doing trans((float3x3)_World2Object) * input.n;
                output.normalWS = normalize(mul(input.normalOS, (float3x3) unity_WorldToObject));
                output.positionProjected = mul(_myProjectorMatrixVP, float4(positionWS.xyz,1.0));
                output.uv = TRANSFORM_TEX(input.uv, _BaseTex);
                return output;
            }

     		float4 FragProjectTexture(v2f input) : COLOR {
     			// Only use this shader with a point light
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz - input.positionWS * _WorldSpaceLightPos0.w);
   				// Renormalizing because the GPU's interpolator doesn't know this is a unit vector
   				float3 n = normalize(input.normalWS);
				float3 diffAlmost = _LightColor0.rgb * max(0, dot(n, lightDir));
				float spotlightEffect = pow(dot(normalize(_spotlightDir), -lightDir),_SpotPower * 128.0);
				diffAlmost *= spotlightEffect;
				diffAlmost *= tex2Dproj(_ProjTex,input.positionProjected);

     			float4 base = tex2D(_BaseTex, input.uv);
     			float3 output = diffAlmost * base.rgb;
     			return(float4(output,1));   
            }

            ENDHLSL
        }
    }
	Fallback "VertexLit"
}
