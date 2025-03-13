extends Node


var paused = false
var player: CharacterBody2D

func _ready():
	print("game manager ready")

func on_player_death():
	paused = true
	print("player died!!!!")
