@tool
class_name Appliance extends StaticBody2D

# Children of the appliance
var appliance_sprite: 	Sprite2D			= Sprite2D.new()
var collision: 			CollisionShape2D	= CollisionShape2D.new()
var rect: 				RectangleShape2D	= RectangleShape2D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Setting the global position
	self.global_position = Vector2(50, 50)

	# Adding the sprite
	appliance_sprite.texture  		 = preload("res://icon.svg") # Replace with your texture path
	appliance_sprite.global_position = self.global_position
	add_child(appliance_sprite)

	# Setting the collision shape to a rectangle shape
	rect.size 						 = appliance_sprite.texture.get_size()
	collision.shape 				 = rect

	# Adding the collision shape
	collision.debug_color			 = Color(0, 0, 0, 0.5)
	collision.global_position 		 = self.global_position
	add_child(collision)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
