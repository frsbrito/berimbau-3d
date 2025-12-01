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

func _ready():
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

func _on_btn_viola_pressed():
	GameData.berimbau_atual = GameData.BERIMBAU_VIOLA
	print("Selecionado: Viola")

func _on_btn_medio_pressed():
	GameData.berimbau_atual = GameData.BERIMBAU_MEDIO
	print("Selecionado: Médio")

func _on_btn_gunga_pressed():
	GameData.berimbau_atual = GameData.BERIMBAU_GUNGA
	print("Selecionado: Gunga")
	
func _on_btn_angola_pressed():
	GameData.toque_nome_atual = "Angola"
	print("Toque: Angola")

func _on_btn_sb_grande_pressed():
	GameData.toque_nome_atual = "SaoBentoGrande"
	print("Toque: São Bento Grande")

func _on_btn_sb_pequeno_pressed():
	GameData.toque_nome_atual = "SaoBentoPequeno"
	print("Toque: São Bento Pequeno")

func _on_btn_fechar_pressed():
	queue_free()
	get_tree().paused = false

func _on_btn_lento_pressed():
	GameData.velocidade_atual = 2

func _on_btn_equilibrado_pressed():
	GameData.velocidade_atual = 1.5

func _on_btn_rapido_pressed():
	GameData.velocidade_atual = 1
