extends Node2D

#Define signals
signal HUD_showLevel(level)
signal HUD_showGameOver()
signal UnloadAsteroids()

var latch = false
var gunToggle = false
var bgmToggle = true
var gunFiring = false
var objectCount = 0
var objectLoopIndex = 0
var asteroidToggle = true
var asteroidList = []
export (PackedScene) var asteroid
export (PackedScene) var asteroid1
export (PackedScene) var playerbullet
export (PackedScene) var puff
export (PackedScene) var player


# Called when the node enters the scene tree for the first time.
func _ready():
	$bgm.play()
	randomize()
	setupSignalConnections()
	Globals.gameState = Globals.states.IDLE

func check_input():
	if Input.is_action_just_pressed("ui_ToggleBGM"):
		if bgmToggle:
			bgmToggle = false
			$bgm.stop()
		else:
			bgmToggle = true
			$bgm.play()
	 
	if Globals.gameState == Globals.states.IDLE:
		if Input.is_action_pressed("ui_select"):
			if !latch:
				latch = true
				emit_signal("HUD_showLevel", 1)
				createPlayerInstance()
				
	if Globals.gameState == Globals.states.RUNNING:
		if Input.is_action_pressed("ui_select"):
			if !gunFiring:
				gunFiring = true
				fire_weapon()
		if Input.is_action_just_released("ui_select"):
			gunFiring = false

func setupSignalConnections():
	var _rtrn = self.connect('HUD_showLevel', $HUD, 'show_level')
	_rtrn = self.connect('HUD_showGameOver', $HUD, 'game_over')

func createPlayerInstance():
	var p = player.instance()
	add_child(p)
	p.show()
	Globals.player_instance = p
	var printstring = 'Creating player instance: %s' % p
	print(printstring)
	
func fire_weapon():
	if Globals.DataState["Ammo"] > 0 && !Globals.gameState == Globals.states.GAMEOVER:
		var pew
		pew = playerbullet.instance()
		add_child(pew)
		if gunToggle:
			pew.position.x = $Player.position.x
			pew.position.y = $Player.position.y+10
			gunToggle = false
		else:
			pew.position.x = $Player.position.x
			pew.position.y = $Player.position.y-10
			gunToggle = true
		
		var direction = $Player.rotation
		pew.rotation = $Player.rotation
		pew.linear_velocity = Vector2(350,0)
		pew.linear_velocity = pew.linear_velocity.rotated(direction)
		$player_fire.play()
		Globals.DataState["Ammo"] -= 1

func _process(_delta):
	check_input()

func _on_HUD_start_level():
	
	Globals.gameState = Globals.states.RUNNING
	var plyr = Globals.player_instance
	var printstring = 'HUD startup: player reference: %s' % plyr
	print (printstring)
	plyr.show()
	plyr.set_physics_process(true)
	plyr.set_process(true)
	
	#	emit_signal("HUD_updateHealth", Globals.health)
	Globals.levelObjectCount = 0
	Globals.levelObjectLimit = Globals.gameLevel + 1
	Globals.levelObjectIndex = 0
	
	Globals.DataState['Health'] = 25
	Globals.DataState['Ammo'] = 25
	
	#spawn asteroids randomly
	$"object spawn".start()
	Globals.player_instance = plyr
	latch = false

func spawn_object():
	var next_object

	$objectSpawning/objectSpawnPosition.offset = randi()
	
	if (asteroidToggle):
		next_object = asteroid.instance()
		asteroidToggle = false
	else:
		next_object = asteroid1.instance()
		asteroidToggle = true
	var tempScale = rand_range(next_object.min_scale, next_object.max_scale)
	next_object.scaling = tempScale
	next_object.scale = Vector2(tempScale,tempScale)
	add_child(next_object)
	var _rtrn = next_object.connect("asteroid_left_screen",self,"_on_asteroid_left_screen")
	_rtrn = next_object.connect("puff",self,"puff_play")
	_rtrn = self.connect("UnloadAsteroids", next_object, 'unload')
	asteroidList.append(next_object)
	var direction = $objectSpawning/objectSpawnPosition.rotation + PI / 2
	next_object.position =$objectSpawning/objectSpawnPosition.position
	direction += rand_range(-PI / 4, PI / 4)
	next_object.linear_velocity = Vector2(rand_range(next_object.min_speed, next_object.max_speed), 0)
	next_object.linear_velocity = next_object.linear_velocity.rotated(direction)
	next_object.health = rand_range(next_object.min_health, next_object.max_health)
	Globals.levelObjectIndex +=1
	
	if Globals.levelObjectIndex >= Globals.levelObjectLimit:
		$"object spawn".stop()
		return
	else:
		$"object spawn".start()

func _on_asteroid_left_screen(instance):
	var screenX = get_viewport_rect().size.x
	var screenY = get_viewport_rect().size.y
	var astX = instance.position.x
	var astY = instance.position.y
	
	if astX > screenX:
		instance.position.x = 0
	elif astX < 0:
		instance.position.x = screenX + 50
	if astY > screenY:
		instance.position.y = 0
	elif astY < 0:
		instance.position.y = screenY +50
		 

func puff_play( Bullet):
	
	var newPuff = puff.instance()
	add_child(newPuff)
	newPuff.show()
	newPuff.position = Bullet.position
	#$HUD/SCORELIVES/VBoxContainer/Score/VALUE.text  = String(Globals.score)
	
func game_over():
	Globals.gameState = Globals.states.GAMEOVER 
	var p = Globals.player_instance
	emit_signal("HUD_showGameOver")
	p.queue_free()
	Globals.player_instance = null
	$gameOverTimer.start()
	Globals.gameLevel = 1

func _on_gameOver_timeout():
	Globals.gameState = Globals.states.IDLE 
	Globals.DataState['Lives'] = 3
	Globals.DataState['Score'] = 0
	var _rtrn = get_tree().reload_current_scene()

func new_level():
	print ('New Level!!!')
	Globals.gameLevel += 1
	Globals.levelObjectCount = 0
	Globals.levelObjectLimit = Globals.gameLevel+1
	emit_signal("HUD_showLevel", Globals.gameLevel)


func _on_AmmoRegenTimer_timeout():
	if Globals.DataState["Ammo"]<25:
		Globals.DataState["Ammo"] += 1


func _on_PlayerDiedTimer_timeout():
#	print("generating new player")
	Globals.playerImmunity = false
#	Globals.DataState["Ammo"] = 25
#	Globals.DataState["Health"] = 25
#	createPlayerInstance()
	emit_signal('UnloadAsteroids')
	emit_signal("HUD_showLevel", Globals.gameLevel)
	createPlayerInstance()	
		
func startDiedtimer():
	print("respawning timer")
	$PlayerDiedTimer.start()
