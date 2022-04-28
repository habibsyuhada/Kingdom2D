extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var object_name = "keep"
var need_build = false
var worker_build = null

# Called when the node enters the scene tree for the first time.
func _ready():
	var worker = Global.Worker_Instance.instance()
	worker.position = position
	Global.add_people(worker)
	var worker2 = Global.Worker_Instance.instance()
	worker2.position = position
	Global.add_people(worker2)
	Global.change_territory(position, MasterData.building[object_name]["territory"], 2)
	AI_Core.data_ai["max_people"] += MasterData.building[object_name]["max_people"]

func _on_Keep_area_entered(area):
	#print(area.get_parent())
	pass
