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
# NOVA REFERÊNCIA: A Label 'user' dentro do PlayOption
# Nota: Verifique se a label é realmente um filho direto de PlayOption e chama-se 'user'
@onready var user_label = play_option_layer.get_node("user")


func _ready():
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()

	# ----------------------------------------------------
	# 2. LÓGICA DE GERENCIAMENTO DE TELA AO CARREGAR A CENA
	# ----------------------------------------------------
	var target_menu = NetworkManager.next_menu_to_show
	
	if target_menu == "PlayOptions":
		# Se viemos da SkinSelect (ou outro lugar) e queremos o PlayOption
		main_menu_layer.hide()
		play_option_layer.show()
		
		# Recupera o nome de usuário (se estiver logado)
		var username = NetworkManager.logged_in_username
		if !username.is_empty():
			user_label.text = "Bem-vindo, " + username + "!"
			
	else:
		# Comportamento padrão: Esconde o PlayOption e mostra o MainMenu
		play_option_layer.hide()
		main_menu_layer.show()
		
	# Limpa o estado após o uso
	NetworkManager.next_menu_to_show = ""
	# ----------------------------------------------------


func _on_create_table_button_down() -> void:
	var table = {
		"id": {"data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true},
		"username": {"data_type": "text", "not_null": true},
		"hashedPassword": {"data_type": "text", "not_null": true},
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
		"pontuacao": 0
	}
	database.insert_row("players", data)
	print("Conta criada com sucesso!")
	
	username_input.text = ""
	password_input.text = ""
	created = true

	# LÓGICA DE TRANSIÇÃO E ATUALIZAÇÃO DO USERNAME APÓS CRIAÇÃO
	NetworkManager.logged_in_username = username
	user_label.text = "Bem-vindo, " + username + "!"
	main_menu_layer.hide()
	play_option_layer.show()


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
		user_label.text = "Bem-vindo, " + username + "!"
		main_menu_layer.hide()
		play_option_layer.show()
	else:
		print("Senha incorreta!")


func _on_drop_table_button_down() -> void:
	var success = database.drop_table("players")
	if success:
		print("Tabela 'players' deletada com sucesso!")
	else:
		print("Erro ao deletar tabela ou tabela não existe.")
