extends CharacterBody2D
class_name Enemies

@onready var animation = $AnimatedSprite2D
@onready var animation2 = $AnimationPlayer2

#Negative speed means going left
var speed = -100.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var facing_right=false


var dead = NOTIFICATION_WM_CLOSE_REQUEST

func _ready():
	animation.play("walk(?)")

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#If the enemy is at the egde of a platform, it will flip
	if !$RayCast2D.is_colliding() and is_on_floor():
		flip()

	velocity.x = speed
	move_and_slide()

func flip():
	facing_right = !facing_right
	
	#abs means absolute value
	scale.x = abs(scale.x) * -1
	if facing_right:
		speed = abs(speed)
	else: 
		speed = abs(speed) * -1


func die():
	dead = true
	speed = 0
	animation2.play("explode")
