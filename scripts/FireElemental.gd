# FireElemental.gd
# Handles Fire Elemental behavior: searching for coal tiles, crystals, and melons; converting them appropriately
# Uses: SearchModule, ConversionModule, MonsterInfo, SearchRadiusDisplay

extends CharacterBody2D

@onready var EfficiencyTracker := preload("res://scripts/MonsterHelperScripts/EfficiencyTracker.gd").new()
@onready var lava_stat := preload("res://scripts/MonsterHelperScripts/RollingStatTracker.gd").new()
@onready var search_display := $SearchRadiusDisplay

@export var search_radius := 60
@export var move_speed := 240.0
@export var conversion_cooldown := 5.0

var target_data := {"type": "none", "target": null, "resource_type": ""}
var is_busy := false
var cooldown_timer := 0.0
var wander_target: Vector2 = Vector2.ZERO
const EFFICIENCY_RATE := 100.0 / (5 * 60.0)
var efficiency_score: float = 0.0
var lava_tick_timer: float = 0.0

func _ready():
	# Configure collision layers and search display
	collision_layer = 2
	collision_mask = 1
	
	add_child(lava_stat)
	
	if search_display:
		search_display.set_radius(search_radius * 32)

func _process(delta):
	var was_efficient = false

	if is_busy:
		_handle_cooldown(delta)
		was_efficient = true

		# Continue wandering while busy
		if wander_target == Vector2.ZERO or global_position.distance_to(wander_target) < 5.0:
			_pick_wander_target()
		_move_toward_wander_target()
	elif target_data.target:
		_move_toward_target(delta)
		was_efficient = true
	else:
		_search_for_target()

	# Efficiency tracking
	efficiency_score = EfficiencyTracker.update(delta, was_efficient, efficiency_score, EFFICIENCY_RATE)

	# Lava/min rolling stat tracker
	lava_tick_timer += delta
	if lava_tick_timer >= 1.0:
		lava_stat.tick()
		lava_tick_timer = 0.0

func _handle_cooldown(delta: float) -> void:
	# Decrease cooldown and reset when ready
	cooldown_timer -= delta
	if cooldown_timer <= 0.0:
		is_busy = false

func _search_for_target() -> void:
	# First try coal tiles (original behavior)
	var result = SearchModule.find_nearest_tile(global_position, search_radius, 0)  # 0 = coal
	if result:
		target_data = {"type": "tile", "target": result, "resource_type": "coal"}
		return
	
	# Try to find crystal
	var crystal = _find_nearest_crystal()
	if crystal:
		target_data = {"type": "entity", "target": crystal, "resource_type": "crystal"}
		return
	
	# Try to find melon
	var melon = _find_nearest_melon()
	if melon:
		target_data = {"type": "entity", "target": melon, "resource_type": "melon"}
		return
	
	# No targets found - wander
	if wander_target == Vector2.ZERO or global_position.distance_to(wander_target) < 5.0:
		_pick_wander_target()
	_move_toward_wander_target()

func _find_nearest_crystal() -> Node:
	var closest = null
	var closest_dist = search_radius * 32.0
	
	var tree = get_tree()
	if not tree:
		return null
		
	for crystal in tree.get_nodes_in_group("crystals"):
		if crystal.claimed_by != null and crystal.claimed_by != self:
			continue
			
		var dist = global_position.distance_to(crystal.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = crystal
	
	if closest:
		closest.claimed_by = self
	
	return closest

func _find_nearest_melon() -> Node:
	var closest = null
	var closest_dist = search_radius * 32.0
	
	var tree = get_tree()
	if not tree:
		return null
		
	for melon in tree.get_nodes_in_group("melons"):
		if not melon.is_harvestable or (melon.claimed_by != null and melon.claimed_by != self):
			continue
			
		var dist = global_position.distance_to(melon.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = melon
	
	if closest:
		closest.claimed_by = self
	
	return closest

func _pick_wander_target() -> void:
	var wander_distance = randf_range(32.0, 96.0)
	var angle = randf_range(0, TAU)
	var offset = Vector2(cos(angle), sin(angle)) * wander_distance
	wander_target = global_position + offset

func _move_toward_target(delta) -> void:
	if not target_data.target:
		target_data = {"type": "none", "target": null, "resource_type": ""}
		return

	# Get target position based on type
	var target_pos = Vector2.ZERO
	match target_data.type:
		"tile":
			target_pos = target_data.target
		"entity":
			if is_instance_valid(target_data.target):
				target_pos = target_data.target.global_position
			else:
				target_data = {"type": "none", "target": null, "resource_type": ""}
				return

	var direction = (target_pos - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()

	if global_position.distance_to(target_pos) < 4.0:
		_convert_resource()
		target_data = {"type": "none", "target": null, "resource_type": ""}
		is_busy = true
		cooldown_timer = conversion_cooldown

func _convert_resource() -> void:
	match target_data.resource_type:
		"coal":
			lava_stat.add(1)
			# Original behavior - coal to lava
			ConversionModule.replace_tile(target_data.target, 0, 2)  # 0 = Coal, 2 = Lava
			SearchModule.claimed_tile_positions.erase(target_data.target)
			
		"crystal":
			# Crystal to ice
			var tilemap = get_tree().current_scene.get_node("TileMap/TileMapLayer")
			var tile_pos = tilemap.local_to_map(target_data.target.global_position)
			tilemap.set_cell(tile_pos, 4, Vector2i(0, 0))  # 4 = Ice
			if target_data.target.has_method("consume"):
				target_data.target.consume()
			print("❄️ Fire Elemental converted crystal to ice at", tile_pos)
			
		"melon":
			# Melon to water
			var tilemap = get_tree().current_scene.get_node("TileMap/TileMapLayer")
			var tile_pos = tilemap.local_to_map(target_data.target.global_position)
			tilemap.set_cell(tile_pos, 5, Vector2i(0, 0))  # 5 = Water
			if target_data.target.has_method("harvest"):
				target_data.target.harvest(true)  # true = consumed by monster
			print("💧 Fire Elemental converted melon to water at", tile_pos)

func _move_toward_wander_target() -> void:
	var direction = (wander_target - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()

func _input_event(viewport, event, shape_idx):
	# Handle left-click to show monster info popup
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var target_str = "None"
		if target_data.target:
			target_str = target_data.resource_type.capitalize()
		
		var info = {
			"name": "Fire Elemental",
			"efficiency": int(efficiency_score),
			"stats": "Currently Targeting: %s\nCooldown: %.1f seconds" % [target_str, conversion_cooldown],
			"node": self
		}
		MonsterInfo.show_info(info, event.position)
		
func get_live_stats() -> Dictionary:
	var average_lava_per_min = lava_stat.get_average()
	var max_lava_per_min = 60.0 / conversion_cooldown

	return {
		"efficiency": int(efficiency_score),
		"stats": "Cooldown: %.1f seconds\nLava/min: %.1f / %.1f" % [
			conversion_cooldown,
			average_lava_per_min,
			max_lava_per_min
		]
	}
