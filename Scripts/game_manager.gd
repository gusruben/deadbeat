extends Node


var enemies_enabled = true
var current_wave = 0
var wave_enemy_counts = [1, 2, 5, 10, 15, 20]
var time_between_waves = 8
var enemy_spawn_delay = 3 # min delay between enemy spawns
var enemy_spawn_variance = 5 # max variance in enemy spawn time

# get everything in the spawnpoint group
@onready var spawn_points = get_tree().get_nodes_in_group("spawnpoint")
var spawn_point_cooldowns = [] # cooldowns for each spawn point

var player: CharacterBody2D
@onready var enemy_scene = preload("res://Scenes/enemy.tscn");

func _ready():
	for spawn_point in spawn_points:
		spawn_point_cooldowns.append(0)
	#await get_tree().create_timer(time_between_waves).timeout
	await get_tree().create_timer(1).timeout
	if enemies_enabled:
		start_wave()
	pass

func start_wave():
	print("Starting wave ", current_wave)
	# for some reason, unless i refresh it some of the spawnpoints will free / be null?
	spawn_points = get_tree().get_nodes_in_group("spawnpoint")

	var sp_amount = spawn_points.size()
	if wave_enemy_counts[current_wave] < sp_amount:
		for i in range(wave_enemy_counts[current_wave]):
			var index = randi() % sp_amount
			var spawn_point = spawn_points[index]
			spawn_enemy(spawn_point.global_position.x, spawn_point.global_position.y)
		current_wave += 1
		await get_tree().create_timer(time_between_waves).timeout # sleep for n seconds
		start_wave()
	else:
		var spawn_points_with_extra_enemy = wave_enemy_counts[current_wave] % sp_amount
		for i in range(spawn_points_with_extra_enemy):
			spawn_multiple_enemies(
				spawn_points[i].global_position.x,
				spawn_points[i].global_position.y,
				int(ceil(wave_enemy_counts[current_wave] / float(sp_amount))),
				i == 0 # the first one will be the "wave starter" (start the next wave after it's done spawning)
			)
		for i in range(spawn_points_with_extra_enemy, sp_amount):
			spawn_multiple_enemies(
				spawn_points[i].global_position.x,
				spawn_points[i].global_position.y,
				wave_enemy_counts[current_wave] / sp_amount # int division automatically floors it
			)

func on_player_death():
	get_tree().paused = true

func spawn_enemy(x, y):
	print("Spawn enemy at ", x, y)
	var enemy = enemy_scene.instantiate()
	enemy.global_position = Vector2(x, y)
	get_tree().get_root().add_child(enemy)

func spawn_multiple_enemies(x, y, count, wave_starter = false):
	spawn_enemy(x, y);
	await get_tree().create_timer(enemy_spawn_delay + (randf() * enemy_spawn_variance)).timeout;
	if count > 1:
		spawn_multiple_enemies(x, y, count - 1)
	else:
		if wave_starter:
			await get_tree().create_timer(time_between_waves).timeout;
			start_wave();
			
func reset():
	current_wave = 0
	for spawn_point in spawn_points:
		spawn_point_cooldowns.append(0)
	for entity in get_tree().get_root().get_children():
		if entity is Enemy:
			entity.queue_free()
