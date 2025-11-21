extends CharacterBody2D

@onready var anim = $Sprite_player
@onready var idle_anim = $sprite_idle
@onready var ray_left = $RayCastLeft
@onready var ray_right = $RayCastRight
@onready var jump_sound = $jump

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



func _ready():
	ray_left.enabled = true
	ray_right.enabled = true

	# Quand une animation finit
	anim.animation_finished.connect(_on_anim_finished)


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
			jump_sound.play()
		elif hit_left or hit_right:
			velocity.y = wall_jump_force
			jump_sound.play()

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
	#                ATTAQUE
	# -----------------------------------------
	if Input.is_action_just_pressed("attack_1") and not attacking and has_sword:
		attacking = true
		velocity.x = 0
		anim.show()
		idle_anim.hide()
		anim.play("attack_1")
		return



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


# ------------------------------------------------
#         Callback quand une animation finit
# ------------------------------------------------
func _on_anim_finished():
	if anim.animation == "attack_1":
		attacking = false
