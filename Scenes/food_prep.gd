extends Node2D

# Constants
const RECIPE_BOOK_PATH: 		String 		= "res://Scenes/recipes.json"
const BREAKFAST_STR:			String		= "Breakfast Steps:\n"
const LUNCH_STR:				String		= "Lunch Steps:\n"
const DINNER_STR:				String		= "Dinner Steps:\n"
const MEALS_STR:				String		= "Meals Complete: "
const TRY_AGAIN_STR:			String		= "Incorrect step. Try again!"
const MAX_REDUCTION:			int			= 50

# Timer object and label
@onready var _timer:			Timer		= $"Timer"
@onready var _timer_label: 		Label		= $"TimerLabel"

# Text labels
@onready var _complete_label:	Label		= $"CompleteLabel"
@onready var _meal_label:		Label		= $"MealLabel"
@onready var _step_label:		Label		= $"StepLabel"
@onready var _result_label:		Label		= $"ResultLabel"

# Variables to keep track of cooking completion
@onready var _curr_recipe:		Dictionary	= {}
@onready var _reset_list:		Array		= []
@onready var _recipes_complete: int			= 0
@onready var _curr_order:		int			= 0
@onready var _max_order:		int			= 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Instantiating all breakfast nodes
	for item in Globals.breakfast_ing_obj:
		add_child(item)
		item.owner = self.get_tree().get_current_scene()
		item.check_ingredient.connect(success_check)

	# Instantiating all lunch nodes
	for item in Globals.lunch_ing_obj:
		add_child(item)
		item.owner = self.get_tree().get_current_scene()
		item.check_ingredient.connect(success_check)

	# Instantiating all dinner nodes
	for item in Globals.dinner_ing_obj:
		add_child(item)
		item.owner = self.get_tree().get_current_scene()
		item.check_ingredient.connect(success_check)
#
	# Setting the timer
	_timer.wait_time  = Globals.timer_time

	# Setting setting the timer label according to the timer
	_timer_label.text = str(int(round(Globals.timer_time)))

	# Getting the first recipe and setting the initial values
	_curr_recipe 	  = Globals.breakfast
	_recipes_complete = 0
	_curr_order		  = 0
	_max_order		  = _curr_recipe.get("ingredients").size()

	# Setting the labels
	_meal_label.text  = BREAKFAST_STR + _curr_recipe.get("proper_name")
	_step_label.text  = _curr_recipe.get("directions")[0] if len(_curr_recipe.get("directions")) > 0 else "Skipped meal, shouldn't see this"

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
	for i in range(Globals.breakfast.get("ingredients").size()):

		# Create and instantiate new ingredients node
		var new_ingredient   = Ingredient.new()
		new_ingredient.name  = "breakfast_%s" % Globals.breakfast.get("ingredients")[i]
		new_ingredient.set_ing_name(Globals.breakfast.get("ingredients")[i])
		new_ingredient.set_ing_id(i)

		# Setting the sprite and scale
		new_ingredient.set_sprite("%s" % Globals.breakfast.get("ingredients")[i])
		new_ingredient.scale = Vector2(0.15, 0.15)

		# Generating a random starting position
		new_ingredient.set_start_pos(random_start_pos())
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

		# Setting the sprite and scale
		new_ingredient.set_sprite("%s" % Globals.lunch.get("ingredients")[i])
		new_ingredient.scale = Vector2(0.15, 0.15)

		# Generating a random starting position
		new_ingredient.set_start_pos(random_start_pos())
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

		# Setting the sprite and scale
		new_ingredient.set_sprite("%s" % Globals.dinner.get("ingredients")[i])
		new_ingredient.scale = Vector2(0.15, 0.15)

		# Generating a random starting position
		new_ingredient.set_start_pos(random_start_pos())
		new_ingredient.to_start_pos()

		# Adding the new ingredient to the scene tree and ingredients list
		Globals.dinner_ing_obj.append(new_ingredient)

