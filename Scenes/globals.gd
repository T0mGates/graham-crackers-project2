extends Node

# FOR COOKING SCENE

# The ingredients, cooking steps, and success conditions for each meal
var breakfast 		   = {"ingredients":[], "directions":[], "cook_conditions":[]}
var lunch 	  		   = {"ingredients":[], "directions":[], "cook_conditions":[]}
var dinner 	  		   = {"ingredients":[], "directions":[], "cook_conditions":[]}

# The ingredient objects for each meal
var breakfast_ing_obj  = []
var lunch_ing_obj 	   = []
var dinner_ing_obj 	   = []

# Values to help with movement
var picked_up: bool		   	   = false
var is_at_appliance: bool	   = false
var appliance_ref			   = null

# Timer value
var timer_time: float		   = 60.0

# Multiplier value
var stat_multiplier: float	   = 1.0



# FOR RECIPE SELECT SCREEN

var cur_day: int				= 0
var money: int 					= 75
var cur_health: int 			= 70
var cur_energy: int				= 70
var cur_happiness: int 			= 70


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Called to retrieve JSON object from file
func get_json_from_file(path: String) -> Dictionary:
	
	# The variable that will hold the json
	var json_obj: Dictionary = {}
	
	# Checking to see if the desired file exists
	if not FileAccess.file_exists(path):
		print("ERROR: No file found to retrieve JSON from")
		return json_obj

	# Getting the JSON object from the file
	var retrieved_json = JSON.parse_string(FileAccess.get_file_as_string(path))

	# If the type is successfully a dictionary then assign it to the return object
	if typeof(retrieved_json) == TYPE_DICTIONARY:
		json_obj = retrieved_json
	else:
		print("WARNING: JSON file content not a dictionary, type '", typeof(retrieved_json), "' found instead")
		
	return json_obj

# Called to clear the ingredients nodes and json objects
func clear_ingredients() -> void:

	# The ingredients, cooking steps, and success conditions for each meal
	breakfast 		   = {"ingredients":[], "directions":[], "cook_conditions":[]}
	lunch 	  		   = {"ingredients":[], "directions":[], "cook_conditions":[]}
	dinner 	  		   = {"ingredients":[], "directions":[], "cook_conditions":[]}

	# The ingredient objects for each meal
	breakfast_ing_obj  = []
	lunch_ing_obj 	   = []
	dinner_ing_obj 	   = []
