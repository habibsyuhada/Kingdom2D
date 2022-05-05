extends Area2D


var object_name = "wheat_field"
var total_res = 2
var max_res = 8
var istouched = false
var need_build = true
var worker_build = null
var team = null

func _ready():
	AI_Core.data_ai[team][object_name] += 1
	add_to_group("White Field " + team)
	add_to_group("Building " + team)
	max_res = 8+randi()%4+1
	Global.change_territory(position, MasterData.building[object_name]["territory"], 1, team)

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

func build_complete():
	worker_build = null
	need_build = false
	$AnimatedSprite.frame = 1
