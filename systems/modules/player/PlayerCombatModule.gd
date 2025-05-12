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
	if selected_item and selected_item.has("type") and selected_item.type == "weapon":
		print("🗡️ Swinging weapon: %s" % selected_item.name)
		var use_scene = selected_item.get("use_scene", null)

		if use_scene:
			print("🗡️ Use scene found, instantiating")
			if player.has_node("EquippedSword"):
				player.get_node("EquippedSword").queue_free()

			var sword = use_scene.instantiate()
			sword.name = "EquippedSword"
			player.add_child(sword)

			var dir := facing_direction.normalized()
			var offset := Vector2.ZERO

			# Adjust sword position and rotation based on direction
			# INCREASED OFFSETS for better reach
			if dir.x > 0:
				sword.rotation_degrees = 45
				offset = Vector2(64, 8)  # Increased from 16 to 64
			elif dir.x < 0:
				sword.rotation_degrees = 225
				offset = Vector2(-64, 8)  # Increased from -16 to -64
			elif dir.y < 0:
				sword.rotation_degrees = 315
				offset = Vector2(0, -64)  # Increased from -16 to -64
			elif dir.y > 0:
				sword.rotation_degrees = 135
				offset = Vector2(0, 64)  # Increased from 16 to 64
			else:
				# Default if no direction
				sword.rotation_degrees = 45
				offset = Vector2(64, 8)  # Increased

			sword.position = offset
			print("🗡️ Sword positioned at: " + str(offset) + " with rotation: " + str(sword.rotation_degrees))

			if sword.has_method("swing"):
				sword.swing()
				print("🗡️ Sword swing initiated")
