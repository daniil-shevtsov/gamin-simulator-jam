using Godot;
using System;

public partial class CabinGame : Node3D
{

	private Camera3D camera3D;
	private Node3D dummyCamera;
	private CameraMarker initialMarker;
	private CameraMarker knifeMarker;

	private CameraMarker currentCameraMarker = null;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		camera3D = GetNode<Camera3D>("Camera3D");
		dummyCamera = GetNode<Node3D>("DummyCamera");
		initialMarker = GetNode<CameraMarker>("InitialMarker");
		knifeMarker = GetNode<CameraMarker>("KnifeMarker");

		currentCameraMarker = initialMarker;
		SwitchTo(initialMarker);
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (Input.IsActionJustReleased("jump"))
		{
			if (currentCameraMarker == initialMarker)
			{
				SwitchTo(knifeMarker);
			}
			else if (currentCameraMarker == knifeMarker)
			{
				SwitchTo(initialMarker);
			}
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

			// rotationTween.TweenProperty(camera3D, new NodePath("global_position"), currentCameraMarker.cameraMarker.GlobalPosition, 0.3f).SetTrans(Tween.TransitionType.Spring);
			// // rotationTween.TweenProperty(camera3D, new NodePath("transform"), camera3D.Transform.LookingAt(currentCameraMarker.lookAtMarker.GlobalPosition, new Vector3(0, 1, 0)), 0.3f).SetTrans(Tween.TransitionType.Spring);

			// rotationTween.TweenProperty(camera3D, new NodePath("global_transform"), camera3D.GlobalTransform.LookingAt(currentCameraMarker.lookAtMarker.GlobalTransform.Origin, new Vector3(0, 1, 0)), 0.3f).SetTrans(Tween.TransitionType.Spring);

			// // camera3D.GlobalPosition = currentCameraMarker.cameraMarker.GlobalPosition;
			// // camera3D.LookAt(currentCameraMarker.lookAtMarker.GlobalPosition);
		}
	}
}
