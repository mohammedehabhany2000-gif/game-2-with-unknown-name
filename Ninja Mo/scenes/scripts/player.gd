extends CharacterBody2D

signal died
signal health_changed(new_health: int)


const SPEED = 300.0
var last_direction: Vector2 = Vector2.RIGHT
var is_attaking: bool=false
var hitbox_offset: Vector2
var strength: int =20
var knockback_velocity: Vector2 =Vector2.ZERO
var min_x: float =150
var max_x: float =3600
var min_y: float = 170
var max_y:float = 1280
var max_health: int 
var health:int 
var alive: bool = true

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var katana_sound: AudioStreamPlayer2D = $katana_sound
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var katana: AnimatedSprite2D = $weaponpivot/katana
@onready var hitbox: Area2D = $hitbox
@onready var takedamagesound: AudioStreamPlayer2D = $takedamage
@onready var damagecooldown: Timer = $damagecooldown



func _ready() -> void:
	health = playerstats.health
	max_health = playerstats.max_health
	
	if katana:
		katana.visible=false
	hitbox_offset = Vector2(abs(hitbox.position.x),abs(hitbox.position.y))
	if not animated_sprite_2d.animation_finished.is_connected(_on_player_animation_finished):
		animated_sprite_2d.animation_finished.connect(_on_player_animation_finished)

func _physics_process(delta: float) -> void:
	
	hitbox.monitoring = false
	
	if alive:
		if knockback_velocity != Vector2.ZERO:
			knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1500 * delta)
			velocity = knockback_velocity
			move_and_slide()
			return
	
		if Input.is_action_just_pressed("attak") and not is_attaking:
			attak()
		if is_attaking:
			velocity=Vector2.ZERO
			move_and_slide()
			return
		global_position.x= clamp(global_position.x, min_x, max_x)
		global_position.y = clamp(global_position.y, min_y, max_y)
		process_movement()
		process_animation()
		move_and_slide()

func process_movement()-> void:
	var direction:=Input.get_vector("left", "right", "up" ,"down")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		
	else:
		velocity= Vector2.ZERO
	
	
	
func process_animation() -> void:
	if is_attaking:
		return
		
	
	if velocity != Vector2.ZERO:
		play_animation("walk", last_direction)
	else:
		play_animation("idle", last_direction)

func play_animation(prefix: String, dir: Vector2) -> void:
	if abs(dir.x) >= abs(dir.y):
	
		if dir.x >= 0:
			animated_sprite_2d.play(prefix + "_right")
		else:
			animated_sprite_2d.play(prefix + "_left")
	else:
		
		if dir.y >= 0:
			animated_sprite_2d.play(prefix + "_down")
		else: 
			animated_sprite_2d.play(prefix + "_up")
		
func attak() -> void:
	is_attaking = true
	hitbox.monitoring = true
	katana_sound.play()  
	play_animation('attak',last_direction)
	

	
	if abs(last_direction.x) >=abs(last_direction.y):
		if last_direction.x <= 0:
			animation_player.play("attak_right")
		else:
			animation_player.play("attak_left")
	else:
		if last_direction.y>= 0:
			animation_player.play("attak_down1")
		else:
			
			animation_player.play("attak_up")
func _on_player_animation_finished() -> void:
	if "attak" in animated_sprite_2d.animation:
		is_attaking= false
		if katana:
			katana.visible =false 
	


func _on_hitbox_body_entered(body: CharacterBody2D)-> void:
	if is_attaking and body.name.begins_with("slime"):
		body.take_damage(strength, position)
	elif is_attaking and body.name.begins_with("redsquid"):
		body.take_damage(strength, position)
	elif is_attaking and body.name.begins_with("bamboo"):
		body.take_damage(strength, position)
	elif is_attaking and body.name.begins_with("redfrog"):
		
		body.take_damage(strength, position)
		
		
	

func apply_knockback(enemy_position: Vector2, force: float =600) -> void:
	var puch_direction =(global_position - enemy_position).normalized()
	
	knockback_velocity= puch_direction* force
		

func heal(amount: int) ->void:
	health += amount
	if health >= max_health:
		health = max_health
	playerstats.health = health
	emit_signal("health_changed", health)




func take_damage(amount: int) ->void:
	
	if alive:
		if damagecooldown.time_left >0:
			return
		takedamagesound.play()
		health -= amount
		playerstats.health = health
		emit_signal("health_changed", health)
		
		if health <= 0:
			die()
		damagecooldown.start()


func die() ->void:
	animated_sprite_2d.play("die")
	alive = false
	await animated_sprite_2d.animation_finished
	died.emit()


func _on_endinggame_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
