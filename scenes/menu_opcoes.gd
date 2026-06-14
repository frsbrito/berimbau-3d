extends Control

@onready var btn_viola = $Panel/MarginContainer/VBoxContainer/HBoxContainer_Berimbaus/BtnViola
@onready var btn_medio = $Panel/MarginContainer/VBoxContainer/HBoxContainer_Berimbaus/BtnMedio
@onready var btn_gunga = $Panel/MarginContainer/VBoxContainer/HBoxContainer_Berimbaus/BtnGunga

@onready var btn_angola = $Panel/MarginContainer/VBoxContainer/VBoxContainer_Toques/BtnAngola
@onready var btn_sb_grande = $Panel/MarginContainer/VBoxContainer/VBoxContainer_Toques/BtnSBGrande
@onready var btn_sb_pequeno = $Panel/MarginContainer/VBoxContainer/VBoxContainer_Toques/BtnSBPequeno

@onready var btn_lento = $Panel/MarginContainer/VBoxContainer/HBoxContainer_Velocidade/BtnLento
@onready var btn_equilibrado = $Panel/MarginContainer/VBoxContainer/HBoxContainer_Velocidade/BtnEquilibrado
@onready var btn_rapido = $Panel/MarginContainer/VBoxContainer/HBoxContainer_Velocidade/BtnRapido

@onready var btn_rep_nenhum = $Panel/MarginContainer/VBoxContainer/HBoxContainer_Repique/BtnRepNenhum
@onready var btn_rep_baixo  = $Panel/MarginContainer/VBoxContainer/HBoxContainer_Repique/BtnRepBaixo
@onready var btn_rep_medio  = $Panel/MarginContainer/VBoxContainer/HBoxContainer_Repique/BtnRepMedio
@onready var btn_rep_alto   = $Panel/MarginContainer/VBoxContainer/HBoxContainer_Repique/BtnRepAlto

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	process_mode = Node.PROCESS_MODE_ALWAYS

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

func _on_btn_rep_nenhum_pressed():
	GameData.repique_nivel = GameData.REPIQUE_NENHUM

func _on_btn_rep_baixo_pressed():
	GameData.repique_nivel = GameData.REPIQUE_BAIXO

func _on_btn_rep_medio_pressed():
	GameData.repique_nivel = GameData.REPIQUE_MEDIO

func _on_btn_rep_alto_pressed():
	GameData.repique_nivel = GameData.REPIQUE_ALTO

func _on_btn_reiniciar_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_btn_fechar_pressed():
	queue_free()
	get_tree().paused = false

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
