extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_pressed() -> void:

	# Instantiating recipe scene
	load("res://Scenes/recipe_select.tscn").instantiate()

	# Changing to the recipe scene
	get_tree().change_scene_to_file("res://Scenes/recipe_select.tscn")
