extends Sprite2D

var lifetime = 0.0 # 0 to 1
var speed = 1.0 # set by RingManager

@export var fade_end = 1 # how much of the way through the animation the circle should stop fading

@export var start_position = 100
@export var end_position = 25

func _ready():
	centered = true
	offset = Vector2.ZERO
	
	render()

func _process(delta):
	lifetime += delta * speed

	render()

	if lifetime >= 1.0:
		queue_free()

func render():	
	#scale = Vector2.ONE * lerp(start_scale, end_scale, lifetime)
	modulate.a = min(1, lerp(0, 1 / fade_end, lifetime))
