extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var object_name = "keep"
var need_build = false
var worker_build = null
export var team = "Cyan"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Building " + team)
	add_to_group("Storage " + team)
	add_to_group("Keep " + team)
	var worker = Global.Worker_Instance.instance()
	worker.team = team
	worker.position = position
	Global.add_people(worker)
	var worker2 = Global.Worker_Instance.instance()
	worker2.team = team
	worker2.position = position
	Global.add_people(worker2)
	Global.change_territory(position, MasterData.building[object_name]["territory"], 2, team)
	AI_Core.data_ai[team]["max_people"] += MasterData.building[object_name]["max_people"]
	
	$AnimatedSprite.animation = str("Team " + team)
	$AnimatedSprite.frame = randi()%($AnimatedSprite.frames.get_frame_count(str("Team " + team)) - 1) + 1

func _on_Keep_area_entered(area):
	#print(area.get_parent())
	pass
