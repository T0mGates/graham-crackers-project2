extends Control

@onready var info_text: Node2D = $"../InfoText"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	info_text.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_info_text(money_diff: int, health_diff: int, energy_diff: int, happiness_diff: int):
	info_text.get_node("Label").text = "Money: " + str(money_diff) + "\nHealth: " + str(health_diff) + "\nEnergy: " + str(energy_diff) + "\nHappiness: " + str(happiness_diff)

# Used for hover text to appear on top instead of under a recipe
# Call with top == true for it to appear on top, else will appear on bottom
func set_hover_pos(top: bool = false):
	info_text.position = Vector2(info_text.position.x, info_text.position.y - 160 if top else info_text.position.y)

func _on_mouse_entered() -> void:
	info_text.visible = true


func _on_mouse_exited() -> void:
	info_text.visible = false
