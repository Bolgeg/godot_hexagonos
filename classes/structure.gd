class_name Structure
extends RefCounted

var exists:=false
var type:=0
var player:=0

func _init(exists_to_set:bool=false,type_to_set:int=0,player_to_set:int=0) -> void:
	exists=exists_to_set
	type=type_to_set
	player=player_to_set
