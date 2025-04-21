# FireElemental.gd
# Handles Fire Elemental behavior: searching for coal, converting to lava, and wandering when idle.
# Uses: SearchModule, ConversionModule, MonsterInfo, SearchRadiusDisplay

extends CharacterBody2D

@onready var EfficiencyTracker := preload("res://scripts/MonsterHelperScripts/EfficiencyTracker.gd").new()
@onready var lava_stat := preload("res://scripts/MonsterHelperScripts/RollingStatTracker.gd").new()
@onready var search_display := $SearchRadiusDisplay

@export var search_radius := 60
@export var move_speed := 240.0
@export var conversion_cooldown := 5.0

var target_position = null  # ← Type will be inferred dynamically
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
	elif target_position:
		_move_toward_target(delta)
		was_efficient = true
	else:
		_search_for_target()

	# Efficiency logic
	if was_efficient:
		efficiency_score += EFFICIENCY_RATE * delta
	else:
		efficiency_score -= EFFICIENCY_RATE * delta

	efficiency_score = clamp(efficiency_score, 0.0, 100.0)
		
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
	# Attempts to find a coal tile using SearchModule
	var result = SearchModule.find_nearest_tile(global_position, search_radius, 0)  # 0 = coal
	if result:
		target_position = result
	else:
		if wander_target == Vector2.ZERO or global_position.distance_to(wander_target) < 5.0:
			_pick_wander_target()
		_move_toward_wander_target()


func _pick_wander_target() -> void:
	var wander_distance = randf_range(32.0, 96.0)
	var angle = randf_range(0, TAU)
	var offset = Vector2(cos(angle), sin(angle)) * wander_distance
	wander_target = global_position + offset

func _move_toward_target(delta) -> void:
	if target_position == null:
		return

	var direction = (target_position - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()

	if global_position.distance_to(target_position) < 4.0:
		_convert_coal_to_lava()
		target_position = null
		is_busy = true
		cooldown_timer = conversion_cooldown

func _convert_coal_to_lava() -> void:
	lava_stat.add(1)
	# Calls ConversionModule to replace coal with lava
	ConversionModule.replace_tile(target_position, 0, 2)  # 0 = Coal, 2 = Lava

	# Remove the tile from claimed list so others can target it later
	SearchModule.claimed_tile_positions.erase(target_position)

func _input_event(viewport, event, shape_idx):
	# Handle left-click to show monster info popup
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var info = {
			"name": "Fire Elemental",
			"efficiency": int(efficiency_score),
			"stats": "Currently Targeting: %s\nCooldown: %.1f seconds" % [str(target_position), conversion_cooldown],
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

func _move_toward_wander_target() -> void:
	var direction = (wander_target - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()
