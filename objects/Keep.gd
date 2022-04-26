extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var worker = Global.Worker_Instance.instance()
	worker.position = position
	Global.add_people(worker)
	var worker2 = Global.Worker_Instance.instance()
	worker2.position = position
	Global.add_people(worker2)

func _on_Keep_area_entered(area):
	#print(area.get_parent())
	pass
