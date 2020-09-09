extends Node

var Circle = preload("res://objects/Circle.tscn")
var Jumper = preload("res://objects/Jumper.tscn")

var player

func _ready():
	randomize()

func new_game():
	$Camera2D.position = $StartingPosition.position
	player = Jumper.instance()
	player.position = $StartingPosition.position
	add_child(player)
	player.connect("captured", self, "_on_Jumper_captured")
	player.connect("died", self, "_on_Jumper_died")
	spawn_circle($StartingPosition.position)
	
func spawn_circle(_position=null):
	var c = Circle.instance()
	if !_position:
		var x = rand_range(-150, 150)
		var y = rand_range(-500, -400)
		_position = player.target.position + Vector2(x,y)
	
	add_child(c)
	c.init(_position)

func _on_Jumper_captured(object):
	$Camera2D.position = object.position
	object.capture(player)
	# can't call directly spawn_circle() because we are 
	# changing the physics state during physics processing
	call_deferred("spawn_circle")

func _on_Jumper_died():
	get_tree().call_group("circles", "implode") # lets us call a function on each member of the group
	$Screens.game_over()
