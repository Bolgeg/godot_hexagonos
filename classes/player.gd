class_name Player
extends RefCounted

var resources:=[0,0,0,0,0]

func has_resources(res:Array)->bool:
	for i in resources.size():
		if resources[i]<res[i]:
			return false
	return true

func subtract_resources(res:Array):
	for i in resources.size():
		resources[i]-=res[i]
