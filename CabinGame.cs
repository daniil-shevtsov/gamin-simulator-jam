using Godot;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading.Tasks;

public partial class CabinGame : Node3D
{

	private Camera3D camera3D;
	private Node3D dummyCamera;
	private CameraMarker initialMarker;

	private CameraMarker knifeMarker;
	private Item knife;

	private CameraMarker chalkMarker;
	private Item chalk;

	private CameraMarker entranceMarker;

	private Node3D doorLight;
	private AudioStreamPlayer scritchPlayer;

	private AudioStreamPlayer actionPlayer;
	private MeshInstance3D circle;
	private ShaderMaterial circleMaterial;
	private CameraMarker marker1;
	private CameraMarker marker2;
	private CameraMarker marker3;

	private List<CameraMarker> markersToCycle = new();

	private CameraMarker currentCameraMarker = null;
	private Item currentItem = null;
	private int currentMarkerIndex = 0;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		camera3D = GetNode<Camera3D>("Camera3D");
		dummyCamera = GetNode<Node3D>("DummyCamera");
		initialMarker = GetNode<CameraMarker>("InitialMarker");

		knifeMarker = GetNode<CameraMarker>("KnifeMarker");
		knife = (Item)FindChild("Knife");

		chalkMarker = GetNode<CameraMarker>("ChalkMarker");
		chalk = (Item)FindChild("Chalk");

		entranceMarker = GetNode<CameraMarker>("EntranceMarker");

		doorLight = GetNode<Node3D>("DoorLight");
		scritchPlayer = GetNode<AudioStreamPlayer>("ScritchAudioPlayer");

		actionPlayer = GetNode<AudioStreamPlayer>("ActionAudioPlayer");
		circle = (MeshInstance3D)FindChild("Circle");
		circleMaterial = (ShaderMaterial)circle.GetSurfaceOverrideMaterial(0);
		circleMaterial.SetShaderParameter("dissolve_value", 0f);
		marker1 = (CameraMarker)FindChild("marker1");
		marker2 = (CameraMarker)FindChild("marker2");
		marker3 = (CameraMarker)FindChild("marker3");

		currentCameraMarker = initialMarker;
		SwitchTo(initialMarker);

		markersToCycle.Add(initialMarker);
		markersToCycle.Add(chalkMarker);
		markersToCycle.Add(knifeMarker);
		markersToCycle.Add(entranceMarker);
	}

	private void ToggleMoon()
	{
		scritchPlayer.Play();
		doorLight.Visible = !doorLight.Visible;
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override async void _Process(double delta)
	{
		if (Input.IsActionJustReleased("moon"))
		{
			ToggleMoon();
		}

		if (Input.IsActionJustReleased("take"))
		{
			if (currentCameraMarker == knifeMarker)
			{
				ToggleGrabItem(knife);
			}
			else if (currentCameraMarker == chalkMarker)
			{
				ToggleGrabItem(chalk);
			}
		}

		if (Input.IsActionJustReleased("chalk") && currentItem == chalk)
		{
			var finalValue = 1f;
			if ((float)circleMaterial.GetShaderParameter("dissolve_value") > 0f)
			{
				finalValue = 0f;
			}
			var chalkAnimationDuration = 2.0f;
			var durationThird = chalkAnimationDuration / 3f;
			var tween = CreateTween();
			tween.TweenProperty(circleMaterial, "shader_parameter/dissolve_value", finalValue, chalkAnimationDuration);
			SwitchTo(marker1);
			GD.Print("After switch marker1");
			actionPlayer.Autoplay = true;
			actionPlayer.Play();
			await Task.Delay((int)(durationThird * 1000));
			SwitchTo(marker2);
			GD.Print("After switch marker2");

			await Task.Delay((int)(durationThird * 1000));
			SwitchTo(marker3);
			GD.Print("After switch marker3");


			await ToSignal(tween, "finished");
			GD.Print("After tween finished");
			actionPlayer.Stop();
			SwitchTo(initialMarker);
			await Task.Delay(300);
			ToggleMoon();
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

	private void ToggleGrabItem(Item item)
	{
		if (currentItem == null)
		{
			currentItem = item;
			item.GlobalPosition = ((Marker3D)camera3D.FindChild("GrabbedPosition")).GlobalPosition;
			item.Reparent(camera3D);
		}
		else if (currentItem == item)
		{
			currentItem = null;

			item.Reparent(this);
			item.GlobalTransform = item.defaultTransform;
		}
	}
}
