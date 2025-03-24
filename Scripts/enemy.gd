extends CharacterBody2D

class_name Enemy

var ammo_pickup_scene = preload("res://Scenes/ammo_pickup.tscn")
var health_pickup_scene = preload("res://Scenes/health_pickup.tscn")

var player_obstructed = false

@onready var navigation_agent_2d = $NavigationAgent2D
@onready var vision_ray_cast_2d = $VisionRayCast2D as RayCast2D
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
	
	state_machine.transition_to("Chase")

func _physics_process(_delta):
	player_obstructed = is_position_obstructed(get_tree().get_first_node_in_group("player").global_position)

func is_position_obstructed(target_position):
	vision_ray_cast_2d.target_position = target_position - global_position
	vision_ray_cast_2d.force_raycast_update()

	return vision_ray_cast_2d.is_colliding()
	

func move_to_position(target_position: Vector2):
	var motion = position.direction_to(target_position) * current_speed
	navigation_agent_2d.set_velocity(motion)
	velocity = motion
	move_and_slide()

func take_damage(damage: int):
	health_system.take_damage(damage)

func on_died():
	try_to_drop_pickup.call_deferred()

func try_to_drop_pickup():
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
