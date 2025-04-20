extends Node2D

@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
@onready var audio_player = $ShootingSystem.audio_player
@onready var type = WeaponSystem.WeaponTypes.STANDARD

@export var hand_distance = 6
@export var weapon_distance = 6
@export var bullet_speed = 900
@export var bullet_drag = 0

func _ready():
	$ShootingSystem.on_shoot.connect(_on_shoot)

func _on_shoot():
	if !get_tree():
		return
	
	$ShootingSystem.ammo_in_magazine -= 1

	var bullet = bullet_scene.instantiate() as Bullet
	bullet.starting_speed = bullet_speed
	bullet.drag = bullet_drag
	get_tree().root.add_child(bullet)
	
	var move_direction = (get_global_mouse_position() - global_position).normalized()
	bullet.move_direction = move_direction
	bullet.global_position = global_position
	bullet.rotation = move_direction.angle()
	
	
	# play shoot sound
	audio_player.volume_db = -15
	audio_player.stream = $ShootingSystem.shoot_sounds[randi() % $ShootingSystem.shoot_sounds.size()]
	audio_player.play()
