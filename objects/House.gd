extends Area2D


var object_name = "house"
var need_build = true
var worker_build = null
var team = null

func _ready():
	add_to_group("House " + team)
	add_to_group("Building " + team)
	AI_Core.data_ai[team][object_name] += 1
	Global.change_territory(position, MasterData.building[object_name]["territory"], 1, team)

func set_current_frame(idx):
	$AnimatedSprite.frame = idx

func build_complete():
	worker_build = null
	need_build = false
	var frames = $AnimatedSprite.frames
	$AnimatedSprite.animation = str("Team " + team)
	$AnimatedSprite.frame = randi()%(frames.get_frame_count("Team " + team) - 1) + 1
	AI_Core.data_ai[team]["max_people"] += MasterData.building[object_name]["max_people"]
