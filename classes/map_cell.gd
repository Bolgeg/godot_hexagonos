class_name MapCell
extends RefCounted

var resource:=0
var number:=6

var corner_structures:=[]
var side_structures:=[]

func _init(resource_to_set:int=0,number_to_set:int=6) -> void:
	resource=resource_to_set
	number=number_to_set
	for i in range(6):
		corner_structures.append(Structure.new())
		side_structures.append(Structure.new())
