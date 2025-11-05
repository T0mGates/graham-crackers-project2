extends Node2D

@onready var scenario_text: Label = $MainUI/ScenarioText
@onready var day_text: Label = $MainUI/DayText
@onready var final_text: Label = $MainUI/FinalLabel


@onready var health_bar = $MainUI/Resources/Health/ProgressBar
@onready var energy_bar = $MainUI/Resources/Energy/ProgressBar
@onready var happiness_bar = $MainUI/Resources/Happiness/ProgressBar
@onready var money_label = $MainUI/Resources/Money/Label

@onready var breakfast_node: Node2D = $MainUI/RecipeOptions/Breakfast
@onready var lunch_node: Node2D = $MainUI/RecipeOptions/Lunch
@onready var dinner_node: Node2D = $MainUI/RecipeOptions/Dinner

@onready var recipe_options = $MainUI/RecipeOptions

@onready var ready_to_cook: Node2D = $MainUI/ReadyToCook

# Recipe options to spawn
@onready var recipe_btn_scene = preload("res://Scenes/recipe_button.tscn")

const RECIPE_BOOK_PATH: String = "res://Scenes/recipes.json"
const DAY_DATA_PATH: String = "res://Scenes/days.json"

# Resources
var max_health = 100

var max_energy = 100

var max_happiness = 100

# Array of instantiated scenes for each type of food
var breakfast_options = []
var lunch_options = []
var dinner_options = []

# End of day, these will be added to resources
var eod_health_diff = 0
var eod_energy_diff = 0
var eod_happiness_diff = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_new_day()
	update_ui()

# Returns bool indicating if the player has lost
func end_day():
	# Get rid of old objects
	for obj in breakfast_options:
		obj.queue_free()
		
	for obj in lunch_options:
		obj.queue_free()
		
	for obj in dinner_options:
		obj.queue_free()
	
	add_to_health(eod_health_diff)
	add_to_energy(eod_energy_diff)
	add_to_happiness(eod_happiness_diff)
	
	update_ui()
	
func end_game(win: bool, end_name: String, info: String):
	print("You won: %s" % [str(win)])
	day_text.text = "You got the '" + end_name + "' ending"
	scenario_text.text = ""
	final_text.text = info
	ready_to_cook.visible = false
	recipe_options.visible = false
	update_ui()

func update_ui():
	health_bar.value = Globals.cur_health
	energy_bar.value = Globals.cur_energy
	happiness_bar.value = Globals.cur_happiness
	money_label.text = "Money: " + str(Globals.money)
	
func setup_new_day():
	print("IN READY")
	Globals.cur_day += 1
	var day_data = Globals.get_json_from_file(DAY_DATA_PATH).get(str(Globals.cur_day), {})
	
	# First check if we lost
	if check_if_game_over():
		return
	
	# Get data for today, using Globals.cur_day
	# If it doesn't exist, means we've finished the game!
	if {} == day_data:
		# Done! Now we pick an ending!
		var ending_name = ""
		var ending_desc = ""
		if 170 <= Globals.cur_health + Globals.cur_energy + Globals.cur_happiness:
			ending_name = "Master Chef"
			ending_desc = "Victory! That's what happens when a culinary savant like yourself rises to the challenge and chefs their way through everything life has to throw at them. Nothing will ever stop this meal prep pro!"
		elif 0 <= Globals.cur_happiness and Globals.cur_happiness <= 15:
			ending_name = "Barely hanging on"
			ending_desc = "You did it! You got through one of the hardest weeks of your life, but only JUST. Remember that your mental health takes precedence before all else, you should still be proud though."
		elif 100 <= Globals.cur_health + Globals.cur_energy + Globals.cur_happiness and 8 <= Globals.money:
			ending_name = "Master Budgeter"
			ending_desc = "The results? Satisfactory. Your wallet? Overflowing! Hey you know if you put away all of the money you saved into an index fund you could have almost $33 when you retire? Hey wait, where are you going! No, come back! I-"
		elif 120 <= Globals.cur_health + Globals.cur_energy + Globals.cur_happiness:
			ending_name = "Short Order Cook"
			ending_desc = "A burger for every battle! You've proven that a seasoned chef, when put under fire, will always cut the mustard. Here's to many meals and succulent successes in your future."
		else:
			ending_name = "Grease in the pan"
			ending_desc = "There were more than a few close calls, but survival really is all that ever truly matters. Keep your needs in mind, make time for yourself, and you can do anything!"
		end_game(true, ending_name, ending_desc)
		return
	
	print(day_data)
		
	_start_new_day(day_data["breakfast_options"],
					day_data["lunch_options"],
					day_data["dinner_options"],
					day_data["scenario_description"],
					day_data["eod_health_diff"],
					day_data["eod_energy_diff"],
					day_data["eod_happiness_diff"]
				)

