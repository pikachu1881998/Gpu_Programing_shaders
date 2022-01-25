// Aaron Lanterman, July 20, 2020
// Cobbled together from numerous sources (including Catlike Coding & Unity docs)
Shader "GPU19/HW4_part3" {
	Properties {
        _Rough1 ("Roughness for Yellow ", Range (0, 1)) = 0.5
	}

    SubShader {
        Tags { "LightMode" = "ForwardAdd" } // Use for point light
        // Tags { "LightMode" = "ForwardBase" } // Use for directional light
    	 
        Pass {
            HLSLPROGRAM

            #pragma vertex VertPBRTemplate
            #pragma fragment FragPBRTemplate
            #include "UnityCG.cginc"

            sampler2D _BaseTex;	
            float4 _BaseTex_ST;

            float4 _LightColor0; // Unity fills for us
            float _Rough1;


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
 
            v2f VertPBRTemplate(a2v input) {
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

            float4 FragPBRTemplate(v2f input) : COLOR {
                // Unity light position convention is:
                // w = 0, directional light, with x y z pointing in opposite of light direction 
                // w = 1, point light, with x y z indicating position coordinates
                float3 unNormLightDir = _WorldSpaceLightPos0.xyz - input.positionWS * _WorldSpaceLightPos0.w;
                float3 lightDir = normalize(unNormLightDir);

                // renormalizing because the GPU's interpolator doesn't know this is a unit vector
                float3 n = normalize(input.normalWS);

                float3 viewDir = normalize(_WorldSpaceCameraPos - input.positionWS);   
                float3 halfVector = normalize(viewDir + lightDir);

                float pi = 3.14159;

                // roughness calculation
                float alpha1 = _Rough1 * _Rough1;

                // Cook-torrance
                float cook = (2 * (dot(n,halfVector)) * (dot(n,viewDir))) / (dot(viewDir,halfVector));
                float torrance = (2 * (dot(n,halfVector)) * (dot(n,lightDir))) / (dot(viewDir,halfVector));
                float CookTorrance =min(1, min(cook, torrance))/ (4*dot(n,lightDir)*dot(n,viewDir));

//                float cV = ((dot(n,viewDir) * rsqrt(1-pow(dot(n,viewDir),2)))/(alpha1));
//                float cL =((dot(n,lightDir) * rsqrt(1-pow(dot(n,lightDir),2)))/(alpha1));
//                float beckmannV;
//                float beckmannL;
//                if (cV < 1.6)
//                {
//                beckmannV = ((3.535 * cV) + (2.181 * pow(cV,2))) / (1 + (2.276 * cV) + (2.577 *pow(cV,2)));
//                }
//                else
//                {
//                beckmannV = 1;
//                }
//
//                if (cL < 1.6)
//                {
//                beckmannL = ((3.535 * cL) + (2.181 * pow(cL,2))) / (1 + (2.276 * cL) + (2.577 * pow(cL,2)));
//                }
//                else
//                {
//                beckmannL = 1;
//                }
//                float beckmann = beckmannL*beckmannV / (4*dot(n,lightDir)*dot(n,viewDir));
//
                // GGX
                float ggxV = (2*dot(n,viewDir))/(dot(n,viewDir)+ sqrt(pow(alpha1,2)+(1-pow(alpha1,2))*pow(dot(n,viewDir),2)));
                float ggxL = (2*dot(n,lightDir))/(dot(n,lightDir)+ sqrt(pow(alpha1,2)+(1-pow(alpha1,2))*pow(dot(n,lightDir),2)));
                float ggx = ggxV*ggxL/(4*dot(n,lightDir)*dot(n,viewDir));
                float3 output = float3(CookTorrance,CookTorrance,ggx)  ; // A placeholder, replace with your own code
                return(float4(output,1));
            }

            ENDHLSL
        }
    }
}