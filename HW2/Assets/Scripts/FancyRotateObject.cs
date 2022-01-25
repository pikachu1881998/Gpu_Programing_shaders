using UnityEngine;
using System.Collections;

public class FancyRotateObject : MonoBehaviour {

	public float rotateSpeed;
	public bool rotateX;
	public bool rotateY;
	public bool rotateZ;

	private GUIStyle guiStyle;

	// Use this for initialization
	void Start () {
		rotateX = false;
		rotateY = false;
		rotateZ = false;
		rotateSpeed = 30f;
    }

	// Update is called once per frame
	void Update () {
		if (Input.GetKeyDown(KeyCode.Alpha0)) rotateSpeed = 0f;
		if (Input.GetKeyDown(KeyCode.Alpha1)) rotateSpeed = 10f;
		if (Input.GetKeyDown(KeyCode.Alpha2)) rotateSpeed = 20f;
		if (Input.GetKeyDown(KeyCode.Alpha3)) rotateSpeed = 30f;
		if (Input.GetKeyDown(KeyCode.Alpha4)) rotateSpeed = 40f;
		if (Input.GetKeyDown(KeyCode.Alpha5)) rotateSpeed = 50f;

		if (Input.GetKeyDown(KeyCode.X)) rotateX = !rotateX;
		if (Input.GetKeyDown(KeyCode.Y)) rotateY = !rotateY;
		if (Input.GetKeyDown(KeyCode.Z)) rotateZ = !rotateZ;

		float rotateIncrement = Time.deltaTime * rotateSpeed;

		foreach (Transform child in transform) {
			if (rotateX) child.Rotate (Vector3.right * rotateIncrement);
			if (rotateY) child.Rotate (Vector3.up * rotateIncrement);
			if (rotateZ) child.Rotate (Vector3.forward * rotateIncrement);
		}
	}
}
