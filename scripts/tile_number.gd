extends Node2D

func set_number(number:int):
	%Label.text=str(number)
	%Label.label_settings.font_size=32-absi(number-7)*3
	if absi(number-7)<=1:
		%Label.label_settings.font_color=Color8(255,0,0)
	else:
		%Label.label_settings.font_color=Color8(255,255,255)
