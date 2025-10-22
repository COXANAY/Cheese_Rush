extends CanvasLayer

var database : SQLite
var created = false

@onready var NetworkManager = get_node("/root/NetworkManager")
@onready var username_input = $VBoxContainer/username
@onready var password_input = $VBoxContainer/password

func _ready():
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()

func _on_create_table_button_down() -> void:
	var table = {
		"id": {"data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true},
		"username": {"data_type": "text", "not_null": true},
		"hashedPassword": {"data_type": "text", "not_null": true},
	}
	database.create_table("players", table)
	print("Tabela 'players' criada (se ainda não existia).")

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
		"hashedPassword": password
	}
	database.insert_row("players", data)
	print("Conta criada com sucesso!")

	username_input.text = ""
	password_input.text = ""
	created = true

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
		NetworkManager.logged_in_username = input_user
	else:
		print("Senha incorreta!")

func _on_drop_table_button_down() -> void:
	var success = database.drop_table("players")
	if success:
		print("Tabela 'players' deletada com sucesso!")
	else:
		print("Erro ao deletar tabela ou tabela não existe.")
