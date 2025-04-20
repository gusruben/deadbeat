extends Sprite2D

var default = preload("res://Assets/death/restart-icon.png")
var hover = preload("res://Assets/death/restart-icon-hover.png")

func _on_area_2d_mouse_entered() -> void:
	texture = hover
	CursorManager.hover()

func _on_area_2d_mouse_exited() -> void:
	texture = default
	CursorManager.default()

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.button_mask == MOUSE_BUTTON_MASK_LEFT:	
		get_tree().get_first_node_in_group("screen_wipe").play("wipe")
		#get_tree().get_first_node_in_group("screen_overlay").start_showing()
		await get_tree().create_timer(24.0 / 30.0).timeout
		
		get_tree().paused = false
		GameManager.reset()
		get_tree().reload_current_scene()
		CursorManager.default()
