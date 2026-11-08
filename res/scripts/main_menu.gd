#!/usr/bin/env gdscript
extends Control

# Menu configuration
export_var(String, start_scene) = "res://scenes/MainRoot.tscn"
export_var(String, menu_scene) = "res://scenes/MainMenu.tscn"

func _ready():
    # Center the menu
    var viewport = get_viewport()
    var size = viewport.get_visible_rect().size
    set_offset(Vector2(size.x / 2, size.y / 2))
    
    # Initialize UI elements
    var title_label = get_node("TitleLabel")
    title_label.alpha_modulate = Color(1, 1, 1, 1)
    
    # Connect button signals via code for reliability
    var start_btn = get_node("StartButton")
    start_btn.pressed.connect(_on_start_pressed)
    
    var credits_btn = get_node("CreditsButton")
    credits_btn.pressed.connect(_on_credits_pressed)
    
    print("BLACK VEIL - Main Menu loaded")
    print("Historical Assassin's Adventure - Renaissance Europe")
    print("")

func _on_start_pressed():
    print("Starting new game...")
    # Remove current menu
    queue_free()
    
    # Instance the game scene
    var game_scene = load(start_scene)
    if game_scene:
        var instance = game_scene.instantiate()
        get_tree().root.add_child(instance)
        
        # Initialize game systems
        instance.find_player().if_else(
            print("Player found"),
            print("Player not found in game scene")
        )
    
    print("Game started")

func _on_credits_pressed():
    print("About BLACK VEIL...")
    print("Historical assassination adventure in Renaissance Europe")
    print("Inspired by Assassin's Creed style gameplay")
    print("")

func _on_quit_pressed():
    get_tree().quit()