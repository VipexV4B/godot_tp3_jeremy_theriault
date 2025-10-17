extends Node2D 
@onready var intro = $AudioStreamPlayer 

func _ready():
	intro.play(1.5)
