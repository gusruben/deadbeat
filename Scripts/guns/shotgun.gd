extends Node2D

@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
@onready var audio_player = $ShootingSystem.audio_player
@export var spread = 20
@export var bullets = 3
@onready var type = WeaponSystem.WeaponTypes.STANDARD

func _ready():
	$ShootingSystem.on_shoot.connect(_on_shoot)

func _on_shoot():
	$ShootingSystem.ammo_in_magazine -= 1

	for i in range(bullets):
		var bullet = bullet_scene.instantiate() as Bullet
		bullet.drag = 0.075
		get_tree().root.add_child(bullet)
		
		var move_direction = (get_global_mouse_position() - global_position)\
						.normalized()\
						.rotated(deg_to_rad((randf() - 0.5) * 20))
		bullet.move_direction = move_direction
		bullet.global_position = global_position
		bullet.rotation = move_direction.angle()
	
	# play shoot sound
	for i in range(bullets):
		audio_player.volume_db = -15
		audio_player.stream = $ShootingSystem.shoot_sounds[randi() % $ShootingSystem.shoot_sounds.size()]
		audio_player.play()
		await get_tree().create_timer(0.04 * randf()).timeout
