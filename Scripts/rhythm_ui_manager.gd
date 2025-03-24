extends Node2D

var RhythmSegment = preload("res://Scenes/rhythm_ui_segment.tscn")
var RhythmCenter = preload("res://Scenes/rhythm_ui_center.tscn")
var sec_per_beat: float
@export var segments_at_once = 2  

var center
var center_pulse_opacity = 0.4

func _ready():
	BeatManager.on_beat.connect(_on_beat)
	sec_per_beat = 60.0 / BeatManager.bpm
	
	center = RhythmCenter.instantiate()
	center.modulate.a = 0
	add_child(center)


func _process(_delta):
	center.modulate.a = lerp(center_pulse_opacity, 0.0, BeatManager.beat_percentage)
	print(BeatManager.beat_percentage)
		
	if ActionManager.player:
		position = ActionManager.player.position + Vector2(0, -8)

func spawn_segment():
	var segment1 = RhythmSegment.instantiate()
	var segment2 = RhythmSegment.instantiate()
	segment1.speed = 1.0 / (sec_per_beat * float(segments_at_once))
	segment2.speed = 1.0 / (sec_per_beat * float(segments_at_once))
	segment2.left = true
	add_child(segment2)
	add_child(segment1)

func _on_beat():
	spawn_segment()
