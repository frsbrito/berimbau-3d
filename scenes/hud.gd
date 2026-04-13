extends Control

const MENU_OPCOES_SCENE = preload("res://scenes/menu_opcoes.tscn")
const GAME_OVER_SCENE_PATH = "res://scenes/game_over.tscn"

@onready var acertos_label = $AcertosLabel
@onready var erros_label = $ErrosLabel
@onready var porcentagem_label = $PorcentagemLabel

func atualizar_hud(acertos, erros):
	acertos_label.text = "Acertos: " + str(acertos)
	erros_label.text = "Erros: " + str(erros)
	
	var total_resolvido = acertos + erros
	var porcentagem = 0
	
	if total_resolvido > 0:
		porcentagem = (float(acertos) / total_resolvido) * 100
	
	porcentagem_label.text = "Precisão: " + ("%.f" % porcentagem) + "%"

func _on_partida_encerrada(acertos: int, erros: int, total: int) -> void:
	var game_over = load(GAME_OVER_SCENE_PATH).instantiate()
	add_child(game_over)
	game_over.inicializar(acertos, erros, total)
	get_tree().paused = true

func _on_config_pressed() -> void:
	var menu = MENU_OPCOES_SCENE.instantiate()
	add_child(menu)
	get_tree().paused = true
