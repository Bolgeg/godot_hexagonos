class_name Map
extends RefCounted

const RESOURCE_TYPES:=5

var radius:=2

var cell_coordinates:=[]

var cells:=[]

func _init(radius_to_set:int=2) -> void:
	radius=radius_to_set
	for y in range(radius*2+1):
		cells.append([])
		for x in range(radius*2+1):
			cells[y].append(MapCell.new())
			if x+y>=radius and x+y<=radius*2*2-radius:
				cell_coordinates.append(Vector2i(x,y))

func initialize_randomly():
	var resources:=[]
	for i in cell_coordinates.size():
		resources.append(i%RESOURCE_TYPES)
	
	var numbers:=[]
	for i in cell_coordinates.size():
		numbers.append(i%10+2)
	
	resources.shuffle()
	numbers.shuffle()
	
	for i in cell_coordinates.size():
		cells[cell_coordinates[i].y][cell_coordinates[i].x]=MapCell.new(resources[i],numbers[i])
