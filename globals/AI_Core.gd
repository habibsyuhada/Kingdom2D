extends Node2D

enum {IDLE, CUT_TREE, BUILD, GATHER_FOOD, TRAIN}

var req_level = {}
var max_level_reached = {}
var data_ai = {}
var is_ai_process = true
var is_waiting_process = false
var team_list = ["Red", "Cyan"]

func _ready():
	for team in team_list:
		max_level_reached[team] = 0
		req_level[team] = get_level_req(max_level_reached[team])
		data_ai[team] = {
			"wood" : 0,
			"food" : 0,
			"house" : 0,
			"wheat_field" : 0,
			"worker" : 0,
			"swordman" : 0,
			"max_people" : 0,
			"worker_cut_tree_intance" : [],
			"worker_gather_food_intance" : [],
			"melee_barrack" : 0,
			"ranged_barrack" : 0,
		}

func _physics_process(delta):
	if is_ai_process and !is_waiting_process:
		is_waiting_process = true
		for team in team_list:
			yield(ai_process(team), "completed")
		is_waiting_process = false


#for ($i=1; $i < 100; $i++) { 
#	$value = [
#		"level" => $i,
#        "wood" => 5 + ($i * 10),
#		"food" => 5 + ($i * 7),
#		"wheat_field" => 4 + floor($i * 0.3),
#		"max_people" => 4 + floor($i * 0.3),
#		"worker" => 4 + floor($i * 0.1),
#	];
#	echo '<pre>';
#	print_r($value);
#	echo '</pre>';
#}

func get_level_req(level_req):
	var based_req_level = {
		"wood" : 5,
		"food" : 5,
		"wheat_field" : 4,
		"max_people" : 2,
		"worker" : 2,
	}
	if level_req > 0 :
		based_req_level = {
			"wood" : 5 + floor(level_req * 10),
			"food" : 5 + floor(level_req * 8),
			"wheat_field" : 4 + floor(level_req * 0.3),
			"max_people" : 4 + floor(level_req * 0.3),
			"worker" : 4 + floor(level_req * 0.1),
		}
	return based_req_level
	

func ai_process(team):
	var level_up = true
	var level_set = false
	
	#chack level
	for no in (max_level_reached[team] + 1):
		var req_list = get_level_req(no)
		if level_up or no <= max_level_reached[team]:
			for req in req_list:
				if req_list[req] > data_ai[team][req] :
					if req != "worker":
						level_up = false
					if req == "wheat_field":
						yield(build_wheat_field(req, team), "completed")
					elif req == "max_people":
						var forecast_max_people = 0
						for building in get_tree().get_nodes_in_group("Building " + team):
							forecast_max_people += MasterData.building[building.object_name]["max_people"]
						if forecast_max_people < req_list[req]:
							var construct_building = "house"
							yield(build_wheat_field(construct_building, team), "completed")
		if level_up and !level_set:
			if no == max_level_reached[team]:
				max_level_reached[team] += 1
				req_level[team] = get_level_req(max_level_reached[team])
				level_set = true
	
	#check building need to constrcut
	for building in get_tree().get_nodes_in_group("Building " + team):
		if building.need_build:
			if !building.worker_build:
				for worker in get_tree().get_nodes_in_group("Worker " + team):
					if worker.state == AI_Core.IDLE:
						building.worker_build = worker
						worker.change_state(AI_Core.BUILD)
				if !building.worker_build:
					var worker = []
					for body in get_tree().get_nodes_in_group("Worker " + team):
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
				
	#add new worker
	if req_level[team]["max_people"] > get_total_people(team) and data_ai[team]["max_people"] > get_total_people(team):
		var req = "worker"
		var buyable = true
		if data_ai[team]["worker"] < req_level[team]["worker"]:
			pass
		else:
			if data_ai[team]["melee_barrack"] == 0:
				buyable = false
				yield(build_wheat_field("melee_barrack", team), "completed")
