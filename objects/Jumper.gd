extends Area2D

signal captured

onready var trail = $Trail/Points
var velocity = Vector2(100,0) # start value for testing
var jump_speed = 1000
var target = null # if we're on a circle
var trail_length = 25

func _unhandled_input(event):
	if (target && event is InputEventScreenTouch && event.pressed):
		jump()

func jump():
	target.implode()
	target = null
	velocity = transform.x * jump_speed

func _on_Jumper_area_entered(area):
	target = area
	target.get_node("Pivot").rotation = (position - target.position).angle()
	velocity = Vector2.ZERO
	emit_signal("captured", area)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if trail.points.size() > trail_length:
		trail.remove_point(0)
	trail.add_point(position) 
	
	if target:
		transform = target.orbit_position.global_transform
	else:
		position += velocity * delta
