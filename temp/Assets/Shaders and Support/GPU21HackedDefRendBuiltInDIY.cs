// Aaron Lanterman, July 23, 2021
// Cobbled together from numerous sources
using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[AddComponentMenu("GPU21 Built-in DIYEffects/GPU21HackedDefRendBuiltInDIY")]
[RequireComponent (typeof(Camera))]

public class GPU21HackedDefRendBuiltInDIY : MonoBehaviour {
	public Material postMat; 
	public Shader postShader; 
	private Camera myCamera;

	private Vector4[] myLightPosVS;
	Vector4 cameraData;
	
	void Start() {
		myCamera = GetComponent<Camera>();
		myCamera.depthTextureMode = DepthTextureMode.DepthNormals;
        postShader = Shader.Find("Hidden/GPU21HackedDefRendBuiltInDIYShader");
		Debug.Log(postShader);
		postMat = new Material(postShader);
		myLightPosVS = new Vector4[6];
	}

	void OnPreRender() {
		cameraData.y = Mathf.Tan(Mathf.Deg2Rad * myCamera.fieldOfView / 2);   
		cameraData.x = cameraData.y * myCamera.aspect;
		cameraData.z = myCamera.farClipPlane - myCamera.nearClipPlane;
		cameraData.w = myCamera.nearClipPlane;
		postMat.SetVector ("_CameraData", cameraData);
		postMat.SetColor("_DiffColor",0.2f * Vector4.one);
		postMat.SetColor("_SpecColor",Vector4.one);
		postMat.SetFloat("_Shininess",0.9f);
	}

	void Update() {
		// an assortment of wandering lights
		// don't look for any logic here, you will find none...
		myLightPosVS[0].z = 20 * Mathf.Sin (0.5f*Time.time);
		myLightPosVS[1].y = 2 + 20 * Mathf.Cos (0.6f*Time.time + 0.5f);
		myLightPosVS[1].z = -2;
		myLightPosVS[2].x = -3 + 20 * Mathf.Sin (0.7f*Time.time);
		myLightPosVS[2].y = -2 + 20 * Mathf.Cos (0.4f*Time.time - 1f);
		myLightPosVS[2].z = -2;
		myLightPosVS[3].x = 3 + 20 * Mathf.Cos (0.9f*Time.time + 0.25f);
		myLightPosVS[3].y = -1.5f + 20 * Mathf.Sin (0.3f*Time.time);
		myLightPosVS[3].z = -2;
		myLightPosVS[4].x = -3 + 20 * Mathf.Cos (0.8f*Time.time - 0.75f);
		myLightPosVS[4].y = 4 + myLightPosVS[4].x;
		myLightPosVS[4].z = -2;
		myLightPosVS[5].x = 3 + 20 * Mathf.Sin (Time.time + 5f);
		myLightPosVS[5].y = -3 + myLightPosVS[5].x;
		myLightPosVS[5].z = -2;
	}

	void OnRenderImage (RenderTexture source, RenderTexture destination) {
		postMat.SetVector("_lightPosVS0",myLightPosVS[0]);
		postMat.SetVector("_lightPosVS1",myLightPosVS[1]);
		postMat.SetVector("_lightPosVS2",myLightPosVS[2]);
		postMat.SetVector("_lightPosVS3",myLightPosVS[3]);
		postMat.SetVector("_lightPosVS4",myLightPosVS[4]);
		postMat.SetVector("_lightPosVS5",myLightPosVS[5]);

		postMat.SetVector("_CameraData",cameraData);

	    Graphics.Blit(source, destination, postMat);
	}
}
