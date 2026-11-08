#!/usr/bin/env gdscript
extends Node

# This script sets up the complete BLACK VEIL project structure
# Run it once to initialize the project scenes and architecture
# All scenes are created programmatically to avoid .tscn parsing issues

func _ready():
    print("=" * 50)
    print("BLACK VEIL - Project Setup Initialization")
    print("=" * 50)
    
    # Wait a frame then set up scenes
    call_deferred("_setup_scenes")
    
func _setup_scenes():
    print("\nSetting up game scenes...")
    
    # 1. Create MainMenu scene (programmatically)
    print("  - Setting up Main Menu...")
    setup_main_menu()
    
    # 2. Create MainRoot game scene
    print("  - Setting up Game Root...")
    setup_game_root()
    
    # 3. Initialize game systems
    print("  - Initializing game systems...")
    init_game_systems()
    
    print("\nBLACK VEIL project setup complete!")
    print("The game is ready. Use the Main Menu to start.")
    
func setup_main_menu():
    # Create main menu scene elements through code
    var menu = Control.new()
    menu.name = "MainMenu"
    menu.size = Vector2(384, 216)
    menu.position = Vector2(0, 0)
    menu.z_index = 1000 # Render on top
    
    # Background
    var bg = ColorRect.new()
    bg.name = "Background"
    bg.rect_size = menu.size
    bg.color = Color(0.1, 0.1, 0.15, 1)
    menu.add_child(bg)
    
    # Title
    var title = RichTextLabel.new()
    title.name = "TitleLabel"
    title.text = "[center][size=64]BLACK VEIL[/size][/center]"
    title.overflow_mode = RichTextLabel.OVERMODE_WORD_WRAP
    title.position = Vector2(0, 60)
    title.scale = Vector2(1, 1)
    menu.add_child(title)
    
    # Start button
    var start_btn = Button.new()
    start_btn.name = "StartButton"
    start_btn.text = "НАЧАТЬ ИГРУ"
    start_btn.pressed.connect(_on_menu_start)
    start_btn.position = Vector2(0, 120)
    start_btn.size = Vector2(180, 50)
    menu.add_child(start_btn)
    
    # Credits button
    var cred_btn = Button.new()
    cred_btn.name = "CreditsButton"
    cred_btn.text = "О ИГРЕ"
    cred_btn.pressed.connect(_on_menu_credits)
    cred_btn.position = Vector2(0, 190)
    cred_btn.size = Vector2(180, 40)
    menu.add_child(cred_btn)
    
    # Version label
    var version = Label.new()
    version.name = "VersionLabel"
    version.text = "v 0.1.0 — Renaissance Assassin Adventure"
    version.position = Vector2(0, 240)
    version.scale = Vector2(0.8, 0.8)
    menu.add_child(version)
    
    # Add menu to root
    get_tree().root.add_child(menu)
    
    # Set as current scene
    get_tree().set_current_scene(menu)
    
    print("    Main Menu created programmatically")
    
func _on_menu_start():
    print("  - Starting game...")
    queue_free()
    
    # Set up and show game scene
    setup_game_root()
    
func _on_menu_credits():
    print("  - Showing credits...")
    get_tree().paused = true
    var cred_menu = Control.new()
    cred_menu.name = "CreditsMenu"
    cred_menu.size = Vector2(384, 216)
    cred_menu.position = Vector2(0, 0)
    cred_menu.color = Color(0, 0, 0, 0.8)
    cred_menu.z_index = 1001
    
    var cred_text = Label.new()
    cred_text.text = "BLACK VEIL\n\nHistorical Assassin's Adventure\nInspired by Assassin's Creed style\nRenaissance Europe, late 15th century\n\n© 2026 BLACK VEIL Studios"
    cred_text.anchor_sides = Vector2(0, 0, 1, 1)
    cred_text.position = Vector2(20, 80)
    cred_text.scale = Vector2(1, 1)
    cred_menu.add_child(cred_text)
    
    var back_btn = Button.new()
    back_btn.text = "Вернуться"
    back_btn.pressed.connect(_on_credits_back)
    back_btn.position = Vector2(0, 160)
    back_btn.size = Vector2(150, 40)
    cred_menu.add_child(back_btn)
    
    get_tree().root.add_child(cred_menu)
    
func _on_credits_back():
    get_tree().root.find_child("CreditsMenu").queue_free()
    get_tree().paused = false

