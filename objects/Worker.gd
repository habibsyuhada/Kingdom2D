extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var state: int = AI_Core.IDLE
var velocity = Vector2.ZERO
var speed = 25

var nav = null
var path = []
var cur_path_idx = 0
var threshold = 1

var iswaiting = false
var isinaction = false
var detected = {
	"tree" : [],
}
var inventory = []
var max_inventory = 4
var dir_animation = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	AI_Core.data_ai["worker"] += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	nav = Global.astar_tile
	velocity = Vector2.ZERO
	match state:
		AI_Core.IDLE:
			idle()
		AI_Core.CUT_TREE:
			cut_tree()
		AI_Core.BUILD:
			build()
		AI_Core.GATHER_FOOD:
			gather_food()
	move_navigation()
	
func move_navigation():
	if path.size() > 0:
		if Vector2(position).distance_to(Vector2(path[cur_path_idx].x, path[cur_path_idx].y)) < 1:
			path.remove(0)
		else:
			var direction = path[cur_path_idx] - position
			
			var accel = null
			var cur_speed = speed
			for area in $Body.get_overlapping_areas():
				if area.is_in_group("Tree"):
					var deccel = -0.3
					if !accel or accel > deccel:
						accel = deccel
			var tilepos = Global.world_tile.world_to_map(position)
			var tilecell = Global.world_tile.get_cell(tilepos.x, tilepos.y)
			if tilecell in [6]:
				var deccel = -0.1
				if !accel or accel > deccel:
					accel = deccel
			if tilecell in [7]:
				var deccel = -0.5
				if !accel or accel > deccel:
					accel = deccel
			if accel :
				cur_speed = cur_speed * (1 + accel)
			
			velocity = direction.normalized() * cur_speed
			
			if abs(velocity.x) > abs(velocity.y):
				if velocity.x > 0 :
					dir_animation = "Right"
				else:
					dir_animation = "Left"
			else:
				if velocity.y > 0 :
					dir_animation = "Down"
				else:
					dir_animation = "Up"
			if velocity != Vector2.ZERO:
				$AnimatedSprite.animation = str("Walk_", dir_animation)
			move_and_slide(velocity)

func idle():
	if path.size() == 0:
		var radius = 64
		var target_pos = Vector2(rand_range(-radius, radius), rand_range(-radius, radius))
		target_pos = position + target_pos
		path = nav.get_astar_path(position, target_pos)
		change_state(AI_Core.IDLE)

func cut_tree():
	if AI_Core.data_ai["wood"] >= AI_Core.req_level[AI_Core.level]["wood"]:
		change_state(AI_Core.IDLE)
	else:
		if inventory.size() == max_inventory:
			if path.size() == 0:
				var target_node = null
				for body in get_tree().get_nodes_in_group("Building"):
					if body.is_in_group("Storage"):
						if !target_node or (position - body.position).length() < (position - target_node.position).length():
							target_node = body
				if target_node:
					if nav.world_to_map(position) == nav.world_to_map(target_node.position):
						var selected_tree = null
						for area in $Body.get_overlapping_areas():
							if area.is_in_group("Building") and area.is_in_group("Storage"):
								selected_tree = area
						if selected_tree:
							if !isinaction:
								isinaction = true
								var total_decres = inventory.count("wood")
								for i in total_decres:
									if AI_Core.data_ai["wood"] < AI_Core.req_level[AI_Core.level]["wood"]:
										AI_Core.data_ai["wood"] += 1
								inventory.clear()
								isinaction = false
					else:
						path = nav.get_astar_path(position, target_node.position)
		else:
			if path.size() == 0:
				if detected["tree"].size() > 0:
					var selected_tree = null
					for area in $Body.get_overlapping_areas():
						if area.is_in_group("Tree"):
							if area.get_current_frame() != 0:
								if selected_tree == null or (position - selected_tree).length() > (position - area).length():
									selected_tree = area
					if selected_tree:
						if !isinaction:
							isinaction = true
							$AnimatedSprite.animation = str("Att_", dir_animation)
							yield(Global.waits(2), "completed")
							if inventory.size() < max_inventory:
								inventory.push_back("wood")
								selected_tree.decrease_resource()
							isinaction = false
					elif detected["tree"].size() > 0:
						var i = 0
						var target_pos = null
						while target_pos == null and detected["tree"].size() > i:
							if detected["tree"][i].get_current_frame() != 0:
								if rand_range(1,100) > 50:
									target_pos = detected["tree"][i].position
							i += 1
						if target_pos:
							path = nav.get_astar_path(position, target_pos)
						else:
							idle()
				else:
					idle()

