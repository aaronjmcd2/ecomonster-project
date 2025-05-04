# Dragon.gd
# Handles Dragon behavior: searches for lava, converts to soil, stores lava, and excretes ore after cooldown.
# Uses: SearchModule, MonsterInfo, SearchRadiusDisplay

extends CharacterBody2D

@onready var tile_map_layer: TileMapLayer = get_node("/root/Main/TileMap/TileMapLayer")
@onready var search_display := $SearchRadiusDisplay
@onready var anim_sprite := $AnimatedSprite2D  # Add this to the top with the other @onready vars
@onready var wander_module = preload("res://modules/MonsterHelperModules/DragonHelperModules/DragonWanderModule.gd").new()
@onready var movement_module = preload("res://modules/MonsterHelperModules/DragonHelperModules/DragonMovementModule.gd").new()
@onready var consumption_module = preload("res://modules/MonsterHelperModules/DragonHelperModules/DragonConsumptionModule.gd").new()
@onready var excretion_module = preload("res://modules/MonsterHelperModules/DragonHelperModules/DragonExcretionModule.gd").new()
@onready var stats_module = preload("res://modules/MonsterHelperModules/DragonHelperModules/DragonStatsModule.gd").new()
@onready var search_module = preload("res://modules/MonsterHelperModules/DragonHelperModules/DragonSearchModule.gd").new()
@onready var ui_module = preload("res://modules/MonsterHelperModules/DragonHelperModules/DragonUIModule.gd").new()


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
	# Initialize by searching for resources
	search_module.search_for_resources(self)

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
			excretion_module.excrete_ore(self)
		is_efficient = true

	# === Behavior: Try to consume lava or ice if not full ===
	if lava_storage < max_lava_storage or ice_storage < max_lava_storage:
		if target_tile:
			var move_result = movement_module.move_toward_target(delta, self, target_tile, target_egg, wander_target, move_speed)

			if move_result == "tile":
				consumption_module.consume_tile(self, target_tile, tile_map_layer)
			elif move_result == "egg":
				consumption_module.consume_egg(self, target_egg)
			elif move_result == "wander":
				wander_target = wander_module.pick_wander_target(global_position)
				target_tile = null

		else:
			# Use combined search_for_resources function
			search_module.search_for_resources(self)

			if not target_tile:
				# No resources found, ensure we have a wander target
				search_module.ensure_wander_target(self)
				
				var move_result = movement_module.move_toward_target(delta, self, target_tile, target_egg, wander_target, move_speed)

				if move_result == "tile":
					consumption_module.consume_tile(self, target_tile, tile_map_layer)
				elif move_result == "egg":
					consumption_module.consume_egg(self, target_egg)
				elif move_result == "wander":
					wander_target = wander_module.pick_wander_target(global_position)
					target_tile = null

	else:
		# Storage full → wander
		search_module.ensure_wander_target(self)
		
		var move_result = movement_module.move_toward_target(delta, self, target_tile, target_egg, wander_target, move_speed)

		if move_result == "tile":
			consumption_module.consume_tile(self, target_tile, tile_map_layer)
		elif move_result == "egg":
			consumption_module.consume_egg(self, target_egg)
		elif move_result == "wander":
			wander_target = wander_module.pick_wander_target(global_position)
			target_tile = null


	# === Egg Search ===
	if not target_tile and not target_egg:
		# Use the search_for_resources function for a comprehensive search
		search_module.search_for_resources(self)

	# === Efficiency scoring ===
	stats_module.update_efficiency(self, delta, is_efficient)

	# === Ore/min rolling log ===
	stats_module.update_ore_log(self, delta)


func _input_event(viewport, event, shape_idx) -> void:
	ui_module.handle_input_event(self, viewport, event, shape_idx)

func get_live_stats() -> Dictionary:
	return stats_module.get_live_stats(self)

func get_total_storage() -> int:
	return consumption_module.get_total_storage(self)
