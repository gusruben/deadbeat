extends Node

var pointer = preload("res://Assets/Cursors/pointer.png");
var hand = preload("res://Assets/Cursors/hand.png");
var cross = preload("res://Assets/Cursors/crosshair.png");

func _ready():
	Input.set_custom_mouse_cursor(pointer)
	Input.set_custom_mouse_cursor(hand, Input.CURSOR_POINTING_HAND)

func hover():
	Input.set_custom_mouse_cursor(hand)
	
func default():
	Input.set_custom_mouse_cursor(pointer)

func crosshair():
	Input.set_custom_mouse_cursor(cross)	
