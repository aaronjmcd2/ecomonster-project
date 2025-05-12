# FogEffect.gd
# Simple visual effect for foggy lakes
extends Node2D

var time_passed: float = 0.0
var sprites = []
var num_sprites = 10  # Adjust based on desired density

# You can change this from the LakeManager
var bounds = Vector2(200, 200)  # Size of the fog area

func _ready():
	# Create several simple sprites to represent fog
	for i in range(num_sprites):
		var fog_sprite = Sprite2D.new()
		
		# Load the fog texture
		var texture = load("res://effects/simple_fog.png")
		fog_sprite.texture = texture
		
		# Random position within bounds
		fog_sprite.position = Vector2(
			randf_range(-bounds.x/2, bounds.x/2),
			randf_range(-bounds.y/2, bounds.y/2)
		)
		
		# Random scale
		var scale_factor = randf_range(0.5, 1.5)
		fog_sprite.scale = Vector2(scale_factor, scale_factor)
		
		# Ghostly appearance
		fog_sprite.modulate = Color(0.9, 0.95, 1.0, 0.3)
		
		add_child(fog_sprite)
		sprites.append(fog_sprite)

func _process(delta: float):
	time_passed += delta
	
	# Animate each fog sprite
	for i in range(sprites.size()):
		var sprite = sprites[i]
		
		# Slow drift
		sprite.position.x += sin(time_passed * 0.2 + i) * 0.3
		sprite.position.y += cos(time_passed * 0.15 + i) * 0.2
		
		# Pulsing opacity
		sprite.modulate.a = 0.2 + sin(time_passed * 0.3 + i * 0.5) * 0.1

# Method to set the bounds of the fog effect
func set_bounds(new_bounds: Vector2):
	bounds = new_bounds
	
	# Reposition existing sprites if needed
	for sprite in sprites:
		sprite.position = Vector2(
			randf_range(-bounds.x/2, bounds.x/2),
			randf_range(-bounds.y/2, bounds.y/2)
		)
