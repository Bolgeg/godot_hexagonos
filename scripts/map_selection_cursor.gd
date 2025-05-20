extends Node2D

func _ready() -> void:
	visible=false

func set_state(center_position:Vector2,set_if_visible:bool):
	position=center_position-%Panel.size/2
	visible=set_if_visible
