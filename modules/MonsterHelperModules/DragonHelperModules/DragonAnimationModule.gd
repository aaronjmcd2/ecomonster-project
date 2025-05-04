# DragonAnimationModule.gd
# Handles Dragon animation states and transitions
# Currently simple but can be expanded for more complex animations

extends Node

# Initialize animations
func initialize(dragon: Node) -> void:
	if dragon.anim_sprite:
		dragon.anim_sprite.play("idle_down")

# Update animation based on movement and state
func update_animation(dragon: Node) -> void:
	if dragon.velocity.length() > 0:
		# Dragon is moving
		if dragon.velocity.y > 0:  # Moving down
			dragon.anim_sprite.play("idle_down")  # Use idle for now, can be replaced with walk_down when available
		elif dragon.velocity.y < 0:  # Moving up
			dragon.anim_sprite.play("idle_down")  # Replace with walk_up when available
		elif dragon.velocity.x > 0:  # Moving right
			dragon.anim_sprite.play("idle_down")  # Replace with walk_right when available
		elif dragon.velocity.x < 0:  # Moving left
			dragon.anim_sprite.play("idle_down")  # Replace with walk_left when available
	else:
		# Dragon is idle
		dragon.anim_sprite.play("idle_down")  # Default idle state

# Play specific animation
func play_animation(dragon: Node, anim_name: String) -> void:
	if dragon.anim_sprite:
		# Check if the animation exists in the sprite frames
		var sprite_frames = dragon.anim_sprite.sprite_frames
		if sprite_frames and sprite_frames.has_animation(anim_name):
			dragon.anim_sprite.play(anim_name)

# Play excretion animation
func play_excretion_animation(dragon: Node) -> void:
	# This can be expanded when more animations are available
	# For now, just use the idle animation
	play_animation(dragon, "idle_down")
