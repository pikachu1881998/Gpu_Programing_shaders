// Aaron Lanterman, July 23, 2021
// Cobbled together from numerous sources
using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[AddComponentMenu("GPU21 Built-in DIYEffects/GPU21DepthNormalBuiltInDIY")]
[RequireComponent (typeof(Camera))]

public class GPU21DepthNormalBuiltInDIY : MonoBehaviour {
	public Shader postprocShader;
	public Material postprocMat;
	private Camera myCamera;
	public float speed = 1.0f;
	
	void Start() {
		postprocShader = Shader.Find("Hidden/GPU21DepthNormalBuiltInDIYShader");
		postprocMat = new Material(postprocShader);
		myCamera = GetComponent<Camera>();
		myCamera.depthTextureMode = DepthTextureMode.DepthNormals;
	}

	void Update() {
		// probably not very efficient; should probably only update in when speed changes
		postprocMat.SetFloat("_Speed",speed);
	} 

	void OnRenderImage (RenderTexture source, RenderTexture destination) {
	   Graphics.Blit(source, destination, postprocMat);
	}
}
