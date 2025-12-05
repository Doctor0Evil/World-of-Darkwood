extends Node2D
class_name MapGridManager

# Immutable snapshot exposed to AI
class NavSnapshot:
	var version: int
	var astar: AStar2D
	var cell_costs: Dictionary  # Vector2i -> float

# Panic edit record
class PanicEdit:
	var from_cell: Vector2i
	var to_cell: Vector2i
	var new_cost: float
	var edit_type: String  # "SHOVE" or "DOOR_OPEN"

var _current_snapshot: NavSnapshot
var _snapshot_version: int = 0

var _panic_edits: Array[PanicEdit] = []

# Hotspot counters for DebugConsole
var _stall_hotspots: Dictionary = {}  # Vector2i -> int
var _panic_hotspots: Dictionary = {}  # Vector2i -> int

func _ready() -> void:
	_init_nav_snapshot()

func _init_nav_snapshot() -> void:
	var snap := NavSnapshot.new()
	snap.version = 0
	snap.astar = AStar2D.new()
	snap.cell_costs = {}
	_current_snapshot = snap
	_snapshot_version = 0

func get_nav_snapshot() -> NavSnapshot:
	return _current_snapshot

func queue_panic_edit(edit: PanicEdit) -> void:
	_panic_edits.append(edit)

func notify_stall(cell: Vector2i) -> void:
	_stall_hotspots[cell] = int(_stall_hotspots.get(cell, 0)) + 1

func notify_panic(cell: Vector2i) -> void:
	_panic_hotspots[cell] = int(_panic_hotspots.get(cell, 0)) + 1

func get_stall_hotspots() -> Dictionary:
	return _stall_hotspots

func get_panic_hotspots() -> Dictionary:
	return _panic_hotspots

func process_panic_edits() -> void:
	if _panic_edits.is_empty():
		return
	
	var old_snap := _current_snapshot
	var new_snap := NavSnapshot.new()
	new_snap.version = old_snap.version + 1
	new_snap.astar = _clone_astar(old_snap.astar)
	new_snap.cell_costs = old_snap.cell_costs.duplicate(true)

	for edit in _panic_edits:
		_apply_panic_edit(edit, new_snap)
	
	_panic_edits.clear()
	_current_snapshot = new_snap
	_snapshot_version = new_snap.version

func _apply_panic_edit(edit: PanicEdit, snap: NavSnapshot) -> void:
	var from_cell := edit.from_cell
	var to_cell := edit.to_cell
	var key := to_cell
	
	var cur_cost: float = snap.cell_costs.get(key, 1.0)
	var target_cost := cur_cost
	
	if edit.edit_type == "DOOR_OPEN":
		target_cost = 1.0
		_make_cell_walkable(to_cell, snap)
	else:
		target_cost = min(cur_cost, edit.new_cost)
	
	if target_cost < cur_cost:
		snap.cell_costs[key] = target_cost
		_update_astar_edge(from_cell, to_cell, target_cost, snap)

func _clone_astar(src: AStar2D) -> AStar2D:
	# TODO: copy points and connections deterministically
	var dst := AStar2D.new()
	return dst

func _make_cell_walkable(cell: Vector2i, snap: NavSnapshot) -> void:
	# TODO: update internal grid flags + astar points/connections
	pass

func _update_astar_edge(from_cell: Vector2i, to_cell: Vector2i, cost: float, snap: NavSnapshot) -> void:
	# TODO: map grid cells to AStar IDs and set connection weight
	pass
