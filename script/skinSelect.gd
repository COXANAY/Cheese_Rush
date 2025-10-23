extends CanvasLayer

# Pré-carrega a cena de destino para maior eficiência
const WELCOME_SCREEN_SCENE := preload("res://scenes/welcome_screen.tscn")

# --- NÓS VISUAIS DAS SKINS ---
@onready var padrao_skin = get_node("../Padrao")
@onready var gold_skin = get_node("../Gold_mouse")
@onready var soldier_skin = get_node("../Soldier_mouse")

var selected_skin := "padrao"

func _ready() -> void:
	_show_skin(selected_skin)


func _show_skin(skin_name: String) -> void:
	padrao_skin.visible = false
	gold_skin.visible = false
	soldier_skin.visible = false

	match skin_name:
		"padrao":
			padrao_skin.visible = true
		"golden":
			gold_skin.visible = true
		"soldier":
			soldier_skin.visible = true

	selected_skin = skin_name


func _on_padrao_button_down() -> void:
	_show_skin("padrao")

func _on_soldier_button_down() -> void:
	_show_skin("soldier")

func _on_golden_button_down() -> void:
	_show_skin("golden")


func _on_selecionar_button_down() -> void:
	print("Skin selecionada:", selected_skin)
	# 1. DEFINE O ESTADO ANTES DE MUDAR
	NetworkManager.next_menu_to_show = "PlayOptions" 
	_change_to_welcome_screen()

func _on_voltar_button_down() -> void:
	# 1. DEFINE O ESTADO ANTES DE MUDAR
	NetworkManager.next_menu_to_show = "PlayOptions" 
	_change_to_welcome_screen()


func _change_to_welcome_screen() -> void:
	# Muda a cena para a WelcomeScreen
	var error = get_tree().change_scene_to_file("res://scenes/welcome_screen.tscn")
	
	if error != OK:
		push_error("ERRO: Não foi possível carregar a cena 'res://scenes/welcome_screen.tscn'. Verifique o caminho do arquivo.")
