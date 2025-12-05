extends Node
class_name BreachAwareNavigator

var map_manager: MapGridManager
var panic_utils: PanicDetourUtils

var stall_counter: int = 0
var panic_mode: bool = false
var aggression: float = 1.0
var last_macro_cell: Vector2i
var pos: Vector2i
var target: Vector2i

func _ready() -> void:
	# Expect map_manager and panic_utils injected via scene or autoload
	pass

func update_agent(dt: float) -> void:
	var snap := map_manager.get_nav_snapshot()
	var path := _compute_path(snap)
	if path.size() < 2:
		stall_counter += 1
		_check_stall_and_panic(snap, {})
		return
	
	var next_cell: Vector2i = path[1]
	pos = next_cell
	
	var d_prog := _progress_cost(snap, last_macro_cell, pos)
	if d_prog < panic_utils.MIN_PROGRESS_COST:
		stall_counter += 1
		map_manager.notify_stall(pos)
	else:
		stall_counter = 0
		last_macro_cell = pos
	
	_check_stall_and_panic(snap, {})  # dist placeholder; fill with your dijkstra dist

func _compute_path(snap: MapGridManager.NavSnapshot) -> Array:
	# TODO: run AStar2D from pos to target using snap.astar
	return []

func _progress_cost(snap: MapGridManager.NavSnapshot, a: Vector2i, b: Vector2i) -> float:
	# TODO: approximate via grid distance or cached nav distance
	return 1.0

func _check_stall_and_panic(snap: MapGridManager.NavSnapshot, dist) -> void:
	if stall_counter >= panic_utils.STALL_WINDOW_TICKS:
		panic_mode = true
		aggression *= 1.3
		map_manager.notify_panic(pos)
		
		var agent_state := {
			"pos": pos,
			"target": target,
			"last_macro_cell": last_macro_cell,
		}
		var edits := panic_utils.compute_panic_edits(agent_state, dist, snap)
		for e in edits:
			map_manager.queue_panic_edit(e)
		
		stall_counter = 0
