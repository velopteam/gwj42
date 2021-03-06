class_name TurnController extends Node


# Public signals

signal rune_picked(player_state)
signal died()


# Private constants

const __RUNE_SCENE: PackedScene = preload("res://source/scenes/game/rune.tscn")
const __INITIAL_HEALTH: int = 5


# Protected variables

var _deck: CardDeck = null
var _discard: Discard = null
var _hand: Hand = null
var _health: int = __INITIAL_HEALTH
var _hearts: Array = []
var _interact: bool = false
var _plinths: Array = []
var _stack: Stack = null


# Lifecycle methods

func _init(
	discard: Discard,
	hand: Hand,
	hearts: Array,
	plinths: Array,
	stack: Stack
) -> void:
	_discard = discard
	_hand = hand
	_hearts = hearts
	_plinths = plinths
	_stack = stack


# Public methods

func damage(amount: int) -> void:
	_health = max(0, _health - amount)

	for i in _hearts.size():
		_hearts[i].set_full(i < _health)

	if _health == 0:
		emit_signal("died")


func discard() -> void:
	for plinth in _plinths:
		var rune: Rune = plinth.remove()

		if rune:
			_discard.add(rune)


func draw() -> void:
	while _hand.can_add():
		var rune: Rune = _stack.pop()

		_hand.add(rune)

		yield(get_tree().create_timer(0.7), "timeout")

	refill_stack()



func flip() -> void:
	for plinth in _plinths:
		yield(plinth.flip(), "completed")


func heal() -> void:
	for heart in _hearts:
		heart.set_full(true)

		yield(get_tree().create_timer(0.1), "timeout")


func refill_stack() -> void:
	if _stack.empty():
		yield(__shuffle_discard(), "completed")
		yield(get_tree().create_timer(0.5), "timeout")


func set_deck(deck: CardDeck) -> void:
	_deck = deck

	__initialize_discard()


func set_interact(interact: bool) -> void:
	_interact = interact


func get_runes() -> Array:
	var runes: Array = []

	for plinth in _plinths:
		runes.append(plinth.get_rune())

	return runes


# Private methods

func __initialize_discard() -> void:
	for card_state in _deck.cards:
		var rune: Rune = __RUNE_SCENE.instance()
		rune.global_position = _discard.global_position
		rune.card_state = card_state

		add_child(rune)

		_discard.add(rune, false)


func __shuffle_discard() -> void:
	_discard.shuffle()

	while !_discard.empty():
		var rune: Rune = _discard.pop()

		_stack.add(rune)

		yield(get_tree().create_timer(0.5), "timeout")
