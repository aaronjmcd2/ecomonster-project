extends CanvasLayer

@onready var panel = $Panel
@onready var label_name = $Panel/Label_Name
@onready var label_efficiency = $Panel/Label_Efficiency
@onready var label_stats = $Panel/Label_Stats

var is_showing := false

func show_info(monster_data: Dictionary, screen_position: Vector2):
	label_name.text = monster_data.get("name", "Unknown Creature")
	label_efficiency.text = "Efficiency: %d%%" % monster_data.get("efficiency", 0)
	label_stats.text = monster_data.get("stats", "No data available.")

	panel.global_position = screen_position + Vector2(10, -10) # slight offset so it doesn't cover the monster
	is_showing = true
	visible = true

func hide_info():
	is_showing = false
	visible = false

func _unhandled_input(event):
	if is_showing and event is InputEventMouseButton and event.pressed:
		# If clicked anywhere that's NOT the panel, hide it
		if not panel.get_global_rect().has_point(event.position):
			hide_info()
