class_name RecursiveTri extends RegularPoly

var locations : Array[Vector2]


##### FUNCTIONS

func change_clickability() -> bool:
	var clarea : Area2D = get_node("ClickableArea")
	clarea.input_pickable = not clarea.input_pickable
	return clarea.input_pickable

##### Child-Related Funcs

func cull_children():
	for n in ["L","R","C","T"]:
		get_node(name+"_"+n).queue_free()
		
	change_clickability()

func create_children() -> Array[RecursiveTri] :
	change_clickability()
	var children : Array[RecursiveTri] = []
	# create leftest
	var next_name = self.name + "_L"
	if not get_node_or_null(next_name):
		var leftest_child = create_child()
		add_child(leftest_child)
		leftest_child.name = next_name
		children.append(leftest_child)
	# create rightest, going right
	next_name = self.name + "_R"
	if not get_node_or_null(next_name):
		var rightest_child = create_child()
		add_child(rightest_child)
		rightest_child.name = next_name
		rightest_child.position = Vector2(base_length / 2, 0)
		children.append(rightest_child)
	
	# center & top share an origin point, determined by orientation
	var left_mid = get_midpoint(3)
	
	next_name = self.name + "_C"
	if not get_node_or_null(next_name):
		var center_child = create_child(false)
		add_child(center_child)
		center_child.name = next_name
		center_child.position = left_mid
		children.append(center_child)
	
	next_name = self.name + "_T"
	if not get_node_or_null(next_name):
		var top_child = create_child()
		add_child(top_child)
		top_child.name = next_name
		top_child.position = left_mid
		children.append(top_child)
	
	return children
	
func create_child(is_same_orientation : bool = true) -> RecursiveTri:
	var child = RecursiveTri.new()
	child.num_sides = self.num_sides # always 3 atm
	child.is_up_tri = self.is_up_tri if is_same_orientation else not self.is_up_tri
	child.base_length = self.base_length / 2
	return child

func increase_resolution(levels:int=2):
	s_log("info: increasing resolution")
	var current_children = create_children()
	var headcount = len(current_children)
	while levels > 1:
		var next_children = []
		for c in current_children:
			next_children.append_array(c.create_children())
		current_children = next_children
		headcount += len(current_children)
		levels-=1
	s_log("Created %d Children" % headcount)
	pass
	
func decrease_resolution(levels:int=3):
	s_log("info: decreasing resolution")
	
	var parent = get_parent()
	while levels > 1:
		var gramps = parent.get_parent()
		if gramps is RecursiveTri:
			parent = gramps
		levels -= 1
	parent.cull_children()
	pass

##### INPUTS

func init() -> RecursiveTri:
	super.init()
	
	var coll = CollisionPolygon2D.new()
	coll.polygon = self.points_list
	var area = Area2D.new()
	area.name = "ClickableArea"
	area.add_child(coll)
	add_child(area)
	
	area.mouse_entered.connect(_on_clickable_area_mouse_entered)
	area.mouse_exited.connect(_on_clickable_area_mouse_exited)
	area.input_event.connect(_on_clickable_area_input_event)
	
	return self

func _on_clickable_area_mouse_entered() -> void:
	var lmp = get_local_mouse_position()
	var gmp = get_global_mouse_position()
	s_log("Mouse Entered at point: (%f, %f) / (%f, %f)" % [lmp.x, lmp.y, gmp.x, gmp.y])


func _on_clickable_area_mouse_exited() -> void:
	var lmp = get_local_mouse_position()
	var gmp = get_global_mouse_position()
	s_log("Mouse Exited at point: (%f, %f) / (%f, %f)" % [lmp.x, lmp.y, gmp.x, gmp.y])
	

func _on_clickable_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if  event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		increase_resolution()
	if  event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		decrease_resolution()
