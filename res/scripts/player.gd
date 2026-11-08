#!/usr/bin/env gdscript
extends CharacterBody2D

# Player movement settings
export_var(float, speed) = 200.0
export_var(int, z_index) = 1

# Reference to sprite (set in scene)
@onready var sprite: Sprite2D = null

# Animation state
var current_animation: StringName = "down"
var last_move_dir: Vector2 = Vector2.ZERO

# Detection area for interactions (local, not relying on @onready from parent)
@onready var interact_area: Area2D = null

# Mob control - joystick reference set externally
var joystick: Joystick = null

# Interaction signal
signal interacted_with(node: Node)

func _ready():
    # Set up physics process
    process_input = true
    process_physics = true
    
    # Initialize sprite if not set
    if sprite == null:
        sprite = Sprite2D.new()
        sprite.z_index = z_index
        add_child(sprite)
    
    # Set up collision shape
    var collision_shape = CollisionShape2D.new()
    collision_shape.shape = RectangleShape2D.new(Vector2(0, 0), Vector2(32, 32))
    collision_shape.path = "CollisionShape2D"
    add_child(collision_shape)
    
    # Set up interaction area
    interact_area = Area2D.new()
    interact_area.name = "InteractionArea"
    interact_area.position = Vector2(0, 40)
    add_child(interact_area)
    
    # Set up animation player
    var anim_player = AnimationPlayer.new()
    add_child(anim_player)
    
    # Load default animations
    load_animations(anim_player)
    
    # Set starting position
    position = Vector2(150, 150)
    
    # Process joystick if available
    if joystick:
        joystick.joystick_moved.connect(_on_joystick_moved)
    
    print("Player ready at position: ", position)

func load_animations(anim_player: AnimationPlayer):
    # Define frame rectangles for 32x32 sprite sheet
    var frame_size = Vector2(32, 32)
    
    # Down animation (4 frames)
    var down_frames = []
    for i in range(4):
        var frame = AnimatedSprite2D.FrameData.create()
        frame.frame = Rect2(i * 32, 0, 32, 32)
        down_frames.append(frame)
    anim_player.add_animation("down", down_frames)
    
    # Up animation
    var up_frames = []
    for i in range(4):
        var frame = AnimatedSprite2D.FrameData.create()
        frame.frame = Rect2(i * 32, 32, 32, 32)
        up_frames.append(frame)
    anim_player.add_animation("up", up_frames)
    
    # Left animation
    var left_frames = []
    for i in range(4):
        var frame = AnimatedSprite2D.FrameData.create()
        frame.frame = Rect2(i * 32, 64, 32, 32)
        left_frames.append(frame)
    anim_player.add_animation("left", left_frames)
    
    # Right animation
    var right_frames = []
    for i in range(4):
        var frame = AnimatedSprite2D.FrameData.create()
        frame.frame = Rect2(i * 32, 96, 32, 32)
        right_frames.append(frame)
    anim_player.add_animation("right", right_frames)
    
    # Idle animations
    anim_player.add_animation("idle_down", down_frames)
    anim_player.add_animation("idle_up", up_frames)
    anim_player.add_animation("idle_left", left_frames)
    anim_player.add_animation("idle_right", right_frames)

func _physics_process(delta):
    var direction = Vector2.ZERO
    
    # Get input direction - keyboard
    if Input.is_action_pressed("ui_right"):
        direction.x += 1
    if Input.is_action_pressed("ui_left"):
        direction.x -= 1
    if Input.is_action_pressed("ui_down"):
        direction.y += 1
    if Input.is_action_pressed("ui_up"):
        direction.y -= 1
    
    # Get input direction - joystick (mobile)
    if joystick and joystick.get_vector() != Vector2.ZERO:
        direction = joystick.get_vector()
    
    # Normalize diagonal movement
    if direction.length() > 0:
        direction = direction.normalized()
    
    var next_pos = position + direction * speed * delta
    
    # Check collision with map boundaries
    if is_position_valid(next_pos):
        position = next_pos
    else:
        # Try moving only on X axis
        var move_x = Vector2(direction.x * speed * delta, 0)
        if is_position_valid(position + move_x):
            position.x += direction.x * speed * delta
        
        # Try moving only on Y axis
        var move_y = Vector2(0, direction.y * speed * delta)
        if is_position_valid(position + move_y):
            position.y += direction.y * speed * delta
    
    last_move_dir = direction
    update_animation()
    
    # Interact action
    if Input.is_action_just_pressed("interact") and direction.length() == 0:
        interact()

func is_position_valid(pos: Vector2) -> bool:
    # Check screen bounds - keep player within visible area with margin
    var screen_size = get_viewport().get_visible_rect().size
    var margin = 50
    return pos.x >= -margin and pos.x <= screen_size.x + margin and
           pos.y >= -margin and pos.y <= screen_size.y + margin

func update_animation():
    var anim_name: StringName
    
    if last_move_dir.length() > 0:
        # Moving - determine direction
        if abs(last_move_dir.x) > abs(last_move_dir.y):
            # Horizontal movement
            if last_move_dir.x > 0:
                anim_name = StringName("right")
            else:
                anim_name = StringName("left")
        else:
            # Vertical movement
            if last_move_dir.y > 0:
                anim_name = StringName("down")
            else:
                anim_name = StringName("up")
    else:
        # Idle - use last move direction
        if last_move_dir.x > 0:
            anim_name = StringName("idle_right")
        elif last_move_dir.x < 0:
            anim_name = StringName("idle_left")
        elif last_move_dir.y > 0:
            anim_name = StringName("idle_down")
        else:
            anim_name = StringName("idle_up")
    
    if anim_player && anim_player.has_animation(anim_name):
        anim_player.animation_player_play(anim_name)

func interact():
    # Emit signal with self as argument
    emit_signal("interacted_with", self)
    print("Interacting at position: ", position)

# Convenience function for external joystick control
func set_joystick(joy: Joystick):
    joystick = joy
    if joy:
        joy.joystick_moved.connect(_on_joystick_moved)

func _on_joystick_moved(direction: Vector2):
    # This is called from the joystick signal
    # Store the direction for use in _physics_process
    # The actual movement is handled in _physics_process
    pass