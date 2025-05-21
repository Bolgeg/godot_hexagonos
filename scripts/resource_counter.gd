extends Control

const RESOURCE_IMAGE_SIZE:=64

@export var resource_index:=0

func _ready() -> void:
	%TextureRect.texture.region.position.x=resource_index*RESOURCE_IMAGE_SIZE

func update(quantity:int):
	%Label.text=str(quantity)
