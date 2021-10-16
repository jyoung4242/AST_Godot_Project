
extends KinematicBody2D

export (int) var speed = 0
export (float) var rotation_speed = 5

export var velocity = Vector2()
export var rotation_dir = 0 #radians
export var acceleration = 7
export var decceleration = 7
export var maxSpeed = 200
export var weaponPower = 10

export var movingAngle = 0 #degrees
export var bodyAngle = 0 #degrees
var deltaAngle = 0 #degrees
var incrementAngle = 0 #degrees
var direction = "CW"

func get_input():
	rotation_dir = 0
	velocity = Vector2()
	
	if Input.is_action_pressed("ui_right"):
		bodyAngle += 5
		setGap()
	elif Input.is_action_pressed("ui_left"):
		bodyAngle -= 5
		setGap()
	
	if Input.is_action_pressed("ui_down"):
		speed -= decceleration
		if speed <= -maxSpeed:
			speed = -maxSpeed
		closeGap()
		setGap()
		velocity = Vector2(speed, 0).rotated(deg2rad(movingAngle))
		
	elif Input.is_action_pressed("ui_up"):
		speed += acceleration
		if speed >= maxSpeed:
			speed = maxSpeed
		closeGap()
		setGap()
		velocity = Vector2(speed, 0).rotated(deg2rad(movingAngle))
	else: 
		velocity = Vector2(speed, 0).rotated(deg2rad(movingAngle))
	
func normalizeAngle(ang):
	if abs(ang) > 359:
		if ang>0:
			ang -= 360
		else:
			ang += 360
	elif ang < 0:
		ang += 360
	return ang
	
func setGap():
	if bodyAngle != movingAngle:
		bodyAngle = normalizeAngle(bodyAngle)
		movingAngle = normalizeAngle(movingAngle)
		deltaAngle = abs(bodyAngle-movingAngle)
		if deltaAngle > 180:
			deltaAngle = abs(deltaAngle-360)
				
		incrementAngle = (deltaAngle/(abs(speed/15) +.1))
		
		var oppositeAngle = movingAngle + 180
		
		if oppositeAngle >= 360:
			oppositeAngle -= 360
		elif oppositeAngle < 0:
			oppositeAngle += 360
			
		if abs(oppositeAngle - bodyAngle) < 180:
			if bodyAngle > oppositeAngle:
				direction = "CW"
			else:
				direction = "CCW"
		else:
			if bodyAngle > oppositeAngle:
				direction = "CCW"
			else:
				direction = "CW"
			
func rad2deg(rad):
	return 180*rad

func deg2rad(deg):
	return 180/deg
			
			
func closeGap():
	if bodyAngle != movingAngle:
		if deltaAngle < 2:
			movingAngle = bodyAngle
			incrementAngle = 0
		else:
			if (direction == "CW"):
				movingAngle -= incrementAngle
			else:
				movingAngle += incrementAngle


func _physics_process(_delta):
	get_input()
	rotation = deg2rad(bodyAngle) 
	velocity = move_and_slide(velocity)


# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = Vector2((1024/2),(600/2))


func _on_VisibilityNotifier2D_screen_exited():
	var screenX = get_viewport_rect().size.x
	var screenY = get_viewport_rect().size.y
	var astX = self.position.x
	var astY = self.position.y
	
	if astX > screenX:
		self.position.x = 0
	elif astX < 0:
		self.position.x = screenX + 50
	elif astY > screenY:
		self.position.y = 0
	elif astY < 0:
		self.position.y = screenY +50
	
