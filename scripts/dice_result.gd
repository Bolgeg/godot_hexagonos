extends Node2D

func set_number(number:int):
	%Label.text=str(number)

func _ready() -> void:
	%Timer.start()

func _process(_delta: float) -> void:
	modulate=Color8(255,255,255,lerp(0,255,%Timer.time_left/%Timer.wait_time))
	if %Timer.is_stopped():
		queue_free()
