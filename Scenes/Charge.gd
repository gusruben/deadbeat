extends State

@onready var navigation_agent_2d = $"../../NavigationAgent2D" as NavigationAgent2D

func enter(_msg = {}) -> void:
	if !owner || owner.is_queued_for_deletion():
		return
		
	owner.current_speed = owner.speed
	start_chasing()
	
func physics_update(_delta: float):
	if navigation_agent_2d.is_navigation_finished():
		set_next_chasing_target_point()
	
	var next_position = navigation_agent_2d.get_next_path_position()
	(owner as ChargeEnemy).move_to_position(next_position)

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
