extends Node2D

var game:Node2D

func _ready() -> void:
	%StartGameContainer.visible=true
	hide_message_containers()

func create_game():
	game=preload("res://scenes/game.tscn").instantiate()
	game.won.connect(_on_won)
	game.lost.connect(_on_lost)
	
	var color:int=%ColorOptionButton.selected
	for i in range(4):
		game.player_colors[i]=(color+i)%4
	
	%GameContainer.add_child(game)

func hide_message_containers():
	%WonMessageContainer.visible=false
	%LostMessageContainer.visible=false

func _on_won():
	game.process_mode=Node.PROCESS_MODE_DISABLED
	%WonMessageContainer.visible=true

func _on_lost():
	game.process_mode=Node.PROCESS_MODE_DISABLED
	%LostMessageContainer.visible=true

func play_again():
	hide_message_containers()
	game.queue_free()
	%GameContainer.remove_child(game)
	%StartGameContainer.visible=true

func _on_won_play_again_button_pressed() -> void:
	play_again()

func _on_lost_play_again_button_pressed() -> void:
	play_again()

func _on_start_game_button_pressed() -> void:
	%StartGameContainer.visible=false
	create_game()
