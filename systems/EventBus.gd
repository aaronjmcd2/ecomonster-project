# EventBus.gd
# Global event system to handle communication between systems
extends Node

# Signal emitted when an item is dropped in the world
signal item_dropped(item_data, world_position)

# Signal emitted when a specter is spawned
signal specter_spawned(specter_node)

# Signal emitted when a lake becomes foggy
signal lake_became_foggy(lake_data)

# Signal emitted when a specter turns to crystal
signal specter_crystallized(crystal_node, specter_node)