func setup_game_root():
    # Clean up any existing game nodes
    cleanup_game_nodes()
    
    # Create Map
    print("    - Creating Map and City...")
    var map = TileMap.new()
    map.name = "Map"
    map.position = Vector2(0, 0)
    map.z_index = 0
    
    # Generate city layout (programmatic)
    generate_city_layout(map)
    
    # Create Player
    print("    - Creating Player...")
    var player = CharacterBody2D.new()
    player.name = "Player"
    player.position = Vector2(200, 200)
    player.z_index = 1
    player.mode = CharacterBody2D.MODE_PHYSICS_IGNORE
    
    # Add collision shape
    var col_shape = CollisionShape2D.new()
    col_shape.name = "CollisionShape2D"
    col_shape.shape = RectangleShape2D.new(Vector2(), Vector2(32, 32))
    player.add_child(col_shape)
    
    # Add sprite
    var sprite = Sprite2D.new()
    sprite.name = "Sprite2D"
    sprite.z_index = 1
    # Try to load a default color/placeholder
    sprite.modulate = Color(1, 1, 1, 1)
    # Set a basic color as placeholder
    sprite.color = Color(0.8, 0.7, 0.5, 1) # Golden skin tone placeholder
    player.add_child(sprite)
    
    # Add the player script
    var player_script = load("res://scripts/player.gd")
    if player_script:
        player.script = player_script
        print("    - Player script attached")
    
    # Add input handler registration
    Input.map_action("ui_up")
    Input.map_action("ui_down")
    Input.map_action("ui_left")
    Input.map_action("ui_right")
    Input.map_action("interact")
    
    # Create Camera
    print("    - Creating Camera...")
    var camera = Camera2D.new()
    camera.name = "Camera"
    camera.position = Vector2(0, 0)
    camera.zoom = Vector2(2, 2)
    camera.current = true
    map.add_child(camera)
    
    # Try to find and set player as target
    if map.has_node("Player"):
        camera.target = map.get_node("Player")
        print("    - Camera targeting Player")
    
    # Create Joystick
    print("    - Creating Joystick...")
    var joystick = Joystick.new()
    joystick.name = "Joystick"
    joystick.position = Vector2(30, 550)
    joystick.z_index = 100
    map.add_child(joystick)
    
    # Try to connect joystick to player
    try:
        # Set player reference via function
        var set_method = joystick.get_method("set_player")
        if set_method:
            joystick.call(set_method, [player])
    except:
        pass
    
    # Add sun light
    print("    - Adding Light...")
    var sun = Light2D.new()
    sun.name = "Sun"
    sun.energy = 1.0
    sun.shadow_enabled = true
    sun.position = Vector2(0, -200)
    map.add_child(sun)
    
    # Add to root
    get_tree().root.add_child(map)
    
    # Set as current scene
    get_tree().set_current_scene(map)
    
    print("    Game Root scene created successfully!")
    print("    - Map with city layout")
    print("    - Player character with collision and sprite")
    print("    - Camera following player")
    print("    - Joystick for mobile controls")
    print("    - Sun lighting")
    
func generate_city_layout(map: TileMap):
    # Generate a simple city layout programmatically
    map.clear()
    map.map_size = Vector2(40, 30)
    map.tile_size = Vector2(64, 32)
    
    # Set tile set if available
    var ts = load("res://tilesets/city_tileset.tres")
    if ts:
        map.tile_set = ts
    
    # Fill with ground tiles (index 0)
    for y in range(30):
        for x in range(40):
            map.set_tile(x, y, 0)
    
    # Create central cross street
    var center_x = 20
    var center_y = 15
    
    # Horizontal street tiles: 1
    for x in range(1, 39):
        map.set_tile(x, center_y, 1)
    
    # Vertical street tiles: 2
    for y in range(1, 29):
        map.set_tile(center_x, y, 2)
    
    # Add buildings along edges
    # Bottom row buildings (index 7 = small building)
    for x in range(2, 8):
        map.set_tile(x, 1, 7)
        map.set_tile(x, 2, 8) # medium
    
    # Top row buildings
    for x in range(2, 8):
        map.set_tile(x, 24, 7)
        map.set_tile(x, 25, 8)
    
    # Left column buildings
    for y in range(2, 28):
        map.set_tile(1, y, 7)
        map.set_tile(2, y, 8)
    
    # Right column buildings
    for y in range(2, 28):
        map.set_tile(38, y, 7)
        map.set_tile(39, y, 8)
    
    # Center larger building (index 9)
    var cen_x = 20
    var cen_y = 15
    for dy in range(-2, 3):
        for dx in range(-2, 3):
            var tx = cen_x + dx
            var ty = cen_y + dy
            if tx >= 0 and tx < 40 and ty >= 0 and ty < 30:
                map.set_tile(tx, ty, 9)
    
    print("    City layout generated: 40x30 tiles with streets and buildings")
    
func cleanup_game_nodes():
    # Remove existing game nodes from root
    var nodes_to_remove = ["Map", "Player", "Camera", "Joystick", "Sun", "CreditsMenu", "MainMenu"]
    for name in nodes_to_remove:
        if get_tree().root.has_child(name):
            get_tree().root.get_child(name).queue_free()
    print("    - Cleaned up existing game nodes")

func init_game_systems():
    # Initialize input actions
    Input.map_action("ui_up")
    Input.map_action("ui_down")
    Input.map_action("ui_left")
    Input.map_action("ui_right")
    Input.map_action("interact")
    
    print("    - Input actions initialized: ui_up, ui_down, ui_left, ui_right, interact")
    print("    - Game systems ready for gameplay")