extends Area2D

const FIRST_LEVEL_PATH = "res://scenes/levels/level_1.tscn"
@onready var fadeoverlay: ColorRect = $fadeoverlay

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		get_tree().change_scene_to_file(FIRST_LEVEL_PATH)
	
