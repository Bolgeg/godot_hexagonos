class_name Map
extends RefCounted

const RESOURCE_TYPES:=5

var radius:=2

var cell_coordinates:=[]
var corner_coordinates:=[]
var side_coordinates:=[]

var cells:=[]
var corner_structures:=[]
var side_structures:=[]

func _init(radius_to_set:int=2) -> void:
	radius=radius_to_set
	
	for y in range(radius*2+3):
		for x in range(radius*2+3):
			if x-1+y-1>=radius and x-1+y-1<=radius*2*2-radius and x-1>=0 and y-1>=0 and x-1<=radius*2 and y-1<=radius*2:
				cell_coordinates.append(Vector2i(x,y))
				for i in range(6):
					var c:=get_corner_unique_coordinates(Vector3i(x,y,i))
					if not c in corner_coordinates:
						corner_coordinates.append(c)
					var s:=get_side_unique_coordinates(Vector3i(x,y,i))
					if not s in side_coordinates:
						side_coordinates.append(s)
	
	for i in corner_coordinates.size():
		corner_structures.append(Structure.new())
	for i in side_coordinates.size():
		side_structures.append(Structure.new())
	
	for y in range(radius*2+3):
		cells.append([])
		for x in range(radius*2+3):
			cells[y].append(MapCell.new())
			for i in range(6):
				var c:=get_corner_unique_coordinates(Vector3i(x,y,i))
				if c in corner_coordinates:
					cells[y][x].corner_structures[i]=corner_coordinates.find(c)
				var s:=get_side_unique_coordinates(Vector3i(x,y,i))
				if s in side_coordinates:
					cells[y][x].side_structures[i]=side_coordinates.find(s)

func initialize_randomly():
	var resources:=[]
	for i in cell_coordinates.size():
		resources.append(i%RESOURCE_TYPES)
	
	var numbers:=[]
	for i in cell_coordinates.size():
		numbers.append(i%11+2)
	
	resources.shuffle()
	numbers.shuffle()
	
	for i in cell_coordinates.size():
		cells[cell_coordinates[i].y][cell_coordinates[i].x].resource=resources[i]
		cells[cell_coordinates[i].y][cell_coordinates[i].x].number=numbers[i]

func get_corner_unique_coordinates(corner:Vector3i)->Vector3i:
	var c:=corner
	match c.z:
		2:
			c=Vector3i(c.x,c.y+1,0)
		3:
			c=Vector3i(c.x-1,c.y+1,1)
		4:
			c=Vector3i(c.x-1,c.y+1,0)
		5:
			c=Vector3i(c.x-1,c.y,1)
	return c

func get_side_unique_coordinates(side:Vector3i)->Vector3i:
	var s:=side
	match s.z:
		3:
			s=Vector3i(s.x-1,s.y+1,0)
		4:
			s=Vector3i(s.x-1,s.y,1)
		5:
			s=Vector3i(s.x,s.y-1,2)
	return s

func cell_exists(coordinates:Vector2i)->bool:
	return coordinates in cell_coordinates

func corner_exists(corner:Vector3i)->bool:
	return corner in corner_coordinates

func side_exists(side:Vector3i)->bool:
	return side in side_coordinates

func get_corner_adjacent_corners(corner:Vector3i)->Array:
	corner=get_corner_unique_coordinates(corner)
	var corners:=[]
	for i in range(3):
		var c:=corner
		if c.z==0:
			match i:
				0:
					c=Vector3i(c.x,c.y-1,1)
				1:
					c=Vector3i(c.x,c.y,1)
				2:
					c=Vector3i(c.x-1,c.y,1)
		else:
			match i:
				0:
					c=Vector3i(c.x+1,c.y,0)
				1:
					c=Vector3i(c.x,c.y+1,0)
				2:
					c=Vector3i(c.x,c.y,0)
		if corner_exists(c):
			corners.append(c)
	return corners

