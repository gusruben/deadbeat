extends Area2D

class_name Bullet

@export var damage = 100
@export var starting_speed: float = 600 # pixels per second
var speed
@export var drag = 0.0 # from 0 to 1
@export var min_speed = 75

var move_direction: Vector2 = Vector2.ZERO

func _ready():
	speed = starting_speed

func _process(delta):
	global_position += move_direction * delta * speed
	speed *= (1 - drag)
	$Trail.modulate.a = (speed - min_speed) / (starting_speed - min_speed)
	if speed < min_speed:
		queue_free()

func _on_body_entered(body):
	if body is ChargeEnemy or body is ShootEnemy:
		body.take_damage(damage, GameManager.player)	
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
