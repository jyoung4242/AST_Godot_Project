extends RigidBody2D




# Called when the node enters the scene tree for the first time.
func _ready():
	var _rtrn = self.connect("body_entered",self,"hit")
	
	
	

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func hit(_body):
	$targetHit.play()
	self.hide()
	


func _on_targetHit_finished():
	queue_free()
