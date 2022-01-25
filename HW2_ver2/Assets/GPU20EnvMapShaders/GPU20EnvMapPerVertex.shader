// Aaron Lanterman, original June 21, 2014
// Last updated July 16, 2020
// Cobbled together from numerous sources, particularly The Cg Tutorial

Shader "GPU20/EnvMapPerVertex" {
	Properties {
		_Cube ("Reflection Cubemap", CUBE) = "white" {}
		_etaRatio ("Eta Ratio", Range(0.01,3)) = 1.5
		_crossfade ("Crossfade", Range(0,1)) = 0
	}
		
    SubShader {
        Pass {
            HLSLPROGRAM
			 
            #pragma vertex VertEnvMapperVertex
            #pragma fragment FragEnvMapperVertex
            #include "UnityCG.cginc"
            
       	    samplerCUBE _Cube;		
       	    float _etaRatio;
       	    float _crossfade;
       	           	
       	    struct a2v {    		    // application to vertex
       		    float4 positionOS: POSITION;
       		    float3 normalOS: NORMAL;
       	    };
       	
			struct v2f {				// vertex to fragment
           		float4 sv: SV_POSITION;
           		float3 reflectWS: TEXCOORD0; 
           		float3 refractWS: TEXCOORD1; 
           };
 
            v2f VertEnvMapperVertex(a2v input) {
                v2f output;    
                float4 positionWS = mul(unity_ObjectToWorld, float4(input.positionOS.xyz, 1.0));
                output.sv = mul(unity_MatrixVP, positionWS);
                // To transform normals, we want to use the inverse transpose of upper left 3x3
                // Putting input.n in first argument is like doing trans((float3x3)_World2Object) * input.n;
                float3 normalWS = normalize(mul(input.normalOS, (float3x3) unity_WorldToObject));
                // incident is opposite the direction of eyeDir in our other programs
                float3 incidentWS = normalize(positionWS - _WorldSpaceCameraPos).xyz;
                output.reflectWS = reflect(incidentWS, normalWS);
                output.refractWS = refract(incidentWS, normalWS, _etaRatio);
                return output;
            }

     		float4 FragEnvMapperVertex(v2f input) : COLOR {
                float4 reflectColor = texCUBE(_Cube, input.reflectWS);
     		    float4 refractColor = texCUBE(_Cube, input.refractWS);
		 		return(lerp(reflectColor, refractColor, _crossfade));
            }

            ENDHLSL
        }
    }
}
