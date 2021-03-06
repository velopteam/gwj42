class_name PlayerTurnController extends TurnController


# Private variables

var __active_plinth: Plinth = null
var __active_rune: Rune = null
var __following: bool = false
var __has_sounded: bool = false

# Lifecycle methods

func _init(
	discard: Discard,
	hand: Hand,
	hearts: Array,
	plinths: Array,
	stack: Stack
).(discard, hand, hearts, plinths, stack) -> void:
	for plinth in _plinths:
		plinth.hover_area.connect("mouse_exited", self, "__plinth_dectivate", [plinth])
		plinth.hover_area.connect("mouse_entered", self, "__plinth_activate", [plinth])


func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(BUTTON_LEFT) && __active_rune && _interact:
		var can_add: bool = false

		for plinth in _plinths:
			can_add = can_add || plinth.can_add()

		if !can_add && !__following:
			return

		__following = true

		__active_rune.follow_start()
		__active_rune.global_position = get_viewport().get_mouse_position()
		__active_rune.z_index = 10

		if !__has_sounded:
			# Emit move sound when picking up rune
			Event.emit_signal("emit_audio", {"bus": "effect", "choice": "rune_move", "loop": false})
			__has_sounded = !__has_sounded

	elif __following:
		if __has_sounded:
			__has_sounded = !__has_sounded
		__following = false

		if __active_plinth && __active_plinth.can_add():
			__active_rune.follow_stop()
			_hand.remove(__active_rune)

			var rune: Rune = __active_rune
			__active_rune = null

			yield(__active_plinth.add(rune), "completed")

			emit_signal("rune_picked", PlayerState.new(_health, _plinths, _hand))

		else:
			_hand.deactivate_rune(__active_rune)
			__active_rune.z_index = 0
	else:
		__active_rune = _hand.active_rune


# Private methods

func __plinth_activate(plinth: Plinth) -> void:
	__active_plinth = plinth


func __plinth_dectivate(plinth: Plinth) -> void:
	if __active_plinth != plinth:
		return

	__active_plinth = null
