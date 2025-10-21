extends CharacterBody3D

# Velocidade mínima do mob em metros por segundo.
@export var min_speed = 10
# Velocidade maxima do mob em metros por segundo.
@export var max_speed = 18

func _physics_process(_delta):
	move_and_slide()


func initialize(start_position, player_position):
	# Coloca o mob em uma posição e gira em direção ao jogador ao player (Mas ele nn vai direto para o jogador)
	look_at_from_position(start_position, player_position, Vector3.UP)
	# Gire este mob aleatoriamente dentro do alcance de -45 e +45 graus,
	# para que ele não se mova diretamente em direção ao jogador.
	rotate_y(randf_range(-PI / 4, PI / 4))
	# Calculamos uma velocidade aleatória (inteira)
	var random_speed = randi_range(min_speed, max_speed)
	velocity = Vector3.FORWARD * random_speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	# Fiquei com preguiça de comentar o resto fds
func _on_visible_on_screen_notifier_3d_screen_exited():
	queue_free()
