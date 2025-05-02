# Dragon.gd
# Handles Dragon behavior: searches for lava, converts to soil, stores lava, and excretes ore after cooldown.
# Uses: SearchModule, MonsterInfo, SearchRadiusDisplay

extends CharacterBody2D

@onready var tile_map_layer: TileMapLayer = get_node("/root/Main/TileMap/TileMapLayer")
@onready var search_display := $SearchRadiusDisplay
@onready var anim_sprite := $AnimatedSprite2D  # Add this to the top with the other @onready vars

@export var lava_yield: int = 2
@export var ice_yield: int = 2
@export var egg_yield: int = 2
@export var search_radius_tiles: int = 12     # Used for tile search
@export var search_radius_px: float = 3072.0   # THIS IS search_radius_tiles * 256
@export var max_total_storage: int = 8
@export var max_lava_storage: int = 8
@export var ore_drop_count: int = 2
@export var move_speed: float = 200.0
@export var cooldown_time: float = 10.0
@export var ore_drop_scene: PackedScene
@export var required_lava_to_excrete: int = 2
@export var silver_drop_scene: PackedScene = null
@export var required_ice_to_excrete: int = 2
@export var gold_drop_scene: PackedScene = null
@export var required_eggs_to_excrete: int = 1

var egg_storage: int = 0
var excretion_type: String = ""
var target_egg: Node2D = null
var ice_storage: int = 0
var target_tile = null
var lava_storage: int = 0
var cooldown_timer: float = 0.0
var is_cooling_down: bool = false
var is_efficient: bool = false
var efficiency_score: float = 0.0
var ore_log := []
const ORE_LOG_SIZE := 60  # 60 seconds
var ore_this_second: int = 0
var ore_timer: float = 0.0
const EFFICIENCY_RATE := 100.0 / (5 * 60.0)

var wander_timer: float = 0.0
var wander_target: Vector2 = Vector2.ZERO

func _ready():
	target_tile = SearchModule.find_nearest_tile(global_position, search_radius_tiles, 2)  # Lava
	if not target_tile:
		target_tile = SearchModule.find_nearest_tile(global_position, search_radius_tiles, 4)  # Ice

	if not tile_map_layer:
		push_error("Could not find TileMapLayer!")

	collision_layer = 2
	collision_mask = 1
	if search_display:
		search_display.set_radius(search_radius_px)



	anim_sprite.play("idle_down")

func _process(delta: float) -> void:
	is_efficient = false

	# Handle ore excretion cooldown
	if is_cooling_down:
		if cooldown_timer > 0.0:
			cooldown_timer -= delta
		else:
			_excrete_ore()
		is_efficient = true

	# === Behavior: Try to consume lava or ice if not full ===
	if lava_storage < max_lava_storage or ice_storage < max_lava_storage:
		if target_tile:
			_move_toward_target(delta)
		else:
			target_tile = SearchModule.find_nearest_tile(global_position, search_radius_tiles, 2)  # Lava
			if not target_tile:
				target_tile = SearchModule.find_nearest_tile(global_position, search_radius_tiles, 4)  # Ice

			if not target_tile:
				if wander_target == Vector2.ZERO or global_position.distance_to(wander_target) < 5.0:
					_pick_wander_target()
				_move_toward_target(delta)
	else:
		# Storage full → wander
		if wander_target == Vector2.ZERO or global_position.distance_to(wander_target) < 5.0:
			_pick_wander_target()
		_move_toward_target(delta)

	# === Egg Search ===
	if not target_tile:
		target_tile = SearchModule.find_nearest_tile(global_position, search_radius_tiles, 2)
		if not target_tile:
			target_tile = SearchModule.find_nearest_tile(global_position, search_radius_tiles, 4)

		if not target_tile and not target_egg:
			target_egg = SearchModule.find_closest_drop_of_type(global_position, search_radius_px, "egg", self)

	# === Efficiency scoring ===
	if is_efficient:
		efficiency_score += EFFICIENCY_RATE * delta
	else:
		efficiency_score -= EFFICIENCY_RATE * delta

	efficiency_score = clamp(efficiency_score, 0.0, 100.0)

	# === Ore/min rolling log ===
	ore_timer += delta
	if ore_timer >= 1.0:
		ore_log.append(ore_this_second)
		if ore_log.size() > ORE_LOG_SIZE:
			ore_log.pop_front()

		ore_this_second = 0
		ore_timer = 0.0


func _search_for_lava() -> void:
	target_tile = SearchModule.find_nearest_tile(global_position, search_radius_tiles, 2)
	if not target_tile:
		_pick_wander_target()


func _pick_wander_target() -> void:
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * 32
	wander_target = global_position + offset
	target_tile = null

