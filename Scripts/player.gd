extends CharacterBody2D

class_name Player

@onready var health_system = $HealthSystem as HealthSystem
# @onready var shooting_system = $ShootingSystem as ShootingSystem
@onready var weapon_system = $WeaponSystem as WeaponSystem
@onready var audio_player = $AudioStreamPlayer2D

@export var player_ui: PlayerUI
@export var base_speed = 135
@onready var speed = base_speed
@export var dash_length = 0.2
@export var dash_speed = 300

var movement_direction: Vector2 = Vector2.ZERO
var angle
var has_key = false
var is_dashing = false
var dash_timer = 0

func _ready():
	ActionManager.player = self
	GameManager.player = self
	health_system.died.connect(GameManager.on_player_death)
	
	player_ui.set_life_bar_max_value(health_system.base_health)
	health_system.died.connect(on_died)
	
	weapon_system.shot.connect(on_shot)
	weapon_system.gun_reload.connect(on_reload)
	weapon_system.ammo_added.connect(on_ammo_added)
	
	audio_player.volume_db = -12.5
	# currently there are no other sounds
	audio_player.stream = load("res://Assets/Audio/dash.wav")
	
	update_animation()

func _physics_process(delta):
	if angle:
		$WeaponSystem.rotation = angle
		if cos(angle) < 0: # flip the weapon sprite if it's pointing to the left
			$WeaponSystem.scale.y = -1
		else:
			$WeaponSystem.scale.y = 1
	
	# normalize movement direction to avoid diagonal speed increase
	if movement_direction.length() > 0:
		movement_direction = movement_direction.normalized()
	
	if is_dashing:
		dash_timer += delta
		speed = dash_speed
		if dash_timer > dash_length:
			is_dashing = false
			speed = base_speed
	
	velocity = movement_direction * speed
	move_and_slide()
	
func _input(event):
	if is_dashing: return

	update_animation()

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
		ActionManager.set_action(ActionManager.Actions.DASH)
		

	angle = (get_global_mouse_position() - global_position).angle()

func dash():
	audio_player.play()
	dash_timer = 0
	is_dashing = true
	update_animation()
		
func update_animation():
	var position_on_screen = (get_viewport_rect().size / 2) + $Camera2D.offset
	var direction = "right" if get_viewport().get_mouse_position().x > position_on_screen.x else "left"
	
	if is_dashing:
		var dash_direction = "right" if movement_direction.x > 0 else "left"
		$AnimatedSprite2D.play("dash_" + dash_direction + "_look_" + direction)
		return
	
	if Input.is_action_pressed("move_right"):
		$AnimatedSprite2D.play("run_right_look_" + direction)
	elif Input.is_action_pressed("move_left"):
		$AnimatedSprite2D.play("run_left_look_" + direction)	
	elif Input.is_action_pressed("move_forward"):
		$AnimatedSprite2D.play("run_" + direction + "_look_" + direction)
	elif Input.is_action_pressed("move_backwards"):
		$AnimatedSprite2D.play("run_" + direction + "_look_" + direction)
	else:
		$AnimatedSprite2D.play("idle_look_" + direction)

func take_damage(damage: int):
	health_system.take_damage(damage)
	player_ui.update_life_bar_value(health_system.current_health)

func on_shot(ammo_in_magazine: int):
	player_ui.bullet_shot(ammo_in_magazine)

func on_reload(ammo_in_magazine: int, ammo_left: int):
	player_ui.gun_reloaded(ammo_in_magazine, ammo_left)

func on_ammo_pickup():
	weapon_system.on_ammo_pickup()

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
	#queue_free()

func on_died():
	player_ui.on_game_over(true)
	#queue_free()
