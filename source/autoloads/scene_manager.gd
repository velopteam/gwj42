extends Node


export ( Array, Resource ) var scenes

var __scenes_by_name = {}


# Lifecycle methods
func _ready() -> void:
	for scene in self.scenes:
		var scene_name: String = scene.get_state().get_node_name(0)
		self.__scenes_by_name[scene_name] = scene


# Public methods
func load_scene(name: String, handle_transition: bool = true) -> void:
	if name in self.__scenes_by_name:
		if handle_transition:
			yield(Transition.start(), "completed")

		self.get_tree().change_scene_to(self.__scenes_by_name[name])

		if handle_transition:
			yield(Transition.stop(), "completed")
	else:
		push_error("Could not load scene with name: %s" % name)
