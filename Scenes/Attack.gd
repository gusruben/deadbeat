extends State

@onready var sprite = $"../../AnimatedSprite2D"

enum AttackMode {
	SPEED_BASED,
	BEAT_BASED
}

var attack_mode = AttackMode.BEAT_BASED
var attack_speed
var beats_per_attack = 2 # 2 means an attack every other beat
var attack_damage 
var time_elapsed: float = 0
var time_between_attacks
var beats_elapsed = 0

func _ready():
	attack_damage = (owner as ShootEnemy).attack_damage
	if attack_mode == AttackMode.SPEED_BASED:
		time_between_attacks = 0.3 + 1 / (owner as ShootEnemy).attack_speed
	else:
		BeatManager.on_beat.connect(_on_beat)

func physics_update(delta):
	if !owner || owner.is_queued_for_deletion():
		return
	if !GameManager.player:
		owner.queue_free()
		return
	
	if attack_mode == AttackMode.SPEED_BASED:
		time_elapsed += delta
		if time_elapsed >= time_between_attacks:
			attack()
			time_elapsed = 0
	
	# switch back to chasing if player is obstructed or out of range
	if owner && (owner.player_obstructed || owner.global_position.distance_to(GameManager.player.global_position) > owner.chase_distance):
		owner.state_machine.transition_to("Chase")

func attack():
	var player = GameManager.player
	
	EnemyBullet.new_enemy_bullet(sprite.global_position, player.global_position, get_tree().get_root().get_node("main"))
	
	#if player and player.has_method("take_damage"):
		#player.take_damage(attack_damage)
		#
		#var attack_tween = get_tree().create_tween()
		#attack_tween.tween_property(sprite, "modulate", Color(115, 0,0, 1), .3)
		#attack_tween.chain().tween_property(sprite, "modulate", Color.WHITE, .3)

func _on_beat():
	beats_elapsed += 1
	if beats_elapsed % beats_per_attack == 0:
		attack()
