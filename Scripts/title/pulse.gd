extends Sprite2D

@export var max_opacity = 0.05

func _process(_delta):
	modulate.a = max_opacity - (BeatManager.beat_percentage * max_opacity)
