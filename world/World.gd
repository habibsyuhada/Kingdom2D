extends Node2D


export (PackedScene) var Tree_Instance
onready var astar_tilemap = get_node_or_null("/root/World/Navigation2D/Astar_Tilemap")


# Called when the node enters the scene tree for the first time.
func _ready():
	var tilemap = $Navigation2D/TileMap
	var tileset = tilemap.tile_set
	#for tile in tileset.get_tiles_ids():
		#print(tile)
	#print("WORLD")
	
	#var tilemap_size = tilemap.get_used_rect()
	#astar_tilemap.map_size = tilemap_size.end
	if astar_tilemap :
		for tile in tilemap.get_used_cells():
			if tilemap.get_cell(tile.x, tile.y) in [7, 8, 9] :
				astar_tilemap.change_tile_cell(tile, 0)
			elif tilemap.get_cell(tile.x, tile.y) in [13, 14, 15] :
				var random = randi()%100+1
				if random > 3:
					var tree = Tree_Instance.instance()
					tree.position = tilemap.map_to_world(tile)
					tree.position += Vector2(8, 8)
					$Map/Trees.add_child(tree)
					var id_astar = astar_tilemap.astar_node.get_closest_point(Vector3(tile.x, tile.y, 0.0))
					astar_tilemap.astar_node.set_point_weight_scale(id_astar, 1.3)
			elif tilemap.get_cell(tile.x, tile.y) in [10, 11, 12] :
				var random = randi()%100+1
				if random < 3:
					var tree = Tree_Instance.instance()
					tree.position = tilemap.map_to_world(tile)
					tree.position += Vector2(8, 8)
					$Map/Trees.add_child(tree)
					var id_astar = astar_tilemap.astar_node.get_closest_point(Vector3(tile.x, tile.y, 0.0))
					astar_tilemap.astar_node.set_point_weight_scale(id_astar, 1.3)
		astar_tilemap.astar_defined_point_obstacles()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
