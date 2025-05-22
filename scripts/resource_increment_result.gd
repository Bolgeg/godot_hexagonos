extends Node2D

const RESOURCE_IMAGE_SIZE:=64

var center_position:=Vector2(0,0)

func set_resource(resource:int):
	%Sprite2D.region_rect.position=Vector2(RESOURCE_IMAGE_SIZE*resource,0)

func set_quantity(quantity:int):
	if quantity>=0:
		%Label.text="+"+str(quantity)
	else:
		%Label.text=str(quantity)

func set_center_position(center_position_to_set:Vector2):
	center_position=center_position_to_set

func _ready() -> void:
	%Timer.start()

func _process(_delta: float) -> void:
	modulate=Color8(255,255,255,lerp(0,255,%Timer.time_left/%Timer.wait_time))
	position=center_position-%Panel.size/2+Vector2(0,-64*(1-%Timer.time_left/%Timer.wait_time))
	if %Timer.is_stopped():
		queue_free()
