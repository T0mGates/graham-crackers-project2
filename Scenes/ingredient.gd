@tool
class_name Ingredient extends Area2D

# Ingredient fields
var _ing_name: 			String 		 		= ""
var _ing_id: 			int 			 	= 0
var _starting_pos: 		Vector2 	 		= Vector2(0, 0)
var _movement_offset: 	Vector2 			= Vector2(0, 0)

# Child objects of an ingredient
var tex: 				Sprite2D			= Sprite2D.new()
var collision: 		 	CollisionShape2D 	= CollisionShape2D.new()
var rect: 				RectangleShape2D 	= RectangleShape2D.new()

# Values to help with movement
var picked_up: 			bool				= false
var is_checked: 		bool				= false
var picked_up_name:		String				= ""
var appliance_ref							= null

# Signal to check the ingredient
signal check_ingredient(ingredient, appliance)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Setting the sprite
	tex.global_position = self.global_position
	add_child(tex)
	
	# Setting the collision shape to a rectangle shape
	rect.size 						 = tex.texture.get_size()
	collision.shape 				 = rect

	# Adding the collision shape
	#collision.debug_color			 = Color(0, 0, 0, 0.5)
	collision.global_position 		 = self.global_position
	add_child(collision)

	# Attaching signals
	self.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	self.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	self.connect("body_entered", Callable(self, "_on_body_entered"))
	self.connect("body_exited", Callable(self, "_on_body_exited"))

# Called when an input event occurs
func _input(event: InputEvent) -> void:

	# If there is a mouse event then deal with it
	if event is InputEventMouseButton:

		# If the mouse event is left mouse button then deal with it
		if event.button_index == MOUSE_BUTTON_LEFT:

			# Checking if the object is picked up or not
			if event.is_pressed() and picked_up_name != "":
				picked_up = true
			else:
				picked_up = false

			# Setting the drag offset
			_movement_offset   = get_global_mouse_position() - self.global_position

			# If the item is picked up make sure it always appears on top
			if picked_up:
				self.z_index = 100
			else:
				self.z_index = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# If the ingredient is picked up then move it by its calculated offset
	if picked_up and picked_up_name == self.name:
		self.global_position = get_global_mouse_position() - self._movement_offset
		#self.global_position = _movement_offset

	# If the ingredient is dropped on the appliance check if it is correct
	if appliance_ref != null and not picked_up:
		if appliance_ref.is_in_group("is_appliance"):
			check_ingredient.emit(self, appliance_ref)

# Getter for the ingredient name
func get_ing_name() -> String:
	return _ing_name

# Setter for ingredient name
func set_ing_name(new_name: String) -> void:
	_ing_name = new_name

# Getter for the ingredient ID
func get_ing_id() -> int:
	return _ing_id

# Setter for the ingredient ID
func set_ing_id(new_id: int) -> void:
	_ing_id = new_id

# Setter for the ingredient starting position
func set_start_pos(start: Vector2) -> void:
	_starting_pos = start

# Function that returns the ingredient to its starting position
func to_start_pos() -> void:
	self.global_position = _starting_pos
	is_checked			 = false

# Setter for the ingredient sprite
func set_sprite(sprite_image_name: String) -> void:

	# File path for texture
	var tex_path = "res://Assets/%s.png" % sprite_image_name
	print("Name: %s" % sprite_image_name)

	# If the file path exists then load it as a texture
	if ResourceLoader.exists(tex_path):
		tex.texture = load(tex_path)

	# Use the default sprite if no file path exists
	else:
		tex.texture = load("res://Assets/william_korean.png")

	# Setting the collision shape to a rectangle shape
	rect.size 		= tex.texture.get_size()
	collision.shape = rect

# This function triggers if the mouse hovers an ingredient
func _on_mouse_entered() -> void:

	# We only want to do starting pickup changes if the item is not picked up
	if not picked_up:

		# Setting the scale large to indicate hovering
		picked_up_name = self.name
		self.scale	   = self.scale + Vector2(0.03, 0.03)

# This function triggers if the mouse stops hovering an ingredient
func _on_mouse_exited() -> void:

	# If we haven't dropped the item yet then amend this
	if picked_up:
		self.global_position = get_global_mouse_position() - self._movement_offset

	# We only want to do the dropped item operations if we have actually dropped it
	else:

		# Setting the scale smaller to indicate no longer hovering
		picked_up_name = ""
		self.scale     = self.scale - Vector2(0.03, 0.03)

# This function triggers if an ingredient touches an appliance
func _on_body_entered(body: Node2D) -> void:

	# If the body is an appliance then change its colour
	if body.is_in_group("is_appliance"):
		body.modulate = Color(0.0, 1.0, 0.0, 0.5)
		appliance_ref = body

# This function triggers if an ingredient exits an appliance
func _on_body_exited(body: Node2D) -> void:

	# If the body is an appliance then revert its colour
	if body.is_in_group("is_appliance"):
		body.modulate = Color(1.0, 1.0, 1.0, 1.0)
		appliance_ref = null
