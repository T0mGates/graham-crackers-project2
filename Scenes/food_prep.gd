extends Node2D

# Constants
const RECIPE_BOOK_PATH: String 		= "res://Scenes/recipes.json"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Instantiating all breakfast nodes
	for item in Globals.breakfast_ing_obj:
		add_child(item)
		item.owner = self.get_tree().get_current_scene()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


# Called by the previous scene to set the starting data
func set_ingredients(received_recipes: Array) -> void:
	print(received_recipes)

	# Retrieving master list of recipes
	var recipe_book   = Globals.get_json_from_file(RECIPE_BOOK_PATH)
	print(recipe_book)

	# Setting the breakfast lunch and dinner recipes
	Globals.breakfast = recipe_book.get(received_recipes[0])
	Globals.lunch 	  = recipe_book.get(received_recipes[1])
	Globals.dinner    = recipe_book.get(received_recipes[2])

	# Place breakfast ingredients on screen
	print(Globals.breakfast.get("ingredients"))
	for i in range(Globals.breakfast.get("ingredients").size()):
	
		# Create and instantiate new ingredients node
		var new_ingredient  = Ingredient.new()
		new_ingredient.name = "breakfast_%s" % Globals.breakfast.get("ingredients")[i]
		new_ingredient.set_ing_name(Globals.breakfast.get("ingredients")[i])
		new_ingredient.set_ing_id(i)
		new_ingredient.set_sprite("%s_temp" % Globals.breakfast.get("ingredients")[i])
		new_ingredient.scale = Vector2(0.1, 0.1)#new_ingredient.scale / new_ingredient.texture.get_size()
		new_ingredient.set_start_pos(Vector2(i * 20 + 20, 20))
		new_ingredient.to_start_pos()

		# Adding the new ingredient to the scene tree and ingredients list
		Globals.breakfast_ing_obj.append(new_ingredient)

	# Place lunch ingredients on screen



	# Place dinner ingredients on screen
