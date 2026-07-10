extends Control

const MAIN_SCENE = "res://scenes/main.tscn"
const MENU_OPCOES_SCENE = "res://scenes/menus/menu_opcoes_principal.tscn"
const MENU_SOBRE_SCENE = "res://scenes/menus/menu_sobre.tscn"
const MENU_CAPOEIRA_BERIMBAU_SCENE = "res://scenes/menus/menu_capoeira_berimbau.tscn"

func _on_btn_jogar_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_SCENE)

func _on_btn_opcoes_pressed() -> void:
	get_tree().change_scene_to_file(MENU_OPCOES_SCENE)

func _on_btn_sobre_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SOBRE_SCENE)

func _on_btn_capoeira_berimbau_pressed() -> void:
	get_tree().change_scene_to_file(MENU_CAPOEIRA_BERIMBAU_SCENE)
