extends Node2D

@onready var scenario_text: Label 	= $MainUI/ScenarioText
@onready var day_text: Label 		= $MainUI/DayText


@onready var health_bar 	= $MainUI/Resources/Health/ProgressBar
@onready var energy_bar 	= $MainUI/Resources/Energy/ProgressBar
@onready var happiness_bar 	= $MainUI/Resources/Happiness/ProgressBar
@onready var money_label 	= $MainUI/Resources/Money/Label

@onready var breakfast_node: Node2D 	= $MainUI/RecipeOptions/Breakfast
@onready var lunch_node: Node2D 		= $MainUI/RecipeOptions/Lunch
@onready var dinner_node: Node2D 		= $MainUI/RecipeOptions/Dinner

@onready var ready_to_cook: Node2D 		= $MainUI/ReadyToCook

# Recipe options to spawn
@onready var recipe_btn_scene 		= preload("res://Scenes/recipe_button.tscn")

const RECIPE_BOOK_PATH: String 			= "res://Scenes/recipes.json"

# Resources
var max_health 		= 100
var cur_health 		= 100

var max_energy 		= 100
var cur_energy 		= 100

var max_happiness 	= 100
var cur_happiness 	= 100


var money 			= 1000

var cur_day			= 0

# Array of instantiated scenes for each type of food
var breakfast_options = []
var lunch_options     = []
var dinner_options    = []

# End of day, these will be added to resources
var eod_health_diff	   = 0
var eod_energy_diff    = 0
var eod_happiness_diff = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cur_day 			= 0
	
	setup_new_day(
		["bacon_eggs_toast", "salad", "canned_soup"],
		["bacon_eggs_toast", "salad", "canned_soup"],
		["bacon_eggs_toast", "salad", "canned_soup"],
		"This is a CRAZY day! Good luck!",
		-10,
		-15,
		-20
	)
	
	update_ui()

func end_day():
	# Get rid of old objects
	for obj in breakfast_options:
		obj.queue_free()
		
	for obj in lunch_options:
		obj.queue_free()
		
	for obj in dinner_options:
		obj.queue_free()
		
	var recipe_book   	= Globals.get_json_from_file(RECIPE_BOOK_PATH)
	
	var breakfast_data  = recipe_book.get(get_chosen_breakfast_name())
	var lunch_data 		= recipe_book.get(get_chosen_lunch_name())
	var dinner_data 	= recipe_book.get(get_chosen_dinner_name())
	
	add_to_health(eod_health_diff + breakfast_data["health_diff"] + lunch_data["health_diff"] + dinner_data["health_diff"])
	add_to_energy(eod_energy_diff + breakfast_data["energy_diff"] + lunch_data["energy_diff"] + dinner_data["energy_diff"])
	add_to_happiness(eod_happiness_diff + breakfast_data["happiness_diff"] + lunch_data["happiness_diff"] + dinner_data["happiness_diff"])
	add_to_money(-1 * (breakfast_data["cost"] + lunch_data["cost"] + dinner_data["cost"]))
	
	update_ui()
	
	# Look for lose conditions
	# For now just print, but we maybe want a game over screen?
	var money_loss 		= money <= 0
	var health_loss 	= cur_health <= 0
	var energy_loss 	= cur_energy <= 0
	var happiness_loss 	= cur_happiness <= 0
	var overall_loss	= money_loss or health_loss or energy_loss or happiness_loss
	
	# LOST
	if overall_loss:
		if money_loss:
			end_game(false, "YOU LOST cus of money")
		
		if health_loss:
			end_game(false, "YOU LOST cus of health")
		
		if energy_loss:
			end_game(false, "YOU LOST cus of energy")
			
		if happiness_loss:
			end_game(false, "YOU LOST cus of happiness")
	
	# If it was day 3 and we haven't lost, you win!
	elif 3 == cur_day:
		end_game(true, "YOU WIN!")
	
	# Else, keep going!
	else:
		setup_new_day(
		["bacon_eggs_toast", "salad", "canned_soup"],
		["bacon_eggs_toast", "salad", "canned_soup"],
		["bacon_eggs_toast", "salad", "canned_soup"],
		"This is another CRAZY day! Good luck!",
		-10,
		-15,
		-20
	)
	
	update_ui()
	
func end_game(win: bool, info: String):
	print("You won: %s" % [str(win)])
	day_text.text 			= info
	scenario_text.text 		= ""
	ready_to_cook.visible 	= false

func update_ui():
	health_bar.value 	= cur_health
	energy_bar.value 	= cur_energy
	happiness_bar.value = cur_happiness
	money_label.text   	= "Money: " + str(money)
	
