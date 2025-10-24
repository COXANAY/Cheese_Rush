extends Node

@export var mob_scene: PackedScene
@export var cheese_scene: PackedScene

func _ready():
	# Pode iniciar timers se quiser começar o jogo imediatamente
	$MobTimer.start()
	$CheeseTimer.start()


func _on_mob_timer_timeout():
	# Cria uma nova instância do Mob
	var mob = mob_scene.instantiate()

	# Escolhe uma posição aleatória no SpawnPath
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	mob_spawn_location.progress_ratio = randf()

	# Passa a posição do jogador para o mob
	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)

	# Adiciona o mob na cena
	add_child(mob)


func _on_player_hit():
	# Quando o jogador morre:
	# 1️⃣ Para os timers
	$MobTimer.stop()
	$CheeseTimer.stop()

	# 2️⃣ Troca para a cena de Game Over
	get_tree().change_scene_to_file("res://scenes/game_over_scene.tscn")


func _on_cheese_timer_timeout() -> void:
	# Cria um novo queijo
	var cheese = cheese_scene.instantiate()

	# Define posição aleatória no mapa
	cheese.position = Vector3(randf_range(-10, 10), 0.5, randf_range(-10, 10))

	# Conecta o sinal 'collected' ao placar (se existir)
	if has_node("UserInterface/ScoreLabel") and cheese.has_signal("collected"):
		cheese.collected.connect($UserInterface/ScoreLabel._on_collectible_collected.bind(1))

	# Adiciona o queijo à cena
	add_child(cheese)
