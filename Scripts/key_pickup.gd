extends Area2D

func _on_body_entered(body):
	(body as Player).on_key_pickup()
	queue_free()
