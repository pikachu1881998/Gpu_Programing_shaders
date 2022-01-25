// Aaron Lanterman, July 21, 2015
// Last tweaked July 25, 2016 
// Cobbled together from numerous sources
using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[AddComponentMenu("GPU21 Built-in DIYEffects/GPU21OutlinerBuiltInDIY")]
[RequireComponent (typeof(Camera))]

public class GPU21OutlinerBuiltInDIY : MonoBehaviour {
	public Shader postprocShader;
	public Material postprocMat;
	public float speed = 1.0f;
	
	void Start() {
		postprocShader = Shader.Find("Hidden/GPU21OutlinerBuiltInDIYShader");
		postprocMat = new Material(postprocShader);
	}

	void Update() {
		// probably not very efficient; should probably only update in when speed changes
		postprocMat.SetFloat("_Speed",speed);
	} 

	void OnRenderImage (RenderTexture source, RenderTexture destination) {
	   Graphics.Blit(source, destination, postprocMat);
	}
}
