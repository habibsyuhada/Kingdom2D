extends Area2D

var total_res = 1
var max_res = 8
var minimal_total_res_to_transform = 4
var istouched = false

func _ready():
	var frames = $AnimatedSprite.frames
	$AnimatedSprite.frame = randi()%(frames.get_frame_count("default") - 1) + 1
	max_res = 4+randi()%4+1

func _on_Tree_area_entered(area):
	if area.is_in_group("Buildings"):
		queue_free()

func increase_resource(total = 1):
	if total_res < max_res and !istouched:
		var random = randi()%100+1
		if random < 33:
			total_res += total
	if $AnimatedSprite.frame == 0 and total_res > minimal_total_res_to_transform:
		var frames = $AnimatedSprite.frames
		$AnimatedSprite.frame = randi()%(frames.get_frame_count("default") - 1) + 1

func decrease_resource(total = 1):
	istouched = true
	total_res -= total
	if total_res < 1 :
		$AnimatedSprite.frame = 0
		max_res = 6+randi()%4+1
		istouched = false

func get_current_frame():
	return $AnimatedSprite.frame
