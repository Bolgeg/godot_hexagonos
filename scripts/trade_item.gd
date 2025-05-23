extends PanelContainer

signal resource_button_pressed(index:int,origin_index:int)

var resource_index:=0

func _ready() -> void:
	%ResourceButton.resource_index=resource_index
	%ResourceButton.update_icon()

func set_resource_button_enabled(enabled:Array):
	%ResourceButton.disabled=not enabled[%ResourceSelector.selected]

func _on_resource_button_pressed() -> void:
	resource_button_pressed.emit(resource_index,%ResourceSelector.selected)
