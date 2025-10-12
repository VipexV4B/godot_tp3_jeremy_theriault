extends Area2D

@export var nouvelle_vitesse = 300.0
@export var nouvelle_vitesse_course = 500.0

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Vérifie si "speed" existe dans le script du joueur
		if "speed" in body:
			body.speed = nouvelle_vitesse
			body.speed_run = nouvelle_vitesse_course
		queue_free()
