#!/usr/bin/env gdscript
extends Area2D

# Player movement settings
export_var(float, speed) = 150.0
export_var(bool, can_move) = true

# Reference to sprite
@onready var sprite: Sprite2D = $Sprite2D

# Animation state
var current_animation: StringName = "down"
var last_move_dir: Vector2 = Vector2.ZERO

# Detection area for interactions
@onready var interact_area: CollisionArea2D = $InteractionArea

func _ready():
    sprite = get_parent().get_node("Sprite2D") if has_parent() else get_node("Sprite2D")
    setup_animations()
    position = Vector2(100, 100)
    interact_area.position = Vector2(0, 40)
    
    # Connect input actions
    Input.map_action("ui_up")
    Input.map_action("ui_down")
    Input.map_action("ui_left")
    Input.map_action("ui_right")
    Input.map_action("interact")

func setup_animations():
    # Create animation player if not present
    var anim_player = get_node_or_null("AnimationPlayer")
    if anim_player == null:
        anim_player = AnimationPlayer.new()
        add_child(anim_player)
    
    # Down animation
    anim_player.add_animation("down")
    var down_frames = []
    for i in range(4):
        var frame = AnimatedSprite2D.FrameData.create()
        frame.frame = Rect2(i * 32, 0, 32, 32)
        down_frames.append(frame)
    anim_player.set_animation_frames("down", down_frames)
    anim_player.animation_player_play("down")
    
    # Up animation
    anim_player.add_animation("up")
    var up_frames = []
    for i in range(4):
        var frame = AnimatedSprite2D.FrameData.create()
        frame.frame = Rect2(i * 32, 32, 32, 32)
        up_frames.append(frame)
    anim_player.set_animation_frames("up", up_frames)
    
    # Left animation
    anim_player.add_animation("left")
    var left_frames = []
    for i in range(4):
        var frame = AnimatedSprite2D.FrameData.create()
        frame.frame = Rect2(i * 32, 64, 32, 32)
        left_frames.append(frame)
    anim_player.set_animation_frames("left", left_frames)
    
    # Right animation
    anim_player.add_animation("right")
    var right_frames = []
    for i in range(4):
        var frame = AnimatedSprite2D.FrameData.create()
        frame.frame = Rect2(i * 32, 96, 32, 32)
        right_frames.append(frame)
    anim_player.set_animation_frames("right", right_frames)
    
    # Idle animations
    anim_player.add_animation("idle_down")
    anim_player.set_animation_frames("idle_down", down_frames)
    anim_player.animation_player_play("idle_down")
    
    anim_player.add_animation("idle_up")
    anim_player.set_animation_frames("idle_up", up_frames)
    
    anim_player.add_animation("idle_left")
    anim_player.set_animation_frames("idle_left", left_frames)
    
    anim_player.add_animation("idle_right")
    anim_player.set_animation_frames("idle_right", right_frames)

func get_next_position(direction: Vector2) -> Vector2:
    var velocity = direction * speed
    var new_pos = position + velocity * get_process_delta_time()
    return new_pos

func can_move_to(position: Vector2) -> bool:
    # Placeholder for collision checking
    # Will be expanded with tilemap collision
    return true

func _physics_process(delta):
    if not can_move:
        return
    
    var direction = Vector2.ZERO
    
    # Get input direction
    if Input.is_action_pressed("ui_right"):
        direction.x += 1
    if Input.is_action_pressed("ui_left"):
        direction.x -= 1
    if Input.is_action_pressed("ui_down"):
        direction.y += 1
    if Input.is_action_pressed("ui_up"):
        direction.y -= 1
    
    # Normalize diagonal movement
    if direction.length() > 0:
        direction = direction.normalized()
    
    var next_pos = get_next_position(direction)
    
    if can_move_to(next_pos):
        position = next_pos
        last_move_dir = direction
        update_animation()
    
    # Interact action
    if Input.is_action_just_pressed("interact") and direction.length() == 0:
        interact()

func update_animation():
    var anim_name: StringName
    
    if direction.length() > 0:
        # Moving
        if abs(direction.x) > abs(direction.y):
            # Horizontal movement
            if direction.x > 0:
                anim_name = StringName("right")
            else:
                anim_name = StringName("left")
        else:
            # Vertical movement
            if direction.y > 0:
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
    
    if anim_player.has_animation(anim_name):
        anim_player.animation_player_play(anim_name)
    elif anim_player.has_animation("idle_" + anim_name.rollback(5)):
        anim_player.animation_player_play("idle_" + anim_name.rollback(5))

func interact():
    print("Interacting with object...")
    # Emit signal or check for interactable objects
    get_parent().call_deferred("interact_with", self)
EOF