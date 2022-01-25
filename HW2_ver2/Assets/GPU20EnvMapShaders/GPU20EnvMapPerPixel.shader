// Aaron Lanterman, original June 21, 2014
// Last updated July 16, 2020
// Cobbled together from numerous sources, particularly The Cg Turtorial

Shader "GPU20/EnvMapPerPixel" {
	Properties {
		_Cube ("Reflection Cubemap", CUBE) = "white" {}
		_etaRatio ("Eta Ratio", Range(0.01,3)) = 1.5
		_crossfade ("Crossfade", Range(0,1)) = 0
		_fresnelBias ("Fresnel Bias", Range(0,1)) = 0.5
		_fresnelScale ("Fresnel Scale", Range(0,1)) = 0.5
		_fresnelPower ("Fresnel Power", Range(0,10)) = 0.5
		[Toggle(BLUE_YELLOW)] _BlueYellow ("Blue Yellow", Float) = 0
        [KeywordEnum(Crossfade, Fresnel)] _Blend ("Blend Mode", Float) = 0
	}
		
    SubShader {
        Pass {
        	HLSLPROGRAM

            #pragma vertex VertEnvMapperPixel
            #pragma fragment FragEnvMapperPixel
            #pragma shader_feature BLUE_YELLOW
			#pragma multi_compile _BLEND_CROSSFADE _BLEND_FRESNEL
		    #include "UnityCG.cginc"

           	samplerCUBE _Cube;		
           	float _etaRatio;
           	float _crossfade;
           	float _fresnelBias;
           	float _fresnelScale;
           	float _fresnelPower;
           	           	
           	struct a2v {    			// application to vertex
           		float4 positionOS: POSITION;
           		float3 normalOS: NORMAL;	
           	};
           	
			struct v2f {				// vertex to fragment
           		float4 sv: SV_POSITION;   
           		float3 positionWS: TEXCOORD0; 
				float3 normalWS: TEXCOORD1;
           	};

            v2f VertEnvMapperPixel(a2v input) {
                v2f output;
				float4 positionWS = mul(unity_ObjectToWorld, float4(input.positionOS.xyz, 1.0));
				output.sv = mul(unity_MatrixVP, positionWS); 
				output.positionWS = positionWS.xyz;
			   
			    // To transform normals, we want to use the inverse transpose of upper left 3x3
                // Putting input.n in first argument is like doing trans((float3x3)_World2Object) * input.n;
                output.normalWS = normalize(mul(input.normalOS, (float3x3) unity_WorldToObject));
                return output;
            }

     		float4 FragEnvMapperPixel(v2f input) : COLOR {
     		    // incident is opposite the direction of eyeDir in our other programs
     		    float3 incidentWS = normalize(input.positionWS - _WorldSpaceCameraPos.xyz);
     		    float3 reflectWS = reflect(incidentWS, input.normalWS);
                float3 refractWS = refract(incidentWS, input.normalWS, _etaRatio);
                
                float4 reflectColor = texCUBE(_Cube, reflectWS);
     		    float4 refractColor = texCUBE(_Cube, refractWS);
                float reflectFactor = saturate(_fresnelBias +
                    _fresnelScale * pow(1 + dot(incidentWS, input.normalWS), _fresnelPower));
              
			    #ifdef BLUE_YELLOW  // for visualization
                	refractColor = float4(1,1,0,1); 
                	reflectColor = float4(0,0,1,1);
				#endif

				#if defined(_BLEND_CROSSFADE)
                	return(lerp(reflectColor, refractColor, _crossfade));
				#elif defined( _BLEND_FRESNEL)
					return(lerp(refractColor, reflectColor, reflectFactor));
				#endif
            }

            ENDHLSL
        }
    }
}
