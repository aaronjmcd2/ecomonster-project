# MonsterInfoPopup.gd
# Displays creature stats and efficiency when clicked. Follows the creature via live stats.
# Shows and hides the popup panel and controls SearchRadiusDisplay.
# Attached to CanvasLayer in the scene tree.

extends CanvasLayer

@onready var panel = $Panel
@onready var label_name = $Panel/VBoxContainer/Label_Name
@onready var label_efficiency = $Panel/VBoxContainer/Label_Efficiency
@onready var label_stats = $Panel/VBoxContainer/Label_Stats

var current_monster: Node = null
var is_showing := false

# === Displays the popup with data and shows radius ===
func show_info(monster_data: Dictionary, screen_position: Vector2) -> void:
	print("🧪 show_info called with:", monster_data)

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

# === Hides the popup and radius display if present ===
func hide_info() -> void:
	if current_monster:
		var radius_display = current_monster.get_node_or_null("SearchRadiusDisplay")
		if radius_display:
			radius_display.hide_radius()

	current_monster = null
	is_showing = false
	visible = false

# === Handles click outside the popup to close it ===
func _unhandled_input(event: InputEvent) -> void:
	if is_showing and event is InputEventMouseButton and event.pressed:
		if not panel.get_global_rect().has_point(event.position):
			hide_info()

# === Polls the selected monster for live stats and updates the panel ===
func _process(delta: float) -> void:
	if is_showing and current_monster and is_instance_valid(current_monster):
		if current_monster.has_method("get_live_stats"):
			var data = current_monster.get_live_stats()
			label_efficiency.text = "Efficiency: %d%%" % data.get("efficiency", 0)
			label_stats.text = data.get("stats", "No data available.")
