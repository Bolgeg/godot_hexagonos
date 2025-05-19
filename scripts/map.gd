extends Node2D

const TILE_SIZE:=64

@onready var tile_map:TileMapLayer=%TileMapLayer
@onready var tile_numbers:Node2D=%TileNumbers
@onready var structures:Node2D=%Structures

var map_radius:=2

func _ready()->void:
	center_on_screen()

func center_on_screen():
	var center_offset:=get_cell_center(Vector2i(map_radius,map_radius))
	global_position=Vector2(get_viewport().size)/2-center_offset

func get_cell_center(coordinates:Vector2i)->Vector2:
	return Vector2(coordinates.x+coordinates.y*0.5,coordinates.y*0.75)*TILE_SIZE+Vector2(TILE_SIZE,TILE_SIZE)/2

func get_corner_structure_offset(corner:int)->Vector2:
	var offset:=Vector2(0,0)
	match corner:
		0:
			offset=Vector2(0,-1)
		1:
			offset=Vector2(1,-0.5)
		2:
			offset=Vector2(1,0.5)
		3:
			offset=Vector2(0,1)
		4:
			offset=Vector2(-1,0.5)
		5:
			offset=Vector2(-1,-0.5)
	return offset*TILE_SIZE/2

func get_side_structure_offset(side:int)->Vector2:
	return (get_corner_structure_offset(side)+get_corner_structure_offset((side+1)%6))/2

func get_side_structure_rotation(side:int)->float:
	return (get_corner_structure_offset((side+1)%6)-get_corner_structure_offset(side)).angle()

func update(map:Map):
	for child in tile_numbers.get_children():
		tile_numbers.remove_child(child)
	
	for child in structures.get_children():
		structures.remove_child(child)
	
	var tile_number_scene:=preload("res://scenes/tile_number.tscn")
	var structure_scene:=preload("res://scenes/structure.tscn")
	
	for coordinates in map.cell_coordinates:
		var cell:MapCell=map.cells[coordinates.y][coordinates.x]
		tile_map.set_cell(coordinates,0,Vector2i(cell.resource,0))
		
		var cell_center:=get_cell_center(coordinates)
		
		var tile_number:=tile_number_scene.instantiate()
		tile_number.set_number(cell.number)
		tile_numbers.add_child(tile_number)
		tile_number.position=cell_center
		
		for i in range(6):
			if cell.corner_structures[i].exists:
				var p:=cell_center+get_corner_structure_offset(i)
				var structure:=structure_scene.instantiate()
				structure.set_type(cell.corner_structures[i].type,cell.corner_structures[i].player)
				structures.add_child(structure)
				structure.position=p
				structure.z_index=1
			
			if cell.side_structures[i].exists:
				var p:=cell_center+get_side_structure_offset(i)
				var structure:=structure_scene.instantiate()
				structure.set_type(cell.side_structures[i].type,cell.side_structures[i].player)
				structures.add_child(structure)
				structure.position=p
				structure.rotation=get_side_structure_rotation(i)
