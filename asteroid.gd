extends RigidBody2D
signal asteroid_left_screen(instance)
signal puff( Binstance)
signal game_over()
signal levelComplete()
signal startPlayerDiedTimer()
signal flashDamage()

const INDICATOR_POINTS = preload("res://DamageIndicator.tscn")


export var min_scale = .25
export var max_scale = 1.5
export var scaling = 1
export var min_speed = 100  # Minimum speed range.
export var max_speed = 200  # Maximum speed range.
export var min_health = 50
export var max_health = 100
export var health = 50

var collisionFlag = false
var elapsedTime = 0
var animationIndex = 0
export var animationDelay = .15

var spriteArray = [[0,0],[128,0],[256,0],[384,0],[512,0],[640,0],[768,0],[896,0],\
		[0,128],[128,128],[256,128],[384,128],[512,128],[640,128],[768,128],[896,128],\
		[0,256],[128,256],[256,256],[384,256],[512,256],[640,256],[768,256],[896,256],\
		[0,384],[128,384],[256,384],[384,384],[512,384],[640,384],[768,384],[896,384]]

func _ready():
	
	$Sprite.region_rect.position.x = spriteArray[animationIndex][0]
	$Sprite.region_rect.position.y = spriteArray[animationIndex][1]
	$CollisionShape2D.disabled = false
	$Sprite.scale = Vector2(scaling,scaling)
	$CollisionShape2D.scale = Vector2(scaling,scaling)
	self.scale = Vector2(scaling,scaling)	
	self.mass = self.mass * scaling
	var _rtrn = self.connect('body_entered', self, 'bang')
	_rtrn = self.connect('game_over',get_node('../../Main'), 'game_over')
	_rtrn = self.connect('updateHealth',get_node('../HUD'), 'update_health')
	_rtrn = self.connect('updateLives',get_node('../HUD'), 'update_lives')
	_rtrn = self.connect('levelComplete',get_node('../../Main'), 'new_level')
	_rtrn = self.connect('startPlayerDiedTimer',get_node('../../Main'), 'startDiedtimer')
	_rtrn = self.connect('flashDamage',get_node('../HUD'), 'flashDamage')
	
	
	self.show()
	
func _process(delta):
	elapsedTime += delta
	
	if elapsedTime >= animationDelay:
		#change animation
		animationIndex+=1
		if animationIndex >= 32:
			animationIndex = 0
		$Sprite.region_rect.position.x = spriteArray[animationIndex][0]
		$Sprite.region_rect.position.y = spriteArray[animationIndex][1]
		elapsedTime = 0 

func _on_VisibilityNotifier2D_screen_exited():
	emit_signal("asteroid_left_screen", self)

func unload():
	self.queue_free()

func bang(body):
	var plyr = Globals.player_instance

	if "Player" in body.name:
		if !collisionFlag && !Globals.playerImmunity:
			collisionFlag = true
			$collisionTimer.start()
			Globals.camera.shake(100)
			emit_signal("flashDamage")
			$ship2asteroid.play()
			var printstring = 'Collision, asteroid: %s' % plyr
			print(printstring)
			Globals.DataState["Health"] -= 5
			
			if Globals.DataState["Health"] <= 0:
				Globals.DataState["Health"] = 0
				Globals.DataState["Lives"] -= 1
				if Globals.DataState["Lives"] <= 0:
					Globals.DataState["Lives"] = 0
					emit_signal("game_over")
				else:
					#go to player Died psuedo state
					Globals.playerImmunity = true
					plyr.queue_free()
					emit_signal("startPlayerDiedTimer")
					#emit signal to main to start player died timer
#				
	if "asteroid" in body.name:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var my_random_number = rng.randf_range(0, 2)
		if my_random_number < 1:
			$bang1.play()
		elif my_random_number < 2:
			$bang2.play()
		else:
			$bang3.play() 

	if "Bullet" in body.name:
		if Globals.gameState == Globals.states.RUNNING:
			var scoreValue
			if(scaling < .6):
				scoreValue = int(rand_range(15,20))
			elif(scaling < 1 && scaling >= 0.6):
				scoreValue = int(rand_range(10,15))
			else:
				scoreValue = int(rand_range(5,10))
			spawn_Points(scoreValue)
			Globals.DataState["Score"] += scoreValue
			emit_signal("puff",body)
			self.health -= plyr.weaponPower
			if self.health <= 0:
				Globals.DataState["Score"] += 50
				emit_signal("puff",body)
				print('Asteroid Destroid: %s' % self)
				print('Global Objects remaining: %d' % Globals.levelObjectCount)
				self.queue_free()
				Globals.DataState['Ammo'] += 5
				Globals.levelObjectCount += 1
				var diff = Globals.levelObjectLimit -Globals.levelObjectCount
				print('Global Objects remaining: %d' % diff)
				if Globals.levelObjectCount == Globals.levelObjectLimit:
					emit_signal("levelComplete")
	Globals.player_instance = plyr
			

func _on_collisionTimer_timeout():
	collisionFlag = false
	
func spawn_Effect(effect, effect_position = global_position):
	if effect:
		var ef = effect.instance()
		get_tree().current_scene.add_child(ef)
		ef.global_position = effect_position
		return ef

func spawn_Points(points):
	var ind = spawn_Effect(INDICATOR_POINTS)
	if ind:
		ind.label.text = str(points)
