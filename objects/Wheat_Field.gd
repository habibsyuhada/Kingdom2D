extends Area2D


var total_res = 2
var max_res = 8
var istouched = false
var need_build = true
var worker_build = null
var build_time = 5

func _ready():
	AI_Core.data_ai["wheat_field"] += 1
	var frames = $AnimatedSprite.frames
	max_res = 8+randi()%4+1

func increase_resource(total = 1):
	if !need_build:
		if total_res < max_res and !istouched:
			var random = randi()%100+1
			if random > 50:
				total_res += total
				if total_res < 4:
					$AnimatedSprite.frame = total_res


func decrease_resource(total = 1):
	istouched = true
	total_res -= total
	if total_res < 1 :
		$AnimatedSprite.frame = 0
		max_res = 6+randi()%4+1
		istouched = false
		need_build = true

func get_current_frame():
	return $AnimatedSprite.frame

func set_current_frame(idx):
	$AnimatedSprite.frame = idx
