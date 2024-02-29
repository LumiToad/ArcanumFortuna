extends Node

#@export var SFX_CardSignature: AudioStream

const SFX_CardPickUp = preload("res://Audio/Card/CardPickUp.ogg")
const SFX_CardPutDown = preload("res://Audio/Card/CardPutDown.ogg")
const SFX_CardRumble = preload("res://Audio/Card/CardRumble.ogg")


var remappedSpeed = 0.0
var lastSpeed = 0.0
var newSpeed = 0.0

var dropletScaler = 0.0

var audioRandom = RandomNumberGenerator.new()


func _SFX_PickUp():
	# Start Loop
	randomize()
	var randomLoopStart = audioRandom.randf_range(0.0, $LoopRumble.get_stream().get_length())
	$LoopRumble/AnimationPlayer.play("Fade", 1, 10, false)
	$LoopRumble.play(randomLoopStart)
	$LoopFoley.play(randomLoopStart)
	
	# Start OneShot
	$HandleHit.get_stream().set_stream(0, SFX_CardPickUp)
	$HandleHit.play()


func _SFX_PutDown():
	$LoopRumble/AnimationPlayer.play("Fade", 1, -1, true)
	#$Loop.stop()
	$LoopFoley.stop()
	$HandleHit.get_stream().set_stream(0, SFX_CardPutDown)
	$HandleHit.play()
	
	_SFX_Signature()
	
	await get_tree().create_timer(2).timeout
	$LoopRumble.stop()


func _SFX_Attack():
	#Want to implement "Does card die from this attack? then, CardAttack2.ogg, otherwise, CardAttack1.ogg"
	$Attack.play()

func _SFX_Flip():
	$Flip.play()

func _SFX_SetLoopProps(speed, mousePos):
	newSpeed = lerp(lastSpeed, clamp(remap(speed, 0, 2000, 1.0, 2.0), 1.0, 2.0), 0.1)
	$Sprite2D.scale = Vector2(newSpeed,newSpeed)
	self.position = mousePos
	
	$LoopRumble.set_pitch_scale(clamp(remap(newSpeed, 1.0, 2.0, 1.0, 1.5), 0.1, 2.0))
	#$Loop.set_volume_db(remap(newSpeed, 1.0, 2.0, -8.0, 0))
	$LoopFoley.set_pitch_scale(clamp(remap(newSpeed, 1.5, 2.0, 0.5, 1.5), 0.1, 2.0))
	$LoopFoley.set_volume_db(remap(newSpeed, 1.6, 2.0, -32.0, 0))
	
	lastSpeed = newSpeed

func _SFX_HandCardHover():
	$HandHover.play()

func _SFX_KarmaBlip():
	$KarmaPlayerDroplet.play()
	$KarmaPlayerDroplet.set_pitch_scale(0.5*sqrt(dropletScaler)+1)
	dropletScaler += 1

func _SFX_Signature():
	#print_debug(get_parent().sound_effect)
	var signatureSFX = get_parent().card_data.sound_effect
	$Signature.set_stream(signatureSFX)
	$Signature/SignatureTimer.start()

func _on_signature_timer_timeout():
	$Signature.play()
