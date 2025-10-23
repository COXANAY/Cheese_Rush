extends Node

@export var mob_scene: PackedScene
@export var cheese_scene: PackedScene 
func _ready():
	$UserInterface/Retry.hide()


func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on the SpawnPath.
	# We store the reference to the SpawnLocation node.
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	# And give it a random offset.
	mob_spawn_location.progress_ratio = randf()

	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_player_hit():
	$MobTimer.stop()
	$UserInterface/Retry.show()

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		# This restarts the current scene.
		get_tree().reload_current_scene()

func _on_cheese_timer_timeout() -> void:
	# Cria uma instância do queijo
	var cheese = cheese_scene.instantiate()
	# Define a posição (AJUSTE ESSA POSIÇÃO para onde você quer que o queijo apareça!)
	# Exemplo simples, use algo mais sofisticado como o SpawnPath do seu mob, se quiser
	cheese.position = Vector3(randf_range(-10, 10), 0.5, randf_range(-10, 10))
	# Coneta o sinal 'collected' do queijo ao placar
	# O .bind(1) passa o valor '1' para a função do placar, adicionando 1 ponto.
	cheese.collected.connect($UserInterface/ScoreLabel._on_collectible_collected.bind(1))
	# Adiciona o queijo à cena
	add_child(cheese)# Replace with function body.
