// Aaron Lanterman, June 14, 2014

using UnityEngine;
using System.Collections;

public class MatrixTests : MonoBehaviour {

	// Use this for initialization
	void Start () {
		Debug.ClearDeveloperConsole ();
		Matrix4x4 myTransMat = Matrix4x4.TRS (new Vector3 (2f, 3f, 4f),
			                                  Quaternion.identity,
			                                  new Vector3 (1f, 1f, 1f));
		Matrix4x4 myScaleMat = Matrix4x4.TRS(new Vector3(0f, 0f, 0f),
			                                 Quaternion.identity, 
			                                 new Vector3(5f, 6f, 7f));
		Matrix4x4 myRotMat = Matrix4x4.TRS(new Vector3(0f, 0f, 0f),
		                                   Quaternion.Euler (10,45,80),
		                                   new Vector3(1f, 1f, 1f));
		Matrix4x4 myScaleRotMat = Matrix4x4.TRS(new Vector3(0f, 0f, 0f),
		                                        Quaternion.Euler (10,45,80),
		                                        new Vector3(5f, 6f, 7f));
		Matrix4x4 myMatColStyle = myRotMat * myScaleMat;
		Matrix4x4 myMatRowStyle = myScaleMat * myRotMat;

		Debug.Log ("myTransMat"); Debug.Log (myTransMat);
		Debug.Log ("myScaleMat"); Debug.Log (myScaleMat); 
		Debug.Log ("myRotMat"); Debug.Log (myRotMat); 
		Debug.Log ("myScaleRotMat"); Debug.Log (myScaleRotMat);
		Debug.Log ("myMatColStyle"); Debug.Log (myMatColStyle);
		Debug.Log ("myMatRowStyle"); Debug.Log (myMatRowStyle);

		float fov = 30f;
		float ar = 2f;
		float n = 30f;
		float f = 110f;

		Matrix4x4 myPerspectiveMat = Matrix4x4.Perspective(fov, ar, n, f);

		Matrix4x4 m = new Matrix4x4 ();
		float cotfovdiv2 = 1f / Mathf.Tan(Mathf.Deg2Rad * fov / 2f);
		m[0,0] = cotfovdiv2 / ar;	m[0,1] = 0f;			m[0,2] = 0f;			m[0,3] = 0f;
		m[1,0] = 0f;				m[1,1] = cotfovdiv2;	m[1,2] = 0f;			m[1,3] = 0f;
		m[2,0] = 0f;				m[2,1] = 0f;			m[2, 2] = -(f+n)/(f-n);	m[2,3] = -2*f*n/(f-n);
		m[3,0] = 0f;				m[3,1] = 0f;  			m[3,2] = -1f;			m[3,3] = 0f;

		Debug.Log ("myPerspectiveMat"); Debug.Log (myPerspectiveMat);
		Debug.Log ("Guess of PerspectiveMat"); Debug.Log (m);

		float l = -20; float r = 30; float b = -50; float t = 70;
		Matrix4x4 myOrthoMat = Matrix4x4.Ortho(l, r, b, t, n, f);

		m[0,0] = 2/(r-l);			m[0,1] = 0f;			m[0,2] = 0f;			m[0,3] = -(r+l)/(r-l);
		m[1,0] = 0f;				m[1,1] = 2/(t-b);		m[1,2] = 0f;			m[1,3] = -(t+b)/(t-b);
		m[2,0] = 0f;				m[2,1] = 0f;			m[2, 2] = -2/(f-n);		m[2,3] = -(f+n)/(f-n);
		m[3,0] = 0f;				m[3,1] = 0f;  			m[3,2] = 0f;			m[3,3] = 1f;
		
		Debug.Log ("myOrthoMat"); Debug.Log (myOrthoMat);
		Debug.Log ("Guess of OrthoMat"); Debug.Log (m);
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
