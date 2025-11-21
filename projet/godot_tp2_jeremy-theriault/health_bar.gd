extends ProgressBar

@export var max_health := 100
var current_health := max_health

func _ready():
	self.max_value = max_health
	self.value = current_health
	update_color()

func set_health(amount):
	current_health = clamp(amount, 0, max_health)
	self.value = current_health
	update_color()

func update_color():
	# change la couleur selon la santé
	var t = current_health / max_health
	if t > 0.5:
		# vert -> santé haute
		self.add_theme_color_override("fg_color", Color(0,1,0))
	elif t > 0.2:
		# jaune -> santé moyenne
		self.add_theme_color_override("fg_color", Color(1,1,0))
	else:
		# rouge -> santé faible
		self.add_theme_color_override("fg_color", Color(1,0,0))
