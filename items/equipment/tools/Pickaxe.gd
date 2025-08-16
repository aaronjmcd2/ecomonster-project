# Pickaxe.gd
extends Node2D

@onready var anim := $AnimationPlayer
@onready var tile_map_layer: TileMapLayer = get_node("/root/Main/TileMap/TileMapLayer")

# Static hit tracking - persists across pickaxe instances
static var boulder_hits = {}  # boulder_id -> hit_count
static var coal_tile_hits = {}  # tile_position -> hit_count

# Flag to prevent multiple hits during a single swing
var has_hit_target = false

func _ready():
	$Hitbox.connect("body_entered", Callable(self, "_on_hitbox_body_entered"))
	$Hitbox.connect("area_entered", Callable(self, "_on_hitbox_area_entered"))
	$Hitbox.monitoring = false  # Start disabled
	
	# Set the hitbox to detect boulders and rocks
	if $Hitbox.has_method("set_collision_mask"):
		$Hitbox.set_collision_mask(1)  # Layer 1 for world objects

func swing():
	if anim.is_playing():
		anim.stop()
	
	has_hit_target = false  # Reset flag for this swing
	$Hitbox.monitoring = true  # Enable hit detection
	
	# Enable collision manually (don't rely on animation)
	$Hitbox/CollisionShape2D.disabled = false
	
	anim.play("swing")
	
	# Wait a brief moment for collision detection to register, then mine once
	await get_tree().create_timer(0.1).timeout
	
	if not has_hit_target:
		_find_and_mine_closest_target()
	
	# Keep collision enabled for the rest of the swing duration
	await get_tree().create_timer(0.3).timeout  # Wait for swing to finish
	
	queue_free()

func _on_hitbox_body_entered(body):
	# Only used for collision detection now - mining handled in swing()
	pass

func _on_hitbox_area_entered(area):
	# Only used for collision detection now - mining handled in swing()
	pass

func _break_boulder(boulder):
	# Get unique identifier for this boulder
	var boulder_id = boulder.get_instance_id()
	
	# Track hits on this boulder
	if not boulder_hits.has(boulder_id):
		boulder_hits[boulder_id] = 0
	
	boulder_hits[boulder_id] += 1
	var current_hits = boulder_hits[boulder_id]
	
	var progress_bar = _create_progress_bar(current_hits, 10)
	print("🪨 Boulder %s (%d/10)" % [progress_bar, current_hits])
	
	# Only break boulder after 10 hits
	if current_hits >= 10:
		# Get reference to Main scene for spawning stones
		var main_scene = Engine.get_main_loop().get_root().get_node_or_null("Main")
		if main_scene == null:
			print("❌ Main scene not found. Cannot spawn stones.")
			return
		
		# Spawn 2-4 stones at the boulder's position
		var stone_scene = preload("res://items/drops/resources/Stone.tscn")
		var num_stones = randi_range(2, 4)
		
		for i in num_stones:
			var stone_instance = stone_scene.instantiate()
			# Scatter stones around the boulder position
			var offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
			stone_instance.position = boulder.global_position + offset
			main_scene.add_child(stone_instance)
		
		print("🪨 Boulder destroyed! Spawned %d stones" % num_stones)
		
		# Clean up hit tracking for this boulder
		boulder_hits.erase(boulder_id)
		
		# Remove the boulder
		boulder.queue_free()

func _find_and_mine_closest_target():
	var closest_target = null
	var closest_distance = INF
	var target_type = ""
	
	# Check for boulders in hitbox range
	var hitbox = $Hitbox
	var bodies = hitbox.get_overlapping_bodies()
	var areas = hitbox.get_overlapping_areas()
	
	# Check boulders in bodies
	for body in bodies:
		if body.is_in_group("boulders") and body.name != "Player":
			var distance = global_position.distance_to(body.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_target = body
				target_type = "boulder"
	
	# Check boulders in areas
	for area in areas:
		if area.is_in_group("boulders") and area.name != "Player":
			var distance = global_position.distance_to(area.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_target = area
				target_type = "boulder"
	
	# Check for coal tiles (reduced range - only the tile we're directly on)
	if not tile_map_layer:
		print("❌ TileMapLayer not found. Cannot check for coal tiles.")
	else:
		var main_scene = Engine.get_main_loop().get_root().get_node_or_null("Main")
		if main_scene:
			var pickaxe_pos = global_position
			var tile_pos = tile_map_layer.local_to_map(pickaxe_pos)
			
			# Only check the exact tile we're on (much tighter range)
			var source_id = tile_map_layer.get_cell_source_id(tile_pos)
			if source_id == 0:  # Coal tile has source_id = 0
				var tile_world_pos = tile_map_layer.map_to_local(tile_pos)
				var distance = global_position.distance_to(tile_world_pos)
				if distance < closest_distance:
					closest_distance = distance
					closest_target = tile_pos
					target_type = "coal"
	
	# Mine the closest target found
	if closest_target != null and not has_hit_target:
		has_hit_target = true  # Prevent multiple hits this swing
		if target_type == "boulder":
			_break_boulder(closest_target)
		elif target_type == "coal":
			var main_scene = Engine.get_main_loop().get_root().get_node_or_null("Main")
			if main_scene:
				_mine_coal_tile(closest_target, main_scene)

func _mine_coal_tile(tile_pos: Vector2i, main_scene: Node):
	# Track hits on this coal tile position
	var tile_key = str(tile_pos.x) + "," + str(tile_pos.y)
	
	if not coal_tile_hits.has(tile_key):
		coal_tile_hits[tile_key] = 0
	
	coal_tile_hits[tile_key] += 1
	var current_hits = coal_tile_hits[tile_key]
	
	var progress_bar = _create_progress_bar(current_hits, 5)
	print("⛏️ Coal %s (%d/5) at %s" % [progress_bar, current_hits, tile_pos])
	
	# Only mine coal after 5 hits
	if current_hits >= 5:
		# Convert the coal tile to soil (mined out)
		tile_map_layer.set_cell(tile_pos, 3, Vector2i(0, 0))  # 3 = Soil
		
		# Spawn 1-3 coal drops at the tile position
		var coal_scene = preload("res://items/drops/ores/CoalDrop.tscn")
		var num_coal = randi_range(1, 3)
		
		for i in num_coal:
			var coal_instance = coal_scene.instantiate()
			# Convert tile position back to world position and add some scatter
			var world_pos = tile_map_layer.map_to_local(tile_pos)
			var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
			coal_instance.position = world_pos + offset
			main_scene.add_child(coal_instance)
		
		print("⛏️ Coal tile mined! Spawned %d coal drops at %s" % [num_coal, tile_pos])
		
		# Clean up hit tracking for this tile
		coal_tile_hits.erase(tile_key)

func _create_progress_bar(current: int, max_value: int) -> String:
	var bar_length = 10
	var filled = int(float(current) / float(max_value) * bar_length)
	var empty = bar_length - filled
	
	var bar = ""
	for i in filled:
		bar += "█"
	for i in empty:
		bar += "░"
	
	return "[" + bar + "]"