extends ParallaxBackground

export (int) var speed = 0
var offset_scroll = 0


func _process(delta):
	offset_scroll += speed * delta
	
	set_scroll_offset(Vector2(0, offset_scroll))
