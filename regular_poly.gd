class_name RegularPoly extends Node2D

@export var is_up_tri : bool = true
@export var base_length : float = 256
@export var num_sides : int = 3
@export var points_list : PackedVector2Array

@export var min_log_level : LogLevel = LogLevel.INFO

enum LogLevel {
	DEBUG,
	INFO,
	WARNING,
	ERROR
}

func s_log(text : String, lvl : LogLevel = LogLevel.INFO):
	if lvl >= min_log_level:
		var lvl_name = LogLevel.keys()[lvl] 
		print("%s: %s >> %s" %[lvl_name, self.name, text])  
	
	
func get_reg_angle(side_count : int) -> float:
	assert( side_count >= 2, "ERROR: You must provide a reasonable number of sides.");
	var total_angle = (side_count - 2) * PI
	var side_angle = total_angle / side_count
	s_log("-- side_angle: %f" % side_angle, LogLevel.DEBUG)
	return PI - side_angle
	
func create_reg_polygon(angle : float, steps : int, base_vec : Vector2) -> Polygon2D:
	s_log("-- Creating Poly with %d steps of angle %f" % [steps, angle], LogLevel.DEBUG)
	var poly = Polygon2D.new()
	poly.name="Equilateral"
	poly.color = _generate_random_hsv_color()
	var cursor = Vector2(0,0)
	var points = [cursor]
	while steps > 0:
		cursor = cursor + base_vec
		s_log("-- -- Adding Point %f,%f" % [cursor.x, cursor.y], LogLevel.DEBUG)
		points.append(cursor)
		base_vec = base_vec.rotated(angle)
		steps -= 1
	points_list = PackedVector2Array(points)
	poly.set_polygon(points_list)
	return poly

func _generate_random_hsv_color() -> Color:
	return Color.from_hsv(
		randf(), # HUE
		randf_range(0.6, 1), # SATURATION
		randf_range(0.9, 1.0), # BRIGHTNESS
	)
	
	# 1 indexed
func get_midpoint(side : int):
	assert( side <= num_sides and side > 0, "ERROR: There are %d sides, but you asked for the midpoint of side #%d!" % [num_sides, side]);
	var sides = points_list
	sides.append(points_list[0]) 
	var start = points_list[side - 1]
	var end = points_list[side]
	var mp = ((start - end) / 2) + end
	s_log("MP CALC: (s=%d) (%f,%f) -- (%f,%f) -- (%f,%f)" %[side, start.x, start.y, mp.x, mp.y, end.x, end.y], LogLevel.DEBUG)
	return mp
	
		
func init():
	# is drawn from either bottom left or upper left corner
	var angle = get_reg_angle(num_sides)
	if is_up_tri:
		angle = angle * -1
	
	var base_side_vector = Vector2(base_length, 0)
	
	add_child(create_reg_polygon(angle, num_sides-1, base_side_vector))
	s_log("Created Poly with %d sides of len %d" % [num_sides, base_length], LogLevel.DEBUG)
	
	return self
	
func _ready() -> void:
	init()
	s_log("** tris ready **")
