# GlassDragonExcretionModule.gd
# Handles the excretion of glass from the Glass Dragon
# Manages cooldown and choosing which type of glass to excrete

extends Node

func excrete_glass(dragon: Node) -> void:
	var drop_scene: PackedScene = null
	var drops_to_produce := 0

	# Check if we have enough resources to produce glass
	if dragon.lava_storage >= dragon.required_lava_to_excrete and dragon.ice_storage >= dragon.required_ice_to_excrete:
		# Determine what type of glass to produce
		if dragon.lava_storage > dragon.ice_storage and dragon.tempered_glass_drop_scene:
			# More lava than ice = tempered glass (stronger)
			drop_scene = dragon.tempered_glass_drop_scene
		else:
			# Otherwise regular glass
			drop_scene = dragon.glass_drop_scene
			
		drops_to_produce = dragon.glass_yield
		
		# Consume the resources
		dragon.lava_storage -= dragon.required_lava_to_excrete
		dragon.ice_storage -= dragon.required_ice_to_excrete
	
	# Spawn actual glass drops
	if drop_scene and drops_to_produce > 0:
		print("Spawning glass drops: ", drops_to_produce)
		for i in drops_to_produce:
			var instance = drop_scene.instantiate()
			var offset = Vector2(randi_range(-8, 8), randi_range(-8, 8))
			instance.global_position = dragon.global_position + offset
			dragon.get_parent().add_child(instance)
			dragon.glass_this_second += 1

	# Check if we can continue producing glass
	if dragon.lava_storage >= dragon.required_lava_to_excrete and dragon.ice_storage >= dragon.required_ice_to_excrete:
		# We can keep producing, reset cooldown
		print("Glass Dragon can produce more, resetting cooldown")
		dragon.cooldown_timer = dragon.cooldown_time
		dragon.is_cooling_down = true
	else:
		# We don't have enough resources, stop cooling down
		print("Glass Dragon doesn't have enough resources, stopping cooldown")
		dragon.is_cooling_down = false
		dragon.cooldown_timer = 0.0
