// Aaron Lanterman, July 22, 2021
// Modified example from https://github.com/Unity-Technologies/PostProcessing/wiki/Writing-Custom-Effects
// further modified to look like scan and fog effect by Kushal Desai.

Shader "Hidden/Custom/FogAndScanStack"
{

    HLSLINCLUDE

        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
		TEXTURE2D_SAMPLER2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture);
        TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);

        float _Speed;
        float _Distance;
        float _Thickness;
        float _ColorR;
        float _ColorG;
        float _ColorB;
        float mistornot;
        float4 Frag(VaryingsDefault i) : SV_Target
        {
            float4 original = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
			float4 dn_enc = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture, i.texcoord);
            float4 d_enc = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, i.texcoord);
            float depth = Linear01Depth(d_enc);
            float3 normal = DecodeViewNormalStereo(dn_enc);
            float4 _ScanMistColor = {_ColorR, _ColorG, _ColorB, 1.0};
            float Front;
            float FOGorMIST;

            [branch] if (mistornot == 1)
            {
                _Distance = dot(original ,float4(normal,1));
                Front = smoothstep(depth, _Distance,_Distance);
                _Thickness = smoothstep(_Distance - _Thickness, _Distance, depth);
                FOGorMIST = Front * _Thickness ;
                return(lerp(original, _ScanMistColor, FOGorMIST));
            }
            else
            {
                // this is to create a scanner like effect
                _Distance = _Distance + _Speed * ((cos(_Speed * _Time.y) + 1)) * dot(original ,float4(normal,1));
                Front = step(depth, _Distance);

                _Thickness = smoothstep(_Distance - _Thickness, _Distance, depth);
                FOGorMIST = Front * _Thickness ;
                // credits to professor Aaron Lanterman for this part
                float4 original_left = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord - float2(1.0 / _ScreenParams.x,0));
                float4 original_right = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + float2(1.0 / _ScreenParams.x,0));
                float4 original_up = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord - float2(0,1.0 / _ScreenParams.y));
                float4 original_down = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + float2(0,1.0 / _ScreenParams.y));
                float3 horiz_diff = original_left.rgb - original_right.rgb;
                float3 vert_diff = original_up.rgb - original_down.rgb;
                float3 outline = abs(horiz_diff) + abs(vert_diff);

                return(lerp(lerp(float4(outline,1)*original, float4(normal,1)*original ,FOGorMIST), _ScanMistColor, FOGorMIST));
            }
        }
    ENDHLSL

    SubShader {
        Cull Off ZWrite Off ZTest Always

        Pass {
            HLSLPROGRAM

                #pragma vertex VertDefault
                #pragma fragment Frag

            ENDHLSL
        }
    }
}
