// Aaron Lanterman, July 22, 2021
// Modified example from https://github.com/Unity-Technologies/PostProcessing/wiki/Writing-Custom-Effects
// modified by Kushal Desai for further research 

using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

// Warning from https://github.com/Unity-Technologies/PostProcessing/wiki/Writing-Custom-Effects 
// Because of how serialization works in Unity, you have to make sure that the file is named 
// after your settings class name or it won't be serialized properly.

// This is the settings class
[Serializable]
[PostProcess(typeof(FogAndScanRenderer), PostProcessEvent.AfterStack, "Custom/FogAndScanStack")]
public sealed class FogAndScanStack : PostProcessEffectSettings {
    [Tooltip("Speed of crossfade effect.")]
    public FloatParameter speed = new FloatParameter { value = 1f };
    [Range(0f,5f), Tooltip("Speed of crossfade effect.")]
    public FloatParameter thickness = new FloatParameter { value = 1f };
    [Range(0f,1f) , Tooltip("Speed of crossfade effect.")]
    public FloatParameter colorR = new FloatParameter { value = 0f };
    [Range(0f, 1f), Tooltip("Speed of crossfade effect.")]
    public FloatParameter colorG = new FloatParameter { value = 0f };
    [Range(0f, 1f), Tooltip("Speed of crossfade effect.")]
    public FloatParameter colorB = new FloatParameter { value = 0f };
//    [Range(0f,1f), Tooltip("Speed of crossfade effect.")]
//    public FloatParameter mistornot = new FloatParameter { value = 1f };

    public Bool​Parameter ActiveFog = new Bool​Parameter { };
    

}



public sealed class FogAndScanRenderer : PostProcessEffectRenderer<FogAndScanStack> {
    public override DepthTextureMode GetCameraFlags() {
        return DepthTextureMode.DepthNormals;
    }


    public override void Render(PostProcessRenderContext context) {
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/FogAndScanStack"));
        sheet.properties.SetFloat("_Speed", settings.speed);
        sheet.properties.SetFloat("_Thickness", settings.thickness);
        sheet.properties.SetFloat("_ColorR", settings.colorR);
        sheet.properties.SetFloat("_ColorG", settings.colorG);
        sheet.properties.SetFloat("_ColorB", settings.colorB);
        //        sheet.properties.SetFloat("mistornot",settings.mistornot);
        if (settings.ActiveFog)
        {
            sheet.properties.SetFloat("mistornot", 1f );
        }
        else
        {
            sheet.properties.SetFloat("mistornot", 0f);
        }
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
