tool
extends CollisionPolygon2D
class_name Territory

var PlayerColors = preload("res://assets/PlayerColors.tres")

export var territory_owner: int = 0 setget set_territory_owner
export(Enums.territory_types) var type = Enums.territory_types.normal setget set_type

var color: Color setget set_color
var highlight_color: Color
onready var area2d = $Area2D

func _ready():
	color = PlayerColors.colors[territory_owner]
	highlight_color = color.lightened(.2)

	$Polygon2D.polygon = polygon
	$Polygon2D.color = get_polygon_color()

	if not Engine.editor_hint:
		call_deferred("_reparent_area2d")

func _reparent_area2d():
	# make this area2d our parent so we can create a polygon2d in the editor, but
	# use an Area2D with a polygon shape and collision box in game
	remove_child(area2d)
	get_parent().add_child(area2d)

	get_parent().remove_child(self)
	area2d.add_child(self)

func set_color(value):
	color = value
	$Polygon2D.color = get_polygon_color()

func set_territory_owner(value: int):
	territory_owner = value
	set_color(PlayerColors.colors[value])

func set_type(value):
	type = value
	$Polygon2D.color = get_polygon_color()

func get_polygon_color():
	if type == Enums.territory_types.normal:
		return color
	elif type == Enums.territory_types.resource:
		return color.lightened(0.3)
	elif type == Enums.territory_types.destroyed:
		return Color.orangered

# Pass along some area2d signals to the parent
func _on_Area2D_mouse_entered():
	$Polygon2D.color = highlight_color

func _on_Area2D_mouse_exited():
	$Polygon2D.color = get_polygon_color()
