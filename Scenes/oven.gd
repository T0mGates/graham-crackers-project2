extends StaticBody2D

# Child objects
var _collision: 		CollisionShape2D	= CollisionShape2D.new()
var _appliance_sprite: 	Sprite2D			= Sprite2D.new()

# Appliance values
var _app_usage: String = "OVENED"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Assigning children to variables
	var children = get_children()
	for item in children:
		
		# Assigning collision box
		if item is CollisionShape2D:
			_collision = item

		# Assigning sprite
		if item is Sprite2D:
			_appliance_sprite = item

	# Setting the collision shape
	_collision.debug_color		= Color(0, 0, 0, 0.5)
	_collision.global_position 	= self.global_position
	_collision.shape.size 		= _appliance_sprite.texture.get_size()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Getter for the appliance usage
func get_appliance_usage() -> String:
	return _app_usage