func check_if_game_over():
	# Look for lose conditions
	# For now just print, but we maybe want a game over screen?
	var money_loss = Globals.money < 0
	var health_loss = Globals.cur_health <= 0
	var energy_loss = Globals.cur_energy <= 0
	var happiness_loss = Globals.cur_happiness <= 0
	var overall_loss = money_loss or health_loss or energy_loss or happiness_loss
	
	# LOST
	if overall_loss:
		print("Values of loss")
		print(health_loss)
		print(energy_loss)
		print(happiness_loss)
		if health_loss and energy_loss and happiness_loss:
			end_game(false, "Holistic Failure", "Wow, where to start? A total loss on every front implies the need for some serious remedial food education. Start at cereal, and come back once you've reached toasted sandwich.")
			return true
		elif money_loss:
			end_game(false, "Indebted", "On top of your student debt, now you have lunch debt. An issue experienced by tardy bar patrons, American school children, and now you!")
			return true
		elif health_loss:
			end_game(false, "Whispy Husk", "No no no you cant just eat whatever you want! A balanced diet of fruits, vegetables, grains, dairy, and proteins are required for healthy living. To learn more please go to www.williamdual.itch.io/gardenians.")
			return true
		elif energy_loss:
			end_game(false, "Eepy", "While I commend you for not relying on energy drinks or coffee, I will say that you should probably put some more pep in your step.")
			return true
		elif happiness_loss:
			end_game(false, "Big Sad", "Eating happy is almost as important as eating healthy! Have a burger or something every once in a while")
			return true
			
	return false

