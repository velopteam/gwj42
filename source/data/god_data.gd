#god_data.gd
extends Resource

var name
var description


# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(g_name = "", g_description = ""):
	name = g_name
	description = g_description
