extends Node

signal on_beat
signal before_beat # triggers a little before beat, for stuff that takes a sec (like sounds)
signal on_half_beat

@export var bpm = 170
var sec_per_beat = 60.0 / bpm
var elapsed_time = 0.0 # just for the current beat
var before_beat_gap = 0.05 # time before a beat that before_beat will trigger
var before_beat_triggered = false # prevents it triggering more than once per beat
var beat_number = 0 # the current beat in the song loop (best used for its parity)
var beat_percentage = 0 # portion of the way through the current beat

var last_song_position = 0

@onready var music_player = AudioStreamPlayer.new()
var bgm = preload("res://Assets/Audio/loop.wav")

func _ready() -> void:
	music_player.volume_db = -20
	add_child(music_player)
	music_player.stream = bgm
	music_player.play()

func _process(_delta) -> void:
	# update last_beat every beat (aka every sec_per_beat seconds)
	var song_delta = music_player.get_playback_position() - last_song_position
	if song_delta < 0: # if the song loops over, fix song_delta for this beat
		song_delta += music_player.stream.get_length()
		beat_number = 0 # also reset beat_number when the song loops
	last_song_position = music_player.get_playback_position()
	elapsed_time += song_delta
	
	if elapsed_time >= sec_per_beat:
		elapsed_time -= sec_per_beat
		emit_signal("on_beat")
		before_beat_triggered = false
		
	if elapsed_time >= sec_per_beat - before_beat_gap && !before_beat_triggered:
		before_beat_triggered = true
		emit_signal("before_beat")
		beat_number += 1
		
	beat_percentage = elapsed_time / (60.0 / float(bpm))