func build():
	if path.size() == 0:
		var selected_building = null
		for building in get_tree().get_nodes_in_group("Building"):
			if building.worker_build == self:
				selected_building = building
		if selected_building:
			for area in $Body.get_overlapping_areas():
				if area == selected_building:
					if !isinaction:
						isinaction = true
						$AnimatedSprite.animation = str("Att_", dir_animation)
						yield(Global.waits(MasterData.building[selected_building.object_name]["build_time"]), "completed")
						selected_building.worker_build = null
						selected_building.need_build = false
						selected_building.set_current_frame(1)
						isinaction = false
			path = nav.get_astar_path(position, selected_building.position)
		else:
			change_state(AI_Core.IDLE)

func gather_food():
	if AI_Core.data_ai["food"] >= AI_Core.req_level[AI_Core.level]["food"]:
		change_state(AI_Core.IDLE)
	else:
		if path.size() == 0:
			if inventory.size() == max_inventory:
				var target_node = null
				for body in get_tree().get_nodes_in_group("Building"):
					if body.is_in_group("Storage"):
						if !target_node or (position - body.position).length() < (position - target_node.position).length():
							target_node = body
				if target_node:
					if nav.world_to_map(position) == nav.world_to_map(target_node.position):
						var selected_tree = null
						for area in $Body.get_overlapping_areas():
							if area.is_in_group("Building") and area.is_in_group("Storage"):
								selected_tree = area
						if selected_tree:
							if !isinaction:
								isinaction = true
								var total_decres = inventory.count("food")
								for i in total_decres:
									if AI_Core.data_ai["food"] < AI_Core.req_level[AI_Core.level]["food"]:
										AI_Core.data_ai["food"] += 1
								inventory.clear()
								isinaction = false
					else:
						path = nav.get_astar_path(position, target_node.position)
			else:
				var selected_field = null
				for field in get_tree().get_nodes_in_group("White Field"):
					if field.get_current_frame() == 3:
						selected_field = field
				if selected_field:
					for area in $Body.get_overlapping_areas():
						if area == selected_field:
							if !isinaction:
								isinaction = true
								$AnimatedSprite.animation = str("Att_", dir_animation)
								yield(Global.waits(2), "completed")
								if inventory.size() < max_inventory:
									inventory.push_back("food")
									selected_field.decrease_resource()
								isinaction = false
					path = nav.get_astar_path(position, selected_field.position)
				else:
					change_state(AI_Core.IDLE)

func change_state(state_target):
	if !iswaiting:
		iswaiting = true
		if state_target != AI_Core.IDLE:
			yield(Global.waits(rand_range(1,3)), "completed")
		if !isinaction:
			state = state_target
			AI_Core.data_ai["worker_cut_tree_intance"].erase(self)
			AI_Core.data_ai["worker_gather_food_intance"].erase(self)
			if state == AI_Core.CUT_TREE:
				AI_Core.data_ai["worker_cut_tree_intance"].push_back(self)
			elif state == AI_Core.GATHER_FOOD:
				AI_Core.data_ai["worker_gather_food_intance"].push_back(self)
		iswaiting = false

func _on_Sight_area_entered(area):
	if area.is_in_group("Tree"):
		detected["tree"].push_back(area)

func _on_Sight_area_exited(area):
	if area.is_in_group("Tree"):
		detected["tree"].erase(area)


func _on_AnimatedSprite_animation_finished():
	pass # Replace with function body.
