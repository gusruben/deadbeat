extends Sprite2D

var lifetime = 0.0 # 0 to 1
var speed = 1.0 # set by RhythmUIManager
var left = false # is it a segment on the left or right side

@export var fade_end = 1 # how much of the way through the animation the circle should stop fading

@export var start_position = 50
@export var end_position = 0

func _ready():
	if left:
		scale.x = -1
		start_position *= -1
		end_position *= -1
	
	render()

func _process(delta):
	lifetime += delta * speed

	render()

	if lifetime >= 1.0:
		queue_free()

func render():
	#scale = Vector2.ONE * lerp(start_scale, end_scale, lifetime)
	position.x = lerp(start_position, end_position, lifetime)
	modulate.a = min(1, lerp(0, 1 / fade_end, lifetime)) # opacity
