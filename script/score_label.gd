extends Label

var score = 0

@onready var database = SQLite.new()
@onready var NetworkManager = get_node("/root/NetworkManager")

func _ready():
	# Abre o banco de dados
	database.path = "res://data.db"
	database.open_db()
	
	# Carrega a pontuação do usuário logado, se houver
	var username = NetworkManager.logged_in_username
	if username != "Convidado":
		var result = database.select_rows("players", "username = '" + username + "'", ["pontuacao"])
		if result.size() > 0:
			score = result[0]["pontuacao"]
			text = "Pontuação: " + str(score)
		else:
			text = "Pontuação: 0"
	else:
		text = "Pontuação: 0"

func _on_collectible_collected(points = 1):
	# Incrementa a pontuação local
	score += points
	text = "Pontuação: " + str(score)
	
	# Salva no banco se houver usuário logado
	var username = NetworkManager.logged_in_username
	if username != "Convidado":
		var update_query = "UPDATE players SET pontuacao = " + str(score) + " WHERE username = '" + username + "';"
		database.query(update_query)
