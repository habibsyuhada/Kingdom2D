extends Node2D

#randi()%10+1 returns an int from 1 to 10
#randf()*10.0+1.0 returns a float from 1.0 to 10.999999~
#rand_range(1,11) returns a float from 1.0 to 10.999999~
#range(1,11)[randi()%range(1,11).size()] is a little ugly and less efficient but returns an int 
#from 1 to 10 without you having to do the math yourself (aka the 11+1 part) 
#because all you need to do is set the range()




export (PackedScene) var Worker_Instance
export (PackedScene) var Swordman_Instance
export (PackedScene) var Wheat_Field_Instance
export (PackedScene) var House_Instance
export (PackedScene) var Melee_Barrack_Instance
onready var territory_tile = get_node_or_null("/root/World/Navigation2D/Territory")
onready var world_tile = get_node_or_null("/root/World/Navigation2D/TileMap")
onready var astar_tile = get_node_or_null("/root/World/Navigation2D/Astar_Tilemap")
var territory_tileset = {
	"Red": 0,
	"Cyan": 1,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

func _physics_process(delta):
	if Input.is_action_just_released("`"):
		Engine.time_scale = 0.1
	elif Input.is_action_just_released("1"):
		Engine.time_scale = 1
	elif Input.is_action_just_released("2"):
		Engine.time_scale = 2
	elif Input.is_action_just_released("3"):
		Engine.time_scale = 4
	elif Input.is_action_just_released("4"):
		Engine.time_scale = 6

func add_people(object_target):
	var people_container = get_node_or_null("/root/World/Map/People")
	if people_container and object_target:
		people_container.add_child(object_target)
		
func add_building(object_target):
	var building_container = get_node_or_null("/root/World/Map/Building")
	if building_container and object_target:
		building_container.add_child(object_target)

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
	get_tree().call_group("Resource", "increase_resource")

func change_territory(source_position, large, additon, team, force = false):
	if territory_tile:
		var tilepos = territory_tile.world_to_map(source_position)
		tilepos += Vector2(large, large) 
		large += large+additon
		var tile = tilepos
		for y in large:
			tile.y = tilepos.y - y
			for x in large:
				tile.x = tilepos.x - x
				if force:
					territory_tile.set_cell(tile.x, tile, territory_tileset[team])
				elif territory_tile.get_cell(tile.x, tile.y)  == -1 :
					territory_tile.set_cell(tile.x, tile.y, territory_tileset[team])
			
