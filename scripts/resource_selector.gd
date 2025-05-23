extends OptionButton

const RESOURCE_IMAGE_SIZE:=64

func _ready() -> void:
	var texture:=preload("res://assets/resources.png")
	for i in range(5):
		var atlas_texture:=AtlasTexture.new()
		atlas_texture.atlas=texture
		atlas_texture.region=Rect2(RESOURCE_IMAGE_SIZE*i,0,RESOURCE_IMAGE_SIZE,RESOURCE_IMAGE_SIZE)
		add_icon_item(atlas_texture,"x4",i)
	selected=0
