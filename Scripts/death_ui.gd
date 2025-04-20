extends CanvasLayer

@onready var score_digits = [
	$CanvasGroup/ScoreWrapper/ScoreContainer/ScoreDigit1,
	$CanvasGroup/ScoreWrapper/ScoreContainer/ScoreDigit2,
	$CanvasGroup/ScoreWrapper/ScoreContainer/ScoreDigit3,
	$CanvasGroup/ScoreWrapper/ScoreContainer/ScoreDigit4,
	$CanvasGroup/ScoreWrapper/ScoreContainer/ScoreDigit5
]
var digit_textures = []

func _ready():
	for i in range(10):
		digit_textures.append(load("res://Assets/font/" + str(int(i)) + ".png"))

func show_ui(killer):
	if !get_tree():
		return
	CursorManager.default()
	
	$"Overlay1".show_length = 12
	$"Overlay1".final_opacity = 0.4
	$"Overlay1".start_showing()
	$"CanvasGroup/Skull".play("appear")
	await get_tree().create_timer((12.0 / 30.0) + 0.5).timeout

	$"CanvasGroup/Overlay2".show_length = 12
	$"CanvasGroup/Overlay2".final_opacity = 0.8
	$"CanvasGroup/Overlay2".start_showing()
	await get_tree().create_timer((8.0 / 30.0)).timeout

	$CanvasGroup/UIBackground.play("open")
	await get_tree().create_timer(48.0 / 30.0).timeout
	
	$CanvasGroup/ScoreWrapper.visible = true
	var score_to_count = GameManager.score
	for i in range(10):
		set_score(GameManager.score - score_to_count)
		score_to_count /= 2
		await get_tree().create_timer(0.03).timeout
	set_score(GameManager.score)

	
	$"CanvasGroup/CanvasGroup/Combo-icon".visible = true
	$"CanvasGroup/CanvasGroup/ComboLabel".text = str(int(GameManager.max_combo))
	$CanvasGroup/CanvasGroup/ComboLabel.visible = true
	
	await get_tree().create_timer(0.1).timeout
	$"CanvasGroup/CanvasGroup/Sword-icon".visible = true
	$CanvasGroup/CanvasGroup/KillsLabel.text = str(int(GameManager.kills))
	$CanvasGroup/CanvasGroup/KillsLabel.visible = true
	
	await get_tree().create_timer(0.1).timeout
	$"CanvasGroup/CanvasGroup/Clock-icon".visible = true
	$CanvasGroup/CanvasGroup/TimeLabel.text = str(int(GameManager.time))
	$CanvasGroup/CanvasGroup/TimeLabel.visible = true
	
	await get_tree().create_timer(0.1).timeout
	$"CanvasGroup/CanvasGroup/Target-icon".visible = true
	if GameManager.hits > 0 && GameManager.misses > 0:
		$CanvasGroup/CanvasGroup/AccuracyLabel.text = "%.2f%%" % (100.0 * GameManager.hits / float(GameManager.hits + GameManager.misses))
	else:
		$CanvasGroup/CanvasGroup/AccuracyLabel.text = "00.0%"
	$CanvasGroup/CanvasGroup/AccuracyLabel.visible = true
	
	await get_tree().create_timer(0.3).timeout
	if killer is ChargeEnemy:
		$CanvasGroup/EnemySprite.sprite_frames = load("res://Assets/enemy_charge.tres")
		$CanvasGroup/EnemySprite.play("run")
		$CanvasGroup/EnemySprite.scale.x = -1
	else:
		$CanvasGroup/EnemySprite.sprite_frames = load("res://Assets/enemy_shoot.tres")
		$CanvasGroup/EnemySprite.play("idle_look_right")
	$CanvasGroup/EnemySprite.visible = true
	await get_tree().create_timer(0.1).timeout
	$"CanvasGroup/Menu-icon".visible = true
	await get_tree().create_timer(0.1).timeout
	$"CanvasGroup/Restart-icon".visible = true
		

func set_score(score):
	var full_num = str(round(score)).pad_zeros(5)
	for i in range(5):
		score_digits[i].texture = digit_textures[int(full_num[i])]
