extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum {IDLE, CUT_TREE}
var state: int = IDLE
var velocity = Vector2.ZERO
var speed = 100

onready var nav = get_node("/root/World/Navigation2D")
var path = []
var cur_path_idx = 0
var threshold = 1

var iswaiting = false
var isaction = false
var detected = {
	"tree" : [],
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = Vector2.ZERO
	match state:
		IDLE:
			idle()
		CUT_TREE:
			cut_tree()
	move_navigation()
	
func move_navigation():
	if path.size() > 0:
		if Vector2(position).distance_to(Vector2(path[cur_path_idx].x, path[cur_path_idx].y)) < 1:
			path.remove(0)
		else:
			var direction = path[cur_path_idx] - position
			velocity = direction.normalized() * 25
			if abs(velocity.x) > abs(velocity.y):
				if velocity.x > 0 :
					$AnimatedSprite.animation = "Walk_Right"
				else:
					$AnimatedSprite.animation = "Walk_Left"
			else:
				if velocity.y > 0 :
					$AnimatedSprite.animation = "Walk_Down"
				else:
					$AnimatedSprite.animation = "Walk_Up"
			move_and_slide(velocity)

func choose_action():
	if !iswaiting:
		iswaiting = true
		yield(Global.waits(5), "completed")
		if Global.data_player["wood"] < Global.data_player["max_storage"] and detected["tree"].size() > 0:
			state = CUT_TREE
		iswaiting = false

func idle():
	choose_action()
	if path.size() == 0:
		var radius = 64
		var target_pos = Vector2(rand_range(-radius, radius), rand_range(-radius, radius))
		target_pos = position - target_pos
		path = nav.get_simple_path(position, target_pos, false)

func cut_tree():
	if path.size() == 0 and detected["tree"].size() > 0:
		var selected_tree = null
		for area in $Body.get_overlapping_areas():
			if area.is_in_group("Tree"):
				if selected_tree == null or (position - selected_tree).length() > (position - area).length():
					selected_tree = area
		if selected_tree:
			isaction = true
		elif detected["tree"].size() > 0:
			var target_pos = detected["tree"][0].position
			path = nav.get_simple_path(position, target_pos, false)


func _on_Sight_area_entered(area):
	if area.is_in_group("Tree"):
		detected["tree"].push_back(area)

func _on_Sight_area_exited(area):
	if area.is_in_group("Tree"):
		detected["tree"].erase(area)
