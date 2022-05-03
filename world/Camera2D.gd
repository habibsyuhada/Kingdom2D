extends Camera2D

export (NodePath) var target
onready var cursor = get_node_or_null("/root/World/Cursor")

var target_return_enabled = true
var target_return_rate = 0.02
var min_zoom = 0.5
var max_zoom = 2
var zoom_sensitivity = 10
var zoom_speed = 0.05

var events = {}
var events_check_drag = {}
var last_drag_distance = 0
var cursor_tile = 16


func _process(delta):
	if target and target_return_enabled and events.size() == 0:
		position = lerp(position, get_node(target).position, target_return_rate)
	
	if Input.is_action_just_pressed("Q"):
		var new_zoom = clamp((zoom.x + -0.5), min_zoom, max_zoom)
		zoom = Vector2.ONE * new_zoom
	if Input.is_action_just_pressed("E"):
		var new_zoom = clamp((zoom.x + 0.5), min_zoom, max_zoom)
		zoom = Vector2.ONE * new_zoom

func _unhandled_input(event):
	detect_input(event)

func detect_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
			events_check_drag[event.index] = false
		else:
			if cursor and !events_check_drag[event.index]:
				var targetpos = get_viewport().canvas_transform.affine_inverse().xform(event.position)
				#cursor.position = targetpos
				change_pos_cursor(targetpos)
			events.erase(event.index)

	if event is InputEventScreenDrag:
		events[event.index] = event
		if events.size() == 1:
			position += event.relative.rotated(rotation) * zoom.x * Vector2(-1, -1)
			if event.relative.rotated(rotation) * zoom.x * Vector2(-1, -1) != Vector2.ZERO :
				events_check_drag[event.index] = true
		elif events.size() == 2:
			var drag_distance = events[0].position.distance_to(events[1].position)
			if abs(drag_distance - last_drag_distance) > zoom_sensitivity:
				var new_zoom = (1 + zoom_speed) if drag_distance < last_drag_distance else (1 - zoom_speed)
				new_zoom = clamp(zoom.x * new_zoom, min_zoom, max_zoom)
				zoom = Vector2.ONE * new_zoom
				last_drag_distance = drag_distance

func change_pos_cursor(targetpos):
	var cursor_position = cursor.position
	cursor_position.x = (ceil(targetpos.x / cursor_tile) - 0.5) * cursor_tile
	if cursor_tile == 16 :
		cursor_position.y = (ceil((targetpos.y) / cursor_tile) - 0.5) * cursor_tile
	elif cursor_tile == 32 :
		cursor_position.y = (ceil((targetpos.y - 16) / cursor_tile)) * cursor_tile
	cursor.position = cursor_position
