extends Node2D

func set_center_position(center_position:Vector2):
	position=center_position-%Panel.size/2

func _ready() -> void:
	%Timer.start()

func _process(_delta: float) -> void:
	modulate=Color8(255,255,255,lerp(0,255,%Timer.time_left/%Timer.wait_time))
	if %Timer.is_stopped():
		queue_free()
