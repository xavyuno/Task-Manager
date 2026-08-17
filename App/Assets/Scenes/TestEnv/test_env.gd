extends Control

var points = []

func _process(delta):
	if Input.is_action_pressed("Click"):
		var mouse_pos = get_global_mouse_position()
		points.append(mouse_pos)
		queue_redraw()
	if Input.is_action_pressed("Drag"):
		var mouse_pos = get_global_mouse_position()
		delete_nearest_point(mouse_pos, 5)
	if Input.is_action_pressed("Delete"):
		clear_all()

func delete_nearest_point(pos, radius):
	var nearest_idx = -1
	var nearest_dist = INF
	
	for i in range(points.size()):
		var dist = points[i].distance_to(pos)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_idx = i
	
	if nearest_idx != -1 and nearest_dist < radius:
		points.remove_at(nearest_idx)
		queue_redraw()
		return true
	return false

func clear_all():
	points.clear()
	queue_redraw()

func _draw():
	for p in points:
		draw_circle(p, 3, Color.YELLOW)
