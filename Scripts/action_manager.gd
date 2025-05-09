extends Node

enum Actions { NONE, SHOOT, RELOAD, DASH }
var current_action = Actions.NONE
var actioned_last_beat = false # keeps track of if there was an action this past beat, so you can't use the grace period to take a second action
@export var grace_period = 0.05 # grace period (in seconds) after you miss a beat to still act on that beat

var player: CharacterBody2D
var weapon_system: Node2D


func _ready() -> void:
	#shooting_system = get_tree().get_root().get_node("/Player/ShootingSystem")
	BeatManager.on_beat.connect(_on_beat)

func set_action(action: Actions):
	# if the player just missed a beat, let them trigger it now (a little late)
	# rather than waiting until next beat
	if  BeatManager.elapsed_time <= grace_period && !actioned_last_beat:
		trigger_action(action)
	else:
		current_action = action
		
	actioned_last_beat = true

func trigger_action(action: Actions):
	if !GameManager.player:
		return
		
	match action:
		Actions.SHOOT:
			weapon_system.shoot()
		Actions.RELOAD:
			weapon_system.reload()
		Actions.DASH:
			player.dash()

func _on_beat():
	if current_action:
		trigger_action(current_action)
		current_action = Actions.NONE
	else:
		actioned_last_beat = false
