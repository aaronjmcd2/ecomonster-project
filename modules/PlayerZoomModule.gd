# PlayerZoomModule.gd
# Handles zoom in/out functionality for the player's camera.

extends Node

var camera: Camera2D = null
var zoom_step: float = 0.1
var min_zoom: float = 0.5
var max_zoom: float = 2.0

func setup(cam, step, min_val, max_val):
	camera = cam
	zoom_step = step
	min_zoom = min_val
	max_zoom = max_val

func zoom_in():
	zoom_camera(zoom_step)

func zoom_out():
	zoom_camera(-zoom_step)

func zoom_camera(amount: float) -> void:
	if camera == null:
		return
	var new_zoom = camera.zoom + Vector2(amount, amount)
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	camera.zoom = new_zoom
