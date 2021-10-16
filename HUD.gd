extends CanvasLayer
signal start_level()
var blinkstatus = false
var oldAmmo = 0
var oldHealth = 0
var oldLives = 0
var oldScore = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	show_idle()
	$VERSION.text = Globals.versionString
	$blinkTimer.start()

		
		
func _on_messageTimer_timeout():
	$LEVELMESSAGE.hide()
	$CONTROLS.hide()
	emit_signal("start_level")

func _on_blinkTimer_timeout():
	if(blinkstatus):
		blinkstatus = false
		$STARTMESSAGE.hide()
	else:
		blinkstatus = true
		$STARTMESSAGE.show()

func _on_gameOver_timeout():
	show_idle()
	
func show_idle():
	$STARTMESSAGE/START/MESSAGE.text = "PRESS SPACEBAR TO BEGIN"
	$STARTMESSAGE.show()
	$LEVELMESSAGE.hide()
	$AMMO.hide()
	$HEALTH.hide()
	$SCORELIVES.hide()
	$blinkTimer.start()
	$CONTROLS.show()
	$VERSION.show()
	$TITLE.show()
	
func show_level(level):
	$STARTMESSAGE.hide()
	$LEVELMESSAGE.show()
	$LEVELMESSAGE/LEVEL/VALUE.text = str(level)
	$AMMO.show()
	$HEALTH.show()
	$SCORELIVES.show()
	$messageTimer.start()
	$blinkTimer.stop()
	$VERSION.hide()
	$TITLE.hide()

func game_over():
	$STARTMESSAGE/START/MESSAGE.text = "GAME OVER"
	$STARTMESSAGE.show()
	
func update_health(newValue):
	$HEALTH/HEALTH/VALUE.text = str(newValue)

func update_lives(newValue):
	$SCORELIVES/VBoxContainer/Lives/VALUE.text = str(newValue)



func _on_stateTimer_timeout():
	if Globals.DataState["Ammo"] != oldAmmo:
		$AMMO/AMMO/VALUE.text = str(Globals.DataState["Ammo"])
	if Globals.DataState["Health"] != oldHealth:
		$HEALTH/HEALTH/VALUE.text = str(Globals.DataState["Health"])
	if Globals.DataState["Score"] != oldScore:
		$SCORELIVES/VBoxContainer/Score/VALUE.text = str(Globals.DataState["Score"])
	if Globals.DataState["Lives"] != oldLives:
		$SCORELIVES/VBoxContainer/Lives/VALUE.text = str(Globals.DataState["Lives"])
		
	oldAmmo = Globals.DataState["Ammo"]
	oldHealth = Globals.DataState["Health"]
	oldLives = Globals.DataState["Lives"]
	oldScore = Globals.DataState["Score"]

func flashDamage():
	print ('signal received')
	$DamageRect/AnimationPlayer.play("showdamage")
		
