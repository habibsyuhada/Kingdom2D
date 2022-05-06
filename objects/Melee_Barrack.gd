extends Area2D


var object_name = "melee_barrack"
var need_build = true
var worker_build = null
var intraining = false
var worker_train = null
var team = null

func _ready():
	add_to_group("Melee Barrack " + team)
	add_to_group("Building " + team)
	AI_Core.data_ai[team][object_name] += 1
	Global.change_territory(position, MasterData.building[object_name]["territory"], 1, team)

func set_current_frame(idx):
	$AnimatedSprite.frame = idx

func build_complete():
	worker_build = null
	need_build = false
	var frames = $AnimatedSprite.frames
	$AnimatedSprite.animation = str("Team " + team)
	$AnimatedSprite.frame = randi()%(frames.get_frame_count("Team " + team) - 1) + 1
	AI_Core.data_ai[team]["max_people"] += MasterData.building[object_name]["max_people"]

func start_training():
	intraining = true
	worker_train = null
	yield(Global.waits(MasterData.unit["swordman"]["build_time"]), "completed")
	var unit = Global.Swordman_Instance.instance()
	unit.team = team
	unit.position = position
	Global.add_people(unit)
	intraining = false
