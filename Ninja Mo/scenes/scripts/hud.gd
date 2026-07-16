extends CanvasLayer
@onready var fadeoverlay: ColorRect = $fadeoverlay




func fade(to_alpha: float) -> void:
	var tween:= create_tween()
	tween.tween_property(fadeoverlay, "modulate:a", to_alpha,1.5)
	
	await tween.finished
