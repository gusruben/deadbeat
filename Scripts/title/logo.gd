extends Node2D

@export var bounce_amount = 4
@export var base_offset = 24

func _process(_delta):
	$LogoTop.offset.y = base_offset - bounce_amount + ((BeatManager.beat_percentage + (BeatManager.beat_number % 2)) / 2.0) * bounce_amount
	$LogoBottom.offset.y = base_offset + bounce_amount - ((BeatManager.beat_percentage + (BeatManager.beat_number % 2)) / 2.0) * bounce_amount
