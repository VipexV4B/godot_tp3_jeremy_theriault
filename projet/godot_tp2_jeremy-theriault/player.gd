extends CharacterBody2D

@onready var anim = $Sprite_player
@onready var animation = $sprite_idle
@onready var ray_left = $RayCastLeft
@onready var ray_right = $RayCastRight

# --- Variables modifiables par le jeu ---
@export var speed = 200.0          # vitesse normale (modifiable par un objet)
@export var speed_run = 300.0      # vitesse quand on court
@export var jump_force = -330.0
@export var gravity = 900.0
@export var wall_jump_force = -300.0
@export var wall_pushback = 420.0   # augmente si tu veux un recul plus visible
@export var wall_jump_lock = 0.18   # durée pendant laquelle on bloque le contrôle horizontal

# --- Variables internes ---
var wall_jump_lock_timer := 0.0

func _ready() -> void:
	# activer les raycasts
	ray_left.enabled = true
	ray_right.enabled = true

func _physics_process(delta: float) -> void:
	# gravité
	if not is_on_floor():
		velocity.y += gravity * delta

	# input horizontal
	var direction := 0.0
	if Input.is_action_pressed("move_right"):
		direction += 1
		anim.flip_h = false
	if Input.is_action_pressed("move_left"):
		direction -= 1
		anim.flip_h = true

	# détection mur via raycasts
	var hit_left: bool = ray_left.is_colliding()
	var hit_right: bool = ray_right.is_colliding()

	# saut normal ou wall jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_force
		elif (hit_left or hit_right) and not is_on_floor():
			velocity.y = wall_jump_force
			if hit_right:
				velocity.x = -wall_pushback
			else:
				velocity.x = wall_pushback
			wall_jump_lock_timer = wall_jump_lock
			
	# Si timer actif, on ne réécrit pas velocity.x (laisse le pushback agir)
	if wall_jump_lock_timer > 0.0:
		wall_jump_lock_timer -= delta
	else:
		# contrôle horizontal normal
		if direction == 0:
			velocity.x = 0
		elif Input.is_action_pressed("run"):
			velocity.x = direction * speed_run
		else:
			velocity.x = direction * speed

	move_and_slide()

	# animations
	if not is_on_floor():
		anim.show()
		animation.hide()
		if anim.animation != "jump":
			anim.play("jump")
	elif direction == 0 and is_on_floor():
		anim.hide()
		animation.show()
		animation.play("idle")
	elif Input.is_action_pressed("run"):
		anim.show()
		animation.hide()
		anim.play("run")
	else:
		anim.show()
		animation.hide()
		anim.play("walk")
