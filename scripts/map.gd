extends Node2D

const TILE_SIZE:=64

@onready var tile_map:TileMapLayer=%TileMapLayer
@onready var tile_numbers:Node2D=%TileNumbers

var map_radius:=2

func _ready()->void:
	center_on_screen()

func center_on_screen():
	var center_offset:=get_cell_center(Vector2i(map_radius,map_radius))
	global_position=Vector2(get_viewport().size)/2-center_offset

func get_cell_center(coordinates:Vector2i)->Vector2:
	return Vector2(coordinates.x+coordinates.y*0.5,coordinates.y*0.75)*TILE_SIZE+Vector2(TILE_SIZE,TILE_SIZE)/2

func update(map:Map):
	for child in tile_numbers.get_children():
		tile_numbers.remove_child(child)
	
	var tile_number_scene:=preload("res://scenes/tile_number.tscn")
	
	for coordinates in map.cell_coordinates:
		var cell:MapCell=map.cells[coordinates.y][coordinates.x]
		tile_map.set_cell(coordinates,0,Vector2i(cell.resource,0))
		
		var tile_number:=tile_number_scene.instantiate()
		tile_number.set_number(cell.number)
		tile_numbers.add_child(tile_number)
		tile_number.position=get_cell_center(coordinates)
