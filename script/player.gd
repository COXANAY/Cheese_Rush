extends CharacterBody3D

# Parâmetros de movimento
@export var speed = 14
@export var jump_impulse = 20
@export var fall_acceleration = 75
@export var bounce_impulse = 16

var target_velocity = Vector3.ZERO

func _physics_process(delta):
	var direction = Vector3.ZERO

	# Movimento horizontal
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	# Se houver direção, normaliza e rotaciona o corpo do jogador
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Body_player.basis = Basis.looking_at(direction)

	# Aplica velocidade no plano (x, z)
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Aplica gravidade se não estiver no chão
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta

	# Pulo
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse

	# Atualiza a velocidade e move o personagem
	velocity = target_velocity
	move_and_slide()

	# Verifica colisões após o movimento
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		if collision == null:
			continue

		var collider = collision.get_collider()
		if collider == null:
			continue

		# Se colidiu com um inimigo
		if collider.is_in_group("mob"):
			# Verifica se o impacto foi de cima
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				collider.squash()
				target_velocity.y = bounce_impulse
				break
