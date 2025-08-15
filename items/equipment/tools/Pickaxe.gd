# Pickaxe.gd
extends Node2D

@onready var anim := $AnimationPlayer

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
	$Hitbox.monitoring = true  # Enable hit detection
	
	# Enable collision manually (don't rely on animation)
	$Hitbox/CollisionShape2D.disabled = false
	
	anim.play("swing")
	
	# Keep collision enabled for the entire swing duration
	await get_tree().create_timer(0.4).timeout  # Wait for swing to finish
	
	queue_free()

func _on_hitbox_body_entered(body):
	# Skip if the body is the player
	if body.name == "Player":
		return
	
	# Check for boulders group
	if body.is_in_group("boulders"):
		_break_boulder(body)

func _on_hitbox_area_entered(area):
	# Skip if the area is the player
	if area.name == "Player":
		return
	
	# Check for boulders group
	if area.is_in_group("boulders"):
		_break_boulder(area)

func _break_boulder(boulder):
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
	
	
	# Remove the boulder
	boulder.queue_free()