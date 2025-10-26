extends Node2D

@onready var day_text: Label 		= $DayText
@onready var label: Label 		= $Label

const END_SCENE_PATH: String = "res://Scenes/EndScene.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_text()

func _setup_text():
	day_text.text = "Day " + str(Globals.cur_day) + " Results"
	
	var delta_money = Globals.prev_money - Globals.money
	var delta_health = Globals.prev_health - Globals.cur_health
	var delta_energy = Globals.prev_energy - Globals.cur_energy
	var delta_happiness = Globals.prev_happiness - Globals.cur_happiness
	
	print("previous money: " + str(Globals.prev_money))
	print("current money: " + str(Globals.money))
	print("delta money: " + str(delta_money))
	
	if (delta_money >= 30):
		label.text = label.text + "You spent a lot of money today!\n"
	if (delta_health <= 10):
		label.text = label.text + "You gained a lot of health today!\n"
	if (delta_energy <= 10):
		label.text = label.text + "You gained a lot of energy today!\n"
	if (delta_happiness <= 10):
		label.text = label.text + "You gained a lot of happiness today!\n"
	if (Globals.cur_day == 1):
		if (Globals.cur_health <= 50):
			label.text = label.text + "That swim was a lot more tiring than you thought and you felt sick afterwards\n"
	if (Globals.cur_day == 2): 
		if (Globals.cur_energy <= 50):
			label.text = label.text + "During your fight against Old Orc Oliver you found it harder and harder to keep up, you didn't have enough energy and were getting tired,\nand one slow step later, you took a massive hit to the chest from his club, and your chestplate was shattered.\nThankfully, you made it out of the fight alive, but now you'll need to get new gear when you leave the dungeon.\n"
	if (Globals.cur_day == 3):
		if (Globals.cur_health <= 50 || Globals.cur_energy <= 50):
			label.text = label.text + "The lord of profound suffering was indeed suffering, with low health and energy you found it difficult to fight like you usually do,\nand the fight ended up being a lot harder than it should have been for a skilled adventurer like you"
		
	#setup prev values for next day
	Globals.prev_money = Globals.money
	Globals.prev_health = Globals.cur_health
	Globals.prev_energy = Globals.cur_energy
	Globals.prev_happiness = Globals.cur_happiness

func _on_pressed():
	var end_scene = load(END_SCENE_PATH).instantiate()
	# Changing to the food prep scene
	get_tree().change_scene_to_file(END_SCENE_PATH)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
