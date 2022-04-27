extends Area2D

func _ready():
	#randi()%3+1
	var frames = $AnimatedSprite.frames
	$AnimatedSprite.frame = randi()%(frames.get_frame_count("default") - 1) + 1



func _on_Tree_area_entered(area):
	if area.is_in_group("Building"):
		queue_free()
