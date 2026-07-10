extends Control

const MAIN_SCENE = "res://scenes/main.tscn"

var modo_jogo: bool = false
var houve_alteracao: bool = false

@onready var btn_voltar      = %BtnVoltar
@onready var btn_tela_inicial = %BtnTelaInicial
@onready var btn_viola = %BtnViola
@onready var btn_medio = %BtnMedio
@onready var btn_gunga = %BtnGunga

@onready var btn_angola = %BtnAngola
@onready var btn_sb_grande = %BtnSBGrande
@onready var btn_sb_pequeno = %BtnSBPequeno
@onready var btn_pratica_livre = %BtnPraticaLivre

@onready var btn_lento = %BtnLento
@onready var btn_equilibrado = %BtnEquilibrado
@onready var btn_rapido = %BtnRapido

@onready var btn_rep_nenhum = %BtnRepNenhum
@onready var btn_rep_baixo  = %BtnRepBaixo
@onready var btn_rep_medio  = %BtnRepMedio
@onready var btn_rep_alto   = %BtnRepAlto

@onready var btn_modo_padrao = %BtnModoPadrao
@onready var btn_modo_livre  = %BtnModoLivre

@onready var btn_qtd_20  = %BtnQtd20
@onready var btn_qtd_40  = %BtnQtd40
@onready var btn_qtd_60  = %BtnQtd60
@onready var btn_qtd_100 = %BtnQtd100

@onready var vbox_modo_coluna = %VBoxContainer_Modo
@onready var separador_modo_coluna = %VSeparator2

@onready var sep_velocidade = %Sep2
@onready var label_velocidade = %Label_Velocidade
@onready var hbox_velocidade = %HBoxContainer_Velocidade

@onready var separador_repique_coluna = %VSeparator
@onready var vbox_repique_coluna = %VBoxContainer_Right

@onready var label_qtd_notas = %Label_QtdNotas
@onready var hbox_qtd_notas  = %HBoxContainer_QtdNotas

func _ready():
	if modo_jogo:
		btn_tela_inicial.visible = true
		btn_voltar.text = "↩ Retomar"

	if GameData.berimbau_atual == GameData.BERIMBAU_VIOLA:
		btn_viola.button_pressed = true
	elif GameData.berimbau_atual == GameData.BERIMBAU_MEDIO:
		btn_medio.button_pressed = true
	elif GameData.berimbau_atual == GameData.BERIMBAU_GUNGA:
		btn_gunga.button_pressed = true

	if GameData.pratica_livre_ativa:
		btn_pratica_livre.button_pressed = true
	elif GameData.toque_nome_atual == "Angola":
		btn_angola.button_pressed = true
	elif GameData.toque_nome_atual == "SaoBentoGrande":
		btn_sb_grande.button_pressed = true
	elif GameData.toque_nome_atual == "SaoBentoPequeno":
		btn_sb_pequeno.button_pressed = true

	_atualizar_visibilidade_modo_coluna()

	if GameData.velocidade_atual >= 1.4:
		btn_lento.button_pressed = true
	elif GameData.velocidade_atual <= 0.7:
		btn_rapido.button_pressed = true
	else:
		btn_equilibrado.button_pressed = true

	match GameData.repique_nivel:
		GameData.REPIQUE_NENHUM: btn_rep_nenhum.button_pressed = true
		GameData.REPIQUE_BAIXO:  btn_rep_baixo.button_pressed  = true
		GameData.REPIQUE_MEDIO:  btn_rep_medio.button_pressed  = true
		GameData.REPIQUE_ALTO:   btn_rep_alto.button_pressed   = true

	if GameData.modo_livre_ativo():
		btn_modo_livre.button_pressed = true
		_desmarcar_qtd_notas()
	else:
		btn_modo_padrao.button_pressed = true
		_marcar_qtd_notas_atual()

	_atualizar_visibilidade_qtd_notas()

func _on_btn_viola_pressed():
	houve_alteracao = true
	GameData.berimbau_atual = GameData.BERIMBAU_VIOLA
	btn_medio.button_pressed = false
	btn_gunga.button_pressed = false

func _on_btn_medio_pressed():
	houve_alteracao = true
	GameData.berimbau_atual = GameData.BERIMBAU_MEDIO
	btn_viola.button_pressed = false
	btn_gunga.button_pressed = false

func _on_btn_gunga_pressed():
	houve_alteracao = true
	GameData.berimbau_atual = GameData.BERIMBAU_GUNGA
	btn_viola.button_pressed = false
	btn_medio.button_pressed = false

func _on_btn_angola_pressed():
	houve_alteracao = true
	GameData.toque_nome_atual = "Angola"
	GameData.pratica_livre_ativa = false
	btn_sb_grande.button_pressed = false
	btn_sb_pequeno.button_pressed = false
	btn_pratica_livre.button_pressed = false
	_atualizar_visibilidade_modo_coluna()

func _on_btn_sb_grande_pressed():
	houve_alteracao = true
	GameData.toque_nome_atual = "SaoBentoGrande"
	GameData.pratica_livre_ativa = false
	btn_angola.button_pressed = false
	btn_sb_pequeno.button_pressed = false
	btn_pratica_livre.button_pressed = false
	_atualizar_visibilidade_modo_coluna()

