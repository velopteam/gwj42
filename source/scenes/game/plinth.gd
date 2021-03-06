class_name Plinth extends Node2D


# Public varaibles

onready var hover_area: Area2D = $hover_area


# Private variables

onready var __rune_position: Position2D = $rune_position;

var __rune: Rune = null


# Public variables

func add(rune: Rune) -> void:
	__rune = rune

	yield(rune.move(__rune_position.global_position, false, z_index), "completed")


func can_add() -> bool:
	return __rune == null


func flip() -> void:
	yield(__rune.move(__rune_position.global_position, true, z_index), "completed")


func get_rune() -> Rune:
	return __rune


func remove() -> Rune:
	var rune: Rune = __rune

	__rune = null

	return rune
