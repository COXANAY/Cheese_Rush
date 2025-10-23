extends Label

var score = 0

func _on_collectible_collected(points = 1):
	# O valor padrão 'points = 1' garante que, se for chamado sem argumento, some 1 ponto.
	score += points
	text = "Pontuação: " + str(score)
