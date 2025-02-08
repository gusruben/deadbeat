extends CharacterBody2D

class_name Player

@onready var health_system = $HealthSystem as HealthSystem
@onready var shooting_system = $ShootingSystem as ShootingSystem
@onready var audio_player = $AudioStreamPlayer2D

@export var damage_per_bullet = 5
@export var player_ui: PlayerUI
@export var base_speed = 400
@onready var speed = base_speed
@export var rotation_speed = 5
@export var dash_length = 0.2
@export var dash_speed = 1000

var movement_direction: Vector2 = Vector2.ZERO
var angle
var has_key = false
var is_dashing = false
var dash_timer = 0

func _ready():
	player_ui.set_life_bar_max_value(health_system.base_health)
	player_ui.set_max_ammo(shooting_system.magazine_size)
	player_ui.set_ammo_left(shooting_system.max_ammo)

	shooting_system.shot.connect(on_shot)
	shooting_system.gun_reload.connect(on_reload)
	shooting_system.ammo_added.connect(on_ammo_added)
	health_system.died.connect(on_died)
	
	audio_player.volume_db = -12.5
	# currently there are no other sounds
	audio_player.stream = load("res://Assets/Audio/dash.wav")

func _physics_process(delta):
	# Normalize movement direction to avoid diagonal speed increase
	if movement_direction.length() > 0:
		movement_direction = movement_direction.normalized()
	
	if is_dashing:
		dash_timer += delta
		print(dash_timer)
		speed = dash_speed
		if dash_timer > dash_length:
			is_dashing = false
			speed = base_speed
	
	velocity = movement_direction * speed
	move_and_slide()
	
	if angle:
		global_rotation = lerp_angle(global_rotation, angle, delta * rotation_speed)

func _input(event):
	if is_dashing: return
	
	movement_direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_forward"):
		movement_direction.y -= 1
	if Input.is_action_pressed("move_backwards"):
		movement_direction.y += 1
	if Input.is_action_pressed("move_left"):
		movement_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		movement_direction.x += 1
	if Input.is_action_pressed("dash"):
		dash()

	angle = (get_global_mouse_position() - global_position).angle()

func dash():
	audio_player.play()
	dash_timer = 0
	is_dashing = true

func take_damage(damage: int):
	health_system.take_damage(damage)
	player_ui.update_life_bar_value(health_system.current_health)

func on_shot(ammo_in_magazine: int):
	player_ui.bullet_shot(ammo_in_magazine)

func on_reload(ammo_in_magazine: int, ammo_left: int):
	player_ui.gun_reloaded(ammo_in_magazine, ammo_left)

func on_ammo_pickup():
	shooting_system.on_ammo_pickup()

func on_ammo_added(total_ammo: int):
	player_ui.set_ammo_left(total_ammo)

func on_health_pickup(health_to_restore: int):
	health_system.current_health += health_to_restore
	player_ui.life_bar.value += health_to_restore

func on_key_pickup():
	has_key = true
	player_ui.on_key_pickup()

func update_extract_timer(time_left: float):
	player_ui.update_extract_timer(time_left)

func hide_extract_countdown():
	player_ui.hide_extract_countdown()

func extract():
	player_ui.on_game_over(false)
	queue_free()

func on_died():
	player_ui.on_game_over(true)
	queue_free()
