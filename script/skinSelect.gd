extends CanvasLayer

const WELCOME_SCREEN_SCENE := preload("res://scenes/welcome_screen.tscn")

@onready var NetworkManager = get_node("/root/NetworkManager")
var database : SQLite

@onready var padrao_skin = get_node("../Padrao")
@onready var gold_skin = get_node("../Gold_mouse")
@onready var soldier_skin = get_node("../Soldier_mouse")

# Referências dos botões
@onready var padrao_button = $VBoxContainer/padrao
@onready var soldier_button = $VBoxContainer/soldier
@onready var golden_button = $VBoxContainer/golden

var selected_skin := "padrao"

# Preço das skins
var skin_prices = {
	"soldier": 50,
	"golden": 100
}

func _ready() -> void:
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()

	var username = NetworkManager.logged_in_username
	if !username.is_empty():
		var result = database.select_rows("players", "username = '" + username + "'", ["skin_atual", "skins_disponiveis"])
		if result.size() > 0:
			selected_skin = result[0]["skin_atual"]
			var skins = result[0]["skins_disponiveis"].split(",")
			_show_skin(selected_skin)
			_update_skin_buttons(skins)

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
	var username = NetworkManager.logged_in_username
	if username.is_empty():
		push_error("Nenhum usuário logado! Não foi possível selecionar a skin.")
		return

	var result = database.select_rows("players", "username = '" + username + "'", ["pontuacao", "skins_disponiveis"])
	if result.size() == 0:
		push_error("Usuário não encontrado no banco.")
		return

	var player = result[0]
	var pontos = player["pontuacao"]
	var skins = player["skins_disponiveis"].split(",")

	if selected_skin in skins:
		print("Você já possui a skin", selected_skin)
	else:
		if selected_skin in skin_prices:
			var preco = skin_prices[selected_skin]
			if pontos >= preco:
				pontos -= preco
				skins.append(selected_skin)
				var novas_skins = ",".join(skins)
				var update_query = "UPDATE players SET pontuacao = " + str(pontos) + ", skins_disponiveis = '" + novas_skins + "' WHERE username = '" + username + "';"
				database.query(update_query)
				print("Skin", selected_skin, "comprada com sucesso! Pontos restantes:", pontos)
			else:
				print("Pontos insuficientes para comprar", selected_skin, "precisa de", preco, "pontos.")
				return

	var update_skin_query = "UPDATE players SET skin_atual = '" + selected_skin + "' WHERE username = '" + username + "';"
	database.query(update_skin_query)
	print("Skin '" + selected_skin + "' selecionada.")

	# Atualiza os botões
	_update_skin_buttons(skins)

	# Vai para o menu de PlayOptions
	NetworkManager.next_menu_to_show = "PlayOptions"
	_change_to_welcome_screen()

func _update_skin_buttons(skins_disponiveis: Array) -> void:
	if "soldier" in skins_disponiveis:
		soldier_button.text = "Soldier"
	else:
		soldier_button.text = "Soldier 50 🧀"

	if "golden" in skins_disponiveis:
		golden_button.text = "Golden"
	else:
		golden_button.text = "Golden 100 🧀"

	# Se quiser manter padrao igual, por segurança
	padrao_button.text = "Padrao"

func _on_voltar_button_down() -> void:
	NetworkManager.next_menu_to_show = "PlayOptions"
	_change_to_welcome_screen()

func _change_to_welcome_screen() -> void:
	var error = get_tree().change_scene_to_file("res://scenes/welcome_screen.tscn")
	if error != OK:
		push_error("ERRO: Não foi possível carregar a cena 'res://scenes/welcome_screen.tscn'. Verifique o caminho do arquivo.")
