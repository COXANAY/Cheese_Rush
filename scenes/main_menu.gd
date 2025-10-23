extends CanvasLayer
 
var database : SQLite

var created = false
 
# Referências aos nós de entrada e gerenciador de rede (mantidos)

@onready var NetworkManager = get_node("/root/NetworkManager")

@onready var username_input = $VBoxContainer/username

@onready var password_input = $VBoxContainer/password
 
# 1. Referências para os dois CanvasLayers para controle de visibilidade

@onready var main_menu_layer = self # Este script está anexado ao MainMenu

# O PlayOption é acessado como um nó irmão (sibling)

@onready var play_option_layer = get_parent().get_node("PlayOption")

# NOVA REFERÊNCIA: A Label 'user' dentro do PlayOption (assumindo que está na raiz do PlayOption)

@onready var user_label = play_option_layer.get_node("user")
 
 
func _ready():

	database = SQLite.new()

	database.path = "res://data.db"

	database.open_db()

	# 2. Garante que a tela de PlayOption esteja oculta ao iniciar

	# Caractere de espaço inválido removido

	play_option_layer.hide()
 
func _on_create_table_button_down() -> void:

	var table = {

		"id": {"data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true},

		"username": {"data_type": "text", "not_null": true},

		"hashedPassword": {"data_type": "text", "not_null": true},

		# NOVA COLUNA: Pontuação inicial

		"pontuacao": {"data_type": "int", "default": 0, "not_null": true},

	}

	database.create_table("players", table)

	print("Tabela 'players' criada (se ainda não existia) com a coluna 'pontuacao'.")
 
func _on_criar_button_down() -> void:

	if username_input == null or password_input == null: return
 
	var username = username_input.text.strip_edges().to_lower()

	var password = password_input.text.sha256_text()
 
	if username.is_empty() or password_input.text.is_empty():

		print("Preencha usuário e senha.")

		return
 
	var existing_user = database.select_rows("players", "username = '" + username + "'", ["*"])
 
	if existing_user.size() > 0:

		print("Usuário já existe!")

		return
 
	var data = {

		"username": username,

		"hashedPassword": password,

		# Incluímos pontuacao, embora o DEFAULT 0 já garanta o valor. 

		# É bom para clareza, mas estritamente opcional aqui.

		"pontuacao": 0

	}

	database.insert_row("players", data)

	print("Conta criada com sucesso!")
 
	username_input.text = ""

	password_input.text = ""

	created = true

	# LÓGICA DE TRANSIÇÃO E ATUALIZAÇÃO DO USERNAME APÓS CRIAÇÃO

	NetworkManager.logged_in_username = username

	user_label.text = "Bem-vindo, " + username + "!" # Define o nome na Label

	main_menu_layer.hide()

	play_option_layer.show() # Caractere de espaço inválido removido
 
func _on_login_button_down() -> void:

	if username_input == null or password_input == null: return

	var input_user = username_input.text.strip_edges().to_lower()

	var input_pass_hash = password_input.text.sha256_text()
 
	if input_user.is_empty() or password_input.text.is_empty():

		print("Preencha usuário e senha.")

		return
 
	var result = database.select_rows("players", "username = '" + input_user + "'", ["*"])
 
	if result.size() == 0:

		print("Usuário não encontrado!")

		return
 
	var user_data = result[0]
 
	if not user_data.has("hashedPassword"):

		print("Erro: registro inválido no banco de dados.")

		return
 
	var stored_hash = user_data["hashedPassword"]
 
	if input_pass_hash == stored_hash:

		print("Login efetuado com sucesso!")

		var username = input_user

		NetworkManager.logged_in_username = username

		# LÓGICA DE TRANSIÇÃO E ATUALIZAÇÃO DO USERNAME APÓS LOGIN

		user_label.text = "Bem-vindo, " + username + "!" # Define o nome na Label

		main_menu_layer.hide() # Oculta o MainMenu (onde este script está)

		play_option_layer.show() # Torna o PlayOption visível

	else:

		print("Senha incorreta!")
 
func _on_drop_table_button_down() -> void:

	var success = database.drop_table("players")

	if success:

		print("Tabela 'players' deletada com sucesso!")

	else:

		print("Erro ao deletar tabela ou tabela não existe.")

 