func _move_toward_target(delta: float) -> void:
	var target = target_tile if target_tile else (target_egg.global_position if target_egg else wander_target)
	var direction = (target - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()

	if global_position.distance_to(target) < 5.0:
		if global_position.distance_to(target) < 5.0:
			if target_tile:
				_consume_tile()
			elif target_egg:
				_consume_egg()
			else:
				_pick_wander_target()


func _consume_tile() -> void:
	if get_total_storage() >= max_total_storage:
		return
		
	if not target_tile or (lava_storage >= max_lava_storage and ice_storage >= max_lava_storage):
		return

	var tile_pos = tile_map_layer.local_to_map(target_tile)
	var source_id = tile_map_layer.get_cell_source_id(tile_pos)

	match source_id:
		2:  # Lava
			tile_map_layer.set_cell(tile_pos, 3, Vector2i(0, 0))  # Soil
			TileRefreshModule.refresh_neighbors(tile_map_layer, tile_pos, true)
			tile_map_layer.fix_invalid_tiles()
			lava_storage += 1
			SearchModule.claimed_tile_positions.erase(target_tile)

			if lava_storage >= required_lava_to_excrete and not is_cooling_down:
				is_cooling_down = true
				cooldown_timer = cooldown_time
				excretion_type = "lava"

		4:  # Ice
			tile_map_layer.set_cell(tile_pos, 3, Vector2i(0, 0))  # Soil
			TileRefreshModule.refresh_neighbors(tile_map_layer, tile_pos, true)
			tile_map_layer.fix_invalid_tiles()
			ice_storage += 1
			SearchModule.claimed_tile_positions.erase(target_tile)

			if ice_storage >= required_ice_to_excrete and not is_cooling_down:
				is_cooling_down = true
				cooldown_timer = cooldown_time
				excretion_type = "ice"

	target_tile = null

	print("ICE STORAGE:", ice_storage, " | REQUIRED:", required_ice_to_excrete, " | COOLING:", is_cooling_down)

func _excrete_ore() -> void:
	var drop_instance: Node2D = null

	# Excrete based on current excretion_type
	match excretion_type:
		"lava":
			if lava_storage >= required_lava_to_excrete:
				drop_instance = ore_drop_scene.instantiate()
				lava_storage -= required_lava_to_excrete
		"ice":
			if ice_storage >= required_ice_to_excrete and silver_drop_scene:
				drop_instance = silver_drop_scene.instantiate()
				ice_storage -= required_ice_to_excrete
		"egg":
			if egg_storage >= required_eggs_to_excrete and gold_drop_scene:
				drop_instance = gold_drop_scene.instantiate()
				egg_storage -= required_eggs_to_excrete

	# If we produced something, add it to the world
	if drop_instance:
		var offset = Vector2(randi_range(-8, 8), randi_range(-8, 8))
		drop_instance.global_position = global_position + offset
		get_parent().add_child(drop_instance)
		ore_this_second += 1

	# Decide what to do next
	# Step 1: Can we keep excreting the same type?
	match excretion_type:
		"lava":
			if lava_storage >= required_lava_to_excrete:
				cooldown_timer = cooldown_time
				return
		"ice":
			if ice_storage >= required_ice_to_excrete:
				cooldown_timer = cooldown_time
				return
		"egg":
			if egg_storage >= required_eggs_to_excrete:
				cooldown_timer = cooldown_time
				return

	# Step 2: Look for another type to switch to
	if lava_storage >= required_lava_to_excrete:
		excretion_type = "lava"
		cooldown_timer = cooldown_time
		return
	elif ice_storage >= required_ice_to_excrete:
		excretion_type = "ice"
		cooldown_timer = cooldown_time
		return
	elif egg_storage >= required_eggs_to_excrete:
		excretion_type = "egg"
		cooldown_timer = cooldown_time
		return

	# Step 3: Nothing left to excrete
	is_cooling_down = false
	cooldown_timer = 0.0


func _input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var info = {
			"name": "Dragon",
			"efficiency": int(float(lava_storage) / float(max_lava_storage) * 100.0),
			"stats": "Lava Stored: %d/%d\nOre Output: %d\nCooldown: %.1f sec" % [
				lava_storage, max_lava_storage, ore_drop_count, cooldown_time
			],
			"node": self
		}
		MonsterInfo.show_info(info, event.position)

func get_live_stats() -> Dictionary:
	var total_stored = get_total_storage()
	var efficiency_pct = int(efficiency_score)

	var next_output = "None"
	var next_output_count = 0

	if excretion_type == "lava":
		next_output = "Iron Ore"
		next_output_count = int(lava_storage / required_lava_to_excrete) * lava_yield
	elif excretion_type == "ice":
		next_output = "Silver Ore"
		next_output_count = int(ice_storage / required_ice_to_excrete) * ice_yield
	elif excretion_type == "egg":
		next_output = "Gold Ore"
		next_output_count = int(egg_storage / required_eggs_to_excrete) * egg_yield

	var stat_text = "Storage: %d / %d\n" % [total_stored, max_total_storage]
	stat_text += "- Lava: %d (%d needed → %d Iron Ore)\n" % [lava_storage, required_lava_to_excrete, lava_yield]
	stat_text += "- Ice: %d (%d needed → %d Silver Ore)\n" % [ice_storage, required_ice_to_excrete, ice_yield]
	stat_text += "- Eggs: %d (%d needed → %d Gold Ore)\n" % [egg_storage, required_eggs_to_excrete, egg_yield]
	stat_text += "Cooldown: %.1f sec\n" % cooldown_time
	stat_text += "Next Output: %s x%d" % [next_output, next_output_count]

	return {
		"efficiency": efficiency_pct,
		"stats": stat_text
	}

	
func _consume_egg() -> void:
	if get_total_storage() >= max_total_storage:
		return

	if not target_egg or egg_storage >= max_lava_storage:
		return

	if target_egg.is_inside_tree():
		target_egg.queue_free()

	egg_storage += 1
	target_egg = null

	if egg_storage >= required_eggs_to_excrete and not is_cooling_down:
		is_cooling_down = true
		cooldown_timer = cooldown_time
		excretion_type = "egg"

func get_total_storage() -> int:
	return lava_storage + ice_storage + egg_storage
