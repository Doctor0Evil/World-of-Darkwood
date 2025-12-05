extends Node
class_name PanicDetourUtils

const EDIT_TYPE_SHOVE := "SHOVE"
const EDIT_TYPE_DOOR_OPEN := "DOOR_OPEN"

var MIN_PROGRESS_COST := 0.5
var STALL_WINDOW_TICKS := 15
var PANIC_RADIUS_FACTOR := 1.5
var OBSTACLE_SHOVE_FACTOR := 0.6
var DOOR_COST_THRESHOLD := 5.0
var DOOR_OPEN_COST := 1.0

# agent_state: expects pos: Vector2i, target: Vector2i, last_macro_cell: Vector2i
# dist: Dictionary or Array of node distances from last dijkstra
# snap: MapGridManager.NavSnapshot
func compute_panic_edits(agent_state: Dictionary, dist, snap: MapGridManager.NavSnapshot) -> Array:
	var edits: Array = []
	var current: Vector2i = agent_state.pos
	var target: Vector2i = agent_state.target

	# 1) Obstacle shove on neighbors
	for nb in _neighbors_of(snap, current):
		var old_cost := _get_cell_cost(snap, nb)
		var new_cost := old_cost * OBSTACLE_SHOVE_FACTOR
		if new_cost < old_cost:
			var e := MapGridManager.PanicEdit.new()
			e.from_cell = current
			e.to_cell = nb
			e.new_cost = new_cost
			e.edit_type = EDIT_TYPE_SHOVE
			edits.append(e)
	# 2) Radius expansion (optional: if you have graph distances)
	# 3) Door break
	var cand := _high_cost_neighbors(snap, current, DOOR_COST_THRESHOLD)
	if not cand.is_empty():
		var j: Vector2i = _deterministic_pick(current, cand)
		var e2 := MapGridManager.PanicEdit.new()
		e2.from_cell = current
		e2.to_cell = j
		e2.new_cost = DOOR_OPEN_COST
		e2.edit_type = EDIT_TYPE_DOOR_OPEN
		edits.append(e2)
	
	return edits

func _neighbors_of(snap: MapGridManager.NavSnapshot, cell: Vector2i) -> Array:
	# TODO: based on grid topology; 4- or 8-neighbors
	return []

func _get_cell_cost(snap: MapGridManager.NavSnapshot, cell: Vector2i) -> float:
	return float(snap.cell_costs.get(cell, 1.0))

func _high_cost_neighbors(snap: MapGridManager.NavSnapshot, cell: Vector2i, threshold: float) -> Array:
	var result: Array = []
	for nb in _neighbors_of(snap, cell):
		var c := _get_cell_cost(snap, nb)
		if c > threshold:
			result.append(nb)
	return result

func _deterministic_pick(current: Vector2i, candidates: Array) -> Vector2i:
	candidates.sort_custom(self, "_cell_sort_key")
	return candidates[0]

func _cell_sort_key(a, b) -> bool:
	# sort by y then x for deterministic ordering
	if a.y == b.y:
		return a.x < b.x
	return a.y < b.y
