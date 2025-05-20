class_name Structure
extends RefCounted

enum Type{ROAD=0,VILLAGE=1,CITY=2}

var exists:=false
var type:=0
var color:=0

func _init(exists_to_set:bool=false,type_to_set:int=0,color_to_set:int=0) -> void:
	exists=exists_to_set
	type=type_to_set
	color=color_to_set
