extends Node

const SFX_VFXKarmaBlipLo = preload("res://Audio/Karma/VFXKarmaBlipLo.ogg")
const SFX_VFXKarmaBlipMid = preload("res://Audio/Karma/VFXKarmaBlipMid.ogg")
const SFX_VFXKarmaBlipHi = preload("res://Audio/Karma/VFXKarmaBlipHi.ogg")

const SFX_DamagePlayer = preload("res://Audio/Card/PlayerDamage.ogg")
const SFX_DamageEnemy = preload("res://Audio/Card/DamageEnemy.tres")

const SFX_Win = preload("res://Audio/LevelStuff/Win1.ogg")
const SFX_Loss = preload("res://Audio/LevelStuff/Win1.ogg")

var dropletScaler = 0.0
var waitingOnKarma = false

func _SFX_Draw():
	$Draw.play()


func _SFX_HandOpen():
	$HandOpen.play()


func _SFX_HandClose():
	$HandClose.play()


func _SFX_HandCardHover():
	$HandCardHover.play()


func _SFX_Damage():
	return


func _SFX_DamagePlayer():
	$Damage.set_stream(SFX_DamagePlayer)
	$Damage.play()

func _SFX_DamageEnemy():
	$Damage.set_stream(SFX_DamageEnemy)
	$Damage.play()

func _SFX_PlacableHover():
	$PlacableHover.play();
	$PlacableHoverLoop.play();
	$PlacableHoverLoop/AnimationPlayer.play("Fade", 1, 10, false)
	
func _SFX_PlacableHoverStop():
	#$UIHoverLoop.stop();
	$PlacableHoverLoop/AnimationPlayer.play("Fade", 1, -4, true)

func _SFX_Blip(karmaValue):
	#var blipScale = clamp(remap(karmaValue, -4.0, 4.0, 0.8, 1.5), 0.8, 1.5)
	
	#$KarmaPlayerBlip.play()
	#$KarmaPlayerBlip.set_pitch_scale(blipScale)
	if karmaValue <0:
		$KarmaPlayerBlip.get_stream().set_stream(0, SFX_VFXKarmaBlipLo)
	elif karmaValue >0:
		$KarmaPlayerBlip.get_stream().set_stream(0, SFX_VFXKarmaBlipHi)
	else:
		$KarmaPlayerBlip.get_stream().set_stream(0, SFX_VFXKarmaBlipMid)
	$KarmaPlayerBlip.play()
	
	
	$KarmaPlayerDroplet.play()
	$KarmaPlayerDroplet.set_pitch_scale(0.5*sqrt(dropletScaler)+1)
	dropletScaler += 1
	
	#_SFX_KarmaResult()

func _SFX_KarmaResult():
	if waitingOnKarma == false:
		waitingOnKarma = true
		await get_tree().create_timer(1).timeout
		$KarmaResult.play()
		waitingOnKarma = false


func _SFX_UIButtonHover():
	$UiButtonHover.play()


func _SFX_UIButtonPress():
	$UiButtonPress.play()

func _SFX_Knock():
	$Knocks.play()

func _on_test_knock_timer_timeout():
	#_SFX_Knock()
	_SFX_Coin()

func _SFX_EnterLevel():
	$LevelDenoter.play()

func _SFX_DestroyCard():
	$DestroyCard.play()

func _SFX_Effect():
	$Effect.play()

func _SFX_Win():
	$WinLoss.set_stream(SFX_Win)
	$WinLoss.play()

func _SFX_Loss():
	$WinLoss.set_stream(SFX_Loss)
	$WinLoss.play()

func _SFX_Coin():
	$UiButtonPress.play()
	$CoinDing.play()
	$CoinLand.play()

func _SFX_Money():
	$Money.play()
