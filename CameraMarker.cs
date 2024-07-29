using Godot;
using System;

public partial class CameraMarker : Node3D
{
	public Marker3D cameraMarker;
	public Marker3D lookAtMarker;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		cameraMarker = GetNode<Marker3D>("CameraMarker");
		lookAtMarker = GetNode<Marker3D>("LookAtMarker");
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		// if (cameraMarker.GlobalPosition != cameraPosition)
		// {
		// 	cameraMarker.GlobalPosition = cameraPosition;
		// }

		// if (lookAtMarker.GlobalPosition != lookAtPosition)
		// {
		// 	lookAtMarker.GlobalPosition = lookAtPosition;
		// }
	}
}
