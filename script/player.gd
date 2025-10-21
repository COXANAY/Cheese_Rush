extends CharacterBody3D
# Movimentação por segundo
@export var speed = 14

@export var fall_acceleration = 75

var target_velocity = Vector3.ZERO

func _physics_process(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Body_player.basis = Basis.looking_at(direction)

	# Velocidade no solo
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# velocidade vertical
	if not is_on_floor(): # Se estiver no ar, caia em direção ao chão. 
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Movendo o personagem
	velocity = target_velocity
	move_and_slide()
