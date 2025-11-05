extends Node2D

@onready var select_btn: Button 		= $SelectButton
@onready var recipe_label: Label 		= $SelectButton/RecipeName
@onready var recipe_img: Sprite2D 		= $SelectButton/RecipeImg
@onready var info_text: Node2D 			= $InfoText


const RECIPE_BOOK_PATH: String 			= "res://Scenes/recipes.json"

var recipe_name: String = ""

var money_diff: int 	= 0
var health_diff: int 	= 0
var energy_diff: int 	= 0
var happiness_diff: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	recipe_name = "salad"
	setup(recipe_name)

func get_recipe_name()-> String:
	return recipe_name

# Call with top == true for it to appear on top, else will appear on bottom
func setup(recipe_name_param: String, top: bool = false):
	recipe_name 		= recipe_name_param
	var recipe_book   	= Globals.get_json_from_file(RECIPE_BOOK_PATH)
	var recipe_data  	= recipe_book.get(recipe_name_param)

	if recipe_name_param == "skip":
		recipe_label.text = "Skip %s" % Globals.curr_meal
	else:
		recipe_label.text = recipe_data["proper_name"]
	
	money_diff 			= recipe_data["cost"]
	health_diff 		= recipe_data["health_diff"]
	energy_diff 		= recipe_data["energy_diff"]
	happiness_diff 		= recipe_data["happiness_diff"]
	var num_steps 		= len(recipe_data["directions"])
	var summary_text	= recipe_data["summary_text"]
	
	var recipe_img_texture = load(recipe_data["path_to_img"])
	if recipe_img_texture:
		recipe_img.texture = recipe_img_texture  
	
	select_btn.set_info_text(money_diff, health_diff, energy_diff, happiness_diff, num_steps, summary_text)
	select_btn.set_hover_pos(top)

func get_btn_node()-> CheckButton:
	return select_btn
	
func get_info_text_node()-> Node2D:
	return info_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
