extends Node

# Represents the whole grid map environment
class_name MapGridManager

# Data structures
var grid_config = {}
var breach_config = {}
var grid = []
var grid_rows = 0
var grid_cols = 0

# For storing breach routes and their states
var breach_routes = {}

# Called when node is ready
func _ready():
    grid_config = load_config("res://world/maps/silent-perimeter/config/map_grid_config.json")
    breach_config = load_config("res://world/maps/silent-perimeter/config/breach_routes_config.json")
    
    # Setup grid dimensions from config
    grid_rows = grid_config.get("rows", 10)
    grid_cols = grid_config.get("cols", 10)
    
    # Initialize grid: 2D array of cells, each cell can store position, type, status
    init_grid()
    
    # Setup breach routes based on config
    setup_breach_routes()
    
    # Example: You could now call a routine to validate grid and breaches
    validate_configurations()
    
    # Debug output to confirm setup
    print("Grid and breach routes initialized successfully")

# Loads JSON configuration from file path and returns parsed Dictionary
func load_config(path: String) -> Dictionary:
    var file = File.new()
    if file.file_exists(path):
        file.open(path, File.READ)
        var content = file.get_as_text()
        file.close()
        var json_result = JSON.parse(content)
        if json_result.error == OK:
            return json_result.result
        else:
            push_error("JSON parse error in " + path)
    else:
        push_error("Config file not found: " + path)
    return {}

# Initialize the internal grid data structure based on grid_config settings
func init_grid():
    grid.clear()
    for r in range(grid_rows):
        var row = []
        for c in range(grid_cols):
            var cell_data = {
                "row": r,
                "col": c,
                "type": "empty",    # could be "empty", "obstacle", "spawnpoint", etc.
                "breach_here": false
            }
            # Optionally override cell types based on grid_config details
            var cell_key = str(r) + "," + str(c)
            if grid_config.has("cells") and grid_config["cells"].has(cell_key):
                cell_data["type"] = grid_config["cells"][cell_key].get("type", "empty")
            row.append(cell_data)
        grid.append(row)

# Setup breach routes - maps of connected cells covered by breach paths
func setup_breach_routes():
    breach_routes.clear()
    if breach_config.has("routes"):
        for route_id in breach_config["routes"]:
            var route_data = breach_config["routes"][route_id]
            var cells = route_data.get("cells", [])
            # Store the route as a list of grid positions and initialize their statuses
            breach_routes[route_id] = {
                "cells": cells,
                "active": false,
                "breached_cells": []
            }
            # Mark cells in grid that are part of breach routes for faster lookup
            for pos in cells:
                var row = pos[0]
                var col = pos[1]
                if row >= 0 and row < grid_rows and col >= 0 and col < grid_cols:
                    grid[row][col]["breach_here"] = true

# Validate configurations for consistency - grid size matches config and routes are valid
func validate_configurations():
    # Check grid size matches config
    if grid_rows <= 0 or grid_cols <= 0:
        push_error("Invalid grid dimensions: rows or cols <= 0")
    # Check breach routes cells are within grid boundaries
    for route_id in breach_routes.keys():
        for pos in breach_routes[route_id]["cells"]:
            var r = pos[0]
            var c = pos[1]
            if r < 0 or r >= grid_rows or c < 0 or c >= grid_cols:
                push_warning("Breach route " + route_id + " cell out of grid bounds: (" + str(r) + "," + str(c) + ")")

# Example function: Activate a breach route (simulate breach)
func activate_breach(route_id: String):
    if breach_routes.has(route_id):
        breach_routes[route_id]["active"] = true
        breach_routes[route_id]["breached_cells"] = breach_routes[route_id]["cells"].duplicate()
        # Could trigger additional logic like opening doors, spawning enemies, etc.
        emit_signal("breach_activated", route_id)
        print("Breach route " + route_id + " activated.")
    else:
        push_warning("Breach route ID not found: " + route_id)

# Example function: Check if a grid cell is breached
func is_cell_breached(row: int, col: int) -> bool:
    if row < 0 or row >= grid_rows or col < 0 or col >= grid_cols:
        return false
    for route_id in breach_routes.keys():
        if breach_routes[route_id]["active"]:
            if Vector2(row, col) in breach_routes[route_id]["breached_cells"]:
                return true
    return false

# Fetch all breach routes for external queries or UI
func get_all_breach_routes() -> Dictionary:
    return breach_routes

# Signal to notify breach activation (connect to other game systems)
signal breach_activated(route_id)

# Additional helper functionality could include:
# - Dynamic breach updates (partially breached routes)
# - Pathfinding utilities using grid and breach status (to plan safe routes)
# - Event hooks on breach completion or failure
# - Visual debugging overlays, auto-map building, etc.
