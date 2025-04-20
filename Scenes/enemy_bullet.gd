class_name EnemyBullet
extends Node2D

const my_scene = preload("res://Scenes/enemy_bullet.tscn")

var direction: Vector2
var damage: int = 3
var starting_speed: float = 600 # pixels per second
var speed: float = starting_speed
var drag = 0.05 # from 0 to 1
var min_speed = 75

static func new_enemy_bullet(origin: Vector2, target: Vector2, src: Node) -> EnemyBullet:
	var bullet: EnemyBullet = my_scene.instantiate()
	bullet.direction = (target - origin).normalized()
	bullet.rotation = bullet.direction.angle()
	bullet.position = origin
	
	src.add_child(bullet)
		
	return bullet

func _process(delta: float) -> void:
	position += direction*delta*speed
	speed *= (1 - drag)
	$Trail.modulate.a = (speed - min_speed) / (starting_speed - min_speed)
	if speed < min_speed:
		GameManager.misses += 1
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(damage, owner)
	queue_free()
