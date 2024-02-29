extends Node
const musicCity = preload("res://Audio/Music/Music1.ogg")
const musicSpring = preload("res://Audio/Music/SpringSong1.ogg")
const musicWinter = preload("res://Audio/Music/MusicWinter1.ogg")
const musicShop = preload("res://Audio/Music/ShopSong1.ogg")

const ambienceCity = preload("res://Audio/Ambience/BackgroundAmbienceLoop1.ogg")
const ambienceSpring = preload("res://Audio/Ambience/AmbienceSpring.ogg")
const ambienceWinter = preload("res://Audio/Ambience/AmbienceWinter.ogg")

enum MapTypes { CITY, SPRING, WINTER, SHOP }
@export var currentMapType:= MapTypes.SPRING
var mapTypeToChangeTo:= MapTypes.CITY

var isEvenTurn = false

var musicRandom = RandomNumberGenerator.new()


var testHealth = 100


func _on_timer_timeout():
	pass
	#_SFX_ThinkMode(true)
	#_playTrack(MapTypes.SHOP)
	#_SFX_BG_SetLowPass(true)
	#testHealth -= 10
	#_SFX_HealthToHighPass(testHealth)


func _playTrack(mapTypeToChangeTo):
	var musicPlayerToChange
	var ambiencePlayerToChange
	
	if !isEvenTurn:
		musicPlayerToChange = $Music
		ambiencePlayerToChange = $Ambience
	else:
		musicPlayerToChange = $Music2
		ambiencePlayerToChange = $Ambience2
	
	#Set music and ambience variables to mapTypeToChangeTo
	if mapTypeToChangeTo == MapTypes.CITY:
		musicPlayerToChange.set_stream(musicCity)
		ambiencePlayerToChange.set_stream(ambienceCity)
	elif mapTypeToChangeTo == MapTypes.SPRING:
		musicPlayerToChange.set_stream(musicSpring)
		ambiencePlayerToChange.set_stream(ambienceSpring)
	elif mapTypeToChangeTo == MapTypes.WINTER:
		musicPlayerToChange.set_stream(musicWinter)
		ambiencePlayerToChange.set_stream(ambienceWinter)
	elif mapTypeToChangeTo == MapTypes.SHOP:
		musicPlayerToChange.set_stream(musicShop)
		ambiencePlayerToChange.set_stream(ambienceCity)
	
	await get_tree().create_timer(0.1).timeout
	var randomMusicLoopStart = musicRandom.randf_range(0.0, musicPlayerToChange.get_stream().get_length())
	var randomAmbienceLoopStart = musicRandom.randf_range(0.0, ambiencePlayerToChange.get_stream().get_length())
	
	musicPlayerToChange.play(randomMusicLoopStart)
	ambiencePlayerToChange.play(randomAmbienceLoopStart)
	
	if !isEvenTurn:
		$AnimationPlayer1.play("FadeAM1", -1, -1, true)
		$AnimationPlayer2.play("FadeAM2", -1, 0.2, false)
	else:
		$AnimationPlayer1.play("FadeAM1", -1, 0.2, false)
		$AnimationPlayer2.play("FadeAM2", -1, -1, true)
	
	isEvenTurn = !isEvenTurn


func _SFX_BG_SetLowPass(toState):
	var lowPassTween = get_tree().create_tween()
	var lowPass = AudioServer.get_bus_effect(1, 0)
	var desiredLowPassHz
	if toState == true:
		desiredLowPassHz = 800
	else:
		desiredLowPassHz = 20500
		
	lowPassTween.tween_property(lowPass, "cutoff_hz", desiredLowPassHz, 1)


func _SFX_HealthToHighPass(health, max_health):
	var highPassStrength = clamp(remap(health, max_health / 2, 0.0, 1.0, 10000.0), 1.0, 15000.0)
	var heartVolume = clamp(remap(health, max_health / 2, 0.0, -12.0, 0.0), -80.0, 0.0)
	var heartPitch = clamp(remap(health, max_health / 2, 0.0, 0.8, 1.2), 0.8, 1.2)
	var heartSpeed = clamp(remap(health, max_health / 2, 0.0, 4.0, 0.8), 0.8, 0.4)
	_SFX_BG_SetHighPass(highPassStrength)
	
	#print_debug(heartSpeed)
	$Heart.set_pitch_scale(heartPitch)
	$Heart.set_volume_db(heartVolume)
	$Heart/HeartTimer.set_wait_time(heartSpeed)
	#$Heart/HeartTimer.start()


func _on_heart_timer_timeout():
	$Heart.play()
	#print_debug($Heart/HeartTimer.get_wait_time())


func _SFX_BG_SetHighPass(hz):
	var highPassTween = get_tree().create_tween()
	var highPass = AudioServer.get_bus_effect(1, 1)
	highPassTween.tween_property(highPass, "cutoff_hz", hz, 1)

func _SFX_ThinkMode(toState):
	var amplifierTween = get_tree().create_tween()
	var amplifierMusic = AudioServer.get_bus_effect(1, 4)
	var amplifierAmbience = AudioServer.get_bus_effect(2, 1)
	
	var desiredVolume
	if toState == true:
		desiredVolume = -10
	else:
		desiredVolume = 0
		
	amplifierTween.tween_property(amplifierMusic, "volume_db", desiredVolume, 0.5)
	amplifierTween.tween_property(amplifierAmbience, "volume_db", desiredVolume, 0.5)
	


