extends Node

var Circle = preload("res://objects/Circle.tscn")
var Jumper = preload("res://objects/Jumper.tscn")

var player
var num_circles = 0
var score = 0 setget set_score
var highscore = 0
var new_highscore = false
var level = 0
var bonus = 0 setget set_bonus

func _ready():
	randomize()
	load_score()
	$HUD.hide()

func new_game():
	print('new gmae')
	reset()
	$HUD.update_score(score, 0)
	$Camera2D.position = $StartPosition.position
	player = Jumper.instance()
	player.position = $StartPosition.position
	add_child(player)
	connect_signals()
	spawn_circle($StartPosition.position)
	$HUD.show()
	$HUD.show_message("Go!")
	if settings.enable_music:
		$Music.volume_db = 0
		$Music.play()
	
func reset():
	new_highscore = false
	set_score(0)
	set_bonus(0)
	num_circles = 0
	level = 0
	
func connect_signals():
	player.connect("captured", self, "_on_Jumper_captured")
	player.connect("died", self, "_on_Jumper_died")
	player.connect("jumped", $Background1, "on_player_jump")
	player.connect("jumped", $Background2, "on_player_jump")
	player.connect("jumped", $Background3, "on_player_jump")

func spawn_circle(_position=null):
	var c = Circle.instance()
	if !_position:
		var x = rand_range(-150, 150)
		var y = rand_range(-550, -330)
		_position = player.target.position + Vector2(x, y)
	add_child(c)
	c.connect("full_orbit", self, "set_bonus", [1])
	c.init(_position, level)
	
func _on_Jumper_captured(object):
	$Camera2D.position = object.position
	object.capture(player)
	print('captired', object)
	call_deferred("spawn_circle")
	self.score += 1 * bonus
#	print('score', score)
	self.bonus += 1
	num_circles += 1
	$Camera2D/ScreenShake.start()
	if num_circles > 0 and num_circles % settings.circles_per_level == 0:
		level += 1
		$HUD.show_message("Level %s" % str(level))
#	if (level == 5):
#		$CameraZoomTween.interpolate_property($Camera2D, 'zoom', Vector2(1,1), Vector2(1.5,1.5), 2, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT )
#		$CameraZoomTween.start()
#		$Camera2D.zoom = Vector2(1.5, 1.5)

func set_score(value):
	print('setscore value', value)
	if(value):
		$HUD.update_score(score, value)
		score = value
		if score > highscore and !new_highscore:
			$HUD.show_message("New\nRecord!")
			new_highscore = true

func _on_Jumper_died():
	if score > highscore:
		highscore = score
		save_score()
	get_tree().call_group("circles", "implode")
	$Screens.game_over(score, highscore, level)
	$HUD.hide()
	if settings.enable_music:
		fade_music()

func load_score():
	var f = File.new()
	if f.file_exists(settings.score_file):
		f.open(settings.score_file, File.READ)
		highscore = f.get_var()
		f.close()

func save_score():
	var f = File.new()
	f.open(settings.score_file, File.WRITE)
	f.store_var(highscore)
	f.close()

func fade_music():
	$MusicFade.interpolate_property($Music, "volume_db", 0, -50, 1.0, Tween.TRANS_SINE, Tween.EASE_IN)
	$MusicFade.start()
	yield($MusicFade, "tween_all_completed")
	$Music.stop()

func set_bonus(value):
	bonus = value
	$HUD.update_bonus(bonus)
