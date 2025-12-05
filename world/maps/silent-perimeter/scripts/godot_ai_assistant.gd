extends Node

func _ready():
    var grid_config = load_config("res://world/maps/silent-perimeter/config/map_grid_config.json")
    var breach_config = load_config("res://world/maps/silent-perimeter/config/breach_routes_config.json")
    # ... (Add logic for grid generation, breach routes, etc.)
