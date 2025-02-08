extends Node

signal on_beat
signal on_half_beat

@export var bpm = 170
var sec_per_beat = 60.0 / bpm
var last_beat = 0.0
var elapsed_time = 0.0

@onready var music_player = AudioStreamPlayer.new()
var bgm = preload("res://Assets/Audio/loop.wav")

func _ready() -> void:
	music_player.volume_db = -25
	add_child(music_player)
	music_player.stream = bgm
	music_player.play()
	last_beat = Time.get_ticks_msec() / 1000.0


func _process(delta: float) -> void:
	# update last_beat every beat (aka every sec_per_beat seconds)
	elapsed_time += delta
	if elapsed_time >= sec_per_beat:
		elapsed_time -= sec_per_beat
		emit_signal("on_beat")
