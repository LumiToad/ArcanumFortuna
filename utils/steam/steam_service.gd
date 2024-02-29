extends Node


var is_stats_ready := false

func _ready():
	initialize_steam()
	Steam.user_stats_received.connect(_on_steam_stats_ready, CONNECT_ONE_SHOT)


func _process(_delta: float) -> void:
	Steam.run_callbacks()


func initialize_steam() -> void:
	var initialize_response: Dictionary = Steam.steamInitEx()
	if OS.has_feature("debug"):
		print("[Steam] initialize result: %s " % initialize_response)
		print_debug_data()


func print_debug_data():
	var is_on_steam_deck: bool = Steam.isSteamRunningOnSteamDeck()
	var is_online: bool = Steam.loggedOn()
	var is_owned: bool = Steam.isSubscribed()
	var steam_id: int = Steam.getSteamID()
	var steam_username: String = Steam.getPersonaName()
	
	print("[Steam] on Steam Deck: %s" % is_on_steam_deck)
	print("[Steam] is online: %s" % is_online)
	print("[Steam] is game owned: %s" % is_owned)
	print("[Steam] Steam ID: %d" % steam_id)
	print("[Steam] Steam username: %s" % steam_username)
	
	print("[Steam] Test achievement: %s" % try_get_achievement("Better than Noyan"))


func _on_steam_stats_ready(game: int, result: int, user: int) -> void:
	if OS.has_feature("debug"):
		print("[Steam] stat result: %s" % result)
		print("[Steam] received game ID: %s" % game)
		print("[Steam] received user ID: %s" % user)

	is_stats_ready = true


func try_get_achievement(name: String):
	var achievement: Dictionary = Steam.getAchievement(name)

	# Achievement exists
	if achievement['ret']:
		return achievement
	return null



func try_unlock_achievement(name: String) -> bool:
	# Pass the value to Steam
	var result = Steam.setAchievement(name)
	if not result:
		return false
	
	# Makes the visual achivement pop appear
	Steam.storeStats()
	return true
