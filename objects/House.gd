extends Area2D


var object_name = "house"
var need_build = true
var worker_build = null

func _ready():
	AI_Core.data_ai[object_name] += 1
	Global.change_territory(position, MasterData.building[object_name]["territory"], 1)

func set_current_frame(idx):
	$AnimatedSprite.frame = idx

func build_complete():
	worker_build = null
	need_build = false
	var frames = $AnimatedSprite.frames
	$AnimatedSprite.frame = randi()%(frames.get_frame_count("default") - 1) + 1
	AI_Core.data_ai["max_people"] += MasterData.building[object_name]["max_people"]
