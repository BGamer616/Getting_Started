extends CharacterBody2D
class_name Player

@onready var animation = $AnimatedSprite2D
@onready var animationPlayer = $AnimationPlayer
@onready var dash: GPUParticles2D = $DashParticles
@onready var enemies_sound = $enemies
@onready var sword_sound = $Sword
@onready var shoot_sound = $Shoot
@onready var bullet_path = preload("res://scripts/bullet.tscn")
@onready var effects = $AnimationEffects
@onready var hurtTimer = $HurtTimer


@onready var coyoteTimer = $CoyoteTimer
var coyote_time_activated: bool = false

@export var maxhealth = 11
@onready var currentHealth: int = maxhealth
var isHurt: bool = false

var speed = 300.0
const JUMP_VELOCITY = -400.0

@export var attacking = false
@export var cant_move = false
@export var is_taunting = false
@export var can_attack = true
@export var knockbackPower: int = 500

var right_direction = true
var left_direction = false

var enemyCollisions = []

signal healthChanged

var dashing = false
var can_animate = true
var can_dash = true

func _ready():
	GameManager.player = self

func _physics_process(delta):
	if !isHurt:
		for enemyArea in enemyCollisions:
			hurt_by_enemy(enemyArea)
	if cant_move == false:
		var direction = Input.get_axis("ui_left", "ui_right")
		if not is_on_floor():
			velocity += get_gravity() * delta
		if Input.is_action_just_pressed("Left"):
			$HitBox.scale.x = abs($HitBox.scale.x) * -1
			$Node2D.scale.x = -1
			left_direction = true
			right_direction = false
		if Input.is_action_just_pressed("Right"):
			$HitBox.scale.x = abs($HitBox.scale.x)
			$Node2D.scale.x = 1
			right_direction = true
			left_direction = false
		if velocity.x:
			$AnimatedSprite2D.flip_h = velocity.x < 0 #flips sprite based on velocity
		#Jump and Coyote time
		if is_on_floor():
			if coyote_time_activated:
				coyote_time_activated = false
				coyoteTimer.stop()
		else:
			if !coyote_time_activated:
				coyoteTimer.start()
				coyote_time_activated = true
		if Input.is_action_just_pressed("ui_accept") and (!coyoteTimer.is_stopped() or is_on_floor()):
			velocity.y = JUMP_VELOCITY
			coyoteTimer.stop()
			coyote_time_activated = true
		'''if velocity.y < 0 & (is_on_floor() || coyoteTimer.is_stopped()): 
			velocity.y = input_vectory * JUMP_SPEED'''
			
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		
		if Input.is_action_just_pressed("Dash") and can_dash==true:
			dash_move()
		
		if dashing == true:
			velocity.x = direction * (speed * 1.5)
			dash.emitting=true
		else:
			dash.emitting=false
		
		dash.scale.x = -1 if direction < 0 else 1
		
		if Input.is_action_just_pressed("petah"):
			cant_move=true
			what()
		
		if Input.is_action_just_pressed("Shoot"):
			shoot()
		
		var was_on_floor = is_on_floor()
		
		if position.y > 700:
			#print("fall")
			fall()
		
		move_and_slide()
		update_animation()
	
	

func _process(delta):
	if Input.is_action_just_pressed("Attack") and can_attack==true:
		attack()

func update_animation():
	if can_animate == true:
		if !attacking:
			if is_on_floor():
				if velocity.x == 0:
					animation.play("idle")
					dash.emitting=false
				else:
					if !dashing:
						animation.play("run")
					'''else:
						animation.play("dash_start")'''
			else:
				if velocity.y < 0:
					animation.play("jump")
				if velocity.y > 0:
					animation.play("fall")

func dash_move():
	print("dash")
	#animation.play("dash")
	dashing = true
	$DashTimer.start()

func attack():
	var overlapping_objects = $HitBox.get_overlapping_areas()
	for area in overlapping_objects:
		if area.get_parent().is_in_group("Enemies"):
			print(area.get_parent().get_class())
	attacking = true
	can_attack=false
	if velocity.y == 0:
		cant_move=true
	else:
		cant_move=false
	animationPlayer.play("attack")
	sword_sound.play()
	$AttackCooldownTimer.start()
	
func _on_attack_cooldown_timer_timeout():
	$AttackCooldownTimer
	can_attack=true

func shoot():
	var direction = Input.get_axis("ui_left", "ui_right")
	var bullet=bullet_path.instantiate()
	shoot_sound.play()
	if right_direction == true:
		bullet.pos=$Node2D.global_position
		bullet.speed = 700
	elif left_direction == true:
		bullet.pos=$Node2D2.global_position
		bullet.speed = -700
		
	get_parent().add_child(bullet)

func _on_dash_timer_timeout():
	dashing = false

func what():
	is_taunting=true
	can_animate=false
	animation.play("hehe")
	cant_move=true
	can_attack=false
	can_dash=false
	$TauntTimer.start()
	enemies_sound.play()


func _on_taunt_timer_timeout():
	is_taunting=false
	cant_move=false
	can_animate=true
	can_attack=true
	can_dash=true

func hurt_by_enemy(area):
	if !is_taunting:
		currentHealth -= 1
		if currentHealth < 0:
			currentHealth = maxhealth
		healthChanged.emit(currentHealth)
		isHurt = true
		knockback(area.get_parent().velocity) #gets enemy's velocity
		effects.play("HurtBlink")
		animation.play("hurt")
		hurtTimer.start()
		await hurtTimer.timeout
		effects.play("RESET")
		isHurt = false
		print(currentHealth)

#These two functions make it so when you're hurt by the enemy, you can still get hit by them when the iframes wear off and you're still inside their box
func _on_hurt_box_area_entered(area):
	if area.name == "HitBox":
		enemyCollisions.append(area)
		print("oof")
	
func _on_hurt_box_area_exited(area):
	enemyCollisions.erase(area)

func knockback(enemyVelocity: Vector2):
	var knockbackDirection = (enemyVelocity - velocity).normalized() * knockbackPower
	velocity = knockbackDirection
	print_debug(velocity)
	print_debug(position)
	move_and_slide()

func fall():
	GameManager.respawn_player()
