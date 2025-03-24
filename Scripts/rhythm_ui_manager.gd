extends Node2D

var RhythmSegment = preload("res://Scenes/rhythm_ui_segment.tscn")
var RhythmCenter = preload("res://Scenes/rhythm_ui_center.tscn")
var camera
var sec_per_beat: float
@export var rings_at_once = 2  
var wrapper: Node2D # wrapper element for all the rings, so it can be positioned

func _ready():
	BeatManager.on_beat.connect(_on_beat)
	sec_per_beat = 60.0 / BeatManager.bpm
	
	wrapper = Node2D.new()
	add_child(wrapper)
	
	var center = RhythmCenter.instantiate()
	wrapper.add_child(center)

func _process(_delta):
	if !camera:
		camera = ActionManager.player.get_node("Camera2D")
	else:
		wrapper.position = (get_viewport().get_visible_rect().size / 2) - camera.offset

func spawn_segment():
	var segment = RhythmSegment.instantiate()
	wrapper.add_child(segment)
	segment.speed = 1.0 / (sec_per_beat * float(rings_at_once))

func _on_beat():
	spawn_segment()
