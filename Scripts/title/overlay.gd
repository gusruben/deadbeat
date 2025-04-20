extends Sprite2D

var showing = false
@export var show_length = 24
@export var final_opacity = 1.0

func _ready():
	modulate.a = 0
	visible = false
	
func start_showing():
	showing = true
	visible = true

func _process(_delta):
	if showing && modulate.a < final_opacity:
		modulate.a += final_opacity / show_length
