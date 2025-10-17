extends Area2D

@export var nouvelle_vitesse = 300.0
@export var nouvelle_vitesse_course = 500.0
@onready var power_up = $AudioStreamPlayer

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		if "speed" in body and "speed_run" in body:
			body.speed = nouvelle_vitesse
			body.speed_run = nouvelle_vitesse_course

		# Joue le son à partir de 3 secondes, mais le détache d'abord
		var sound = power_up.duplicate()
		get_parent().add_child(sound)
		sound.play()
		sound.seek(3.5)

		# Le son se supprimera automatiquement quand il aura fini
		sound.finished.connect(func(): sound.queue_free())

		# Supprime l'objet immédiatement
		queue_free()
