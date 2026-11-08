#!/usr/bin/env gdscript
extends Camera2D

# Camera settings
export_var(float, follow_speed) = 5.0
export_var(Vector2, offset) = Vector2(0, -50)
export_var(int, min_zoom) = 1
export_var(int, max_zoom) = 4

# Target to follow (set automatically)
@onready var target: Node2D = null

# Internal state
var current_zoom: float = 2.0
var init_done: bool = false

func _ready():
    # Set up initial zoom
    zoom = Vector2(current_zoom, current_zoom)
    current_zoom = zoom.x
    
    # Try to find player target if not set manually
    if target == null:
        # Search for Player node in the scene tree
        var root = get_tree().root
        target = root.find_player() if root else null
    
    if target:
        print("Camera targeting: ", target.name)
    else:
        print("WARNING: Camera target not found - player may not be in scene yet")

func _process(delta):
    if target == null:
        # Try to find target if not set
        if not init_done:
            var root = get_tree().root
            target = root.find_player() if root else null
            init_done = true
        if target == null:
            return
    
    # Calculate desired position with offset
    var target_pos = target.global_position + offset
    
    # Smoothly follow the target using lerp
    global_position = lerp(global_position, target_pos, follow_speed * delta)
    
    # Keep camera within map bounds
    clamp_to_map_bounds()

func clamp_to_map_bounds():
    # Get viewport size
    var viewport_size = get_viewport().get_visible_rect().size
    var half_width = viewport_size.x / 2
    var half_height = viewport_size.y / 2
    
    # Use map size from the Map node if available
    var map_node = get_node("/root/Map") if get_tree().has_node("/root/Map") else null
    var map_size = Vector2(4000, 3000) # Default large map size
    if map_node:
        map_size = map_node.map_size * map_node.tile_size
    
    # Clamp camera position so player can't move outside visible area
    global_position.x = clamp(global_position.x, half_width, map_size.x - half_width)
    global_position.y = clamp(global_position.y, half_height, map_size.y - half_height)

# Static helper to find player node from root
static func find_player_from_root() -> Node2D:
    var root = get_tree().root
    if root:
        var children = root.get_children()
        for child in children:
            if child is CharacterBody2D and child.name == "Player":
                return child
    return null