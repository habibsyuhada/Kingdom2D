extends Node2D


export (PackedScene) var Tree_Instance
var astar_tilemap = null


# Called when the node enters the scene tree for the first time.
func _ready():
	astar_tilemap = Global.astar_tile
	var tilemap = Global.world_tile
	var tileset = tilemap.tile_set
	Global.refresh_resource_timer_start(true)
	
	if astar_tilemap :
		for tile in tilemap.get_used_cells():
			if tilemap.get_cell(tile.x, tile.y) in [8, 9] :
				astar_tilemap.change_tile_cell(tile, 0)
			elif tilemap.get_cell(tile.x, tile.y) in [6] :
				var id_astar = astar_tilemap.astar_node.get_closest_point(Vector3(tile.x, tile.y, 0.0))
				astar_tilemap.astar_node.set_point_weight_scale(id_astar, 1.1)
			elif tilemap.get_cell(tile.x, tile.y) in [7] :
				var id_astar = astar_tilemap.astar_node.get_closest_point(Vector3(tile.x, tile.y, 0.0))
				astar_tilemap.astar_node.set_point_weight_scale(id_astar, 1.5)
			elif tilemap.get_cell(tile.x, tile.y) in [13, 14, 15] :
				var random = randi()%100+1
				if random > 10:
					var tree = Tree_Instance.instance()
					tree.position = tilemap.map_to_world(tile)
					tree.position += Vector2(8, 8)
					$Map/Trees.add_child(tree)
					var id_astar = astar_tilemap.astar_node.get_closest_point(Vector3(tile.x, tile.y, 0.0))
					astar_tilemap.astar_node.set_point_weight_scale(id_astar, 1.3)
			elif tilemap.get_cell(tile.x, tile.y) in [10, 11, 12] :
				var random = randi()%100+1
				if random < 10:
					var tree = Tree_Instance.instance()
					tree.position = tilemap.map_to_world(tile)
					tree.position += Vector2(8, 8)
					$Map/Trees.add_child(tree)
					var id_astar = astar_tilemap.astar_node.get_closest_point(Vector3(tile.x, tile.y, 0.0))
					astar_tilemap.astar_node.set_point_weight_scale(id_astar, 1.3)
		astar_tilemap.astar_defined_point_obstacles()
		AI_Core.is_ai_process = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
