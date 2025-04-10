# SearchRadiusDisplay.gd
# Visual node that renders a soft, colored circle representing a creature's search radius.
# Used by all monsters when selected via MonsterInfoPopup.

extends Node2D

@export var radius: float = 64.0  # In pixels
@export var color: Color = Color(0.4, 0.7, 1.0, 0.3)  # Soft blue, semi-transparent

var visible_radius := false  # Controls whether the radius is drawn

func _ready() -> void:
	queue_redraw()

# === Draws the radius if visible ===
func _draw() -> void:
	if visible_radius:
		draw_circle(Vector2.ZERO, radius, color)

# === Makes the radius visible and redraws ===
func show_radius() -> void:
	visible_radius = true
	queue_redraw()

# === Hides the radius and redraws ===
func hide_radius() -> void:
	visible_radius = false
	queue_redraw()

# === Updates the radius value and redraws ===
func set_radius(new_radius: float) -> void:
	radius = new_radius
	queue_redraw()
