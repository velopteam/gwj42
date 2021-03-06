extends Node

var effect_player = preload("res://source/helpers/soundEffectPlayer.tscn")
var music_player = preload("res://source/helpers/musicPlayer.tscn")
var voice_player = preload("res://source/helpers/voicePlayer.tscn")

var active_music_players : Array = []

var __volume_max: Dictionary = {
	# key: bus name
	# value: starting volume
}
var __volume_min: float = -40.0


# Lifecylce methods
func _ready() -> void:
	randomize()
	var levels = SettingsManager.get_setting("volume", {})
	for key in levels.keys():
		var index = self.__get_bus_index(key)
		self.__volume_max[key] = AudioServer.get_bus_volume_db(index)
		var value: float = lerp(self.__volume_min, self.__volume_max[key], levels[key])
		AudioServer.set_bus_volume_db(index, value)
	
	Event.connect("emit_audio", self, "play_audio")


# Public methods
func get_volume(name: String) -> float:
	return SettingsManager.get_setting("volume/%s" % name, 1.0)


func get_volume_db(name: String) -> float:
	var volume: float = self.get_volume(name)
	return lerp(self.__volume_min, self.__volume_max[name], volume)


func set_volume(name: String, value: float) -> void:
	var index: int = self.__get_bus_index(name)

	var volume_db: float = -INF
	if value > 0.0:
		volume_db = lerp(self.__volume_min, self.__volume_max[name], value)
	AudioServer.set_bus_volume_db(index, volume_db)

	SettingsManager.set_setting("volume/%s" % name, value, true)


# Private methods
func __get_bus_index(name: String) -> int:
	return AudioServer.get_bus_index(name)

func play_audio(options: Dictionary) -> void:
	var bus = options["bus"]
	var choice = options["choice"]
	var loop = options["loop"]
	if bus == "music":
		__play_music(choice, loop)
	elif bus == "effect":
		__play_effect(choice)
	elif bus == "voice":
		__play_voice(choice)
	else:
		__play_effect("error")

func __play_music(choice: String, loop: bool) -> void:
	var new_player = music_player.instance()
	match choice:
		"menu":
			if !loop:
				new_player.audio_path = "res://assets/audio/music/menu_start.ogg"
			else:
				new_player.audio_path = "res://assets/audio/music/menu_loop.ogg"
			new_player.choice = "menu"
		"battle":
			if !loop:
				new_player.audio_path = "res://assets/audio/music/battle_start.ogg"
			else:
				new_player.audio_path = "res://assets/audio/music/battle_loop.ogg"
			new_player.choice = "battle"
		"battle_end":
			new_player.audio_path = "res://assets/audio/music/battle_end.ogg"
		
	# Delete last music player, if one exists
	if active_music_players.size() > 0:
		active_music_players[0].queue_free()
		active_music_players.pop_front()
	# Add handle to array for layer deletion
	active_music_players.push_back(new_player)
	self.add_child(new_player)

func __play_effect(choice: String) -> void:
	var new_player = effect_player.instance()
	new_player.pitch_scale = rand_range(0.9, 1.1)
	match choice:
		"thunder":
			new_player.audio_path = "res://assets/audio/effects/zeus/thunder.ogg"
		"rune_thud":
			var randChoice = randi() % 2
			match randChoice:
				0:
					new_player.audio_path = "res://assets/audio/effects/slab_thud/slab_hit1.ogg"
				1:
					new_player.audio_path = "res://assets/audio/effects/slab_thud/slab_hit2.ogg"
		"rune_move":
			var randChoice = randi() % 5
			match randChoice:
				0:
					new_player.audio_path = "res://assets/audio/effects/slab_move/HeavyStone-00.ogg"
				1:
					new_player.audio_path = "res://assets/audio/effects/slab_move/HeavyStone-01.ogg"
				2:
					new_player.audio_path = "res://assets/audio/effects/slab_move/HeavyStone-02.ogg"
				3:
					new_player.audio_path = "res://assets/audio/effects/slab_move/HeavyStone-03.ogg"
				4:
					new_player.audio_path = "res://assets/audio/effects/slab_move/HeavyStone-04.ogg"
		"rune_drop":
			new_player.pitch_scale = rand_range(0.7, 1.0)
			new_player.audio_path = "res://assets/audio/effects/slab_thud/land.ogg"
		"GONG":
			new_player.pitch_scale = rand_range(0.7, 1.0)
			new_player.audio_path = "res://assets/audio/effects/god_select/GONG.ogg"
		"menu_select":
			new_player.pitch_scale = rand_range(0.85, 1.15)
			new_player.volume_db = 3
			var randChoice = randi() % 2
			match randChoice:
				0:
					new_player.audio_path = "res://assets/audio/effects/menu_select/menu_select-00.ogg"
				1:
					new_player.audio_path = "res://assets/audio/effects/menu_select/menu_select-01.ogg"
		"paper":
			new_player.pitch_scale = rand_range(0.85, 1.15)
			new_player.volume_db = -3
			var randChoice = randi() % 3
			match randChoice:
				0:
					new_player.audio_path = "res://assets/audio/effects/paper/1.ogg"
				1:
					new_player.audio_path = "res://assets/audio/effects/paper/2.ogg"
				2:
					new_player.audio_path = "res://assets/audio/effects/paper/3.ogg"
	
	self.add_child(new_player)

func __play_voice(choice: String) -> void:
	var new_player = voice_player.instance()
	new_player.pitch_scale = rand_range(0.85, 1.15)
	match choice:
		"zeus":
			new_player.audio_path = "res://assets/audio/effects/god_voice/zeus.ogg"
		"amon ra":
			new_player.pitch_scale = rand_range(0.55, 0.85)
			new_player.audio_path = "res://assets/audio/effects/god_voice/amon_ra.ogg"
		"chicomecoatl":
			new_player.audio_path = "res://assets/audio/effects/god_voice/chicomecoatl.ogg"
		"gaia":
			new_player.audio_path = "res://assets/audio/effects/god_voice/Gaia.ogg"
		"poseidon":
			new_player.audio_path = "res://assets/audio/effects/god_voice/poseidon.ogg"
		"dionysus":
			new_player.audio_path = "res://assets/audio/effects/god_voice/dionysus.ogg"
		"hades":
			new_player.audio_path = "res://assets/audio/effects/god_voice/hades.ogg"
	self.add_child(new_player)
