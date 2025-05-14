# Dragon.gd
# Orchestrates Dragon behavior through specialized modules.
# Handles state management and module coordination.
# 
# Behavior summary:
# - Searches for lava and ice to consume
# - Stores resources and produces ore through excretion
# - Wanders when no resources are available
# - Shows stats when clicked
# - Can evolve into Glass Dragon when conditions are met

extends CharacterBody2D

# === Node References ===
@onready var tile_map_layer: TileMapLayer = get_node("/root/Main/TileMap/TileMapLayer")
@onready var search_display := $SearchRadiusDisplay
@onready var anim_sprite := $AnimatedSprite2D

# === Dragon Helper Modules ===
@onready var wander_module = preload("res://creatures/dragon/base/modules/DragonWanderModule.gd").new()
@onready var movement_module = preload("res://creatures/dragon/base/modules/DragonMovementModule.gd").new()
@onready var consumption_module = preload("res://creatures/dragon/base/modules/DragonConsumptionModule.gd").new()
@onready var excretion_module = preload("res://creatures/dragon/base/modules/DragonExcretionModule.gd").new()
@onready var stats_module = preload("res://creatures/dragon/base/modules/DragonStatsModule.gd").new()
@onready var search_module = preload("res://creatures/dragon/base/modules/DragonSearchModule.gd").new()
@onready var ui_module = preload("res://creatures/dragon/base/modules/DragonUIModule.gd").new()
@onready var tile_module = preload("res://creatures/dragon/base/modules/DragonTileModule.gd").new()
@onready var animation_module = preload("res://creatures/dragon/base/modules/DragonAnimationModule.gd").new()
@onready var init_module = preload("res://creatures/dragon/base/modules/DragonInitModule.gd").new()

# === Configuration Parameters ===
@export_group("Resource Production")
@export var lava_yield: int = 2
@export var ice_yield: int = 2
@export var egg_yield: int = 2
@export var required_lava_to_excrete: int = 2
@export var required_ice_to_excrete: int = 2
@export var required_eggs_to_excrete: int = 1

@export_group("Ore Production")
@export var ore_drop_scene: PackedScene
@export var silver_drop_scene: PackedScene = null
@export var gold_drop_scene: PackedScene = null
@export var ore_drop_count: int = 2

@export_group("Movement & Search")
@export var search_radius_tiles: int = 12
@export var search_radius_px: float = 3072.0
@export var move_speed: float = 200.0

@export_group("Resource Storage")
@export var max_total_storage: int = 8
@export var max_lava_storage: int = 8
@export var cooldown_time: float = 10.0

@export_group("Evolution")
@export var required_lava_to_evolve: int = 6
@export var required_ice_to_evolve: int = 6
@export var glass_dragon_scene: PackedScene = preload("res://creatures/dragon/GlassDragon/GlassDragon.tscn")

# === State Variables ===
# Storage
var lava_storage: int = 0
var ice_storage: int = 0
var egg_storage: int = 0

# Lifetime resource tracking for evolution
var total_lava_collected: int = 0
var total_ice_collected: int = 0

# Targets
var target_tile = null
var target_egg: Node2D = null
var wander_target: Vector2 = Vector2.ZERO

# Excretion
var excretion_type: String = ""
var cooldown_timer: float = 0.0
var is_cooling_down: bool = false

# Efficiency tracking
var is_efficient: bool = false
var efficiency_score: float = 0.0
var ore_log := []
const ORE_LOG_SIZE := 60  # 60 seconds
var ore_this_second: int = 0
var ore_timer: float = 0.0
const EFFICIENCY_RATE := 100.0 / (5 * 60.0)

# Evolution tracking
var can_evolve: bool = false

# === Core Functions ===
func _ready():
	# Use init module to handle all initialization
	init_module.initialize(self)

