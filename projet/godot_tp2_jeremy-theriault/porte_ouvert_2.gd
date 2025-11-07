extends Area2D

@export var next_level_path := "res://fin.tscn" # chemin vers ton niveau 2

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Chargement du niveau suivant...")
		await get_tree().create_timer(0.3).timeout
		get_tree().change_scene_to_file(next_level_path)
