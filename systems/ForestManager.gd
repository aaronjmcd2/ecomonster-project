# ForestManager.gd
# Manages forest detection and wisp spawning for tree scenes (not tiles)
extends Node

# Configuration parameters
@export var min_trees_for_forest: int = 8
@export var detection_interval: float = 30.0  # Seconds between forest detection
@export var spawn_interval: float = 15.0  # Seconds between wisp spawns
@export var max_wisps_per_forest: int = 3
@export var wisp_scene: PackedScene
@export var forest_radius: float = 500.0  # Radius to check for trees (in world units)

# Tracking variables
var detection_timer: float = 0.0
var forests = []  # Array of dictionaries with forest data

# === Core Functions ===
func _ready():
	# Initial forest detection
	_detect_forests()

func _process(delta: float):
	# Update detection timer
	detection_timer += delta
	if detection_timer >= detection_interval:
		_detect_forests()
		detection_timer = 0.0
	
	# Process forests
	_process_forests(delta)

# === Forest Detection ===
func _detect_forests():
	forests = []
	var tree_nodes = _find_all_trees()
	
	print("Found %d trees in the world" % tree_nodes.size())
	
	# Group trees into potential forests
	for tree in tree_nodes:
		# Skip if this tree is already part of a forest
		if _is_tree_in_forest(tree.global_position):
			continue
		
		# Find nearby trees
		var nearby_trees = _find_trees_in_radius(tree.global_position)
		
		if nearby_trees.size() >= min_trees_for_forest:
			# Create a new forest
			var forest_center = _calculate_forest_center(nearby_trees)
			var forest = {
				"center": forest_center,
				"trees": nearby_trees,
				"spawn_timer": spawn_interval,
				"wisps": []
			}
			forests.append(forest)
			
			print("Found forest with %d trees at %s" % [nearby_trees.size(), forest_center])

# Find all tree nodes in the world
func _find_all_trees() -> Array:
	return get_tree().get_nodes_in_group("trees")

# Check if a tree position is already part of a detected forest
func _is_tree_in_forest(tree_pos: Vector2) -> bool:
	for forest in forests:
		for tree in forest.trees:
			if tree.global_position.distance_to(tree_pos) < 50:  # Small threshold
				return true
	return false

# Find trees within radius of a point
func _find_trees_in_radius(center: Vector2) -> Array:
	var nearby_trees = []
	var all_trees = _find_all_trees()
	
	for tree in all_trees:
		if tree.global_position.distance_to(center) <= forest_radius:
			nearby_trees.append(tree)
	
	return nearby_trees

# Calculate the center position of a forest
func _calculate_forest_center(trees: Array) -> Vector2:
	var sum = Vector2.ZERO
	for tree in trees:
		sum += tree.global_position
	
	return sum / trees.size()

# === Wisp Spawning ===
func _process_forests(delta: float):
	for forest in forests:
		# Update spawn timer
		forest.spawn_timer -= delta
		
		# Clean up invalid wisps
		var valid_wisps = []
		for wisp in forest.wisps:
			if is_instance_valid(wisp):
				valid_wisps.append(wisp)
		forest.wisps = valid_wisps
		
		# Spawn wisp if timer expired and not at max capacity
		if forest.spawn_timer <= 0 and forest.wisps.size() < max_wisps_per_forest:
			_spawn_wisp(forest)
			forest.spawn_timer = spawn_interval

func _spawn_wisp(forest):
	# Choose a random tree in the forest
	var spawn_tree = forest.trees[randi() % forest.trees.size()]
	var spawn_pos = spawn_tree.global_position
	
	print("✨ Spawning wisp at tree position: %s" % spawn_pos)
	
	# Spawn the wisp
	var wisp = wisp_scene.instantiate()
	wisp.global_position = spawn_pos
	wisp.birth_forest = forest
	get_parent().add_child(wisp)
	
	# Add to forest's wisp list
	forest.wisps.append(wisp)
	
	print("✨ Spawned wisp from forest")
