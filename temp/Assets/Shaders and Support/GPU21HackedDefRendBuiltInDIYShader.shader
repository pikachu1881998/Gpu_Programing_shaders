// Aaron Lanterman, July 23, 2021
// Cobbled together from numerous sources
Shader "Hidden/GPU21HackedDefRendBuiltInDIYShader" {
	Properties {
		// We shouldn't need these to be Properties since they're
		// set by a script, but if I don't the colors wind up
		// wrong, and I have no idea why
		_DiffColor ("Diff Color", Color) = (1,1,1,1)
		_SpecColor ("Spec Color", Color) = (1,1,1,1)
	}
		
    SubShader {
    
    Tags { "RenderType"="Opaque" }
	LOD 300
	
        Pass {
        	CGPROGRAM
			#include "UnityCG.cginc"
			
			#pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment frag
           
           	uniform float4 _CameraData;
           	
           	float4 _DiffColor, _SpecColor;
           	float _Shininess;
           	
           	float4 _lightPosVS0, _lightPosVS1,
           				   _lightPosVS2, _lightPosVS3,
           				   _lightPosVS4, _lightPosVS5;
           				   
           	sampler2D _CameraDepthNormalsTexture;
        
     		float4 frag(v2f_img i) : COLOR {
     		    float3 normalVS;
     		    

				float4 enc = tex2D(_CameraDepthNormalsTexture, i.uv);

				float depth;
				float3 n;
    			DecodeDepthNormal(enc, /* out */  depth, /* out */ normalVS);
	
				normalVS.z = -normalVS.z;
				
				normalVS = normalize(normalVS);
					
     		 	float zRecon = DECODE_EYEDEPTH(depth);				   	
				float2 xy_minus1to1 = (2 * i.uv ) - 1;
				float2 xyRecon = xy_minus1to1 * zRecon * _CameraData.xy;
				float3 posVS = float3(xyRecon,zRecon);
				
				// eye is at origin
				float3 eyeDir = normalize(-posVS);
				
				// I hardcoded the light colors, which is a bad idea
				float3 lightDir = normalize(_lightPosVS0.xyz - posVS);
				float3 halfDir = normalize(lightDir + eyeDir);
				float diff = max(0,dot(normalVS, lightDir));
				float spec = max(0,pow(dot(normalVS, halfDir),_Shininess*128.0));
				float4 col = float4(0.25,0,0.25,1) * (_SpecColor * spec + _DiffColor * diff);
				
				lightDir = normalize(_lightPosVS1.xyz - posVS);
				halfDir = normalize(lightDir + eyeDir);
				diff = max(0,dot(normalVS, lightDir));
				spec = max(0,pow(dot(normalVS, halfDir),_Shininess*128.0));
				col += float4(0.25,0,0,1) * (_SpecColor * spec + _DiffColor * diff);
				
				lightDir = normalize(_lightPosVS2.xyz - posVS);
				halfDir = normalize(lightDir + eyeDir);
				diff = max(0,dot(normalVS, lightDir));
				spec = max(0,pow(dot(normalVS, halfDir),_Shininess*128.0));
				col += float4(0,0.25,0,1) * (_SpecColor * spec + _DiffColor * diff);
				
				lightDir = normalize(_lightPosVS3.xyz - posVS);
				halfDir = normalize(lightDir + eyeDir);
				diff = max(0,dot(normalVS, lightDir));
				spec = max(0,pow(dot(normalVS, halfDir),_Shininess*128.0));
				col += float4(0,0,0.25,1) * (_SpecColor * spec + _DiffColor * diff);
					
				lightDir = normalize(_lightPosVS4.xyz - posVS);
				halfDir = normalize(lightDir + eyeDir);
				diff = max(0,dot(normalVS, lightDir));
				spec = max(0,pow(dot(normalVS, halfDir),_Shininess*128.0));
				col += float4(0.25,0.25,0,1) * (_SpecColor * spec + _DiffColor * diff);
							
				lightDir = normalize(_lightPosVS5.xyz - posVS);
				halfDir = normalize(lightDir + eyeDir);
				diff = max(0,dot(normalVS, lightDir));
				spec = max(0,pow(dot(normalVS, halfDir),_Shininess*128.0));
				col += float4(0.25,0.125,0,1) * (_SpecColor * spec + _DiffColor * diff);
													
				return(float4(col.rgb,1));
            }

            ENDCG
        }
    }
}