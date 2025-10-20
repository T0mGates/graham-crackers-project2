extends TextureButton

@onready var recipe_select_scene: Node2D = $"../../.."

# Constants
const FOOD_PREP_PATH 	= "res://Scenes/food_prep.tscn"

var breakfast_name   	= ""
var lunch_name 			= ""
var dinner_name 		= ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_meals(breakfast: String, lunch: String, dinner: String):
	breakfast_name 	= breakfast
	lunch_name 		= lunch
	dinner_name 	= dinner

# Called when the pressed signal is received for this button
func _on_pressed() -> void:
	# Instantiating food prep scene and sending list of recipe names
	'''
	var food_prep_scene = load(FOOD_PREP_PATH).instantiate()
	food_prep_scene.set_ingredients([breakfast_name, lunch_name, dinner_name])

	# Changing to the food prep scene
	get_tree().change_scene_to_file(FOOD_PREP_PATH)
	'''
	
	# Now that cooking is finished, tell the main scene manager
	recipe_select_scene.end_day()
