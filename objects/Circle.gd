extends Area2D

signal full_orbit
onready var orbit_position = $Pivot/OrbitPosition
onready var move_tween = $MoveTween

onready var test = $"."

# LIMITED = limited number of orbits
enum MODES {STATIC, LIMITED}
var radius = 100
var rotation_speed = PI
var mode = MODES.STATIC
var move_range = 0
var move_speed = 4.0
var num_orbits = 3
var current_orbits = 0
var orbit_start = null
var jumper = null

func init(_position, level = 0):
	var _mode = settings.rand_weighted([10, level - 1])
	set_mode(_mode)
	position = _position
	print('level ', level)
	set_theme(level)
	set_arrow_speed(level)
	
	var move_chance = clamp(level-3, 0, 4) / 3.0
#	print('move chance', move_chance)
	print(move_chance)
	if randf() < move_chance:
		move_range = max(25, 100 * rand_range(0.75, 1.25) * move_chance) * pow(-1, randi() % 2)
		move_speed = max(2.5 - ceil(level/5) * 0.25, 2)
#		print('move range', move_range)
#		print('move speed', move_speed)
	var small_chance = min(0.6, max(0, (level-4) / 8.0))
	if randf() < small_chance:
		radius = max(50, radius - level * rand_range(0.55, 1.25))
#		print('radius', radius)
		
	$Sprite.material = $Sprite.material.duplicate()
	$SpriteEffect.material = $SpriteEffect.material
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	$CollisionShape2D.shape.radius = radius
	var img_size = $Sprite.texture.get_size().x / 2
	$Sprite.scale = Vector2(1,1) * radius / img_size
	orbit_position.position.x = radius + 25

	rotation_speed *= pow(-1, randi() % 2)
	print('rotation_speed2 ', rotation_speed)
#	$AnimationPlayer.play("music")
	set_tween()
	
func _process(delta):
	$Pivot.rotation += rotation_speed * delta
	if mode == MODES.LIMITED && jumper:
#	if jumper:
		check_orbits()
		update()

func set_theme(level):
	if(level >= 1 and level <= 3):
		settings.changeTheme(settings.color_schemes["NEON3"])
	elif(level>=3 and level <= 5):
		settings.changeTheme(settings.color_schemes["NEON1"])
	elif(level>=5 and level <= 7):
		settings.changeTheme(settings.color_schemes["NEON2"])
	else:
		settings.changeTheme(settings.color_schemes["NEON1"])
#	print('set_theme', settings.theme)

func set_arrow_speed(level):
	if(level >= 0 and level < 4):
		rotation_speed /= 1.5
	if(level>=4 and level < 7):
		rotation_speed /= 1.3
	elif(level>=7 and level < 9):
		rotation_speed /= 1.1
	elif (level >= 9 and level < 12):
		rotation_speed *= 1.2
	elif (level >= 12 and level < 14):
		rotation_speed *= 1.3
	elif (level >= 14 and level < 16):
		rotation_speed *= 1.4
	elif (level >= 16):
		rotation_speed *= 1.5
	print('set_arrow_speed', rotation_speed)

func check_orbits():
	# test if done a full circle
	if abs($Pivot.rotation - orbit_start) > 2 * PI:
		current_orbits += 1
		emit_signal("full_orbit")
		if mode == MODES.LIMITED:
			if settings.enable_sound:
				$Beep.play()
#			$AnimationPlayer.play("test")
#			$SizeTween.interpolate_property(self, "scale",
#				scale, scale * .8,
#				1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
#			$SizeTween.start()
			$Label.text = str(num_orbits - current_orbits)

			if current_orbits >= num_orbits:
#				print('current_orbits num_orbits', current_orbits, num_orbits)
				jumper.die()
				jumper = null
				implode()
		orbit_start = $Pivot.rotation

func set_mode(_mode):
	mode = _mode
	var color
	match mode:
		MODES.STATIC:
			$Label.hide()
			color = settings.theme["circle_static"]
		MODES.LIMITED:
			current_orbits = num_orbits
			$Label.text = str(num_orbits)
			$Label.show()
			color = settings.theme["circle_limited"]
	$Sprite.material.set_shader_param("color", color)
	$SpriteEffect.material.set_shader_param("color", color)
	$Particles2D.process_material.color = color
	
func implode():
	$Particles2D.emitting = true
	jumper = null
	$AnimationPlayer2.play("implode")
	$AnimationPlayer.play("capture")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func capture(target):
	$Particles2D.emitting = true
#	print("CAPGTURE taret", target)
	current_orbits = 0
	
	jumper = target
#	$AnimationPlayer.play("capture")
	$Pivot.rotation = (jumper.position - position).angle()
	orbit_start = $Pivot.rotation
	if mode == MODES.LIMITED:
		set_size_tween()

func _draw():
	if mode != MODES.LIMITED:
		return
	if jumper:
		return
##		var r = ((radius - 50) / num_orbits) * (1 + current_orbits)
##		draw_circle_arc_poly(Vector2.ZERO, r, orbit_start + PI/2,
##							$Pivot.rotation + PI/2, settings.theme["circle_fill"])
##
#func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
#	var nb_points = 32
#	var points_arc = PoolVector2Array()
#	points_arc.push_back(center)
#	var colors = PoolColorArray([color])
#
#	for i in range(nb_points + 1):
#		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points - PI/2
#		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
#	draw_polygon(points_arc, colors)
#
func set_tween(_object=null, _key=null):
	if move_range == 0:
		return
	move_range *= -1
	move_tween.interpolate_property(self, "position:x",
				position.x, position.x + move_range,
				move_speed, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	move_tween.start()


func set_size_tween(_object=null, _key=null):
	$SizeTween.interpolate_property(self, "scale",
				scale, scale * .2,
				num_orbits * 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$SizeTween.start()
