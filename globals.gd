extends Node

const versionString = "V0.0.02"

var levelObjectLimit = 2
var levelObjectCount = 0
var levelObjectIndex = 0
var camera = null
var playerImmunity = false

enum states {IDLE, RUNNING, GAMEOVER}
var gameState = states.IDLE

var DataState = {
	"Lives": 3,
	"Health": 25,
	"Ammo": 25,
	"Score": 0,
}

var player_instance = null
var gameLevel = 1
