#!/usr/bin/env gdscript
extends Area2D

# Joystick visual components
export_var(Texture2D, base_texture) = null
export_var(Texture2D, stick_texture) = null

# Joystick state
var is_dragging: bool = false
var stick_position: Vector2 = Vector2.ZERO
var dead_zone: float = 40.0

# Size constants
var base_size: float = 120.0
var stick_size: float = 50.0

# Reference to player for direct control
@onready var player_ref: Player = null

# Signals
signal joystick_moved(direction: Vector2)

func _ready():
    # Set up drag detection
    Mouse.button_pressed.connect(_on_mouse_pressed)
    Mouse.button_released.connect(_on_mouse_released)
    Mouse.mouse_motion.connect(_on_mouse_motion)
    
    # Set position - bottom left of screen
    var viewport_size = get_viewport().get_visible_rect().size
    position = Vector2(30, viewport_size.y - 30 - base_size / 2)
    
    # Make sure it's above other UI but below game
    z_index = 100
    
    # Try to find player reference
    if player_ref == null:
        var parent = get_parent()
        if parent:
            player_ref = parent.find_player()
    
    print("Joystick ready at: ", position)

func find_player() -> Player:
    # Search for Player script in siblings
    var parent = get_parent()
    if parent:
        var children = parent.get_children()
        for child in children:
            if child is Player:
                return child as Player
    return null

func _on_mouse_pressed(button: int):
    if button == MOUSE_BUTTON_LEFT:
        is_dragging = true

func _on_mouse_released(button: int):
    if button == MOUSE_BUTTON_LEFT:
        is_dragging = false
        stick_position = Vector2.ZERO
        update_stick_position()

func _on_mouse_motion(position: Vector2):
    if is_dragging:
        var viewport_size = get_viewport().get_visible_rect().size
        var rel_pos = position - self.position - Vector2(base_size / 2, base_size / 2)
        
        # Clamp to base area
        var clamped = rel_pos.clamped(base_size / 2 - stick_size / 2)
        stick_position = clamped
        
        # Update visual
        update_stick_position()

func update_stick_position():
    # Get normalized direction (-1 to 1)
    var x = stick_position.x / (base_size / 2 - stick_size / 2)
    var y = stick_position.y / (base_size / 2 - stick_size / 2)
    
    # Apply dead zone
    if abs(x) < dead_zone / (base_size / 2 - stick_size / 2):
        x = 0
    if abs(y) < dead_zone / (base_size / 2 - stick_size / 2):
        y = 0
    
    # Clamp values
    x = clamp(x, -1, 1)
    y = clamp(y, -1, 1)
    
    # Emit signal with direction
    emit_signal("joystick_moved", Vector2(x, y))

# Convenience function for finding player
func set_player_ref(player: Player):
    player_ref = player