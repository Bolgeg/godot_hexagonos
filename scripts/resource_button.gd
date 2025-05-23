extends Button

const RESOURCE_IMAGE_SIZE:=64

var resource_index:=0

func _ready() -> void:
	update_icon()

func update_icon():
	icon.region.position=Vector2(RESOURCE_IMAGE_SIZE*resource_index,0)
