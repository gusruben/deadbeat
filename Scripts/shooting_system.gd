extends Marker2D

class_name ShootingSystem

signal shot(ammo_in_magazine: int)
signal gun_reload(ammo_in_magazine: int, ammo_left: int)
signal ammo_added(total_ammo: int)

@export var max_ammo = 120
@export var total_ammo = 120
@export var magazine_size = 8

@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
var audio_player: AudioStreamPlayer2D

var reloading = false

var shoot_sounds = [
	preload("res://Assets/Audio/Shotgun_Shot-001.wav"),
	preload("res://Assets/Audio/Shotgun_Shot-002.wav"),
	preload("res://Assets/Audio/Shotgun_Shot-003.wav"),
	preload("res://Assets/Audio/Shotgun_Shot-004.wav"),
]
# one of them is the first half of the reload, the other is the second half-- it plays 1 beat later
var reload_sound_1 = preload("res://Assets/Audio/Shotgun_Pump_1.wav")
var reload_sound_2 = preload("res://Assets/Audio/Shotgun_Pump_2.wav")

var ammo_in_magazine = 0
var crosshair_texture = preload("res://Assets/crosshair_white-export.png")

func _ready():
	Input.set_custom_mouse_cursor(crosshair_texture)
	ammo_in_magazine = magazine_size
	
	get_node("/root/BeatManager").before_beat.connect(_before_beat)
	
	# need to create it dynamicall for some reason, it doesn't work otherwise
	audio_player = AudioStreamPlayer2D.new()
	add_child(audio_player)

func _input(event):
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("reload"):
		reload()
	
func reload():
	if total_ammo <= 0:
		return
	
	var bullet_missing_in_magazine = magazine_size - ammo_in_magazine
	var reloaded_amount = bullet_missing_in_magazine if bullet_missing_in_magazine < total_ammo else total_ammo
	
	total_ammo -= reloaded_amount
	ammo_in_magazine += reloaded_amount
	gun_reload.emit(ammo_in_magazine, total_ammo)
	
	# play reload sound
	audio_player.volume_db = -10
	audio_player.stream = reload_sound_1
	audio_player.play()
	reloading = true
	
func shoot():
	if ammo_in_magazine == 0:
		return
	
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.damage = owner.damage_per_bullet	
	get_tree().root.add_child(bullet)
	
	var move_direction = (get_global_mouse_position() - global_position).normalized()
	bullet.move_direction = move_direction
	bullet.global_position = global_position
	bullet.rotation = move_direction.angle()
	
	ammo_in_magazine -= 1
	shot.emit(ammo_in_magazine)
	
	# play shoot sound
	audio_player.volume_db = -15
	audio_player.stream = shoot_sounds[randi() % shoot_sounds.size()]
	audio_player.play()

func on_ammo_pickup():
	var ammo_to_add = max_ammo - total_ammo if total_ammo + magazine_size > max_ammo else magazine_size
	total_ammo += ammo_to_add
	ammo_added.emit(total_ammo)
	
func _before_beat():
	if reloading:
		reloading = false
		# play second half of reloading noise
		audio_player.volume_db = -10
		audio_player.stream = reload_sound_2
		audio_player.play()
