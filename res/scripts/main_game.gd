extends Node2D

# Game configuration
export var string game_title = "BLACK VEIL"
export var int start_level = 1

# Game nodes
@onready var player: Player = null
@onready var map: TileMap = null
@onready var camera: Camera2D = null
@onready var joystick: Joystick = null

func _ready():
    # Initialize game systems
    print("=" * 40)
    print("BLACK VEIL - Initializing...")
    print("=" * 40)
    
    # Find and reference key nodes
    player = get_node("/root/Player") as Player
    map = get_node("/root/Map") as TileMap
    camera = get_node("/root/Camera") as Camera2D
    joystick = get_node("/root/Joystick") as Joystick
    
    # Set up camera tracking
    if camera and player:
        camera.target = player
    
    # Connect joystick to player
    if joystick and player:
        joystick.joystick_moved.connect(_on_joystick_moved)
    
    # Initialize player at starting position
    if player:
        player.start_position = Vector2(200, 200)
        player.position = player.start_position
    
    # Set up input actions for mobile
    setup_mobile_input()
    
    print("Game systems initialized")
    print("Player position: ", player.position if player else "N/A")
    print("Map size: ", map.map_size if map else "N/A")
    print("")

func setup_mobile_input():
    # Register mobile input actions
    Input.map_action("ui_up", [Input.KEY_W, Input.GAMEPAD_DP_UP])
    Input.map_action("ui_down", [Input.KEY_S, Input.GAMEPAD_DP_DOWN])
    Input.map_action("ui_left", [Input.KEY_A, Input.GAMEPAD_DP_LEFT])
    Input.map_action("ui_right", [Input.KEY_D, Input.GAMEPAD_DP_RIGHT])
    Input.map_action("interact", [Input.KEY_E, Input.GAMEPAD_BUTTON_A])

func _process(delta):
    # Update game state
    pass

func _input(event):
    # Handle input events
    pass