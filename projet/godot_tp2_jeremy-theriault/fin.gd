extends Control

@onready var congrats = $AudioStreamPlayer
func _ready():
	congrats.play()
