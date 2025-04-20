extends AnimatedSprite2D

func switch_anim(new_anim):
	var current_frame = get_frame()
	var progress = get_frame_progress()
	play(new_anim)
	set_frame_and_progress(current_frame, progress)

func _on_area_2d_mouse_entered() -> void:
	switch_anim("hover")
	CursorManager.hover()

func _on_area_2d_mouse_exited() -> void:
	switch_anim("default")
	CursorManager.default()

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.button_mask == MOUSE_BUTTON_MASK_LEFT:	
		get_tree().get_first_node_in_group("screen_wipe").play("wipe")
		#get_tree().get_first_node_in_group("screen_overlay").start_showing()
		await get_tree().create_timer(24.0 / 30.0).timeout
		
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
		GameManager.initialize()
		CursorManager.crosshair()
