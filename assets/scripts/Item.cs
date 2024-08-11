using Godot;
using System;
using System.ComponentModel;

public partial class Item : StaticBody3D
{

	[Export]
	public ItemType type;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}

public enum ItemType
{
	Knife,
	Chalk
}