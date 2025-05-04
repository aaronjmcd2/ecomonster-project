# DragonExcretionModule.gd
# Handles the excretion of ores from the Dragon
# Manages cooldown and choosing which type of ore to excrete

extends Node

func excrete_ore(dragon: Node) -> void:
	var drop_scene: PackedScene = null
	var drops_to_produce := 0

	match dragon.excretion_type:
		"lava":
			if dragon.lava_storage >= dragon.required_lava_to_excrete:
				drops_to_produce = dragon.lava_yield
				dragon.lava_storage -= dragon.required_lava_to_excrete
				drop_scene = dragon.ore_drop_scene
		"ice":
			if dragon.ice_storage >= dragon.required_ice_to_excrete and dragon.silver_drop_scene:
				drops_to_produce = dragon.ice_yield
				dragon.ice_storage -= dragon.required_ice_to_excrete
				drop_scene = dragon.silver_drop_scene
		"egg":
			if dragon.egg_storage >= dragon.required_eggs_to_excrete and dragon.gold_drop_scene:
				drops_to_produce = dragon.egg_yield
				dragon.egg_storage -= dragon.required_eggs_to_excrete
				drop_scene = dragon.gold_drop_scene

	# 🧾 Spawn actual drops
	if drop_scene:
		for i in drops_to_produce:
			var instance = drop_scene.instantiate()
			var offset = Vector2(randi_range(-8, 8), randi_range(-8, 8))
			instance.global_position = dragon.global_position + offset
			dragon.get_parent().add_child(instance)
			dragon.ore_this_second += 1

	# 🧠 Step 1: See if we can keep excreting the same type
	match dragon.excretion_type:
		"lava":
			if dragon.lava_storage >= dragon.required_lava_to_excrete:
				dragon.cooldown_timer = dragon.cooldown_time
				return
		"ice":
			if dragon.ice_storage >= dragon.required_ice_to_excrete:
				dragon.cooldown_timer = dragon.cooldown_time
				return
		"egg":
			if dragon.egg_storage >= dragon.required_eggs_to_excrete:
				dragon.cooldown_timer = dragon.cooldown_time
				return

	# 🧠 Step 2: Switch to something else if available
	if dragon.lava_storage >= dragon.required_lava_to_excrete:
		dragon.excretion_type = "lava"
		dragon.cooldown_timer = dragon.cooldown_time
		return
	elif dragon.ice_storage >= dragon.required_ice_to_excrete:
		dragon.excretion_type = "ice"
		dragon.cooldown_timer = dragon.cooldown_time
		return
	elif dragon.egg_storage >= dragon.required_eggs_to_excrete:
		dragon.excretion_type = "egg"
		dragon.cooldown_timer = dragon.cooldown_time
		return

	# 🧠 Step 3: Nothing left
	dragon.is_cooling_down = false
	dragon.cooldown_timer = 0.0
