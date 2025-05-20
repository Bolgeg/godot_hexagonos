extends Node2D

@onready var map_node:Node2D=%Map
@onready var player_status_squares:Control=%PlayerStatusSquares
@onready var player_status_square_timer:Timer=%PlayerStatusSquareTimer
@onready var ai_wait_timer:Timer=%AIWaitTimer

enum GameStage{PUT_FIRST_VILLAGE,PUT_SECOND_VILLAGE,MAIN_STAGE}
var game_stage:=GameStage.PUT_FIRST_VILLAGE
var game_stage_turn_count:=0

var map:=Map.new()

var player_colors:=[0,1,2,3]
var active_player:=0
var ai_waiting:=false
var turn_start:=true

enum PlayerState{ACTION_SELECTION,NEXT_TURN,PUT_VILLAGE,PUT_ROAD}
var player_state:=PlayerState.ACTION_SELECTION

func _ready() -> void:
	map.initialize_randomly()
	map_node.update(map)
	
	active_player=randi_range(0,3)
	
	update_player_status_squares()

func _process(_delta: float) -> void:
	
	if active_player==0:
		if turn_start:
			if game_stage==GameStage.PUT_FIRST_VILLAGE or game_stage==GameStage.PUT_SECOND_VILLAGE:
				player_state=PlayerState.PUT_VILLAGE
			else:
				player_state=PlayerState.ACTION_SELECTION
			turn_start=false
		
		if player_state==PlayerState.NEXT_TURN:
			next_turn()
	else:
		if not ai_waiting:
			ai_wait_timer.start()
			ai_waiting=true
		elif ai_wait_timer.is_stopped():
			ai_waiting=false
			execute_ai_turn()
			next_turn()
	
	if player_state==PlayerState.PUT_VILLAGE:
		map_node.selection_mode=map_node.SelectionMode.CORNER
	elif player_state==PlayerState.PUT_ROAD:
		map_node.selection_mode=map_node.SelectionMode.SIDE
	else:
		map_node.selection_mode=map_node.SelectionMode.NONE
	
	map_node.update(map)
	
	update_player_status_squares()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click") and map_node.selection_active:
		if player_state==PlayerState.PUT_VILLAGE:
			if game_stage==GameStage.PUT_FIRST_VILLAGE or game_stage==GameStage.PUT_SECOND_VILLAGE:
				if map.put_village_game_start(map_node.selection_coordinates,player_colors[0]):
					return_to_action_selection()
			else:
				if map.put_village(map_node.selection_coordinates,player_colors[0]):
					return_to_action_selection()
		elif player_state==PlayerState.PUT_ROAD:
			if map.put_road(map_node.selection_coordinates,player_colors[0]):
				return_to_action_selection()

func return_to_action_selection():
	if game_stage==GameStage.PUT_FIRST_VILLAGE or game_stage==GameStage.PUT_SECOND_VILLAGE:
		if player_state==PlayerState.PUT_VILLAGE:
			player_state=PlayerState.PUT_ROAD
		elif player_state==PlayerState.PUT_ROAD:
			player_state=PlayerState.NEXT_TURN
	else:
		player_state=PlayerState.ACTION_SELECTION

func update_player_status_squares():
	for square in player_status_squares.get_children():
		var index:int=square.index
		var t=1-player_status_square_timer.time_left/player_status_square_timer.wait_time
		square.set_state(player_colors[index],active_player==index,t)

func next_turn():
	game_stage_turn_count+=1
	if game_stage==GameStage.PUT_FIRST_VILLAGE:
		if game_stage_turn_count==4:
			game_stage=GameStage.PUT_SECOND_VILLAGE
			game_stage_turn_count=0
		else:
			active_player=(active_player+1)%4
	elif game_stage==GameStage.PUT_SECOND_VILLAGE:
		if game_stage_turn_count==4:
			game_stage=GameStage.MAIN_STAGE
			game_stage_turn_count=0
		else:
			active_player=(active_player+3)%4
	else:
		active_player=(active_player+1)%4
	turn_start=true

func execute_ai_turn():
	pass
