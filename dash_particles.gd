extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


#Makes dash particle bigger
func _process(delta):
	process_material.scale_min = self.scale.x * 1
	process_material.scale_min = self.scale.y * 1
