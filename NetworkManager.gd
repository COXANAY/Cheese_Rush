# NetworkManager.gd
extends Node

# VARIÁVEL GLOBAL PARA ARMAZENAR O NOME DO USUÁRIO LOGADO
var logged_in_username = "Convidado"

# >>> VARIÁVEL ADICIONADA PARA CONTROLE DA UI <<<
var next_menu_to_show: String = ""

# As variáveis e funções relacionadas a rede (que não usaremos por enquanto)
const DEFAULT_PORT = 9999
const MAX_PLAYERS = 8
var peer = ENetMultiplayerPeer.new()
var host_ip = "127.0.0.1"
