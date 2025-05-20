extends Control

@export var index:=0

const COLORS:=[
	Color8(255,255,255),
	Color8(255,0,0),
	Color8(255,128,0),
	Color8(0,0,255),
]

func set_state(color:int,active:bool,t:float):
	var final_color:=Color8(0,0,0)
	if color>=0 and color<COLORS.size():
		final_color=COLORS[color]
	%ColorRect.color=final_color
	
	var i:int=round(lerpf(128,224,(sin(t*PI*2)+1)/2))
	var panel_color:= Color8(i,i,i) if active else Color8(128,128,128)
	%Panel.get_theme_stylebox("panel").bg_color=panel_color
