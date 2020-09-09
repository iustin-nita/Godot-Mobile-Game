extends Node

signal start_game

var current_screen = null


# Called when the node enters the scene tree for the first time.
func _ready():
	register_buttons()
	change_screen($TitleScreen)
	
func register_buttons():
	var buttons = get_tree().get_nodes_in_group("buttons")
	for button in buttons:
		button.connect("pressed", self, "_on_button_pressed", [button.name])

func _on_button_pressed(name):
	print("button pressed", name)
	match name:
		"Home":
			change_screen($TitleScreen)
		"Play":
			change_screen(null)
			yield(get_tree().create_timer(.5), "timeout")
			emit_signal("start_game")
		"Settings":
			change_screen($SettingsScreen)
		"Return":
			change_screen($TitleScreen)

func change_screen(new_screen):
	if current_screen:
		current_screen.disappear()
		yield(current_screen.tween, "tween_completed")
	current_screen = new_screen
	if new_screen:
		current_screen.appear()
		yield(current_screen.tween, "tween_completed")

func game_over():
	change_screen($GameOverScreen)
