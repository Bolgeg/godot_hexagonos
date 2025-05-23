extends Control

signal pressed(index:int)

var building_index:=0
var building_name:=""
var tooltip:=""

func set_values(building_index_to_set:int,building_name_to_set:String,tooltip_to_set:String):
	building_index=building_index_to_set
	building_name=building_name_to_set
	tooltip=tooltip_to_set

func set_state_enabled(enabled:bool):
	%Button.disabled= not enabled

func _ready() -> void:
	%Button.text="Build "+building_name
	%Button.tooltip_text=tooltip

func _on_button_pressed() -> void:
	pressed.emit(building_index)
