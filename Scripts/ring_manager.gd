extends CanvasLayer

var Ring = preload("res://Scenes/ring.tscn")
var sec_per_beat: float
@export var rings_at_once = 2  
var wrapper: Node2D # wrapper element for all the rings, so it can be positioned

func _ready():
	#BeatManager.connect("on_beat", self, "_on_beat")
	get_node("/root/BeatManager").on_beat.connect(_on_beat)
	sec_per_beat = 60.0 / BeatManager.bpm
	
	wrapper = Node2D.new()
	add_child(wrapper)
	
	var marker = Ring.instantiate()
	marker.marker = true
	wrapper.add_child(marker)

func _process(_delta):
	wrapper.position = get_viewport().get_mouse_position()

func spawn_ring():
	var ring = Ring.instantiate()
	wrapper.add_child(ring)
	ring.speed = 1.0 / (sec_per_beat * float(rings_at_once))
	#ring.lifetime = -beats_ahead
	#ring.speed = 1.0 / sec_per_beat

func _on_beat():
	spawn_ring()
