extends TextureButton

# Constants
const FOOD_PREP_PATH = "res://Scenes/food_prep.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Called when the pressed signal is received for this button
func _on_pressed() -> void:

	# Instantiating food prep scene and sending list of recipe names
	var food_prep_scene = load(FOOD_PREP_PATH).instantiate()
	food_prep_scene.set_ingredients(["bacon_eggs_toast", "salad", "canned_soup"])

	# Changing to the food prep scene
	get_tree().change_scene_to_file(FOOD_PREP_PATH)
