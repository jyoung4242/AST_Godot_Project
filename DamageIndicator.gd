extends Node2D

export var animSpeed = 30
export var friction = 15
var SHIFT_DIRECTION = Vector2.ZERO

onready var label = $Label

func _ready():
	SHIFT_DIRECTION = Vector2(rand_range(-1,1), rand_range(-1,1))
	
func _process(delta):
	global_position += animSpeed * SHIFT_DIRECTION * delta
	animSpeed = max(friction * delta, 0)
 
