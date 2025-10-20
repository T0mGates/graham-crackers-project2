extends Node2D

# Constants
const RECIPE_BOOK_PATH: String 		= "res://Scenes/recipes.json"

# Timer object and label
var _timer: Timer					= Timer.new()
var _timer_label: Label				= Label.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Instantiating all breakfast nodes
	for item in Globals.breakfast_ing_obj:
		add_child(item)
		item.owner = self.get_tree().get_current_scene()

	# Instantiating all lunch nodes
	for item in Globals.lunch_ing_obj:
		add_child(item)
		item.owner = self.get_tree().get_current_scene()

	# Instantiating all dinner nodes
	for item in Globals.dinner_ing_obj:
		add_child(item)
		item.owner = self.get_tree().get_current_scene()

	# Fetching and storing required children
	for child in self.get_children():

		# Setting and storing the timer
		if child is Timer:
			_timer 			 = child
			_timer.wait_time = Globals.timer_time

		# Setting and storing the label
		if child is Label:
			_timer_label = child
			_timer_label.text = str(int(round(Globals.timer_time)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Making sure the timer is always displayed properly
	_timer_label.set_text(str(int(round(_timer.get_time_left()))))


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
	#print(Globals.breakfast.get("ingredients"))
	for i in range(Globals.breakfast.get("ingredients").size()):
	
		# Create and instantiate new ingredients node
		var new_ingredient   = Ingredient.new()
		new_ingredient.name  = "breakfast_%s" % Globals.breakfast.get("ingredients")[i]
		new_ingredient.set_ing_name(Globals.breakfast.get("ingredients")[i])
		new_ingredient.set_ing_id(i)
		new_ingredient.set_sprite("%s_temp" % Globals.breakfast.get("ingredients")[i])
		new_ingredient.scale = Vector2(0.15, 0.15)#new_ingredient.scale / new_ingredient.texture.get_size()
		new_ingredient.set_start_pos(Vector2(i * 125 + 50, 50))
		new_ingredient.to_start_pos()

		# Adding the new ingredient to the scene tree and ingredients list
		Globals.breakfast_ing_obj.append(new_ingredient)

	# Place lunch ingredients on screen
	for i in range(Globals.lunch.get("ingredients").size()):
	
		# Create and instantiate new ingredients node
		var new_ingredient   = Ingredient.new()
		new_ingredient.name  = "lunch_%s" % Globals.lunch.get("ingredients")[i]
		new_ingredient.set_ing_name(Globals.lunch.get("ingredients")[i])
		new_ingredient.set_ing_id(i)
		new_ingredient.set_sprite("%s_temp" % Globals.lunch.get("ingredients")[i])
		new_ingredient.scale = Vector2(0.15, 0.15)#new_ingredient.scale / new_ingredient.texture.get_size()
		new_ingredient.set_start_pos(Vector2(i * 125 + 50, 150))
		new_ingredient.to_start_pos()

		# Adding the new ingredient to the scene tree and ingredients list
		Globals.lunch_ing_obj.append(new_ingredient)

	# Place dinner ingredients on screen
	for i in range(Globals.dinner.get("ingredients").size()):
	
		# Create and instantiate new ingredients node
		var new_ingredient   = Ingredient.new()
		new_ingredient.name  = "dinner_%s" % Globals.dinner.get("ingredients")[i]
		new_ingredient.set_ing_name(Globals.dinner.get("ingredients")[i])
		new_ingredient.set_ing_id(i)
		new_ingredient.set_sprite("%s_temp" % Globals.dinner.get("ingredients")[i])
		new_ingredient.scale = Vector2(0.15, 0.15)#new_ingredient.scale / new_ingredient.texture.get_size()
		new_ingredient.set_start_pos(Vector2(i * 125 + 50, 250))
		new_ingredient.to_start_pos()

		# Adding the new ingredient to the scene tree and ingredients list
		Globals.dinner_ing_obj.append(new_ingredient)

func end_cooking() -> void:

	## Removing all breakfast nodes
	#for item in Globals.breakfast_ing_obj:
		#item.queue_free()
#
	## Removing all lunch nodes
	#for item in Globals.lunch_ing_obj:
		#item.queue_free()
#
	## Removing all dinner nodes
	#for item in Globals.dinner_ing_obj:
		#item.queue_free()

	# Instantiating end scene
	load("res://Scenes/EndScene.tscn").instantiate()

	# Changing to the end scene
	get_tree().change_scene_to_file("res://Scenes/EndScene.tscn")

func _on_timer_timeout() -> void:
	end_cooking()
