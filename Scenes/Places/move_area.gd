class_name MovementArea
extends Node2D

# Assign your Polygon2D child node to this in the Inspector
@export var boundary_polygon_node_path: NodePath

@onready var _boundary_polygon: Polygon2D = $Polygon2D

# These will store the corner points in this node's local space
var _top_left: Vector2
var _top_right: Vector2
var _bottom_left: Vector2
var _bottom_right: Vector2

var _is_initialized: bool = true

func _ready():
	
	if not _boundary_polygon:
		printerr("PlayerMovementArea: BoundaryPolygon node not found or not of type Polygon2D at path: ", boundary_polygon_node_path)
		return

	# Ensure the polygon's transform doesn't complicate things.
	# Ideally, its position is (0,0) relative to this PlayerMovementArea node.
	if _boundary_polygon.position != Vector2.ZERO or _boundary_polygon.rotation_degrees != 0.0 or _boundary_polygon.scale != Vector2.ONE:
		print("PlayerMovementArea: For best results, BoundaryPolygon's transform (position, rotation, scale) should be default relative to PlayerMovementArea.")

	_initialize_bounds_from_polygon()

	# Optional: Connect to a signal if the polygon data might change at runtime
	# and you need to re-initialize. For editor changes, a tool script or manual
	# refresh might be needed if you don't re-run the scene.
	# _boundary_polygon.connect("item_rect_changed", Callable(self, "_on_polygon_changed")) # May not always fire for vertex edits

# Call this if you programmatically change the polygon's points at runtime
func reinitialize_bounds():
	if _boundary_polygon:
		_initialize_bounds_from_polygon()

func _initialize_bounds_from_polygon():
	if not _boundary_polygon or _boundary_polygon.polygon.size() == 0:
		printerr("PlayerMovementArea: BoundaryPolygon has no points defined.")
		_is_initialized = false
		return
	
	var raw_polygon_points: PackedVector2Array = _boundary_polygon.polygon
	
	if raw_polygon_points.size() != 4:
		printerr("PlayerMovementArea: BoundaryPolygon must have exactly 4 points to define a trapezoid. It has ", raw_polygon_points.size())
		_is_initialized = false
		return

	print(raw_polygon_points)

	# After sorting:
	# points[0] and points[1] are the "top" two points (smaller Y)
	# points[2] and points[3] are the "bottom" two points (larger Y)

	 # --- Fix for Issue 2: Transform points to MovementArea's local space ---
	var points_in_parent_space: PackedVector2Array = PackedVector2Array()
	var poly_transform_to_parent: Transform2D = _boundary_polygon.transform # Gets local transform relative to parent
	for p_local_to_poly in raw_polygon_points:
		points_in_parent_space.append(poly_transform_to_parent * p_local_to_poly)
	
	var points: PackedVector2Array = points_in_parent_space # Now use these transformed points
	
	_bottom_left = points[0]
	_bottom_right = points[1]
	_top_right = points[2]
	_top_left = points[3]
	# Sanity check for a valid trapezoid structure (e.g., top Ys are less than bottom Ys)
	if _top_left.y >= _bottom_left.y or _top_right.y >= _bottom_right.y:
 	# Allow for perfectly horizontal lines (top_y == bottom_y) if it's a rectangle
		if not (abs(_top_left.y - _bottom_left.y) < 0.001 and abs(_top_right.y - _bottom_right.y) < 0.001):
			printerr("MovementArea: Polygon points do not form a valid top/bottom trapezoid structure after sorting and transformation.")
			print("Interpreted corners: TL:", _top_left, " TR:", _top_right, " BL:", _bottom_left, " BR:", _bottom_right)
			_is_initialized = false
			return
			
	_is_initialized = true
	# print_debug("Movement area initialized: TL:", _top_left, " TR:", _top_right, " BL:", _bottom_left, " BR:", _bottom_right)


func clamp_global_position(global_target_pos: Vector2) -> Vector2:
	if not _is_initialized:
		printerr("PlayerMovementArea: Not initialized. Returning original position.")
		return global_target_pos

	# Convert the global target position to this node's local space
	var local_target_pos: Vector2 = to_local(global_target_pos)
	var clamped_local_pos: Vector2 = local_target_pos

	# 1. Clamp Y position (in local space)
	#    Using the Y values from the identified corners
	var min_y: float = min(_top_left.y, _top_right.y)
	var max_y: float = max(_bottom_left.y, _bottom_right.y)
	clamped_local_pos.y = clamp(local_target_pos.y, min_y, max_y)

	# 2. Calculate X boundaries for the clamped_local_pos.y using linear interpolation
	var t: float = 0.0
	if max_y - min_y > 0.001: # Avoid division by zero
		# Inverse lerp: (value - from) / (to - from)
		# t = 0 at the "bottom" Y level (max_y), t = 1 at the "top" Y level (min_y)
		t = inverse_lerp(max_y, min_y, clamped_local_pos.y)
	elif clamped_local_pos.y <= min_y:
		t = 1.0
	# else t remains 0.0 (at or below max_y)

	var x_left_boundary: float = lerp(_bottom_left.x, _top_left.x, t)
	var x_right_boundary: float = lerp(_bottom_right.x, _top_right.x, t)

	clamped_local_pos.x = clamp(local_target_pos.x, x_left_boundary, x_right_boundary)

	# Convert the clamped local position back to global space
	return to_global(clamped_local_pos)
