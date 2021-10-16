extends AnimatedSprite

func _ready():
	self.show()


func _on_boom_animation_finished():
	self.queue_free()
