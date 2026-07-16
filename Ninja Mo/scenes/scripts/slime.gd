extends CharacterBody2D

const SPEED:int = 100
const Knockback_Force: int = 100



const DROP_CHANGE: float = 0.5



var target = null
var health: int = 100
var is_alive: bool = true
var strength: int =10
var target_in_range : bool= false



var health_pickup_scene = preload("res://scenes/healthpickup.tscn") 



@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var takedamage: AudioStreamPlayer2D = $takedamage
@onready var health_bar: Node2D = $healthBar
@onready var attaktimer: Timer = $attaktimer




func _physics_process(delta: float) -> void:
	if is_alive and target:
		_attak(delta)



func _attak(delta: float) -> void:
	
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	animated_sprite_2d.play("attak")


func take_damage(damage: int, attacker_position: Vector2) ->  void:
	health -= damage  
	health_bar.update_health(health)
	if health <= 0:
		_die()
	else:
		takedamage.play()
		var knockback_direction = (position - attacker_position).normalized()
		var target_position = position + knockback_direction *Knockback_Force
		var tween =create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", target_position, 0.5)


func _die() -> void:
	is_alive=false
	animated_sprite_2d.play("die")
	takedamage.pitch_scale = 0.5
	takedamage.play()
	$CollisionShape2D.set_deferred("disabled",true)
	$sight/CollisionShape2D.set_deferred("disabled", true)
	
	$hitbox/CollisionShape2D.set_deferred("disabled", true)
	
	if randf() <=  DROP_CHANGE:
		drop_item()
	
func _on_syte_body_entered(body: Node2D) -> void:
	if body.name== "player":
		target = body
		
		


func _on_syte_body_exited(body: Node2D) -> void:
	if body.name== "player" and is_alive:
		target = null
		animated_sprite_2d.play("idle")


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "die":
		queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "player":
		target_in_range= true
		body.take_damage(strength)
		attaktimer.start()


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "player":
		target_in_range= false
		body.take_damage(strength)
		attaktimer.stop()

func _on_attaktimer_timeout() -> void:
	if target and target_in_range:
		target.take_damage(strength)
		
		
		
func drop_item():
	var drop = health_pickup_scene.instantiate()
	drop.position = position
	var level_root = get_parent().get_parent()
	var items_node = level_root.get_node("items")
	items_node.call_deferred("add_child", drop)



	
