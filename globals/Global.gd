extends Node


export (PackedScene) var Worker_Instance
var data_player = {
	"food": 0,
	"stone": 0,
	"wood": 0,
	"max_storage": 10,
	"gather_wood": [],
}
var is_ai_process = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

func _physics_process(delta):
	if is_ai_process == true:
		ai_process()
		
func ai_process():
	for body in get_tree().get_nodes_in_group("Worker"):
		if body.state == StateAI.IDLE:
			body.change_state(StateAI.CUT_TREE)

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


func refresh_resource_timer_start(status):
	if status == true :
		$refresh_resource_timer.start()
	else:
		$refresh_resource_timer.stop()

func _on_refresh_resource_timer_timeout():
	get_tree().call_group("Tree", "increase_resource")

