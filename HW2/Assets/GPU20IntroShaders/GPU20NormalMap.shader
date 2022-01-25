// Aaron Lanterman, June 30, 2020
// Cobbled together from numerous sources (including Catlike Coding & Unity docs)
Shader "GPU20/TexturedNormalMap" {
	Properties {
		_BaseTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
		_NormalMap ("Normalmap", 2D) = "bump" {}
        _AttenFactor ("Atten Factor", float) = 1
	}
		
    SubShader {
        Tags { "LightMode" = "ForwardAdd" } // Use for point light
        // Tags { "LightMode" = "ForwardBase" } // Use for directional light
    	 
        Pass {
        	HLSLPROGRAM

            #pragma vertex VertNormalMap
            #pragma fragment FragNormalMap
	        #include "UnityCG.cginc"

            sampler2D _BaseTex;	
           	float4 _BaseTex_ST;
           	sampler2D _NormalMap;
           	float4 _NormalMap_ST;

            float _AttenFactor; 

            float4 _LightColor0; // Unity fills for us

           	struct a2v {    			
           		float4 positionOS: POSITION;
           		float3 normalOS: NORMAL;
           		float4 tangentOS: TANGENT;
           		float2 uv: TEXCOORD0;	
           	};
           	
			struct v2f {				
           		float4 sv: SV_POSITION;
           		float2 bmap_uv:TEXCOORD0;   
           		float2 nmap_uv: TEXCOORD1;   
           		float3 positionWS: TEXCOORD2;     
           		float3 normalWS: TEXCOORD3;  
           		float3 tangentWS: TEXCOORD4;  
           		float3 bitangentWS: TEXCOORD5; 
           	};
 
            v2f VertNormalMap(a2v input) {
                v2f output;           
                float4 positionWS = mul(unity_ObjectToWorld, float4(input.positionOS.xyz, 1.0));
                output.sv = mul(unity_MatrixVP, positionWS);
				output.positionWS = positionWS.xyz;

                // To transform normals, we want to use the inverse transpose of upper left 3x3
                // Putting input.n in first argument is like doing trans((float3x3)_World2Object) * input.n;
                output.normalWS = normalize(mul(input.normalOS, (float3x3) unity_WorldToObject));

				// Transforming tangents is not as weird as transforming normals
			    output.tangentWS = normalize(mul((float3x3) unity_ObjectToWorld, input.tangentOS.xyz));
				output.bitangentWS = normalize(cross(output.normalWS, output.tangentWS)
             				         * input.tangentOS.w); // Flip tangents if needed (memory saving trick)
               
                output.bmap_uv = TRANSFORM_TEX(input.uv, _BaseTex);
                output.nmap_uv = TRANSFORM_TEX(input.uv, _NormalMap);
                return output;
            }

     		float4 FragNormalMap(v2f input) : COLOR {
				// need to map [0,1] "colors" to [-1,1]
				// also, Unity uses a weird strategy of packing X and Y in alpha and green
				// because of precision issues with some texture compression formats
				float2 nMapXY = 2 * tex2D(_NormalMap, input.nmap_uv).ag - 1;
				float nMapRecreatedZ = sqrt(1 - saturate(dot(nMapXY,nMapXY)));

				// we are renormalizing because the GPU's interpolator doesn't know these are unit vectors
				float3 nWS = normalize(input.normalWS); 
				float3 tWS = normalize(input.tangentWS);
				float3 btWS = normalize(input.bitangentWS);
				
				float3 newNormal = tWS * nMapXY.x + btWS * nMapXY.y + nWS * nMapRecreatedZ;
				newNormal = normalize(newNormal);
				
				// Unity light position convention is:
                // w = 0, directional light, with x y z pointing in opposite of light direction 
                // w = 1, point light, with x y z indicating position coordinates
                float3 unNormLightDir = _WorldSpaceLightPos0.xyz - input.positionWS * _WorldSpaceLightPos0.w;
                float3 lightDir = normalize(unNormLightDir);
   				
   				float lengthSq = dot(unNormLightDir,unNormLightDir);

   				float atten = 1.0 / (1.0 + lengthSq * _AttenFactor * _WorldSpaceLightPos0.w);
   				
				float3 diffAlmost = _LightColor0.rgb * max(0, dot(newNormal, lightDir)) * atten;
            	
     			float4 base = tex2D(_BaseTex, input.bmap_uv);
     			float3 output = diffAlmost * base.rgb;
     			return(float4(output,1));    
            }

            ENDHLSL
        }
    }
}