# Up to three options for each of breakfast, lunch and dinner
func _start_new_day(breakfast_options_param: Array,
						lunch_options_param: Array,
						dinner_options_param: Array,
						scenario_description: String,
						eod_health_diff_param: int,
						eod_energy_diff_param: int,
						eod_happiness_diff_param: int
					):
						ready_to_cook.visible = false
						
						breakfast_options = []
						lunch_options = []
						dinner_options = []
						
						# BREAKFAST
						var pos_to_set = breakfast_node.position
						var num_loops = 0
						Globals.curr_meal = "Breakfast"
						
						for breakfast_option in breakfast_options_param:
							var recipe_option_btn = recipe_btn_scene.instantiate()
							add_child(recipe_option_btn)
							recipe_option_btn.get_btn_node().toggled.connect(on_recipe_btn_pressed.bind("breakfast:" + str(num_loops)))
							
							breakfast_options.append(recipe_option_btn)
							
							if breakfast_option == "skip":
								recipe_option_btn.position = pos_to_set + Vector2(150 * 2.1, -35)
								recipe_option_btn.scale = recipe_option_btn.scale * 0.8
							else:
								recipe_option_btn.position = pos_to_set + Vector2(150 * num_loops, 50)
							
							recipe_option_btn.setup(breakfast_option, false)
							
							num_loops += 1
							
						# LUNCH
						pos_to_set = lunch_node.position
						num_loops = 0
						Globals.curr_meal = "Lunch"
						
						for lunch_option in lunch_options_param:
							var recipe_option_btn = recipe_btn_scene.instantiate()
							add_child(recipe_option_btn)
							recipe_option_btn.get_btn_node().toggled.connect(on_recipe_btn_pressed.bind("lunch:" + str(num_loops)))
							
							lunch_options.append(recipe_option_btn)
							
							if lunch_option == "skip":
								recipe_option_btn.position = pos_to_set + Vector2(150 * 2.1, -35)
								recipe_option_btn.scale = recipe_option_btn.scale * 0.8
							else:
								recipe_option_btn.position = pos_to_set + Vector2(150 * num_loops, 50)
							
							recipe_option_btn.setup(lunch_option, false)
							
							num_loops += 1
							
						# DINNER
						pos_to_set = dinner_node.position
						num_loops = 0
						Globals.curr_meal = "Dinner"
						
						for dinner_option in dinner_options_param:
							var recipe_option_btn = recipe_btn_scene.instantiate()
							add_child(recipe_option_btn)
							recipe_option_btn.get_btn_node().toggled.connect(on_recipe_btn_pressed.bind("dinner:" + str(num_loops)))
							
							dinner_options.append(recipe_option_btn)
							
							if dinner_option == "skip":
								recipe_option_btn.position = pos_to_set + Vector2(150 * 2.1, -35)
								recipe_option_btn.scale = recipe_option_btn.scale * 0.8
							else:
								recipe_option_btn.position = pos_to_set + Vector2(150 * num_loops, 50)
							
							recipe_option_btn.setup(dinner_option, true)
							
							num_loops += 1
						
						day_text.text = "Day " + str(Globals.cur_day)
						scenario_text.text = scenario_description
						
						eod_health_diff = eod_health_diff_param
						eod_energy_diff = eod_energy_diff_param
						eod_happiness_diff = eod_happiness_diff_param
	
func on_recipe_btn_pressed(pressed_state: bool, btn_id: String):
	print("%s toggled: %s" % [btn_id, pressed_state])
	var recipe_book = Globals.get_json_from_file(RECIPE_BOOK_PATH)
	
	var old_breakfast = null
	var old_lunch = null
	var old_dinner = null
	
	# If it was set to true, make sure all others are false
	if pressed_state:
		# Look if it is a breakfast, lunch or dinner
		var recipe_type = btn_id.split(":")[0]
		var idx = int(btn_id.split(":")[1])
		
		if "breakfast" in recipe_type:
			for i in range(len(breakfast_options)):
				if idx != i:
					if breakfast_options[i].get_btn_node().button_pressed:
						breakfast_options[i].get_btn_node().button_pressed = false
						old_breakfast = breakfast_options[i]
						break
					
		elif "lunch" in recipe_type:
			for i in range(len(lunch_options)):
				if idx != i:
					if lunch_options[i].get_btn_node().button_pressed:
						lunch_options[i].get_btn_node().button_pressed = false
						old_lunch = lunch_options[i]
						break
					
		elif "dinner" in recipe_type:
			for i in range(len(dinner_options)):
				if idx != i:
					if dinner_options[i].get_btn_node().button_pressed:
						dinner_options[i].get_btn_node().button_pressed = false
						old_dinner = dinner_options[i]
						break
					
		# If it was set to true, then look to see if we have chosen all of breakfast, lunch and dinner
		# If we have, then we can enable the "go cooking" button, else we disable it
		var chosen_breakfast = get_chosen_breakfast_name()
		var chosen_lunch = get_chosen_lunch_name()
		var chosen_dinner = get_chosen_dinner_name()
		
		# Update resource for clicked type
		if "breakfast" in recipe_type:
			_update_resources_after_selection(recipe_book.get(old_breakfast) if null != old_breakfast else null, recipe_book.get(chosen_breakfast) if chosen_breakfast else null)
			
		elif "lunch" in recipe_type:
			_update_resources_after_selection(recipe_book.get(old_lunch) if null != old_lunch else null, recipe_book.get(chosen_lunch) if chosen_lunch else null)
			
		elif "dinner" in recipe_type:
			_update_resources_after_selection(recipe_book.get(old_dinner) if null != old_dinner else null, recipe_book.get(chosen_dinner) if chosen_dinner else null)
		
		ready_to_cook.get_node("TextureButton").set_meals(chosen_breakfast, chosen_lunch, chosen_dinner)
		ready_to_cook.visible = chosen_breakfast and chosen_lunch and chosen_dinner
	
	else:
		# In this case, need to give back the resources it was using
		var recipe_type = btn_id.split(":")[0]
		var idx = int(btn_id.split(":")[1])
		var old_recipe = null
		
		if "breakfast" in recipe_type:
			old_recipe = breakfast_options[idx]
					
		elif "lunch" in recipe_type:
			old_recipe = lunch_options[idx]
					
		elif "dinner" in recipe_type:
			old_recipe = dinner_options[idx]
			
		_update_resources_after_selection(recipe_book.get(old_recipe.get_recipe_name()) if old_recipe != null else null, null)
		ready_to_cook.visible = false
		
