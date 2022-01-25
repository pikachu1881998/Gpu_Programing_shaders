// Aaron Lanterman, July 20, 2020
// Cobbled together from numerous sources (including Catlike Coding & Unity docs)
Shader "GPU19/PBRTemplate" {
	Properties {

        _Rough1 ("Roughness for Yellow ", Range (0, 1)) = 0.5
        _rough2("Roughness for Blue", Range (0, 1)) = 0.5
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
            float _rough2;

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
                float NdotM = dot(n,halfVector);
                float pi = 3.14159;

                // roughness calculation
                float alpha1 = _Rough1 * _Rough1;
                float alphaSquare1 = alpha1 * alpha1;
                // beckman normal ditribution
                float exponenet = ((pow(dot(n,halfVector),2) -1)/(pow(alpha1,2)*(pow(dot(n,halfVector),2))));
                float beckMan = (1/((pi*alphaSquare1)*(pow(dot(n,halfVector),4))));
                float Beckmann3 = beckMan*exp(exponenet);

                // rough ness 2
                float alpha2 = _rough2 * _rough2;
                float alphaSquare2 = alpha2 * alpha2;
                // Blinn-Phong distributation

                float blingEXP =(2/alphaSquare2) -2 ;
                float blingDinominator = 1/(pi*alphaSquare2);
                float BlinnPhong = blingDinominator*pow(dot(n,halfVector),blingEXP);
                //
                float GGXDenominator = pi*pow((pow(NdotM,2)*(alphaSquare2-1) + 1),2);
                float ggx = alphaSquare2 / GGXDenominator;
                float3 output = float3(Beckmann3,Beckmann3,BlinnPhong) ; // A placeholder, replace with your own code
                return(float4(output,1));
            }

            ENDHLSL
        }
    }
}