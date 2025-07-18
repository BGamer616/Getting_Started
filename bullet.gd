extends CharacterBody2D

var speed = 700
var direction = 1

var pos:Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	global_position=pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity=Vector2(speed,0)
	var overlapping_objects = $Area2D.get_overlapping_areas()
	for area in overlapping_objects:
		if area.get_parent().is_in_group("Enemies"):
			area.get_parent().die()
	move_and_slide()
	
	if velocity.x == 0:
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	print("Removed")
	queue_free()
