extends Node2D

@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
@onready var audio_player = $ShootingSystem.audio_player
var bullets = 3
@onready var type = WeaponSystem.WeaponTypes.STANDARD


func _ready():
	$ShootingSystem.on_shoot.connect(_on_shoot)

func _on_shoot():
	for i in range(bullets):
		$ShootingSystem.ammo_in_magazine -= 1
		
		var bullet = bullet_scene.instantiate() as Bullet
		get_tree().root.add_child(bullet)
		
		var move_direction = (get_global_mouse_position() - global_position).normalized()
		bullet.move_direction = move_direction
		bullet.global_position = global_position
		bullet.rotation = move_direction.angle()
		
		# play shoot sound
		audio_player.volume_db = -15
		audio_player.stream = $ShootingSystem.shoot_sounds[randi() % $ShootingSystem.shoot_sounds.size()]
		audio_player.play()
		
		await get_tree().create_timer(BeatManager.sec_per_beat / bullets).timeout
