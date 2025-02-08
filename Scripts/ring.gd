extends Sprite2D

var lifetime = 0.0 # 0 to 1
var speed = 1.0 # set by RingManager

# if this is true the ring will be darker, and not change over time
# this is for the central ring that acts as a marker, only 1 will have this set to true
var marker = false

@export var fade_end = 1 # how much of the way through the animation the circle should stop fading

@export var start_scale = 8.0
@export var end_scale = 3.0

func _ready():
	if marker:
		scale = Vector2.ONE * end_scale
		modulate.v = 0.5
		return
	
	render()

func _process(delta):
	if marker: return
	lifetime += delta * speed

	render()

	if lifetime >= 1.0:
		queue_free()

func render():	
	scale = Vector2.ONE * lerp(start_scale, end_scale, lifetime)
	modulate.a = min(1, lerp(0, 1 / fade_end, lifetime))
