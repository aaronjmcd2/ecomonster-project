# Sword.gd
extends Node2D

@onready var anim := $AnimationPlayer

func _ready():
	$Hitbox.connect("body_entered", Callable(self, "_on_hitbox_body_entered"))
	$Hitbox.monitoring = false  # Start disabled
	
	# Set the hitbox to detect monsters on collision layer 2
	# Make sure this matches your Specter's collision layer
	if $Hitbox.has_method("set_collision_mask_value"):
		$Hitbox.set_collision_mask_value(2, true)
	
	# Let's force the sword to detect on layers 1, 2, and 3 just to be safe
	if $Hitbox.has_method("set_collision_mask"):
		$Hitbox.set_collision_mask(7)  # Binary 111 = Layers 1, 2, and 3

func swing():
	if anim.is_playing():
		anim.stop()
	$Hitbox.monitoring = true  # Enable hit detection
	anim.play("swing")
	await anim.animation_finished
	queue_free()

func _on_hitbox_body_entered(body):
	print("🗡️ Sword hit body: " + body.name)
	print("🗡️ Body collision layer: " + str(body.collision_layer))
	
	# Skip if the body is the player
	if body.name == "Player":
		print("🗡️ Ignoring hit on player")
		return
	
	# Check for monsters group
	if body.is_in_group("monsters"):
		print("🩸 Hit monster:", body.name)
		
		if body.has_method("take_damage"):
			body.take_damage(1)
			print("🩸 Applied damage to " + body.name)
	else:
		print("🗡️ Hit non-monster body: " + body.name)
