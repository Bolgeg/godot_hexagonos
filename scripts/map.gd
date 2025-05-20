extends Node2D

const TILE_SIZE:=64

@onready var tile_map:TileMapLayer=%TileMapLayer
@onready var tile_numbers:Node2D=%TileNumbers
@onready var structures:Node2D=%Structures
@onready var selection_cursor:Node2D=%MapSelectionCursor

var map_radius:=2

enum SelectionMode{NONE,CORNER,SIDE}
var selection_mode:=SelectionMode.NONE

var selection_active:=false
var selection_coordinates:=Vector3i(0,0,0)

func _ready()->void:
	center_on_screen()

func center_on_screen():
	var center_offset:=get_cell_center(Vector2i(1+map_radius,1+map_radius))
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
		child.queue_free()
		tile_numbers.remove_child(child)
	
	for child in structures.get_children():
		child.queue_free()
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
			var corner_structure=map.corner_structures[cell.corner_structures[i]]
			if corner_structure.exists:
				var p:=cell_center+get_corner_structure_offset(i)
				var structure:=structure_scene.instantiate()
				structure.set_type(corner_structure.type,corner_structure.color)
				structures.add_child(structure)
				structure.position=p
				structure.z_index=1
			
			var side_structure=map.side_structures[cell.side_structures[i]]
			if side_structure.exists:
				var p:=cell_center+get_side_structure_offset(i)
				var structure:=structure_scene.instantiate()
				structure.set_type(side_structure.type,side_structure.color)
				structures.add_child(structure)
				structure.position=p
				structure.rotation=get_side_structure_rotation(i)
	
	const SELECTION_MOUSE_RADIUS:=16
	var mouse_position:=get_viewport().get_mouse_position()-global_position
	selection_cursor.set_state(Vector2(0,0),false)
	selection_active=false
	if selection_mode==SelectionMode.CORNER:
		for coordinates in map.cell_coordinates:
			for i in range(6):
				var p:=get_cell_center(coordinates)+get_corner_structure_offset(i)
				if (p-mouse_position).length()<=SELECTION_MOUSE_RADIUS:
					selection_cursor.set_state(p,true)
					selection_active=true
					selection_coordinates=Vector3i(coordinates.x,coordinates.y,i)
	elif selection_mode==SelectionMode.SIDE:
		for coordinates in map.cell_coordinates:
			for i in range(6):
				var p:=get_cell_center(coordinates)+get_side_structure_offset(i)
				if (p-mouse_position).length()<=SELECTION_MOUSE_RADIUS:
					selection_cursor.set_state(p,true)
					selection_active=true
					selection_coordinates=Vector3i(coordinates.x,coordinates.y,i)
