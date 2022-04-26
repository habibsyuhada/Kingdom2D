extends Area2D

func _ready():
	#randi()%3+1
	var frames = $AnimatedSprite.frames
	$AnimatedSprite.frame = randi()%(frames.get_frame_count("default") - 1) + 1
