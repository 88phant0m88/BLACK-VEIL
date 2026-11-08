#!/usr/bin/env gdscript
extends TileMap

# Tile set reference
export_var(String, tileset_path) = "res://tilesets/city_tileset.tres"

# Tile index mappings
const TILE_GRASS = 0
const TILE_STREET_HORIZONTAL = 1
const TILE_STREET_VERTICAL = 2
const TILE_STREET_CORNER_NW = 3
const TILE_STREET_CORNER_NE = 4
const TILE_STREET_CORNER_SW = 5
const TILE_STREET_CORNER_SE = 6
const TILE_BUILDING_SMALL = 7
const TILE_BUILDING_MEDIUM = 8
const TILE_BUILDING_LARGE = 9
const TILE_NPC_STAND = 10

func _ready():
    tileset = load(tileset_path)
    if tileset == null:
        print("ERROR: Could not load tileset at: ", tileset_path)
        return
    
    # Set map size - smaller demo map
    map_size = Vector2(40, 30)
    tile_size = Vector2(64, 32) # Isometric tile size
    
    # Configure tile set
    set_tile_set(tileset)
    set_tile_size(tile_size)
    
    # Generate the city layout
    generate_city_layout()
    
    # Set up collision/navigation
    setup_navigation()
    
    print("City map generated: ", map_size.x, "x", map_size.y)

func generate_city_layout():
    # Clear any existing data
    clear()
    
    var half_w = int(map_size.x / 2)
    var half_h = int(map_size.y / 2)
    
    # Fill background with ground tiles
    for y in range(map_size.y):
        for x in range(map_size.x):
            set_tile(x, y, TILE_GRASS)
    
    # Create main street - the central cross
    # Horizontal street through center
    for x in range(1, map_size.x - 1):
        set_tile(x, half_h, TILE_STREET_HORIZONTAL)
    set_tile(0, half_h, TILE_STREET_CORNER_SW)
    set_tile(map_size.x - 1, half_h, TILE_STREET_CORNER_SE)
    
    # Vertical street through center
    for y in range(1, map_size.y - 1):
        set_tile(half_w, y, TILE_STREET_VERTICAL)
    set_tile(half_w, 0, TILE_STREET_CORNER_NW)
    set_tile(half_w, map_size.y - 1, TILE_STREET_CORNER_SW)
    
    # Add buildings around the edges and center
    add_buildings()
    
    # Add NPC markers
    add_npcs()

func add_buildings():
    # Row of buildings along bottom edge
    for x in range(2, map_size.x - 2):
        set_tile(x, 1, TILE_BUILDING_SMALL)
        set_tile(x, 2, TILE_BUILDING_MEDIUM)
    
    # Row of buildings along top edge
    for x in range(2, map_size.x - 2):
        set_tile(x, map_size.y - 3, TILE_BUILDING_SMALL)
        set_tile(x, map_size.y - 4, TILE_BUILDING_MEDIUM)
    
# Column of buildings on left edge
    for y in range(2, map_size.y - 2):
        set_tile(1, y, TILE_BUILDING_SMALL)
        set_tile(2, y, TILE_BUILDING_MEDIUM)
    
# Column of buildings on right edge
    for y in range(2, map_size.y - 2):
        set_tile(map_size.x - 3, y, TILE_BUILDING_SMALL)
        set_tile(map_size.x - 4, y, TILE_BUILDING_MEDIUM)
    
    # Add a few larger buildings in the center area
    var center_x = int(map_size.x / 2)
    var center_y = int(map_size.y / 2)
    for dy in range(-2, 3):
        for dx in range(-2, 3):
            var tx = center_x + dx
            var ty = center_y + dy
            if tx >= 0 and tx < map_size.x and ty >= 0 and ty < map_size.y:
                if tx > 5 and tx < map_size.x - 5 and ty > 5 and ty < map_size.y - 5:
                    set_tile(tx, ty, TILE_BUILDING_LARGE)

func add_npcs():
    # Add 3 NPC markers in the city
    var npc_positions = [
        Vector2(5, 5),
        Vector2(map_size.x - 6, map_size.y - 6),
        Vector2(half_w, half_h),
    ]
    
    for npc_pos in npc_positions:
        var nx = int(npc_pos.x)
        var ny = int(npc_pos.y)
        if nx >= 0 and nx < map_size.x and ny >= 0 and ny < map_size.y:
            set_tile(nx, ny, TILE_NPC_STAND)

func setup_navigation():
    # Mark building tiles as obstacles for navigation
    for y in range(map_size.y):
        for x in range(map_size.x):
            var tile_id = get_tile_id(x, y)
            # Tiles 7-9 are buildings, mark as not walkable
            if tile_id >= TILE_BUILDING_SMALL and tile_id <= TILE_BUILDING_LARGE:
                # Set as navigation obstacle
                pass
            # Also mark street corners that might be tricky
            # Tiles 3-6 are street corners