extends CharacterBody2D

@onready var congrats_sound = $AudioStreamPlayer

# --- Stats ---
@export var speed := 60
@export var max_health := 100
@export var attack_cooldown := 2.0

var health := 0
var player: Node = null
var is_attacking := false
var attack_timer := 0.0

# --- Nodes ---
@onready var detection = $DetectionArea
@onready var attack_area = $AttackArea
@onready var healthbar = $HealthBar

func _ready():
	health = max_health
	healthbar.max_value = max_health
	healthbar.value = health

	detection.body_entered.connect(_on_player_detected)
	detection.body_exited.connect(_on_player_lost)

	attack_area.body_entered.connect(_on_attack_hit)

func _physics_process(delta):
	if player and not is_attacking:
		_follow_player(delta)

	if player:
		attack_timer -= delta
		if attack_timer <= 0:
			_attack()
			attack_timer = attack_cooldown

func _follow_player(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

func _attack():
	is_attacking = true
	# ici tu peux jouer une animation d'attaque si tu veux
	await get_tree().create_timer(0.5).timeout
	is_attacking = false

func _on_player_detected(body):
	if body.is_in_group("player"):
		player = body

func _on_player_lost(body):
	if body == player:
		player = null

func _on_attack_hit(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(10)

func take_damage(amount):
	health -= amount
	healthbar.value = health
	$hurt.play()
	print("Boss hit ! Dégâts :", amount, " | PV restants :", health)

	if health <= 0:
		die()

func die():
	$CollisionShape2D.disabled = true
	congrats_sound.play()
	await congrats_sound.finished
	queue_free()
