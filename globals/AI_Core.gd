extends Node2D

enum {IDLE, CUT_TREE, BUILD, GATHER_FOOD}

var req_level = [
	{
		"worker_cut_tree" : 1,
		"worker_gather_food" : 1,
		"wood" : 50,
		"food" : 50,
		"wheat_field" : 6,
	},
	{
		"worker_cut_tree" : 1,
		"worker_gather_food" : 2,
		"wood" : 100,
		"food" : 100,
		"worker" : 3,
		"house" : 1,
	},
	{
		"worker_cut_tree" : 1,
		"worker_gather_food" : 2,
		"wood" : 200,
		"food" : 200,
		"worker" : 6,
		"house" : 3,
		"wheat_field" : 12,
	}
]
var level = 0
var max_level_reached = 0
var data_ai = {
	"wood" : 0,
	"food" : 0,
	"house" : 0,
	"wheat_field" : 0,
	"worker" : 0,
	"max_people" : 0,
	"worker_cut_tree_intance" : [],
	"worker_gather_food_intance" : [],
}
var is_ai_process = true
var is_waiting_process = false

func _physics_process(delta):
	if is_ai_process and !is_waiting_process:
		is_waiting_process = true
		yield(ai_process(), "completed")
		is_waiting_process = false
func ai_process():
	var level_up = true
	var no = 0
	var level_set = false
	for req_list in req_level:
		if level_up or no <= max_level_reached:
			for req in req_list:
				if req == "worker_cut_tree":
					if req_level[max_level_reached]["wood"] > data_ai["wood"]:
						if req_list[req] >= data_ai["worker_cut_tree_intance"].size() :
							for body in get_tree().get_nodes_in_group("Worker"):
								if body.state == AI_Core.IDLE and req_list[req] != data_ai["worker_cut_tree_intance"].size():
									body.change_state(AI_Core.CUT_TREE)
				elif req == "worker_gather_food":
					if req_level[max_level_reached]["food"] > data_ai["food"]:
						if req_list[req] >= data_ai["worker_gather_food_intance"].size() :
							for body in get_tree().get_nodes_in_group("Worker"):
								if body.state == AI_Core.IDLE and req_list[req] != data_ai["worker_gather_food_intance"].size():
									body.change_state(AI_Core.GATHER_FOOD)
				elif req_list[req] > data_ai[req] :
					level_up = false
					if req == "wheat_field" or req == "house":
						var buyable = true
						for cost in MasterData.building[req]["cost"]:
							if data_ai[cost] < MasterData.building[req]["cost"][cost] :
								buyable = false
						if buyable:
							for cost in MasterData.building[req]["cost"]:
								data_ai[cost] -= MasterData.building[req]["cost"][cost] 
							yield(build_wheat_field(req), "completed")
					elif req == "worker":
						level_up = true
						if data_ai["max_people"] > get_total_people():
							var buyable = true
							for cost in MasterData.unit[req]["cost"]:
								if data_ai[cost] < MasterData.unit[req]["cost"][cost] :
									buyable = false
							if buyable:
								for cost in MasterData.unit[req]["cost"]:
									data_ai[cost] -= MasterData.unit[req]["cost"][cost] 
								yield(Global.waits(MasterData.unit[req]["build_time"]), "completed")
								
								var house_list = []
								for building in get_tree().get_nodes_in_group("House"):
									if !building.need_build:
										house_list.push_back(building)
								var worker = Global.Worker_Instance.instance()
								worker.position = house_list[randi()%(house_list.size())].position
								Global.add_people(worker)
		if !level_up and !level_set:
			level = no
			if level > max_level_reached:
				max_level_reached = level
			level_set = true
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
						elif !body.isinaction and body.inventory.size() == 0:
							worker.push_back(body)
					if worker.size() > 0 :
						var select_worker = worker[randi()%worker.size()]
						building.worker_build = select_worker
						select_worker.change_state(AI_Core.BUILD)
			else:
				building.worker_build.change_state(AI_Core.BUILD)
	yield(get_tree(), "idle_frame")

func build_wheat_field(req):
	var req_tile = [10, 11, 12, 13, 14, 15] # wheat_field is default
	var building = Global.Wheat_Field_Instance.instance()
	if req == "house":
		req_tile = [5, 10, 11, 12, 13, 14, 15]
		building = Global.House_Instance.instance()
	
	var territory_tilemap = Global.territory_tile.get_used_cells_by_id (0)
	var tilemap = []
	for tile in territory_tilemap:
		var tilecell = Global.world_tile.get_cell(tile.x, tile.y)
		if tilecell in req_tile:
			var world_position = Global.world_tile.map_to_world(tile) + Vector2(8, 8)
			#world_position = get_node("/root/World/Map/Building/Keep").position
			var space_state = get_world_2d().direct_space_state
			var result = space_state.intersect_point(world_position, 32, [], 0x7FFFFFFF, false, true)
			var count_colider = 0
			for object_col in result:
				if object_col.collider.is_in_group("Building"):
					count_colider += 1
			if count_colider == 0:
				tilemap.push_back(tile)
	
	var select_tile = null
	var field_list = []
	if req == "wheat_field":
		field_list += get_tree().get_nodes_in_group("White Field")
	
	if req == "house":
		field_list += get_tree().get_nodes_in_group("White Field")
		field_list += get_tree().get_nodes_in_group("House")
	
	var district_list = []
	for field in field_list:
		field = Global.world_tile.world_to_map(field.position)
		var district_selected = false
		var no_dist = 0
		for district in district_list:
			for member_dist in district:
				if floor((field - member_dist).length()) < 2:
					district_selected = true
					district_list[no_dist].push_back(field)
					break
			no_dist += 1
		if !district_selected:
			district_list.push_back([field])
	
	var random_dist = randi()%(district_list.size()+1)
	if random_dist == district_list.size():
		select_tile = tilemap[randi()%tilemap.size()]
		print("RANDOM")
	else:
		var random = randi()%(district_list[random_dist].size())
		var radius = 3
		var tile = district_list[random_dist][random]
		tile += Vector2(randi()%radius-1, randi()%radius-1) # Random -1 to 1
		if tile in tilemap:
			select_tile = tile
		else:
			for cost in MasterData.building[req]["cost"]:
				data_ai[cost] += MasterData.building[req]["cost"][cost] 
		
	if select_tile:
		var world_position = Global.world_tile.map_to_world(select_tile) + Vector2(8, 8)
		building.position = world_position
		Global.add_building(building)
	
	yield(get_tree(), "idle_frame")
		
func get_total_people():
	return data_ai["worker"]
