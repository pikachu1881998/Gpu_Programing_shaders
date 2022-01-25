// Aaron Lanterman, June 19, 2014; updated June 15, 2019

using UnityEngine;
using System.Collections;

public class RotateWeirdly : MonoBehaviour {

	// Use this for initialization
	void Start() {
	}
	
	// Update is called once per frame
	void Update() {
		transform.Rotate(0.5f*Mathf.Sin(Time.time), 0, 0);
	}
}
