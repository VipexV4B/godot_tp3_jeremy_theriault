extends CharacterBody2D

@onready var anim = $Sprite_player
@onready var idle_anim = $sprite_idle
@onready var ray_left = $RayCastLeft
@onready var ray_right = $RayCastRight
@onready var jump_sound = $jump
@onready var slash = $slash

# --- Variables modifiables ---
@export var speed := 200.0
@export var speed_run := 300.0
@export var jump_force := -330.0
@export var gravity := 900.0
@export var wall_jump_force := -300.0
@export var wall_pushback := 420.0
@export var wall_jump_lock := 0.18

# --- États internes ---
var wall_jump_lock_timer := 0.0
var attacking := false  # <-- bloque le mouvement pendant l'attaque
var has_sword := false
@export var attack_damage := 20
var is_attacking := false
@onready var attack_area = $AttackArea




func _ready():
	ray_left.enabled = true
	ray_right.enabled = true

	# Quand une animation finit
	anim.animation_finished.connect(_on_anim_finished)
	
	health = max_health
	if healthbar:
		healthbar.max_value = max_health
		healthbar.value = health
	
	$AttackArea.body_entered.connect(_on_attack_area_hit)


func _physics_process(delta):
	# --- SI ATTAQUE EN COURS → TOUT BLOQUER ---
	if attacking:
		velocity.x = 0
		move_and_slide()
		return

	# --- GRAVITÉ ---
	if not is_on_floor():
		velocity.y += gravity * delta

	# --- INPUT HORIZONTAL ---
	var direction := Input.get_axis("move_left", "move_right")

	# flip
	if direction > 0:
		anim.flip_h = false
	elif direction < 0:
		anim.flip_h = true

	# --- DÉTECTION MURS ---
	var hit_left = ray_left.is_colliding()
	var hit_right = ray_right.is_colliding()

	# --- SAUT ---
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_force
			jump_sound.play(0.5)
		elif hit_left or hit_right:
			velocity.y = wall_jump_force
			jump_sound.play(0.5)

			if hit_right:
				velocity.x = -wall_pushback
			else:
				velocity.x = wall_pushback

			wall_jump_lock_timer = wall_jump_lock

	# --- WALL LOCK ---
	if wall_jump_lock_timer > 0:
		wall_jump_lock_timer -= delta
	else:
		if direction != 0:
			if Input.is_action_pressed("run"):
				velocity.x = direction * speed_run
			else:
				velocity.x = direction * speed
		else:
			velocity.x = 0

	move_and_slide()

	# -----------------------------------------
	#                ANIMATIONS
	# -----------------------------------------
	if not is_on_floor():  # jump
		anim.show()
		idle_anim.hide()
		anim.play("jump")

	elif direction == 0:  # idle
		idle_anim.show()
		anim.hide()
		idle_anim.play("idle")

	elif Input.is_action_pressed("run"):  # run
		anim.show()
		idle_anim.hide()
		anim.play("run")

	else:  # walk
		anim.show()
		idle_anim.hide()
		anim.play("walk")

	# -----------------------------------------
	#                ATTAQUE
	# -----------------------------------------
func _process(delta):

	# Ton attaque + on active la hitbox
	if Input.is_action_just_pressed("attack_1") and not attacking and has_sword:
		attacking = true
		velocity.x = 0  
		anim.show()
		idle_anim.hide()
		anim.play("attack_1")
		slash.play()

		# active l'area pendant l'attaque
		$AttackArea.monitoring = true
		$AttackArea.monitorable = true

		await anim.animation_finished

		# désactive après
		$AttackArea.monitoring = false
		$AttackArea.monitorable = false

		attacking = false
		return

		
func _on_attack_area_hit(body):
	if not attacking: 
		return  # empêche les hits quand tu n'attaques pas

	if body.is_in_group("boss"):
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)
			print("Boss touché !")





# ------------------------------------------------
#         Callback quand une animation finit
# ------------------------------------------------
func _on_anim_finished():
	if anim.animation == "attack_1":
		attacking = false
		
		
@export var max_health := 100
var health := 100

@onready var healthbar = $HealthBar

func take_damage(amount):
	health -= amount

	if healthbar:
		healthbar.value = health

	print("Dégâts reçus :", amount, " | PV restants :", health)

	if health <= 0:
		die()

@onready var looser = $AudioStreamPlayer
func die():
	looser.play()
	anim.play("dead")
	await looser.finished
	print("Le joueur est mort")
	var menu = load("res://menu_principal.tscn")
	get_tree().change_scene_to_packed(menu)
