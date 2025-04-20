extends Node

class_name HealthSystem

signal died(source)
signal damage_taken(current_health: float)

@export var base_health: float = 15
var current_health

func _ready():
	current_health = base_health
	if owner is ShootEnemy:
		base_health = 25

func take_damage(damage: float, source):
	current_health -= damage
	damage_taken.emit(current_health)
	if current_health <= 0:
		died.emit(source)
