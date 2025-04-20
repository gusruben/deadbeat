extends Node2D

@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
@onready var audio_player = $ShootingSystem.audio_player
@onready var type = WeaponSystem.WeaponTypes.AUTO

@onready var raycast = $RayCast2D
@onready var ray = $Line2D

@export var damage_tick: float = 50
@export var ammo_tick: float = 2

var shooting = false

func _ready():
	$ShootingSystem.on_start_shoot.connect(_on_start_shooting)
	$ShootingSystem.on_stop_shoot.connect(_on_stop_shooting)

func _on_start_shooting():
	shooting = true
	
func _physics_process(delta):
	if shooting:
		$ShootingSystem.ammo_in_magazine -= ammo_tick * delta
		if $ShootingSystem.ammo_in_magazine <= 0:
			_on_stop_shooting()
			return
		
		raycast.force_raycast_update()
		var p = raycast.get_collision_point()
		var distance = (p - global_position).length()
		var target = Vector2(distance, 0)
		ray.set_point_position(1, target)
		
		var collider = raycast.get_collider()
		if collider is ChargeEnemy or collider is ShootEnemy:
			(collider as ChargeEnemy).take_damage(damage_tick * delta, GameManager.player)

func _on_stop_shooting():
	shooting = false
	ray.set_point_position(1, Vector2.ZERO)