# Up to three options for each of breakfast, lunch and dinner
func setup_new_day( breakfast_options_param: Array, 
					lunch_options_param: Array, 
					dinner_options_param: Array, 
					scenario_description: String, 
					eod_health_diff_param: int, 
					eod_energy_diff_param: int, 
					eod_happiness_diff_param: int
					):
						ready_to_cook.visible 	= false
						
						breakfast_options   	= []
						lunch_options       	= []
						dinner_options      	= []
						cur_day 				+= 1
						
						# BREAKFAST
						var pos_to_set				= breakfast_node.position
						var num_loops				= 0
						
						for breakfast_option in breakfast_options_param:
							var recipe_option_btn 		= recipe_btn_scene.instantiate()
							add_child(recipe_option_btn)
							recipe_option_btn.get_btn_node().toggled.connect(on_recipe_btn_pressed.bind("breakfast:" + str(num_loops)))
							
							breakfast_options.append(recipe_option_btn)
							
							recipe_option_btn.position 	= pos_to_set + Vector2(150 * num_loops, 50)
							
							recipe_option_btn.setup(breakfast_option)
							
							num_loops 					+= 1
							
						# LUNCH
						pos_to_set				= lunch_node.position
						num_loops				= 0
						
						for lunch_option in lunch_options_param:
							var recipe_option_btn 		= recipe_btn_scene.instantiate()
							add_child(recipe_option_btn)
							recipe_option_btn.get_btn_node().toggled.connect(on_recipe_btn_pressed.bind("lunch:" + str(num_loops)))
							
							lunch_options.append(recipe_option_btn)
							
							recipe_option_btn.position 	= pos_to_set + Vector2(150 * num_loops, 50)
							
							recipe_option_btn.setup(lunch_option)
							
							num_loops 					+= 1
							
						# DINNER
						pos_to_set				= dinner_node.position
						num_loops				= 0
						
						for dinner_option in dinner_options_param:
							var recipe_option_btn 		= recipe_btn_scene.instantiate()
							add_child(recipe_option_btn)
							recipe_option_btn.get_btn_node().toggled.connect(on_recipe_btn_pressed.bind("dinner:" + str(num_loops)))
							
							dinner_options.append(recipe_option_btn)
							
							recipe_option_btn.position 	= pos_to_set + Vector2(150 * num_loops, 50)
							
							recipe_option_btn.setup(dinner_option)
							
							num_loops 					+= 1
						
						day_text.text 		= "Day " + str(cur_day)
						scenario_text.text 	= scenario_description
						
						eod_health_diff 	= eod_health_diff_param
						eod_energy_diff 	= eod_energy_diff_param
						eod_happiness_diff 	= eod_happiness_diff_param
	
func on_recipe_btn_pressed(pressed_state: bool, btn_id: String):
	print("%s toggled: %s" % [btn_id, pressed_state])
	
	# If it was set to true, make sure all others are false
	if pressed_state:
		# Look if it is a breakfast, lunch or dinner
		var recipe_type = btn_id.split(":")[0]
		var idx 		= int(btn_id.split(":")[1])
		
		if "breakfast" in recipe_type:
			for i in range(len(breakfast_options)):
				if idx != i:
					breakfast_options[i].get_btn_node().button_pressed = false
					
		elif "lunch" in recipe_type:
			for i in range(len(lunch_options)):
				if idx != i:
					lunch_options[i].get_btn_node().button_pressed = false
					
		elif "dinner" in recipe_type:
			for i in range(len(dinner_options)):
				if idx != i:
					dinner_options[i].get_btn_node().button_pressed = false
					
		# If it was set to true, then look to see if we have chosen all of breakfast, lunch and dinner
		# If we have, then we can enable the "go cooking" button, else we disable it
		var chosen_breakfast 	= get_chosen_breakfast_name()
		var chosen_lunch 		= get_chosen_lunch_name()
		var chosen_dinner 		= get_chosen_dinner_name()
		
		ready_to_cook.get_node("TextureButton").set_meals(chosen_breakfast, chosen_lunch, chosen_dinner)
		ready_to_cook.visible = chosen_breakfast and chosen_lunch and chosen_dinner
	
	else:
		ready_to_cook.visible = false
		
func get_chosen_breakfast_name() -> String:
	var chosen_breakfast 	= ""
	
	for option in breakfast_options:
		if option.get_btn_node().button_pressed:
			chosen_breakfast = option.get_recipe_name()
			break
	
	return chosen_breakfast
	
func get_chosen_lunch_name() -> String:
	var chosen_lunch 	= ""
	
	for option in lunch_options:
		if option.get_btn_node().button_pressed:
			chosen_lunch = option.get_recipe_name()
			break
	
	return chosen_lunch
	
func get_chosen_dinner_name() -> String:
	var chosen_dinner 	= ""
	
	for option in dinner_options:
		if option.get_btn_node().button_pressed:
			chosen_dinner = option.get_recipe_name()
			break
	
	return chosen_dinner

func add_to_health(diff: int):
	print("In add_to_health with cur_health: %d and diff: %d" % [cur_health, diff])
	
	# Keep cur_health between 0 and max val
	cur_health = clamp(cur_health + diff, 0, max_health)
	update_ui()
	
func add_to_energy(diff: int):
	print("In add_to_energy with cur_energy: %d and diff: %d" % [cur_energy, diff])
	
	# Keep cur_energy between 0 and max val
	cur_energy = clamp(cur_energy + diff, 0, max_energy)
	update_ui()
	
func add_to_happiness(diff: int):
	print("In add_to_happiness with cur_happiness: %d and diff: %d" % [cur_happiness, diff])
	
	# Keep cur_happiness between 0 and max val
	cur_happiness = clamp(cur_happiness + diff, 0, max_happiness)
	update_ui()

func add_to_money(diff: int):
	print("In add_to_money with money: %d and diff: %d" % [money, diff])
	
	# Keep money above -1
	money = max(money + diff, 0)
	update_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
