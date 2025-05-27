# SpiderConversionModule.gd
# Handles resource conversion for the Spider

extends Node

# Convert the consumed resource into silk
func convert_resource(spider: Node, target_data: Dictionary) -> void:
	print("🕷️ Converting resource: ", target_data.resource_type)
	
	var drop_scene: PackedScene = null
	var silk_type = ""
	
	match target_data.resource_type:
		"tempered_glass":
			drop_scene = spider.glass_silk_scene
			silk_type = "Glass Silk"
			
		"soul":
			drop_scene = spider.soul_silk_scene
			silk_type = "Soul Silk"
	
	# Spawn the silk drop
	if drop_scene:
		var silk = drop_scene.instantiate()
		var offset = Vector2(randi_range(-16, 16), randi_range(-16, 16))
		silk.global_position = spider.global_position + offset
		spider.get_parent().add_child(silk)
		spider.silk_stat.add(1)
		print("🕸️ Spider produced: ", silk_type)
	else:
		print("❌ No drop scene found for resource type: ", target_data.resource_type)
