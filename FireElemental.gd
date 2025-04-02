extends CharacterBody2D

@export var search_radius := 10
@export var move_speed := 60.0
@export var conversion_cooldown := 2.0

var target_position = null
var is_busy := false
var cooldown_timer := 0.0

func _ready():
	collision_layer = 2
	collision_mask = 1  # Collides only with player/environment

func _process(delta):
	if is_busy:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			is_busy = false
	else:
		if target_position:
			move_toward_target(delta)
		else:
			search_for_coal()

func search_for_coal():
	var result = SearchModule.find_nearest_tile(global_position, search_radius, 0) # coal
	if result:
		target_position = result
	else:
		if not target_position:
			pick_wander_target()

func pick_wander_target():
	var wander_distance = randf_range(32.0, 96.0)
	var angle = randf_range(0, TAU)
	var offset = Vector2(cos(angle), sin(angle)) * wander_distance
	target_position = global_position + offset

func move_toward_target(delta):
	if target_position == null:
		return

	var direction = (target_position - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()

	if global_position.distance_to(target_position) < 4.0:
		convert_coal_to_lava()
		target_position = null
		is_busy = true
		cooldown_timer = conversion_cooldown

func convert_coal_to_lava():
	ConversionModule.replace_tile(target_position, 0, 2) # coal to lava
	target_position = null
