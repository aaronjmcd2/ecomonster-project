# PlayerCombatModule.gd
# Handles weapon usage and equipping for the player.

extends Node

var player: Node2D = null
var inventory_ui: Node = null

func setup(p, ui):
	player = p
	inventory_ui = ui

func use_weapon(facing_direction: Vector2):
	var selected_item = inventory_ui.get_selected_hotbar_item()
	if selected_item and selected_item.has("type") and (selected_item.type == "weapon" or selected_item.type == "tool"):
		var tool_name = "⛏️" if selected_item.type == "tool" else "🗡️"
		print("%s Swinging %s: %s" % [tool_name, selected_item.type, selected_item.name])
		var use_scene = selected_item.get("scene", null)

		if use_scene:
			print("%s Use scene found, instantiating" % tool_name)
			if player.has_node("EquippedTool"):
				player.get_node("EquippedTool").queue_free()

			var tool = use_scene.instantiate()
			tool.name = "EquippedTool"
			player.add_child(tool)

			var dir := facing_direction.normalized()
			var offset := Vector2.ZERO

			# Adjust tool position and rotation based on direction
			# INCREASED OFFSETS for better reach
			if dir.x > 0:
				tool.rotation_degrees = 45
				offset = Vector2(64, 8)  # Increased from 16 to 64
			elif dir.x < 0:
				tool.rotation_degrees = 225
				offset = Vector2(-64, 8)  # Increased from -16 to -64
			elif dir.y < 0:
				tool.rotation_degrees = 315
				offset = Vector2(0, -64)  # Increased from -16 to -64
			elif dir.y > 0:
				tool.rotation_degrees = 135
				offset = Vector2(0, 64)  # Increased from 16 to 64
			else:
				# Default if no direction
				tool.rotation_degrees = 45
				offset = Vector2(64, 8)  # Increased

			tool.position = offset
			print("%s Tool positioned at: %s with rotation: %s" % [tool_name, str(offset), str(tool.rotation_degrees)])

			if tool.has_method("swing"):
				tool.swing()
				print("%s Tool swing initiated" % tool_name)
