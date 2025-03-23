extends State

@onready var navigation_agent_2d = $"../../NavigationAgent2D" as NavigationAgent2D
@onready var sprite_2d = $"../../Sprite2D" as Sprite2D

func enter(_msg = {}) -> void:
	if !owner || owner.is_queued_for_deletion():
		return
		
	owner.current_speed = owner.speed
	start_chasing()
	
func physics_update(_delta: float):
	if try_to_stop_chasing():
		return

	if navigation_agent_2d.is_navigation_finished():
		set_next_chasing_target_point()
	
	var next_position = navigation_agent_2d.get_next_path_position()
	(owner as Enemy).move_to_position(next_position)

func try_to_stop_chasing() -> bool:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return true

	var player_position = player.global_position
	var distance_to_player = (owner as Enemy).global_position.distance_to(player_position)

	if distance_to_player < owner.chase_distance && !owner.player_obstructed:
		stop_chasing()
		return true
	else:
		return false
			


func stop_chasing():
	state_machine.transition_to("Attack")

func start_chasing(): 
	set_next_chasing_target_point()

func set_next_chasing_target_point():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var player_position = player.global_position
	var navigation_point = NavigationServer2D.map_get_closest_point(navigation_agent_2d.get_navigation_map(), player_position)
	navigation_agent_2d.target_position = navigation_point	
