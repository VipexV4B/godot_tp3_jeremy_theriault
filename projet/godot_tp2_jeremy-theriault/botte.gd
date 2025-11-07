extends Area2D

@export var nouveau_jump = -500.0
@onready var power_up = $AudioStreamPlayer

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		if "jump_force" in body:
			body.jump_force = nouveau_jump
		# Supprime l'objet immédiatement
		queue_free()
