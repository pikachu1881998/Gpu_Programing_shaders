// Aaron Lanterman, June 19, 2014; updated June 15, 2019

using UnityEngine;
using System.Collections;

[ExecuteInEditMode]

public class SetupTextureProjection : MonoBehaviour {
	
	private Matrix4x4 projectorMatrix;
	private Matrix4x4 offsetMatrix;
	private Camera myCamera;

	void Start() {
		Vector3 halfs = 0.5f * Vector3.one;
		offsetMatrix = Matrix4x4.TRS(halfs, Quaternion.identity, halfs);
		myCamera = GetComponent<Camera> ();
	}
	
	void Update() {
		projectorMatrix =  offsetMatrix * myCamera.projectionMatrix * myCamera.worldToCameraMatrix;
		// Quick & dirty; it would generally be better to set properties in specific materials
		Shader.SetGlobalMatrix("_myProjectorMatrixVP", projectorMatrix);   
		// Debug.Log (projectorMatrix); 
		Shader.SetGlobalVector("_spotlightDir", transform.forward);
	}
}
