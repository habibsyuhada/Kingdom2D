extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum {IDLE}
var state: int = IDLE
var velocity = Vector2.ZERO
var speed = 100

onready var nav = get_node("/root/World/Navigation2D")
var path = []
var cur_path_idx = 0
var threshold = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	match state:
		IDLE:
			idle()

func idle():
	if path.size() > 0:
		velocity = Vector2.ZERO
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
	else:
		var radius = 64
		var target_pos = Vector2(rand_range(-radius, radius), rand_range(-radius, radius))
		target_pos = position - target_pos
		path = nav.get_simple_path(position, target_pos)
