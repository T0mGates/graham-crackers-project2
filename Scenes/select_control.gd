extends Control

@onready var info_text: Node2D = $"../InfoText"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	info_text.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_info_text(money_diff: int, health_diff: int, energy_diff: int, happiness_diff: int):
	info_text.get_child(0).text = "Money: " + str(money_diff) + "\nHealth: " + str(health_diff) + "\nEnergy: " + str(energy_diff) + "\nHappiness: " + str(happiness_diff)


func _on_mouse_entered() -> void:
	info_text.visible = true


func _on_mouse_exited() -> void:
	info_text.visible = false
