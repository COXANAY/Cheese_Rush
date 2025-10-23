extends CanvasLayer

# Pré-carrega a cena de skins para maior eficiência
const SKIN_SELECT_SCENE_PATH = "res://scenes/skin_select.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Não precisa de lógica aqui, pois o MainMenu.gd gerencia a visibilidade

func _on_jogar_button_down() -> void:
	# Este botão deve levar ao jogo principal
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
func _on_skins_button_down() -> void:
	#  ESTA É A CORREÇÃO: Mudar para a cena de seleção de skins
	var error = get_tree().change_scene_to_file(SKIN_SELECT_SCENE_PATH)
	
	if error != OK:
		push_error("ERRO: Não foi possível carregar a cena de skins. Verifique o caminho: " + SKIN_SELECT_SCENE_PATH)
