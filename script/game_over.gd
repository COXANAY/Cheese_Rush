extends CanvasLayer

# ASSUMIDO: O nome do seu AutoLoad/Singleton é "NetworkManager"
@onready var NetworkManager = get_node("/root/NetworkManager")

# Nome da cena que contém as Play Options (Menu de Jogo/Salas)
const PLAY_OPTIONS_SCENE = "res://scenes/welcome_screen.tscn"

func _on_jogar_novamente_button_down() -> void:
	# Opção para reiniciar o jogo (deve ir para a sua cena principal do JOGO)
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_menu_button_down() -> void:
	# Define a variável de navegação no Singleton (sem o caractere U+00A0)
	NetworkManager.next_menu_to_show = "PlayOptions" 
	
	# Faz a transição de cena, assumindo que suas PlayOptions estão em welcome_screen.tscn
	var error = get_tree().change_scene_to_file(PLAY_OPTIONS_SCENE)
	
	if error != OK:
		# Esta mensagem de erro aparecerá se o Godot não encontrar o arquivo
		push_error("ERRO FATAL: Não foi possível carregar a cena PlayOptions. Verifique o caminho: " + PLAY_OPTIONS_SCENE)
