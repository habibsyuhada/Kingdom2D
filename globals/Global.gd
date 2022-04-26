extends Node


export (PackedScene) var Worker_Instance
var data_player = {
	"food": 0,
	"stone": 0,
	"wood": 0,
	"max_storage": 100,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func add_people(object_target):
	var people_container = get_node_or_null("/root/World/Map/People")
	if people_container and object_target:
		people_container.add_child(object_target)

func waits(s):
	var t = Timer.new()
	t.one_shot = true
	self.add_child(t)
	t.start(s)
	yield(t, "timeout")
	t.queue_free()
