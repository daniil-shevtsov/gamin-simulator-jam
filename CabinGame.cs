using Godot;
using System;
using System.Collections.Generic;

public partial class CabinGame : Node3D
{

	private Camera3D camera3D;
	private Node3D dummyCamera;
	private CameraMarker initialMarker;
	private CameraMarker knifeMarker;
	private CameraMarker entranceMarker;

	private Node3D doorLight;
	private AudioStreamPlayer scritchPlayer;

	private List<CameraMarker> markersToCycle = new();

	private CameraMarker currentCameraMarker = null;
	private int currentMarkerIndex = 0;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		camera3D = GetNode<Camera3D>("Camera3D");
		dummyCamera = GetNode<Node3D>("DummyCamera");
		initialMarker = GetNode<CameraMarker>("InitialMarker");
		knifeMarker = GetNode<CameraMarker>("KnifeMarker");
		entranceMarker = GetNode<CameraMarker>("EntranceMarker");

		doorLight = GetNode<Node3D>("DoorLight");
		scritchPlayer = GetNode<AudioStreamPlayer>("ScritchAudioPlayer");

		currentCameraMarker = initialMarker;
		SwitchTo(initialMarker);

		markersToCycle.Add(initialMarker);
		markersToCycle.Add(knifeMarker);
		markersToCycle.Add(entranceMarker);
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (Input.IsActionJustReleased("moon"))
		{
			scritchPlayer.Play();
			doorLight.Visible = !doorLight.Visible;
		}

		if (Input.IsActionJustReleased("jump"))
		{
			var newIndex = ++currentMarkerIndex;
			if (newIndex > markersToCycle.Count - 1)
			{
				newIndex = 0;
			}

			currentMarkerIndex = newIndex;

			SwitchTo(markersToCycle[currentMarkerIndex]);
			// if (currentCameraMarker == initialMarker)
			// {
			// 	SwitchTo(knifeMarker);
			// }
			// else if (currentCameraMarker == knifeMarker)
			// {
			// 	SwitchTo(initialMarker);
			// }
		}
	}

	private void SwitchTo(CameraMarker newMarker)
	{
		currentCameraMarker = newMarker;

		if (currentCameraMarker != null)
		{
			dummyCamera.GlobalPosition = currentCameraMarker.cameraMarker.GlobalPosition;
			dummyCamera.LookAt(currentCameraMarker.lookAtMarker.GlobalPosition);
			var rotationTween = CreateTween();
			rotationTween.SetParallel(true);
			rotationTween.TweenProperty(camera3D, new NodePath("global_position"), dummyCamera.GlobalPosition, 0.3f).SetTrans(Tween.TransitionType.Spring);
			rotationTween.TweenProperty(camera3D, new NodePath("rotation"), dummyCamera.Rotation, 0.3f).SetTrans(Tween.TransitionType.Spring);
		}
	}
}
