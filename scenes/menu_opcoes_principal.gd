extends Control

var modo_jogo: bool = false

@onready var btn_voltar      = %BtnVoltar
@onready var btn_tela_inicial = %BtnTelaInicial
@onready var btn_viola = %BtnViola
@onready var btn_medio = %BtnMedio
@onready var btn_gunga = %BtnGunga

@onready var btn_angola = %BtnAngola
@onready var btn_sb_grande = %BtnSBGrande
@onready var btn_sb_pequeno = %BtnSBPequeno

@onready var btn_lento = %BtnLento
@onready var btn_equilibrado = %BtnEquilibrado
@onready var btn_rapido = %BtnRapido

@onready var btn_rep_nenhum = %BtnRepNenhum
@onready var btn_rep_baixo  = %BtnRepBaixo
@onready var btn_rep_medio  = %BtnRepMedio
@onready var btn_rep_alto   = %BtnRepAlto

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

	if GameData.toque_nome_atual == "Angola":
		btn_angola.button_pressed = true
	elif GameData.toque_nome_atual == "SaoBentoGrande":
		btn_sb_grande.button_pressed = true
	elif GameData.toque_nome_atual == "SaoBentoPequeno":
		btn_sb_pequeno.button_pressed = true

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

func _on_btn_viola_pressed():
	GameData.berimbau_atual = GameData.BERIMBAU_VIOLA
	btn_medio.button_pressed = false
	btn_gunga.button_pressed = false

func _on_btn_medio_pressed():
	GameData.berimbau_atual = GameData.BERIMBAU_MEDIO
	btn_viola.button_pressed = false
	btn_gunga.button_pressed = false

func _on_btn_gunga_pressed():
	GameData.berimbau_atual = GameData.BERIMBAU_GUNGA
	btn_viola.button_pressed = false
	btn_medio.button_pressed = false

func _on_btn_angola_pressed():
	GameData.toque_nome_atual = "Angola"
	btn_sb_grande.button_pressed = false
	btn_sb_pequeno.button_pressed = false

func _on_btn_sb_grande_pressed():
	GameData.toque_nome_atual = "SaoBentoGrande"
	btn_angola.button_pressed = false
	btn_sb_pequeno.button_pressed = false

func _on_btn_sb_pequeno_pressed():
	GameData.toque_nome_atual = "SaoBentoPequeno"
	btn_angola.button_pressed = false
	btn_sb_grande.button_pressed = false

func _on_btn_lento_pressed():
	GameData.velocidade_atual = 1.5
	btn_equilibrado.button_pressed = false
	btn_rapido.button_pressed = false

func _on_btn_equilibrado_pressed():
	GameData.velocidade_atual = 1.0
	btn_lento.button_pressed = false
	btn_rapido.button_pressed = false

func _on_btn_rapido_pressed():
	GameData.velocidade_atual = 0.7
	btn_lento.button_pressed = false
	btn_equilibrado.button_pressed = false

func _on_btn_rep_nenhum_pressed():
	GameData.repique_nivel = GameData.REPIQUE_NENHUM

func _on_btn_rep_baixo_pressed():
	GameData.repique_nivel = GameData.REPIQUE_BAIXO

func _on_btn_rep_medio_pressed():
	GameData.repique_nivel = GameData.REPIQUE_MEDIO

func _on_btn_rep_alto_pressed():
	GameData.repique_nivel = GameData.REPIQUE_ALTO

func _on_btn_voltar_pressed() -> void:
	if modo_jogo:
		get_tree().paused = false
		queue_free()
	else:
		get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

func _on_btn_tela_inicial_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
