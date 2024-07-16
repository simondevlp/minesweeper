extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	visible=false
	$"../TileMap".connect("endgame",_on_end)

func _on_end():
	visible=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