func _update_resources_after_selection(unselected_recipe, selected_recipe):
	var recipe_book = Globals.get_json_from_file(RECIPE_BOOK_PATH)
	
	print("Updating resources. Unselected: %s, Selected: %s" % [unselected_recipe["proper_name"] if null != unselected_recipe else "N/A", selected_recipe["proper_name"] if null != selected_recipe else "N/A"])
	
	Globals.cur_health -= unselected_recipe["health_diff"] if null != unselected_recipe else 0
	Globals.cur_energy -= unselected_recipe["energy_diff"] if null != unselected_recipe else 0
	Globals.cur_happiness -= unselected_recipe["happiness_diff"] if null != unselected_recipe else 0
	Globals.money += unselected_recipe["cost"] if null != unselected_recipe else 0
	
	Globals.cur_health += selected_recipe["health_diff"] if null != selected_recipe else 0
	Globals.cur_energy += selected_recipe["energy_diff"] if null != selected_recipe else 0
	Globals.cur_happiness += selected_recipe["happiness_diff"] if null != selected_recipe else 0
	Globals.money -= selected_recipe["cost"] if null != selected_recipe else 0
	
	update_ui()
		
func get_chosen_breakfast_name() -> String:
	var chosen_breakfast = ""
	
	for option in breakfast_options:
		if option.get_btn_node().button_pressed:
			chosen_breakfast = option.get_recipe_name()
			break
	
	return chosen_breakfast
	
func get_chosen_lunch_name() -> String:
	var chosen_lunch = ""
	
	for option in lunch_options:
		if option.get_btn_node().button_pressed:
			chosen_lunch = option.get_recipe_name()
			break
	
	return chosen_lunch
	
func get_chosen_dinner_name() -> String:
	var chosen_dinner = ""
	
	for option in dinner_options:
		if option.get_btn_node().button_pressed:
			chosen_dinner = option.get_recipe_name()
			break
	
	return chosen_dinner

func add_to_health(diff: int):
	print("In add_to_health with cur_health: %d and diff: %d" % [Globals.cur_health, diff])
	
	# Keep cur_health between 0 and max val
	Globals.cur_health = clamp(Globals.cur_health + diff, 0, max_health)
	update_ui()
	
func add_to_energy(diff: int):
	print("In add_to_energy with cur_energy: %d and diff: %d" % [Globals.cur_energy, diff])
	
	# Keep cur_energy between 0 and max val
	Globals.cur_energy = clamp(Globals.cur_energy + diff, 0, max_energy)
	update_ui()
	
func add_to_happiness(diff: int):
	print("In add_to_happiness with cur_happiness: %d and diff: %d" % [Globals.cur_happiness, diff])
	
	# Keep cur_happiness between 0 and max val
	Globals.cur_happiness = clamp(Globals.cur_happiness + diff, 0, max_happiness)
	update_ui()

func add_to_money(diff: int):
	print("In add_to_money with money: %d and diff: %d" % [Globals.money, diff])
	
	# Keep money above -1
	Globals.money += diff
	update_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
