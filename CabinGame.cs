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

	private AudioStreamPlayer actionPlayer;
	private MeshInstance3D circle;
	private ShaderMaterial circleMaterial;

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

		actionPlayer = GetNode<AudioStreamPlayer>("ActionAudioPlayer");
		circle = (MeshInstance3D)FindChild("Circle");
		circleMaterial = (ShaderMaterial)circle.GetSurfaceOverrideMaterial(0);
		circleMaterial.SetShaderParameter("dissolve_value", 0f);

		currentCameraMarker = initialMarker;
		SwitchTo(initialMarker);

		markersToCycle.Add(initialMarker);
		markersToCycle.Add(knifeMarker);
		markersToCycle.Add(entranceMarker);
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override async void _Process(double delta)
	{
		if (Input.IsActionJustReleased("moon"))
		{
			scritchPlayer.Play();
			doorLight.Visible = !doorLight.Visible;
		}

		if (Input.IsActionJustReleased("chalk"))
		{
			var finalValue = 1f;
			if ((float)circleMaterial.GetShaderParameter("dissolve_value") > 0f)
			{
				finalValue = 0f;
			}
			var tween = CreateTween();
			tween.TweenProperty(circleMaterial, "shader_parameter/dissolve_value", finalValue, 1.0f);
			actionPlayer.Play();
			await ToSignal(tween, "finished");
			actionPlayer.Stop();
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
