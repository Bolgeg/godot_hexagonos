extends Node2D

@onready var map_node:Node2D=%Map

var map:=Map.new()

func _ready() -> void:
	map.initialize_randomly()
	map_node.update(map)
