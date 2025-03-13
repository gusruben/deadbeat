extends Camera2D

@export var panAmount = 0.2
var realOffset = 0;

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if GameManager.paused: return
	offset = panAmount * (get_viewport().get_mouse_position() - (get_viewport_rect().size / 2))
	realOffset = offset	
