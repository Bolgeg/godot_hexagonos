extends Node2D

@onready var map_node:Node2D=%Map
@onready var player_status_squares:Control=%PlayerStatusSquares
@onready var player_status_square_timer:Timer=%PlayerStatusSquareTimer
@onready var ai_wait_timer:Timer=%AIWaitTimer
@onready var resource_counter_container:HBoxContainer=%ResourceCounterContainer
@onready var build_button_container:HBoxContainer=%BuildButtonContainer
@onready var foreground_node_container:CanvasLayer=%ForegroundNodeContainer

const INCREMENT_RESULT_DISTANCE:=72
const INCREMENT_RESULT_HEIGHT:=64

enum GameStage{PUT_FIRST_VILLAGE,PUT_SECOND_VILLAGE,MAIN_STAGE}
var game_stage:=GameStage.PUT_FIRST_VILLAGE
var game_stage_turn_count:=0

enum ResourceType{WOOD=0,CLAY=1,SHEEP=2,STONE=3,WHEAT=4}

const BUILDING_COSTS:=[
	[1,1,0,0,0],
	[1,1,1,0,1],
	[0,0,0,3,2],
]

var map:=Map.new()

var player_colors:=[0,1,2,3]
var players:=[Player.new(),Player.new(),Player.new(),Player.new()]
var active_player:=0
var ai_waiting:=false
var turn_start:=true

enum PlayerState{ACTION_SELECTION,NEXT_TURN,PUT_VILLAGE,PUT_ROAD,PUT_CITY}
var player_state:=PlayerState.ACTION_SELECTION

func _ready() -> void:
	map.initialize_randomly()
	map_node.update(map)
	
	active_player=randi_range(0,3)
	
	update_player_status_squares()
	
	create_build_buttons()

func create_build_buttons():
	var build_button_scene:=preload("res://scenes/build_button.tscn")
	var buildings:=[
		{
			"index":0,
			"name":"road",
			"tooltip":"1 wood, 1 clay",
		},
		{
			"index":1,
			"name":"village",
			"tooltip":"1 wood, 1 clay, 1 sheep, 1 wheat",
		},
		{
			"index":2,
			"name":"city",
			"tooltip":"3 stone, 2 wheat",
		},
	]
	for building in buildings:
		var build_button:=build_button_scene.instantiate()
		build_button.set_values(building.index,building.name,building.tooltip)
		build_button.pressed.connect(_on_build_button_pressed)
		build_button_container.add_child(build_button)

func update_build_buttons():
	for button in build_button_container.get_children():
		var index=button.building_index
		var enabled:=false
		if active_player==0 and game_stage==GameStage.MAIN_STAGE:
			if player_state==PlayerState.ACTION_SELECTION:
				if players[0].has_resources(BUILDING_COSTS[index]):
					enabled=true
		button.set_state_enabled(enabled)

func _process(_delta: float) -> void:
	
	if active_player==0:
		if turn_start:
			if game_stage==GameStage.PUT_FIRST_VILLAGE or game_stage==GameStage.PUT_SECOND_VILLAGE:
				player_state=PlayerState.PUT_VILLAGE
			else:
				player_state=PlayerState.ACTION_SELECTION
				generate_resources()
			turn_start=false
		
		if player_state==PlayerState.NEXT_TURN:
			next_turn()
	else:
		if not ai_waiting:
			ai_wait_timer.start()
			ai_waiting=true
			if game_stage==GameStage.MAIN_STAGE:
				generate_resources()
		elif ai_wait_timer.is_stopped():
			ai_waiting=false
			execute_ai_turn()
			next_turn()
	
	if player_state==PlayerState.PUT_VILLAGE or player_state==PlayerState.PUT_CITY:
		map_node.selection_mode=map_node.SelectionMode.CORNER
	elif player_state==PlayerState.PUT_ROAD:
		map_node.selection_mode=map_node.SelectionMode.SIDE
	else:
		map_node.selection_mode=map_node.SelectionMode.NONE
	
	map_node.update(map)
	
	update_player_status_squares()
	update_player_bar()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click") and map_node.selection_active:
		if player_state==PlayerState.PUT_VILLAGE:
			if game_stage==GameStage.PUT_FIRST_VILLAGE or game_stage==GameStage.PUT_SECOND_VILLAGE:
				if map.put_village_game_start(map_node.selection_coordinates,player_colors[0]):
					if game_stage==GameStage.PUT_SECOND_VILLAGE:
						add_initial_resources_to_player(active_player,map_node.selection_coordinates)
					return_to_action_selection()
			else:
				if map.put_village(map_node.selection_coordinates,player_colors[0]):
					pay_building(BUILDING_COSTS[1],active_player)
					return_to_action_selection()
		elif player_state==PlayerState.PUT_ROAD:
			if map.put_road(map_node.selection_coordinates,player_colors[0]):
				if game_stage==GameStage.MAIN_STAGE:
					pay_building(BUILDING_COSTS[0],active_player)
				return_to_action_selection()
		elif player_state==PlayerState.PUT_CITY:
			if map.put_city(map_node.selection_coordinates,player_colors[0]):
				pay_building(BUILDING_COSTS[2],active_player)
				return_to_action_selection()

