extends CharacterBody2D

class_name ChargeEnemy

var ammo_pickup_scene = preload("res://Scenes/ammo_pickup.tscn")
var health_pickup_scene = preload("res://Scenes/health_pickup.tscn")

var player_obstructed = false

@onready var navigation_agent_2d = $NavigationAgent2D
@onready var state_machine = $StateMachine as StateMachine
@onready var health_system = $HealthSystem as HealthSystem

@export_group("Locomotion")
@export var navigation_target: Node2D
@export var speed = 100

@export_group("Attack")
@export_range(0.1, 1) var attack_speed: float = 1
@export_range(1, 10) var attack_damage: float = 3
@export var chase_distance = 100

@export_group("Pickups")
@export var chance_to_drop_pickup = .5
@export var ammo_to_health_pickup_ratio = .6

var current_speed

func _ready():
	# var navigation_region = get_tree().get_first_node_in_group("navigation_region") as NavigationRegion2D
	var navigation_map = get_viewport().get_world_2d().get_navigation_map()
	NavigationServer2D.agent_set_map(navigation_agent_2d.get_rid(), navigation_map)
	navigation_agent_2d.set_navigation_map(navigation_map)
	navigation_agent_2d.debug_enabled = false
	
	health_system.died.connect(on_died)
	
	$AnimatedSprite2D.play("run")	
	state_machine.transition_to("Charge")
	

func _physics_process(_delta):
	if !GameManager.player:
		queue_free()
		return
	update_animation()
	if position.distance_to(GameManager.player.position) < 24:
		GameManager.player.take_damage(0.1, self)
	
func update_animation():
	scale.x = -1 if GameManager.player.position.x > position.x else 1

func move_to_position(target_position: Vector2):
	var motion = position.direction_to(target_position) * current_speed
	navigation_agent_2d.set_velocity(motion)
	velocity = motion
	move_and_slide()

func take_damage(damage: float, source):
	health_system.take_damage(damage, source)

func on_died(_source):
	GameManager.on_enemy_death(self)
	try_to_drop_pickup.call_deferred()
	queue_free()

func try_to_drop_pickup():
	if is_queued_for_deletion():
		return
	var current_pickup_drop_chance = randf()
	if current_pickup_drop_chance > chance_to_drop_pickup:
		if randf() < ammo_to_health_pickup_ratio:
			var ammo_pickup = ammo_pickup_scene.instantiate()
			get_tree().root.add_child(ammo_pickup)
			ammo_pickup.global_position = global_position
		else:
			var health_pickup = health_pickup_scene.instantiate()
			get_tree().root.add_child(health_pickup)
			health_pickup.global_position = global_position
