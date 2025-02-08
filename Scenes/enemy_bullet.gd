class_name EnemyBullet
extends Node2D

const my_scene = preload("res://Scenes/enemy_bullet.tscn")

var direction: Vector2
var speed: float = 800 # pixels per second
var damage: int = 3

static func new_enemy_bullet(origin: Vector2, target: Vector2, src: Node) -> EnemyBullet:
	var bullet: EnemyBullet = my_scene.instantiate()
	bullet.direction = (target - origin).normalized()
	bullet.position = origin
	
	src.add_child(bullet)
	
	print(src, bullet)
	
	return bullet

func _process(delta: float) -> void:
	position += direction*delta*speed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(damage)
	queue_free()
