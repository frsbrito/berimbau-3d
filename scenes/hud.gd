extends Control

signal finalizar_pressed()

const MENU_OPCOES_SCENE = preload("res://scenes/menus/menu_opcoes_principal.tscn")
const GAME_OVER_SCENE_PATH = "res://scenes/game_over.tscn"

@onready var placar_panel = $PlacarPanel
@onready var acertos_label = $AcertosLabel
@onready var erros_label = $ErrosLabel
@onready var porcentagem_label = $PorcentagemLabel
@onready var opcoes_atuais_label = $OpcoesAtuaisLabel
@onready var finalizar_button = $Finalizar
@onready var encerrar_button = $Encerrar

func _ready():
	_atualizar_opcoes_atuais_label()
	var pratica_livre = GameData.pratica_livre_ativa
	finalizar_button.visible = GameData.modo_livre_ativo() and not pratica_livre
	encerrar_button.visible = pratica_livre
	placar_panel.visible = not pratica_livre
	acertos_label.visible = not pratica_livre
	erros_label.visible = not pratica_livre
	porcentagem_label.visible = not pratica_livre

const COR_VALOR_OPCAO = "#ffffff"

func _linha_opcao(rotulo: String, valor: String) -> String:
	return "%s [color=%s]%s[/color]" % [rotulo, COR_VALOR_OPCAO, valor]

func _atualizar_opcoes_atuais_label():
	var linhas = [
		_linha_opcao("Toque:", GameData.nome_toque_atual()),
		_linha_opcao("Timbre:", GameData.nome_berimbau_atual()),
		_linha_opcao("Velocidade:", GameData.nome_velocidade_atual()),
	]

	if not GameData.pratica_livre_ativa:
		linhas.append(_linha_opcao("Repique:", GameData.nome_repique_nivel()))
		linhas.append(_linha_opcao("Duração:", GameData.nome_duracao_partida()))

	opcoes_atuais_label.text = "[right]%s[/right]" % "\n".join(linhas)

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
	get_parent().add_child(game_over)
	game_over.inicializar(acertos, erros, total)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_config_pressed()

func _on_config_pressed() -> void:
	var menu = MENU_OPCOES_SCENE.instantiate()
	menu.modo_jogo = true
	get_parent().add_child(menu)
	get_tree().paused = true

func _on_finalizar_pressed() -> void:
	finalizar_pressed.emit()

func _on_encerrar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/menu_principal.tscn")

func _on_voltar_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/menu_principal.tscn")
