extends Node2D

const STRUCTURE_IMAGE_SIZE:=64

func set_type(type:int,color:int):
	%Sprite2D.region_rect.position=Vector2(color,type)*STRUCTURE_IMAGE_SIZE
