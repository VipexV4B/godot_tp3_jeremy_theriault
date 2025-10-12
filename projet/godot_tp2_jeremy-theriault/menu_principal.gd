extends Control

func _ready():
	$Button.pressed.connect(_on_jouer_pressed)

func _on_jouer_pressed():
	var jeu = load("res://jeux.tscn")
	get_tree().change_scene_to_packed(jeu)
