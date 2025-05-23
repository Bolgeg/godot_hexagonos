extends Control

signal resource_button_pressed(output_resource_index:int,input_resource_index:int)

func _ready() -> void:
	for i in range(5):
		var trade_item:=preload("res://scenes/trade_item.tscn").instantiate()
		trade_item.resource_index=i
		%ItemContainer.add_child(trade_item)
		trade_item.resource_button_pressed.connect(_on_resource_button_pressed)

func set_bottom_center_position(center:Vector2):
	global_position=center+Vector2(-%PanelContainer.size.x*0.5,-%PanelContainer.size.y)

func set_resource_buttons_enabled(enabled:Array):
	for child in %ItemContainer.get_children():
		child.set_resource_button_enabled(enabled[child.resource_index])

func _on_resource_button_pressed(index:int,origin_index:int):
	resource_button_pressed.emit(index,origin_index)