func pay_building(building_costs:Array,player:int):
	players[player].subtract_resources(building_costs)
	if player==0:
		var building_costs_negative:=building_costs.duplicate(true)
		for i in building_costs_negative.size():
			building_costs_negative[i]=-building_costs_negative[i]
		show_resource_increments(building_costs_negative,get_main_player_increment_result_center())

func update_player_bar():
	for child in resource_counter_container.get_children():
		child.update(players[0].resources[child.resource_index])
	update_build_buttons()

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

func add_initial_resources_to_player(player:int,village_coordinates:Vector3i):
	var resources:=map.get_corner_adjacent_cell_resources(village_coordinates)
	for r in resources:
		players[player].resources[r]+=1

func get_main_player_increment_result_center()->Vector2:
	return resource_counter_container.global_position+Vector2(
		resource_counter_container.size.x/2,
		-INCREMENT_RESULT_DISTANCE
		)

func show_resource_increments(resource_increments:Array,center:Vector2):
	var new_resources:=[]
	for j in resource_increments.size():
		if resource_increments[j]!=0:
			new_resources.append([j,resource_increments[j]])
	for j in new_resources.size():
		var p:=center+Vector2(0,
			-(new_resources.size()-1)*INCREMENT_RESULT_HEIGHT*0.5
			+INCREMENT_RESULT_HEIGHT*j
			)
		var increment_result:=preload("res://scenes/resource_increment_result.tscn").instantiate()
		foreground_node_container.add_child(increment_result)
		increment_result.set_center_position(p)
		increment_result.set_resource(new_resources[j][0])
		increment_result.set_quantity(new_resources[j][1])

func generate_resources():
	var number:=randi_range(1,6)+randi_range(1,6)
	
	var player_resource_increments:=[]
	for i in players.size():
		player_resource_increments.append([0,0,0,0,0])
	
	for cell in map.cell_coordinates:
		if map.cells[cell.y][cell.x].number==number:
			
			map_node.add_cell_highlight(cell)
			
			var resource:int=map.cells[cell.y][cell.x].resource
			for i in range(6):
				var corner:=map.get_corner_unique_coordinates(Vector3i(cell.x,cell.y,i))
				var structure:Structure=map.corner_structures[map.corner_coordinates.find(corner)]
				if structure.exists:
					var player:=player_colors.find(structure.color)
					var quantity= 2 if structure.type==Structure.Type.CITY else 1
					player_resource_increments[player][resource]+=quantity
					players[player].resources[resource]+=quantity
	
	for i in players.size():
		var center:=Vector2(0,0)
		if i==0:
			center=get_main_player_increment_result_center()
		else:
			for child:Control in player_status_squares.get_children():
				if child.index==i:
					center=child.global_position+child.size/2
					var direction:=Vector2.UP
					match child.index:
						1:
							direction=Vector2.RIGHT
						2:
							direction=Vector2.DOWN
						3:
							direction=Vector2.LEFT
					center+=direction*(child.size.x/2+INCREMENT_RESULT_DISTANCE)
					break
		show_resource_increments(player_resource_increments[i],center)
	
	var dice_result:=preload("res://scenes/dice_result.tscn").instantiate()
	dice_result.set_number(number)
	foreground_node_container.add_child(dice_result)

func execute_ai_turn():
	if game_stage==GameStage.PUT_FIRST_VILLAGE or game_stage==GameStage.PUT_SECOND_VILLAGE:
		var positions:=[]
		for c in map.corner_coordinates:
			positions.append([c,map.get_village_position_score(c)])
		positions.sort_custom(func(a,b):return a[1]>b[1])
		
		var village_coordinates:=Vector3i(0,0,0)
		for p in positions:
			village_coordinates=p[0]
			if map.put_village_game_start(village_coordinates,player_colors[active_player]):
				break
		if game_stage==GameStage.PUT_SECOND_VILLAGE:
			add_initial_resources_to_player(active_player,village_coordinates)
		
		var road_positions:=[]
		for c in map.side_coordinates:
			road_positions.append([c,map.get_road_position_score(c,player_colors[active_player])])
		road_positions.sort_custom(func(a,b):return a[1]>b[1])
		
		var road_coordinates:=Vector3i(0,0,0)
		for p in road_positions:
			road_coordinates=p[0]
			if map.put_road(road_coordinates,player_colors[active_player]):
				break
	else:
		pass
		
		

func _on_end_turn_button_pressed() -> void:
	if active_player==0 and game_stage==GameStage.MAIN_STAGE:
		player_state=PlayerState.NEXT_TURN

func _on_build_button_pressed(index:int)->void:
	if active_player==0 and game_stage==GameStage.MAIN_STAGE:
		if player_state==PlayerState.ACTION_SELECTION:
			if players[0].has_resources(BUILDING_COSTS[index]):
				match index:
					0:
						player_state=PlayerState.PUT_ROAD
					1:
						player_state=PlayerState.PUT_VILLAGE
					2:
						player_state=PlayerState.PUT_CITY

func _on_cancel_button_pressed() -> void:
	if active_player==0 and game_stage==GameStage.MAIN_STAGE:
		if player_state!=PlayerState.ACTION_SELECTION:
			player_state=PlayerState.ACTION_SELECTION
