extends Marker2D

class_name ShootingSystem

signal on_shoot
signal on_start_shoot
signal on_stop_shoot

@export var max_ammo: float = 120
@export var total_ammo: float = 120
@export var magazine_size = 8

var audio_player: AudioStreamPlayer2D

var last_reload = 0
var reloading = false

@export var shoot_sounds = [
	preload("res://Assets/Audio/Shotgun_Shot-001.wav"),
	preload("res://Assets/Audio/Shotgun_Shot-002.wav"),
	preload("res://Assets/Audio/Shotgun_Shot-003.wav"),
	preload("res://Assets/Audio/Shotgun_Shot-004.wav"),
]
# one of them is the first half of the reload, the other is the second half-- it plays 1 beat later
@export var reload_sound_1 = preload("res://Assets/Audio/Shotgun_Pump_1.wav")
@export var reload_sound_2 = preload("res://Assets/Audio/Shotgun_Pump_2.wav")

var ammo_in_magazine = 0

func _ready():
	ammo_in_magazine = magazine_size
	
	BeatManager.before_beat.connect(_before_beat)
	
	# need to create it dynamicall for some reason, it doesn't work otherwise
	audio_player = AudioStreamPlayer2D.new()
	add_child(audio_player)
	
func reload():
	if total_ammo <= 0:
		return
	
	var bullet_missing_in_magazine: float = magazine_size - ammo_in_magazine
	var reloaded_amount = bullet_missing_in_magazine if bullet_missing_in_magazine < total_ammo else total_ammo
	
	total_ammo -= reloaded_amount
	ammo_in_magazine += reloaded_amount
	
	# play reload sound
	audio_player.volume_db = -10
	audio_player.stream = reload_sound_1
	audio_player.play()
	last_reload = Time.get_ticks_msec()
	reloading = true
	
func shoot():
	if ammo_in_magazine == 0:
		return
	
	emit_signal("on_shoot")

func start_shooting():
	if ammo_in_magazine == 0:
		return
		
	emit_signal("on_start_shoot")

func stop_shooting():
	emit_signal("on_stop_shoot")

func on_ammo_pickup():
	var ammo_to_add = max_ammo - total_ammo if total_ammo + magazine_size > max_ammo else float(magazine_size)
	total_ammo += ammo_to_add
	
func _before_beat():
	# if someone reloads right before a beat, it will sometimes not play the second half of the
	# reload sound; this fixes that by waiting 150ms before any logic for playing that sound can run
	if reloading && Time.get_ticks_msec() - last_reload > 150:
		reloading = false
		# play second half of reloading noise
		audio_player.volume_db = -10
		audio_player.stream = reload_sound_2
		audio_player.play()
