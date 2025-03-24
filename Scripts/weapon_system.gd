extends Node2D

class_name WeaponSystem

signal shot(ammo_in_magazine: int)
signal gun_reload(ammo_in_magazine: int, ammo_left: int)
signal ammo_added(total_ammo: int)

@export var starting_weapon: PackedScene = preload("res://Scenes/Weapons/test_weapon_1.tscn")
var weapon_1: PackedScene = preload("res://Scenes/Weapons/test_weapon_1.tscn")
var weapon_2: PackedScene = preload("res://Scenes/Weapons/test_weapon_2.tscn")
var weapon_3: PackedScene = preload("res://Scenes/Weapons/test_weapon_3.tscn")
var cur_weapon: Node
var cur_weapon_shoot_system: ShootingSystem

func _ready() -> void:
	swip_weapon(weapon_1)
	ActionManager.weapon_system = self

func _input(_event):
	if Input.is_action_just_pressed("shoot"):
		ActionManager.set_action(ActionManager.Actions.SHOOT)
	if Input.is_action_just_pressed("reload"):
		ActionManager.set_action(ActionManager.Actions.RELOAD)

func shoot():
	cur_weapon_shoot_system.shoot()
	shot.emit(cur_weapon_shoot_system.ammo_in_magazine)

func reload():
	cur_weapon_shoot_system.reload()
	gun_reload.emit(cur_weapon_shoot_system.ammo_in_magazine, cur_weapon_shoot_system.total_ammo)

func on_ammo_pickup():
	cur_weapon_shoot_system.on_ammo_pickup()
	ammo_added.emit(cur_weapon_shoot_system.total_ammo)

func swip_weapon(new_weapon: PackedScene) -> void:
	cur_weapon = new_weapon.instantiate()
	cur_weapon_shoot_system = cur_weapon.get_node("ShootingSystem")
	
	owner.player_ui.set_max_ammo(cur_weapon_shoot_system.magazine_size)
	owner.player_ui.set_ammo_left(cur_weapon_shoot_system.max_ammo)
	
	add_child(cur_weapon)
