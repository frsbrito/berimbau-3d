extends Control

const MENU_CAPOEIRA_BERIMBAU_SCENE = "res://scenes/menus/menu_capoeira_berimbau.tscn"

@export var titulos_paginas: Array = []
@export var corpos_paginas: Array = []

var pagina_atual: int = 0

@onready var label_titulo: Label = %LabelTitulo
@onready var label_corpo: Label = %LabelCorpo
@onready var label_progresso: Label = %LabelProgresso
@onready var btn_anterior: Button = %BtnAnterior
@onready var btn_proximo: Button = %BtnProximo

func _ready() -> void:
	_atualizar_pagina()

func _atualizar_pagina() -> void:
	label_titulo.text = titulos_paginas[pagina_atual]
	label_corpo.text = corpos_paginas[pagina_atual]

	var total = titulos_paginas.size()
	var multipagina = total > 1
	label_progresso.visible = multipagina
	btn_anterior.visible = multipagina
	btn_proximo.visible = multipagina
	if multipagina:
		label_progresso.text = "%d / %d" % [pagina_atual + 1, total]
		btn_anterior.disabled = pagina_atual == 0
		btn_proximo.disabled = pagina_atual == total - 1

func _on_btn_anterior_pressed() -> void:
	pagina_atual -= 1
	_atualizar_pagina()

func _on_btn_proximo_pressed() -> void:
	pagina_atual += 1
	_atualizar_pagina()

func _on_btn_voltar_pressed() -> void:
	get_tree().change_scene_to_file(MENU_CAPOEIRA_BERIMBAU_SCENE)