func _on_btn_sb_pequeno_pressed():
	houve_alteracao = true
	GameData.toque_nome_atual = "SaoBentoPequeno"
	GameData.pratica_livre_ativa = false
	btn_angola.button_pressed = false
	btn_sb_grande.button_pressed = false
	btn_pratica_livre.button_pressed = false
	_atualizar_visibilidade_modo_coluna()

func _on_btn_pratica_livre_pressed():
	houve_alteracao = true
	GameData.pratica_livre_ativa = true
	btn_angola.button_pressed = false
	btn_sb_grande.button_pressed = false
	btn_sb_pequeno.button_pressed = false
	_atualizar_visibilidade_modo_coluna()

# Velocidade, Repique e Modo/Quantidade de notas não fazem sentido em
# Prática Livre (não há notas nem placar), então somem enquanto essa opção
# estiver ativa.
func _atualizar_visibilidade_modo_coluna():
	var visivel = not GameData.pratica_livre_ativa
	vbox_modo_coluna.visible = visivel
	separador_modo_coluna.visible = visivel
	sep_velocidade.visible = visivel
	label_velocidade.visible = visivel
	hbox_velocidade.visible = visivel
	vbox_repique_coluna.visible = visivel
	separador_repique_coluna.visible = visivel

func _on_btn_lento_pressed():
	houve_alteracao = true
	GameData.velocidade_atual = 1.5
	btn_equilibrado.button_pressed = false
	btn_rapido.button_pressed = false

func _on_btn_equilibrado_pressed():
	houve_alteracao = true
	GameData.velocidade_atual = 1.0
	btn_lento.button_pressed = false
	btn_rapido.button_pressed = false

func _on_btn_rapido_pressed():
	houve_alteracao = true
	GameData.velocidade_atual = 0.7
	btn_lento.button_pressed = false
	btn_equilibrado.button_pressed = false

func _on_btn_rep_nenhum_pressed():
	houve_alteracao = true
	GameData.repique_nivel = GameData.REPIQUE_NENHUM

func _on_btn_rep_baixo_pressed():
	houve_alteracao = true
	GameData.repique_nivel = GameData.REPIQUE_BAIXO

func _on_btn_rep_medio_pressed():
	houve_alteracao = true
	GameData.repique_nivel = GameData.REPIQUE_MEDIO

func _on_btn_rep_alto_pressed():
	houve_alteracao = true
	GameData.repique_nivel = GameData.REPIQUE_ALTO

func _on_btn_modo_padrao_pressed():
	houve_alteracao = true
	GameData.modo_partida = GameData.MODO_PADRAO
	btn_modo_livre.button_pressed = false
	_marcar_qtd_notas_atual()
	_atualizar_visibilidade_qtd_notas()

func _on_btn_modo_livre_pressed():
	houve_alteracao = true
	GameData.modo_partida = GameData.MODO_LIVRE
	btn_modo_padrao.button_pressed = false
	_desmarcar_qtd_notas()
	_atualizar_visibilidade_qtd_notas()

# No modo livre a quantidade de notas não tem efeito nenhum (a partida não
# tem fim automático), então some da tela, igual ocorre com a coluna inteira
# quando "Prática Livre" está selecionada em Toque.
func _atualizar_visibilidade_qtd_notas():
	var visivel = not GameData.modo_livre_ativo()
	label_qtd_notas.visible = visivel
	hbox_qtd_notas.visible  = visivel

func _desmarcar_qtd_notas():
	btn_qtd_20.button_pressed  = false
	btn_qtd_40.button_pressed  = false
	btn_qtd_60.button_pressed  = false
	btn_qtd_100.button_pressed = false

func _marcar_qtd_notas_atual():
	match GameData.limite_notas_atual:
		20:  btn_qtd_20.button_pressed  = true
		60:  btn_qtd_60.button_pressed  = true
		100: btn_qtd_100.button_pressed = true
		_:   btn_qtd_40.button_pressed  = true

func _on_btn_qtd_20_pressed():
	houve_alteracao = true
	GameData.limite_notas_atual = 20
	btn_qtd_40.button_pressed = false
	btn_qtd_60.button_pressed = false
	btn_qtd_100.button_pressed = false

func _on_btn_qtd_40_pressed():
	houve_alteracao = true
	GameData.limite_notas_atual = 40
	btn_qtd_20.button_pressed = false
	btn_qtd_60.button_pressed = false
	btn_qtd_100.button_pressed = false

func _on_btn_qtd_60_pressed():
	houve_alteracao = true
	GameData.limite_notas_atual = 60
	btn_qtd_20.button_pressed = false
	btn_qtd_40.button_pressed = false
	btn_qtd_100.button_pressed = false

func _on_btn_qtd_100_pressed():
	houve_alteracao = true
	GameData.limite_notas_atual = 100
	btn_qtd_20.button_pressed = false
	btn_qtd_40.button_pressed = false
	btn_qtd_60.button_pressed = false

func _on_btn_voltar_pressed() -> void:
	if modo_jogo:
		get_tree().paused = false
		if houve_alteracao:
			get_tree().change_scene_to_file(MAIN_SCENE)
		else:
			queue_free()
	else:
		get_tree().change_scene_to_file("res://scenes/menus/menu_principal.tscn")

func _on_btn_tela_inicial_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/menu_principal.tscn")
