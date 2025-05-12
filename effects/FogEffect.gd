# FogEffect.gd
# Simple visual effect for foggy lakes
extends Node2D

var time_passed: float = 0.0
var sprites = []
var num_sprites = 20  # Increased number of sprites
var bounds = Vector2(200, 200)  # Size of the fog area

func _ready():
	z_index = 10  # Set a higher z_index to ensure it's drawn on top
	# Create several simple sprites to represent fog
	for i in range(num_sprites):
		var fog_sprite = Sprite2D.new()
		
		# Load the fog texture
		var texture = load("res://effects/simple_fog.png")
		if texture == null:
			print("ERROR: Could not load fog texture! Check path: res://effects/simple_fog.png")
			texture = Texture2D.new()  # Empty texture as fallback
		
		fog_sprite.texture = texture
		
		# Random position within bounds
		fog_sprite.position = Vector2(
			randf_range(-bounds.x/2, bounds.x/2),
			randf_range(-bounds.y/2, bounds.y/2)
		)
		
		# Random scale
		var scale_factor = randf_range(0.7, 2.0)  # Larger scales
		fog_sprite.scale = Vector2(scale_factor, scale_factor)
		
		# More visible appearance
		fog_sprite.modulate = Color(0.9, 0.95, 1.0, 0.6)  # Higher opacity
		
		add_child(fog_sprite)
		sprites.append(fog_sprite)
	
	print("🌫️ Created " + str(num_sprites) + " fog sprites at position " + str(global_position))

func _process(delta: float):
	time_passed += delta
	
	# Animate each fog sprite
	for i in range(sprites.size()):
		var sprite = sprites[i]
		
		# Slow drift
		sprite.position.x += sin(time_passed * 0.2 + i) * 0.5  # Increased movement
		sprite.position.y += cos(time_passed * 0.15 + i) * 0.4
		
		# Pulsing opacity
		sprite.modulate.a = 0.4 + sin(time_passed * 0.3 + i * 0.5) * 0.2  # Higher base opacity

# Method to set the bounds of the fog effect
func set_bounds(new_bounds: Vector2):
	bounds = new_bounds
	
	# Reposition existing sprites if needed
	for sprite in sprites:
		sprite.position = Vector2(
			randf_range(-bounds.x/2, bounds.x/2),
			randf_range(-bounds.y/2, bounds.y/2)
		)
	
	print("🌫️ Set fog bounds to " + str(new_bounds))