#			if data_ai[team]["ranged_barrack"] == 0 and max_level_reached[team] == 9:
#				buyable = false
		for cost in MasterData.unit[req]["cost"]:
			if data_ai[team][cost] < MasterData.unit[req]["cost"][cost] :
				buyable = false
		if buyable:
			for cost in MasterData.unit[req]["cost"]:
				data_ai[team][cost] -= MasterData.unit[req]["cost"][cost] 
			yield(Global.waits(MasterData.unit[req]["build_time"]), "completed")

			var house_list = []
			for building in get_tree().get_nodes_in_group("House " + team):
				if !building.need_build:
					house_list.push_back(building)
			var worker = Global.Worker_Instance.instance()
			worker.position = house_list[randi()%(house_list.size())].position
			worker.team = team
			Global.add_people(worker)
	
	if data_ai[team]["worker"] > req_level[team]["worker"]:
		for building in get_tree().get_nodes_in_group("Melee Barrack"):
			if !building.need_build:
				if !building.worker_train:
					if !building.intraining:
						var worker_list = []
						for body in get_tree().get_nodes_in_group("Worker " + team):
							if body.state == AI_Core.IDLE :
								worker_list.push_back(body)
						if worker_list.size() > 0:
							var select_worker = worker_list[randi()%worker_list.size()]
							select_worker.change_state(AI_Core.TRAIN)
							building.worker_train = select_worker
				else:
					building.worker_train.change_state(AI_Core.TRAIN)
	#change state worker
	var division = []
	if req_level[team]["wood"] > data_ai[team]["wood"]:
		division.push_back("wood")
	if req_level[team]["food"] > data_ai[team]["food"]:
		division.push_back("food")
	if division.size() == 0:
		return yield(get_tree(), "idle_frame")
	var max_employee_division = req_level[team]["worker"] / division.size()
	var no = 0
	for body in get_tree().get_nodes_in_group("Worker " + team):
		if body.state == AI_Core.IDLE :
			var min_worker_division = [data_ai[team]["worker_cut_tree_intance"].size(), data_ai[team]["worker_gather_food_intance"].size()].min()
			no +=1
			if "wood" in division and data_ai[team]["worker_cut_tree_intance"].size() < max_employee_division and data_ai[team]["worker_cut_tree_intance"].size() == min_worker_division :
				body.change_state(AI_Core.CUT_TREE)
			elif "food" in division and data_ai[team]["worker_gather_food_intance"].size() < max_employee_division and data_ai[team]["worker_gather_food_intance"].size() == min_worker_division :
				body.change_state(AI_Core.GATHER_FOOD)
	
	yield(get_tree(), "idle_frame")

func build_wheat_field(req, team):
	var buyable = true
	for cost in MasterData.building[req]["cost"]:
		if data_ai[team][cost] < MasterData.building[req]["cost"][cost] :
			buyable = false
	if buyable:
		for cost in MasterData.building[req]["cost"]:
			data_ai[team][cost] -= MasterData.building[req]["cost"][cost] 
							
		var req_tile = [10, 11, 12, 13, 14, 15] # wheat_field is default
		var building = Global.Wheat_Field_Instance.instance()
		if req in ["house", "melee_barrack"]:
			req_tile = [5, 10, 11, 12, 13, 14, 15]
		if req == "house":
			building = Global.House_Instance.instance()
		if req == "melee_barrack":
			building = Global.Melee_Barrack_Instance.instance()
			
		
		var territory_tilemap = Global.territory_tile.get_used_cells_by_id (Global.territory_tileset[team])
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
					if object_col.collider.is_in_group("Buildings"):
						count_colider += 1
				if count_colider == 0:
					tilemap.push_back(tile)
		
		var select_tile = null
		var field_list = []
		if req == "wheat_field":
			field_list += get_tree().get_nodes_in_group("White Field " + team)
		
		if req in ["house", "melee_barrack"]:
			field_list += get_tree().get_nodes_in_group("House " + team)
			field_list += get_tree().get_nodes_in_group("Melee Barrack")
		
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
		else:
			var random = randi()%(district_list[random_dist].size())
			var radius = 3
			var tile = district_list[random_dist][random]
			tile += Vector2(randi()%radius-1, randi()%radius-1) # Random -1 to 1
			if tile in tilemap:
				select_tile = tile
			else:
				for cost in MasterData.building[req]["cost"]:
					data_ai[team][cost] += MasterData.building[req]["cost"][cost] 
			
		if select_tile:
			var world_position = Global.world_tile.map_to_world(select_tile) + Vector2(8, 8)
			building.position = world_position
			building.team = team
			Global.add_building(building)
	
	yield(get_tree(), "idle_frame")
		
func get_total_people(team):
	return data_ai[team]["worker"] + data_ai[team]["swordman"]
