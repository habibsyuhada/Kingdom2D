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
	AI_Core.data_ai["swordman"] += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	nav = Global.astar_tile
	velocity = Vector2.ZERO
	match state:
		AI_Core.IDLE:
			idle()
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

func inventory_store():
	for item in inventory:
		AI_Core.data_ai[item] += 1
	inventory.clear()

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
