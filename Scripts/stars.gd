extends Node2D

@onready var stars = [$Star1,$Star2,$Star3,$Star4,$Star5,$Star6,$Star7,$Star8]
var offsets = []
var elapsed = 0
@export var rot = 20

func _ready():
	for i in range(len(stars)):
		offsets.append((randf() - 0.5) * 3.14 * 2)

func _process(delta):
	elapsed += delta
	for i in range(len(stars)):
		stars[i].rotation_degrees += delta * sin(elapsed + offsets[i]) * rot
