extends Area2D

class_name Bullet

@export var damage = 1000
@export var speed = 1000
var move_direction: Vector2 = Vector2.ZERO

func _process(delta):
	global_position += move_direction * delta * speed

func _on_body_entered(body):
	if body is Enemy:
		body.take_damage(damage)	
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