# Called to generate a random starting position for a sprite
func random_start_pos() -> Vector2:

	# To avoid an infinite loop we have a constant
	const MAX_ATTEMPTS = 100

	# A list containing all ingredient objects
	var master_list    = Globals.breakfast_ing_obj + Globals.lunch_ing_obj + Globals.dinner_ing_obj

	# Default coordinate and break value
	var rand_coord     = Vector2(50.0, 50.0)
	var coord_found    = false

	# Try a number of times to get a valid random position
	for i in range(MAX_ATTEMPTS):

		# If the coordinate was found then break
		if coord_found:
			break

		# Generate a random coordinate
		rand_coord  = Vector2(randf_range(50.0, 600.0), randf_range(50.0, 350.0))

		# Setting the found value to true before the check
		coord_found = true

		# Check master list for ingredients that are too close
		for ing in master_list:
			if ing.global_position.distance_to(rand_coord) < 100.0:
				coord_found = false
				break

	return rand_coord

# Called on a signal to check if the ingredient is being used correctly
func success_check(ingredient, appliance) -> void:

	# Success variable
	var success = true

	# Checking to see if ingredients are correct
	if ingredient.get_ing_name() != _curr_recipe.get("ingredients")[_curr_order]:
		success = false

	# Checking to see if the appliance was correct
	if appliance.get_appliance_usage() != _curr_recipe.get("cook_conditions")[_curr_order]:
		success = false

	print(success)

	# Switching to the next step if the step was successful
	if success and not ingredient.is_checked:

		# Moving the ingredient off screen and marking it checked
		ingredient.is_checked	   = true
		ingredient.global_position = Vector2(1000, 1000)
		_reset_list.append(ingredient)

		# Iterating counter
		_curr_order += 1

		# If the meal is complete then move on to the next one
		if _curr_order == _max_order:

			# Incrementing what meal the player is cooking
			_recipes_complete	   += 1
			_reset_list.clear()

			# If all the recipes are completed then finish cooking
			if _recipes_complete >= 3:
				end_cooking()

			# Checking to see what meal to cook next
			match _recipes_complete:
				1:
					_curr_recipe	 = Globals.lunch
					_meal_label.text = LUNCH_STR + _curr_recipe.get("proper_name")
				2:
					_curr_recipe	 = Globals.dinner
					_meal_label.text = DINNER_STR + _curr_recipe.get("proper_name")
				_:
					_curr_recipe	 = Globals.breakfast
					_meal_label.text = BREAKFAST_STR + _curr_recipe.get("proper_name")

			# Setting the rest of the counter values and labels accordingly
			_curr_order			 = 0
			_max_order			 = _curr_recipe.get("ingredients").size()
			_complete_label.text = MEALS_STR + "%s/3" % _recipes_complete

		# Setting the rest of the labels
		_step_label.text   = _curr_recipe.get("directions")[_curr_order]
		_result_label.text = ""

	# If it was not a success and the ingredient was not checked yet then reset the meal
	if not ingredient.is_checked:

		# Send the ingredient back to the start position
		ingredient.to_start_pos()

		# Moving all necessary ingredients to their starting positions
		for item in _reset_list:
			item.to_start_pos()

		# Setting the current ingredient count back to the beginning
		_curr_order		   = 0
		_reset_list.clear()

		# Setting the rest of the labels
		_step_label.text   = _curr_recipe.get("directions")[_curr_order]
		_result_label.text = TRY_AGAIN_STR

# Called when the cooking scene ends
func end_cooking() -> void:

	# Removing all breakfast nodes
	for item in Globals.breakfast_ing_obj:
		item.queue_free()

	# Removing all lunch nodes
	for item in Globals.lunch_ing_obj:
		item.queue_free()

	# Removing all dinner nodes
	for item in Globals.dinner_ing_obj:
		item.queue_free()

	# Emptying each list
	Globals.breakfast_ing_obj.clear()
	Globals.lunch_ing_obj.clear()
	Globals.dinner_ing_obj.clear()

	# Calculating meal completion modifier
	var completion_penalty = ((float(3) - _recipes_complete) / 3) * MAX_REDUCTION
	print(_recipes_complete)
	print(completion_penalty)

	# Applying meal completion modifier
	Globals.cur_health     = Globals.cur_health - completion_penalty
	Globals.cur_energy     = Globals.cur_energy - completion_penalty
	Globals.cur_happiness  = Globals.cur_happiness - completion_penalty

	# Instantiating end scene
	load("res://Scenes/IntermediaryScene.tscn").instantiate()

	# Changing to the end scene
	get_tree().change_scene_to_file("res://Scenes/IntermediaryScene.tscn")

func _on_timer_timeout() -> void:
	end_cooking()
