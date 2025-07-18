extends Node2D

@onready var heartsContainer = $CanvasLayer/HealthContainer
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	heartsContainer.setMaxHearts(player.maxhealth)
	heartsContainer.updateHearts(player.currentHealth)
	player.healthChanged.connect(heartsContainer.updateHearts)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_2_area_entered(area):
	pass # Replace with function body.
