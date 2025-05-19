class_name MapCell
extends RefCounted

var resource:=0
var number:=6

func _init(resource_to_set:int=0,number_to_set:int=6) -> void:
	resource=resource_to_set
	number=number_to_set
