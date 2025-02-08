extends Node

@onready var beat_manager = $"/root/BeatManager"

enum Actions { NONE, SHOOT, RELOAD, DASH }
var current_action = Actions.NONE
var actioned_last_beat = false # keeps track of if there was an action this past beat, so you can't use the grace period to take a second action
@export var grace_period = 0.05 # grace period (in seconds) after you miss a beat to still act on that beat

var player: CharacterBody2D
var shooting_system: Marker2D


func _ready() -> void:
	#shooting_system = get_tree().get_root().get_node("/Player/ShootingSystem")
	get_node("/root/BeatManager").on_beat.connect(_on_beat)

func set_action(action: Actions):
	# if the player just missed a beat, let them trigger it now (a little late)
	# rather than waiting until next beat
	if  beat_manager.elapsed_time <= grace_period && !actioned_last_beat:
		trigger_action(action)
	else:
		current_action = action
		
	actioned_last_beat = true

func trigger_action(action: Actions):
	match action:
		Actions.SHOOT:
			shooting_system.shoot()
		Actions.RELOAD:
			shooting_system.reload()
		Actions.DASH:
			player.dash()

func _on_beat():
	if current_action:
		trigger_action(current_action)
		current_action = Actions.NONE
	else:
		actioned_last_beat = false
	

func _process(delta: float) -> void:
	pass
