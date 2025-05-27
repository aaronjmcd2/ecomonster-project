# LakeManager.gd
# Manages lake detection, fog effects, and specter spawning
extends Node

@onready var tile_map_layer: TileMapLayer = get_node("/root/Main/TileMap/TileMapLayer")

# References to modules
@onready var lake_detection_module = preload("res://systems/modules/LakeDetectionModule.gd").new()

# References to scenes
@export var specter_scene: PackedScene
@export var fog_effect_scene: PackedScene

# Configuration
@export var detection_interval: float = 30.0  # Seconds between lake detection
@export var spawn_interval: float = 15.0  # Seconds between specter spawns
@export var max_specters_per_lake: int = 5

# Tracking variables
var detection_timer: float = 0.0
var lakes = []
var fog_effects = {}  # Map of lake index to fog effect node

func _ready():
	# Initial lake detection
	_detect_lakes()
	
	# Connect to the item_dropped signal
	EventBus.connect("item_dropped", Callable(self, "_on_item_dropped"))

func _process(delta: float):
	# Update detection timer
	detection_timer += delta
	if detection_timer >= detection_interval:
		_detect_lakes()
		detection_timer = 0.0
	
	# Update lake fog timers
	lake_detection_module.update_lakes(delta)
	
	# Process foggy lakes
	_process_foggy_lakes(delta)
	
	# Update fog effects
	_update_fog_effects()

# Check for silver ingots dropped in water
func check_silver_ingot_drop(ingot_pos: Vector2) -> bool:
	return lake_detection_module.make_lake_foggy(tile_map_layer, ingot_pos)

# Detect lakes in the current tilemap
func _detect_lakes():
	lakes = lake_detection_module.detect_lakes(tile_map_layer)
	print("Found %d lakes in the map" % lakes.size())

# Process all foggy lakes (spawn specters, etc.)
func _process_foggy_lakes(delta: float):
	for i in range(lakes.size()):
		var lake = lakes[i]
		
		if lake.is_foggy:
			# Update spawn timer
			if not lake.has("spawn_timer"):
				lake.spawn_timer = spawn_interval
			
			lake.spawn_timer -= delta
			
			# Spawn specter if timer expired
			if lake.spawn_timer <= 0:
				_spawn_specter(lake)
				lake.spawn_timer = spawn_interval

# Update fog effects for each lake
# Update fog effects for each lake
func _update_fog_effects():
	# Add fog to newly foggy lakes
	for i in range(lakes.size()):
		var lake = lakes[i]
		
		# Add fog effect if the lake is foggy and doesn't have one
		if lake.is_foggy and not fog_effects.has(i):
			var fog = fog_effect_scene.instantiate()
			
			# Calculate center of lake in tile coordinates
			var tile_center = Vector2.ZERO
			for tile_pos in lake.tiles:
				tile_center += Vector2(tile_pos.x, tile_pos.y)
			tile_center /= lake.tiles.size()
			
			# Convert to world position - this is the key fix
			var world_center = tile_map_layer.map_to_local(Vector2i(int(tile_center.x), int(tile_center.y)))
			
			print("🌫️ Lake center in tiles: " + str(tile_center))
			print("🌫️ Lake center in world: " + str(world_center))
			
			# Calculate size based on lake size
			var size = sqrt(lake.tiles.size()) * 32 * 2  # Rough estimate
			
			# Position the fog effect at the lake center
			fog.position = world_center
			
			# Set the bounds for the fog effect
			fog.set_bounds(Vector2(size, size))
			
			add_child(fog)
			fog_effects[i] = fog
			
			print("🌫️ Created fog effect for lake at " + str(world_center))
		
		# Remove fog effect if the lake is no longer foggy
		elif not lake.is_foggy and fog_effects.has(i):
			fog_effects[i].queue_free()
			fog_effects.erase(i)

# Spawn a specter from a foggy lake
func _spawn_specter(lake):
	# Count existing specters from this lake
	var specters_from_lake = 0
	for specter in get_tree().get_nodes_in_group("specters"):
		if specter.birth_lake == lake:
			specters_from_lake += 1
	
	# Don't spawn if at max capacity
	if specters_from_lake >= max_specters_per_lake:
		return
	
	# Choose a random tile in the lake
	var spawn_tile = lake.tiles[randi() % lake.tiles.size()]
	
	# Convert tile position to world position
	var spawn_pos = tile_map_layer.map_to_local(spawn_tile)
	
	print("👻 Spawning specter at tile: " + str(spawn_tile) + ", world pos: " + str(spawn_pos))
	
	# Spawn the specter
	var specter = specter_scene.instantiate()
	specter.global_position = spawn_pos
	specter.birth_lake = lake
	get_parent().add_child(specter)
	print("👻 Spawned specter from foggy lake")

# Handle signals from EventBus when items are dropped
func _on_item_dropped(item_data, world_position):
	# Check if this is a silver ingot
	if item_data.get("name") == "SilverIngot":
		print("Silver ingot detected at position: ", world_position)
		var result = check_silver_ingot_drop(world_position)
		if result:
			print("🌫️ Lake became foggy from silver ingot!")
		else:
			print("❌ Silver ingot not in a lake")
