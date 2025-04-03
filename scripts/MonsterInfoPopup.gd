extends CanvasLayer

@onready var panel = $Panel
@onready var label_name = $Panel/VBoxContainer/Label_Name
@onready var label_efficiency = $Panel/VBoxContainer/Label_Efficiency
@onready var label_stats = $Panel/VBoxContainer/Label_Stats

var current_monster: Node = null
var is_showing := false

func show_info(monster_data: Dictionary, screen_position: Vector2):
	current_monster = monster_data.get("node", null)

	label_name.text = monster_data.get("name", "Unknown Creature")
	label_efficiency.text = "Efficiency: %d%%" % monster_data.get("efficiency", 0)
	label_stats.text = monster_data.get("stats", "No data available.")

	panel.global_position = screen_position + Vector2(200, -100)
	is_showing = true
	visible = true

	if current_monster:
		var radius_display = current_monster.get_node_or_null("SearchRadiusDisplay")
		if radius_display:
			radius_display.show_radius()

func hide_info():
	if current_monster:
		var radius_display = current_monster.get_node_or_null("SearchRadiusDisplay")
		if radius_display:
			radius_display.hide_radius()

	current_monster = null
	is_showing = false
	visible = false

func _unhandled_input(event):
	if is_showing and event is InputEventMouseButton and event.pressed:
		if not panel.get_global_rect().has_point(event.position):
			hide_info()
