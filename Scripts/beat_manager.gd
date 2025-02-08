extends Node

signal on_beat
signal on_half_beat

var bpm = 120
var sec_per_beat = 60.0 / bpm
var last_beat = 0.0
var elapsed_time = 0.0

func _ready() -> void:
	last_beat = Time.get_ticks_msec() / 1000.0


func _process(delta: float) -> void:
	# update last_beat every beat (aka every sec_per_beat seconds)
	elapsed_time += delta
	if elapsed_time >= sec_per_beat:
		elapsed_time -= sec_per_beat
		emit_signal("on_beat")
