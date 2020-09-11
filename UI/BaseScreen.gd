extends CanvasLayer

onready var tween = $Tween

func animate(start, end):
	tween.interpolate_property(self, "offset:x", start, end, .5, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.start()
	
func appear():
	get_tree().call_group("buttons", "set_disabled", false)
	animate(500, 0)

func disappear():
	get_tree().call_group("buttons", "set_disabled", true)
	animate(0, 500)
