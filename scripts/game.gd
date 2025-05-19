extends Node2D

@onready var map_node:Node2D=%Map

var map:=Map.new()

func _ready() -> void:
	map.initialize_randomly()
	
	#----TEST
	map.cells[2][2].corner_structures[0]=Structure.new(true,1,0)
	map.cells[2][2].corner_structures[2]=Structure.new(true,1,1)
	map.cells[2][2].corner_structures[4]=Structure.new(true,2,2)
	map.cells[2][2].side_structures[0]=Structure.new(true,0,0)
	#----
	
	map_node.update(map)
