extends Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn_jogar_novamente.pressed.connect(_on_btn_jogar_novamente_pressed)
	btn_menu.pressed.connect(_on_btn_menu_pressed)

@onready var pontuacao_label = $Panel/MarginContainer/VBoxContainer/PontuacaoLabel
@onready var acertos_label = $Panel/MarginContainer/VBoxContainer/AcertosLabel
@onready var erros_label = $Panel/MarginContainer/VBoxContainer/ErrosLabel
@onready var precisao_label = $Panel/MarginContainer/VBoxContainer/PrecisaoLabel
@onready var mensagem_label = $Panel/MarginContainer/VBoxContainer/MensagemLabel
@onready var btn_jogar_novamente = $Panel/MarginContainer/VBoxContainer/VBoxContainer/BtnJogarNovamente
@onready var btn_menu = $Panel/MarginContainer/VBoxContainer/VBoxContainer/BtnMenu

func inicializar(acertos: int, erros: int, total: int) -> void:
	var pontuacao = 0
	if total > 0:
		pontuacao = int((float(acertos) / float(total)) * 100)

	pontuacao_label.text = str(pontuacao) + " / 100"
	acertos_label.text = "Acertos: " + str(acertos)
	erros_label.text = "Erros: " + str(erros)

	var total_resolvido = acertos + erros
	var precisao = 0.0
	if total_resolvido > 0:
		precisao = (float(acertos) / float(total_resolvido)) * 100
	precisao_label.text = "Precisão: " + ("%.f" % precisao) + "%"

	mensagem_label.text = _mensagem_por_pontuacao(pontuacao)

func _mensagem_por_pontuacao(pontuacao: int) -> String:
	if pontuacao >= 90:
		return "Excelente! Axé!"
	elif pontuacao >= 70:
		return "Muito bem!"
	elif pontuacao >= 50:
		return "Continue praticando."
	else:
		return "Não desista, tente novamente!"

func _on_btn_jogar_novamente_pressed() -> void:
	get_tree().reload_current_scene()

func _on_btn_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

func _on_btn_opcoes_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_opcoes_principal.tscn")