func get_side_adjacent_sides(side:Vector3i)->Array:
	side=get_side_unique_coordinates(side)
	var sides:=[]
	for i in range(4):
		var s:=side
		if s.z==0:
			match i:
				0:
					s=Vector3i(s.x,s.y-1,1)
				1:
					s=Vector3i(s.x+1,s.y-1,2)
				2:
					s=Vector3i(s.x,s.y,1)
				3:
					s=Vector3i(s.x,s.y-1,2)
		elif s.z==1:
			match i:
				0:
					s=Vector3i(s.x+1,s.y-1,2)
				1:
					s=Vector3i(s.x,s.y+1,0)
				2:
					s=Vector3i(s.x,s.y,2)
				3:
					s=Vector3i(s.x,s.y,0)
		else:
			match i:
				0:
					s=Vector3i(s.x,s.y,1)
				1:
					s=Vector3i(s.x,s.y+1,0)
				2:
					s=Vector3i(s.x-1,s.y+1,1)
				3:
					s=Vector3i(s.x-1,s.y+1,0)
		if side_exists(s):
			sides.append(s)
	return sides

func get_side_adjacent_corners(side:Vector3i)->Array:
	side=get_side_unique_coordinates(side)
	match side.z:
		0:
			return [
				Vector3i(side.x,side.y,0),
				Vector3i(side.x,side.y,1),
			]
		1:
			return [
				Vector3i(side.x,side.y,1),
				Vector3i(side.x,side.y+1,0),
			]
		2:
			return [
				Vector3i(side.x,side.y+1,0),
				Vector3i(side.x-1,side.y+1,1),
			]
		_:
			return []

func get_corner_adjacent_cells(coordinates:Vector3i)->Array:
	var corner=get_corner_unique_coordinates(coordinates)
	var c:=[]
	for i in range(3):
		var cell:=Vector2i(corner.x,corner.y)
		if corner.z==0:
			match i:
				0:
					cell=Vector2i(cell.x+1,cell.y-1)
				1:
					cell=Vector2i(cell.x,cell.y)
				2:
					cell=Vector2i(cell.x,cell.y-1)
		else:
			match i:
				0:
					cell=Vector2i(cell.x+1,cell.y-1)
				1:
					cell=Vector2i(cell.x+1,cell.y)
				2:
					cell=Vector2i(cell.x,cell.y)
		if cell_exists(cell):
			c.append(cell)
	return c

func get_corner_adjacent_sides(coordinates:Vector3i)->Array:
	var corner:=get_corner_unique_coordinates(coordinates)
	var sides:=[]
	for i in range(3):
		var s:=corner
		if corner.z==0:
			match i:
				0:
					s=Vector3i(s.x,s.y-1,1)
				1:
					s=Vector3i(s.x,s.y,0)
				2:
					s=Vector3i(s.x,s.y-1,2)
		else:
			match i:
				0:
					s=Vector3i(s.x+1,s.y-1,2)
				1:
					s=Vector3i(s.x,s.y,1)
				2:
					s=Vector3i(s.x,s.y,0)
		if side_exists(s):
			sides.append(s)
	return sides

func get_corner_adjacent_cell_resources(coordinates:Vector3i)->Array:
	var c:=get_corner_adjacent_cells(coordinates)
	var r:=[]
	for cell in c:
		r.append(cells[cell.y][cell.x].resource)
	return r

func are_adjacent_corners_free(coordinates:Vector3i)->bool:
	for c in get_corner_adjacent_corners(coordinates):
		if corner_structures[corner_coordinates.find(c)].exists:
			return false
	return true

func get_number_probability(number:int)->float:
	if number<2 or number>12:
		return 0.0
	return float(6-abs(number-7))/36

func get_village_position_score(coordinates:Vector3i,color:int,exclude_village:bool)->float:
	var score:=0.0
	var c:=get_corner_adjacent_cells(coordinates)
	for cell in c:
		score+=get_number_probability(cells[cell.y][cell.x].number)
	
	coordinates=get_corner_unique_coordinates(coordinates)
	var structure:Structure=corner_structures[corner_coordinates.find(coordinates)]
	if structure.exists:
		if exclude_village:
			score=0
		elif structure.color!=color:
			score=0
	
	return score