func _process(delta: float) -> void:
	is_efficient = false

	# === Phase 1: Handle excretion cooldown ===
	if is_cooling_down:
		_handle_excretion(delta)
		is_efficient = true
	
	# === Phase 2: Resource gathering or wandering behavior ===
	if _can_gather_more_resources():
		_execute_gathering_behavior(delta)
	else:
		_execute_wandering_behavior(delta)
	
	# === Phase 3: Ensure we have targets if needed ===
	if not target_tile and not target_egg:
		search_module.search_for_resources(self)

	# === Phase 4: Update stats ===
	stats_module.update_efficiency(self, delta, is_efficient)
	stats_module.update_ore_log(self, delta)
	
	# === Phase 5: Check evolution eligibility ===
	_check_evolution_eligibility()

func _input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if can_evolve:
			_show_evolution_dialog()
		else:
			ui_module.handle_input_event(self, viewport, event, shape_idx)

func get_live_stats() -> Dictionary:
	return stats_module.get_live_stats(self)

func get_total_storage() -> int:
	return consumption_module.get_total_storage(self)

# === Helper Functions ===
func _handle_excretion(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	else:
		excretion_module.excrete_ore(self)
		animation_module.play_excretion_animation(self)

func _can_gather_more_resources() -> bool:
	return lava_storage < max_lava_storage or ice_storage < max_lava_storage

func _execute_gathering_behavior(delta: float) -> void:
	if target_tile:
		var move_result = movement_module.move_toward_target(delta, self, target_tile, target_egg, wander_target, move_speed)
		animation_module.update_animation(self)

		if move_result == "tile":
			consumption_module.consume_tile(self, target_tile, tile_map_layer)
		elif move_result == "egg":
			consumption_module.consume_egg(self, target_egg)
		elif move_result == "wander":
			wander_target = wander_module.pick_wander_target(global_position)
			target_tile = null
	else:
		# Use search module for comprehensive resource search
		search_module.search_for_resources(self)

		if not target_tile:
			# No resources found, ensure we have a wander target
			search_module.ensure_wander_target(self)
			
			var move_result = movement_module.move_toward_target(delta, self, target_tile, target_egg, wander_target, move_speed)
			animation_module.update_animation(self)

			if move_result == "tile":
				consumption_module.consume_tile(self, target_tile, tile_map_layer)
			elif move_result == "egg":
				consumption_module.consume_egg(self, target_egg)
			elif move_result == "wander":
				wander_target = wander_module.pick_wander_target(global_position)
				target_tile = null

func _execute_wandering_behavior(delta: float) -> void:
	# Storage full → wander
	search_module.ensure_wander_target(self)
	
	var move_result = movement_module.move_toward_target(delta, self, target_tile, target_egg, wander_target, move_speed)
	animation_module.update_animation(self)

	if move_result == "tile":
		consumption_module.consume_tile(self, target_tile, tile_map_layer)
	elif move_result == "egg":
		consumption_module.consume_egg(self, target_egg)
	elif move_result == "wander":
		wander_target = wander_module.pick_wander_target(global_position)
		target_tile = null

# === Evolution Functions ===
func _check_evolution_eligibility() -> void:
	can_evolve = total_lava_collected >= required_lava_to_evolve and total_ice_collected >= required_ice_to_evolve

func _show_evolution_dialog() -> void:
	# Get the ConfirmationDialog from the UI
	var dialog = ConfirmationDialog.new()
	dialog.title = "Evolve Dragon"
	dialog.dialog_text = "This dragon has consumed enough lava and ice to evolve into a Glass Dragon!\n\nDo you want to evolve this dragon now?"
	dialog.get_ok_button().text = "Evolve"
	
	# Connect the confirmed signal
	dialog.connect("confirmed", Callable(self, "_evolve_to_glass_dragon"))
	
	# Add the dialog to the scene
	get_tree().get_root().add_child(dialog)
	dialog.popup_centered()

func _evolve_to_glass_dragon() -> void:
	# Instantiate the Glass Dragon
	var glass_dragon = glass_dragon_scene.instantiate()
	
	# Transfer the relevant properties
	glass_dragon.global_position = global_position
	
	# Transfer current lava and ice storage to the Glass Dragon
	glass_dragon.lava_storage = lava_storage
	glass_dragon.ice_storage = ice_storage
	
	# Add the glass dragon to the scene
	get_parent().add_child(glass_dragon)
	
	# Remove this dragon
	queue_free()
