extends Node2D

@export var radius: float = 64.0
@export var color: Color = Color(0.4, 0.7, 1.0, 0.3)  # Soft blue, semi-transparent
var visible_radius := false

func _ready():
	queue_redraw()

func _draw():
	if visible_radius:
		draw_circle(Vector2.ZERO, radius, color)

func show_radius():
	visible_radius = true
	queue_redraw()

func hide_radius():
	visible_radius = false
	queue_redraw()

func set_radius(new_radius: float):
	radius = new_radius
	queue_redraw()
