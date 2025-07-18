extends Node2D

@onready var Static = $StaticBody2D
@onready var Area = $Area2D
@onready var animation = $AnimatedSprite2D



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_2d_area_entered(area):
	if area.get_parent() is Player:
		animation.play("open")
		print("door")
		Area.queue_free()
		$DoorTimer.start()

func _on_door_timer_timeout():
	Static.queue_free()
