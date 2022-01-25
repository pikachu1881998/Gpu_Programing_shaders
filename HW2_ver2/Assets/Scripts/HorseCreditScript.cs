// Aaron Lanterman, June 21, 2014

using UnityEngine;
using System.Collections;

public class HorseCreditScript : MonoBehaviour {

	private GUIStyle guiStyle;

	// Use this for initialization
	void Start () {
		guiStyle = new GUIStyle ();
		guiStyle.alignment = TextAnchor.MiddleCenter;
		guiStyle.normal.textColor = Color.black;
		guiStyle.fontSize = 30;
	}

	void OnGUI () {
		Rect textArea = new Rect (100, 0, Screen.width - 200, 50);
		GUI.Label (textArea, "Horse model & animation by Dootsy Development", guiStyle);
	}
	
	void Update () {
	}
}
