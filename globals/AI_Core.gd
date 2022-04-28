extends Node2D

enum {IDLE, CUT_TREE, BUILD, GATHER_FOOD}

var req_level = [
	{
		"wood" : 50,
		"food" : 50,
		"house" : 2,
		"wheat_field" : 4*2,
		"worker" : 2,
		"worker_cut_tree" : 1,
		"worker_gather_food" : 1,
	}
]
var level = 0
var data_ai = {
	"wood" : 0,
	"food" : 0,
	"house" : 0,
	"wheat_field" : 0,
	"worker" : 0,
	"worker_cut_tree_intance" : [],
	"worker_gather_food_intance" : [],
}
var is_ai_process = true
var is_waiting_process = false

func _physics_process(delta):
	if is_ai_process and !is_waiting_process:
		is_waiting_process = true
		ai_process()
		is_waiting_process = false
	
func ai_process():
	var level_up = true
	var no = 0
	for req_list in req_level:
		if level_up:
			level = no
			for req in req_list.keys():
				if req == "worker_cut_tree":
					if req_list[req] != data_ai["worker_cut_tree_intance"].size() :
						for body in get_tree().get_nodes_in_group("Worker"):
							if body.state == AI_Core.IDLE and req_list[req] != data_ai["worker_cut_tree_intance"].size():
								body.change_state(AI_Core.CUT_TREE)
				elif req == "worker_gather_food":
					if req_list[req] != data_ai["worker_gather_food_intance"].size() :
						for body in get_tree().get_nodes_in_group("Worker"):
							if body.state == AI_Core.IDLE and req_list[req] != data_ai["worker_gather_food_intance"].size():
								body.change_state(AI_Core.GATHER_FOOD)
				elif req_list[req] != data_ai[req] :
					level_up = false
					if req == "wheat_field":
						if data_ai["wood"] >= MasterData.building["wheat_field"]["cost"]["wood"]:
							data_ai["wood"] -= MasterData.building["wheat_field"]["cost"]["wood"]
							build_wheat_field()
		no += 1
	
	for building in get_tree().get_nodes_in_group("Building"):
		if building.need_build:
			if !building.worker_build:
				for worker in get_tree().get_nodes_in_group("Worker"):
					if worker.state == AI_Core.IDLE:
						building.worker_build = worker
						worker.change_state(AI_Core.BUILD)
				if !building.worker_build:
					var worker = []
					for body in get_tree().get_nodes_in_group("Worker"):
						if body.state == AI_Core.IDLE:
							worker.push_back(body)
						elif !body.isinaction and body.state != AI_Core.BUILD:
							worker.push_back(body)
					if worker.size() > 0 :
						var select_worker = worker[randi()%worker.size()]
						building.worker_build = select_worker
						select_worker.change_state(AI_Core.BUILD)

func build_wheat_field():
	var territory_tilemap = Global.territory_tile.get_used_cells_by_id (0)
	var tilemap = []
	for tile in territory_tilemap:
		var tilecell = Global.world_tile.get_cell(tile.x, tile.y)
		if tilecell in [10, 11, 12, 13, 14, 15]:
			var world_position = Global.world_tile.map_to_world(tile) + Vector2(8, 8)
			var space_state = get_world_2d().direct_space_state
			var result = space_state.intersect_point(world_position)
			if result.size() == 0:
				tilemap.push_back(tile)
	var select_tile = tilemap[randi()%tilemap.size()]
	var world_position = Global.world_tile.map_to_world(select_tile) + Vector2(8, 8)
	var wheat_field = Global.Wheat_Field_Instance.instance()
	wheat_field.position = world_position
	Global.add_building(wheat_field)
		
