extends Area2D

@onready var unlock;
@export var porte_path: NodePath
@onready var porte = get_node_or_null(porte_path)


func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		if porte:
			# on cherche le sprite et la collision dans la porte
			var spr = porte.get_node_or_null("Sprite2D")
			if spr:
				spr.visible = false

			var col = porte.get_node_or_null("CollisionShape2D")
			if col:
				col.set_deferred("disabled", true)

		# Joue le son à partir de 3 secondes, mais le détache d'abord
		#var sound = unlock.duplicate()
		#get_parent().add_child(sound)
		#sound.play()
		#sound.seek(3.5)

		# Le son se supprimera automatiquement quand il aura fini
		#sound.finished.connect(func(): sound.queue_free())

		# Supprime l'objet immédiatement
		queue_free()