func get_road_position_score(coordinates:Vector3i,color:int)->float:
	var score:=0.0
	if not can_put_road(coordinates,color):
		return 0.0
	
	var village_corner:=-1
	var corners:=get_side_adjacent_corners(coordinates)
	for i in corners.size():
		var structure:Structure=corner_structures[corner_coordinates.find(corners[i])]
		if structure.exists and structure.color==color:
			village_corner=i
			break
	
	if village_corner!=-1:
		var other_corner=corners[(village_corner+1)%2]
		var target_corners:=get_corner_adjacent_corners(other_corner)
		for c in target_corners:
			if c==corners[village_corner]:
				continue
			if corner_structures[corner_coordinates.find(c)].exists:
				continue
			if are_adjacent_corners_free(c):
				score+=get_village_position_score(c,color,true)/8
	else:
		for c in corners:
			if corner_structures[corner_coordinates.find(c)].exists:
				continue
			if are_adjacent_corners_free(c):
				score+=get_village_position_score(c,color,true)/8
	
	return score

func can_put_village_game_start(coordinates:Vector3i,_color:int)->bool:
	coordinates=get_corner_unique_coordinates(coordinates)
	if corner_structures[corner_coordinates.find(coordinates)].exists:
		return false
	for c in get_corner_adjacent_corners(coordinates):
		if corner_structures[corner_coordinates.find(c)].exists:
			return false
	return true

func put_village_game_start(coordinates:Vector3i,color:int)->bool:
	if not can_put_village_game_start(coordinates,color):
		return false
	coordinates=get_corner_unique_coordinates(coordinates)
	corner_structures[corner_coordinates.find(coordinates)]=Structure.new(true,Structure.Type.VILLAGE,color)
	return true

func can_put_village(coordinates:Vector3i,color:int)->bool:
	coordinates=get_corner_unique_coordinates(coordinates)
	if corner_structures[corner_coordinates.find(coordinates)].exists:
		return false
	for c in get_corner_adjacent_corners(coordinates):
		if corner_structures[corner_coordinates.find(c)].exists:
			return false
	var sides:=get_corner_adjacent_sides(coordinates)
	for side in sides:
		var structure:Structure=side_structures[side_coordinates.find(side)]
		if structure.exists and structure.color==color:
			return true
	return false

func put_village(coordinates:Vector3i,color:int)->bool:
	if not can_put_village(coordinates,color):
		return false
	coordinates=get_corner_unique_coordinates(coordinates)
	corner_structures[corner_coordinates.find(coordinates)]=Structure.new(true,Structure.Type.VILLAGE,color)
	return true

func can_put_road(coordinates:Vector3i,color:int)->bool:
	coordinates=get_side_unique_coordinates(coordinates)
	if side_structures[side_coordinates.find(coordinates)].exists:
		return false
	for c in get_side_adjacent_sides(coordinates):
		var structure:Structure=side_structures[side_coordinates.find(c)]
		if structure.exists and structure.color==color:
			return true
	for c in get_side_adjacent_corners(coordinates):
		var structure:Structure=corner_structures[corner_coordinates.find(c)]
		if structure.exists and structure.color==color:
			return true
	return false

func put_road(coordinates:Vector3i,color:int)->bool:
	if not can_put_road(coordinates,color):
		return false
	coordinates=get_side_unique_coordinates(coordinates)
	side_structures[side_coordinates.find(coordinates)]=Structure.new(true,Structure.Type.ROAD,color)
	return true

func can_put_city(coordinates:Vector3i,color:int)->bool:
	coordinates=get_corner_unique_coordinates(coordinates)
	var structure:Structure=corner_structures[corner_coordinates.find(coordinates)]
	return structure.exists and structure.type==Structure.Type.VILLAGE and structure.color==color

func put_city(coordinates:Vector3i,color:int)->bool:
	if not can_put_city(coordinates,color):
		return false
	coordinates=get_corner_unique_coordinates(coordinates)
	corner_structures[corner_coordinates.find(coordinates)]=Structure.new(true,Structure.Type.CITY,color)
	return true

func get_color_points(color:int)->int:
	var points:=0
	for i in corner_coordinates.size():
		var structure:Structure=corner_structures[i]
		if structure.exists and structure.color==color:
			if structure.type==Structure.Type.CITY:
				points+=2
			else:
				points+=1
	return points
