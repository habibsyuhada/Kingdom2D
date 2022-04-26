extends Node2D


export (PackedScene) var Tree_Instance


# Called when the node enters the scene tree for the first time.
func _ready():
	var tilemap = $Navigation2D/TileMap
	var tileset = tilemap.tile_set
	for tile in tileset.get_tiles_ids():
		print(tile)
	#for tile in tilemap.get_used_cells():
		#print(tilemap.get_cell(tile.x, tile.y))
		#pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
