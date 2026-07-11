extends CharacterBody2D


const SPEED = 300.0
var last_direction: Vector2 = Vector2.RIGHT
var is_attaking: bool = false
var hitbox_offset: Vector2


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var katana_sound: AudioStreamPlayer2D = $katana_sound
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var katana: AnimatedSprite2D = $weaponpivot/katana
@onready var hitbox: Area2D = $hitbox


func _ready() -> void:
	if katana:
		katana.visible=false
	hitbox_offset = Vector2(abs(hitbox.position.x),abs(hitbox.position.y))
	if not animated_sprite_2d.animation_finished.is_connected(_on_player_animation_finished):
		animated_sprite_2d.animation_finished.connect(_on_player_animation_finished)

func _physics_process(_delta: float) -> void:
	
	hitbox.monitoring = false
	if Input.is_action_just_pressed("attak") and not is_attaking:
		attak()
	if is_attaking:
		velocity=Vector2.ZERO
		move_and_slide()
		return
	
	process_movement()
	process_animation()
	move_and_slide()

func process_movement()-> void:
	var direction := Input.get_vector("left", "right", "up" ,"down")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		
	else:
		velocity = Vector2.ZERO
	
	
	
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
	play_animation('attak', last_direction)
	

	
	if abs(last_direction.x) >= abs(last_direction.y):
		if last_direction.x <= 0:
			animation_player.play("attak_right")
		else:
			animation_player.play("attak_left")
	else:
		if last_direction.y >= 0:
			animation_player.play("attak_down1")
		else:
			animation_player.play("attak_up")
func _on_player_animation_finished() -> void:
	if "attak" in animated_sprite_2d.animation:
		is_attaking= false
		if katana:
			katana.visible = false 
	


func _on_hitbox_body_entered(body: CharacterBody2D) -> void:
	if is_attaking and body.name == 'slime':
		print(body.name)
		print("hit")
