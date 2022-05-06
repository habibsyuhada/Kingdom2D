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
var isenemyinsight = false
var detected = {
	"enemy" : [],
}
var inventory = []
var max_inventory = 4
var dir_animation = ""
export var team = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	AI_Core.data_ai[team]["swordman"] += 1
	add_to_group("Swordman " + team)
	add_to_group("Unit " + team)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	nav = Global.astar_tile
	velocity = Vector2.ZERO
	if detected["enemy"].size() > 0:
		change_state(AI_Core.ATTACK_ENEMY)
	match state:
		AI_Core.IDLE:
			idle()
		AI_Core.PATROL:
			patrol()
		AI_Core.ATTACK_ENEMY:
			attack_enemy()
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
				$AnimatedSprite.animation = str(team, "_Walk_", dir_animation)
			move_and_slide(velocity)

func idle():
	if path.size() == 0:
		var radius = 64
		var target_pos = Vector2(rand_range(-radius, radius), rand_range(-radius, radius))
		target_pos = position + target_pos
		path = nav.get_astar_path(position, target_pos)
		change_state(AI_Core.PATROL)

func patrol():
	if path.size() == 0:
		var territory_tilemap = Global.territory_tile.get_used_cells_by_id(Global.territory_tileset[team])
		var selected_tile = territory_tilemap[randi()%territory_tilemap.size()]
		var target_pos = Global.territory_tile.map_to_world(selected_tile) + Vector2(8, 8)
		path = nav.get_astar_path(position, target_pos)

func attack_enemy():
	
	var selected_enemy = null
	for enemy in detected["enemy"]:
		if !selected_enemy or (position - enemy.position).length() < (position - selected_enemy.position).length():
			selected_enemy = enemy
	if selected_enemy:
		if path.size() == 0 or Global.territory_tile.map_to_world (Global.territory_tile.world_to_map(selected_enemy.position)) + Vector2(8, 8) != path[path.size() - 1]:
			var target_pos = selected_enemy.position
			path = nav.get_astar_path(position, target_pos)
			path.remove(0)

func inventory_store():
	for item in inventory:
		AI_Core.data_ai[team][item] += 1
	inventory.clear()

func change_state(state_target):
	if !iswaiting:
		iswaiting = true
		if state_target != AI_Core.IDLE:
			yield(Global.waits(rand_range(1,3)), "completed")
		if !isinaction:
			state = state_target
		iswaiting = false

func _on_AnimatedSprite_animation_finished():
	pass # Replace with function body.

func _on_Sight_area_entered(area):
	var body = area.get_parent()
	if !body in detected["enemy"]:
		if body.is_in_group("Units"):
			if !body.is_in_group("Unit " + team):
				detected["enemy"].push_back(body)

func _on_Sight_area_exited(area):
	var body = area.get_parent()
	if body in detected["enemy"]:
		detected["enemy"].erase(body)
