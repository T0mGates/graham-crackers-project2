extends Button

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
	# Do the end of day updates
	var game_over = recipe_select_scene.end_day()
	
	if game_over:
		# Game is over, wrap it up folks (for now we don't have a game over screen, so just return nothing and let it handle itself)
		# Add a 'return' here if you want to NOT cook the food on loss
		pass
	
	# Instantiating food prep scene and sending list of recipe names
	var food_prep_scene = load(FOOD_PREP_PATH).instantiate()
	food_prep_scene.set_ingredients([breakfast_name, lunch_name, dinner_name])

	# Changing to the food prep scene
	get_tree().change_scene_to_file(FOOD_PREP_PATH)
