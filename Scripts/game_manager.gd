extends Node

@export var wave_enemy_counts = [1, 2, 5, 10, 15, 20, 20, 20, 20, 20, 20, 20]
@export var score_thresholds = [100, 500, 1000]
@export var time_between_waves = 8
@export var enemy_spawn_delay = 3 # min delay between enemy spawns
@export var enemy_spawn_variance = 5 # max variance in enemy spawn time

var enemies_enabled = true
var current_wave = 0
var score = 0
var streak = 0
var multiplier = 1
var multiplier_value: float = 1

# run stats
var max_combo = 0
var time = 0
var kills = 0
var hits = 0
var misses = 0

var mult_decay = 0.005

var last_wave_start = 0

# get everything in the spawnpoint group
@onready var spawn_points = get_tree().get_nodes_in_group("spawnpoint")
var spawn_point_cooldowns = [] # cooldowns for each spawn point

var player: CharacterBody2D
@onready var enemies = [preload("res://Scenes/enemy_shoot.tscn"), preload("res://Scenes/enemy_charge.tscn")]

func _ready():
	for i in range(1000):
		wave_enemy_counts.append(20)
	#initialize()
	pass

func initialize():
	for spawn_point in spawn_points:
		spawn_point_cooldowns.append(0)
	#await get_tree().create_timer(time_between_waves).timeout
	await get_tree().create_timer(1).timeout
	if enemies_enabled:
		start_wave()

func _process(delta):
	if !player:
		return
	time += delta
	
	if multiplier_value > 1:
		multiplier_value -= mult_decay
		multiplier = floor(multiplier_value)
	else:
		multiplier_value = 1
		multiplier = 1
		
	# update mult display
	player.player_ui.multiplier_bar_1.value = floor((multiplier_value - multiplier) * 100)
	player.player_ui.multiplier_num.texture = player.player_ui.number_textures[int(multiplier) % 10]
	
	player.player_ui.streak_label.text = "(" + str(streak) + ")"
	
	if time - last_wave_start > 12:
		start_wave()


func start_wave():	
	if !GameManager.player:
		return
		
	last_wave_start = time
		
	enemy_spawn_delay = min(8, max(2, 8.0 / (float(current_wave) / 2.0)))
	print(enemy_spawn_delay)
	if current_wave > 6:
		mult_decay = 0.008
	if current_wave > 11:
		mult_decay = 0.01
	
	time_between_waves = max(time_between_waves - 2, 1)
	
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
				i == 0 # the first one will be the "wave starter" (tthe next wave after it's done spawning)
			)
		for i in range(spawn_points_with_extra_enemy, sp_amount):
			spawn_multiple_enemies(
				spawn_points[i].global_position.x,
				spawn_points[i].global_position.y,
				wave_enemy_counts[current_wave] / sp_amount # int division automatically floors it
			)

func on_player_death(_killer):
	get_tree().paused = true

func on_enemy_death(enemy):
	add_score(enemy.health_system.base_health)
	kills += 1
	streak += 1
	multiplier_value += (1.0/sqrt(float(multiplier_value)))
	
	if streak > max_combo:
		max_combo = streak
	

func spawn_enemy(x, y):
	if get_tree().paused or !GameManager.player:
		return
	print("Spawn enemy at ", x, y)
	var enemy = enemies[floor(randf() * len(enemies))].instantiate()
	enemy.global_position = Vector2(x, y)
	get_tree().get_root().add_child(enemy)

func spawn_multiple_enemies(x, y, count, wave_starter = false):
	if get_tree().paused or !GameManager.player:
		return
	spawn_enemy(x, y);
	await get_tree().create_timer(enemy_spawn_delay + (randf() * enemy_spawn_variance)).timeout;
	if count > 1:
		spawn_multiple_enemies(x, y, count - 1)
	else:
		if wave_starter:
			await get_tree().create_timer(time_between_waves).timeout;
			start_wave();
			
func add_score(num):
	score += num * multiplier * 50
	update_ui()

func update_ui():
	player.player_ui.score_label.text = String.num(score, 0)
	player.player_ui.streak_label.text = "(" + String.num(streak, 0) + ")"
	

func reset():
	current_wave = 0
	score = 0
	streak = 0
	multiplier = 1
	multiplier_value = 1
	max_combo = 0
	time = 0
	kills = 0
	hits = 0
	misses = 0
	for spawn_point in spawn_points:
		spawn_point_cooldowns.append(0)
	for entity in get_tree().get_root().get_children():
		if entity is ChargeEnemy or entity is ShootEnemy:
			entity.queue_free()
	await get_tree().create_timer(1).timeout
	if enemies_enabled:
		start_wave()
