extends CharacterBody2D

const SPEED = 130.0
var target = null

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D




func _physics_process(delta: float) -> void:
	if target:
		_attak(delta)



func _attak(delta: float) -> void:
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	animated_sprite_2d.play("attak")
func _on_syte_body_entered(body: Node2D) -> void:
	if body.name== "player":
		target = body
		
		


func _on_syte_body_exited(body: Node2D) -> void:
	if body.name== "player":
		target = null
		animated_sprite_2d.play("idle")
