extends Control

const MAIN_SCENE = "res://scenes/main.tscn"
const MENU_OPCOES_SCENE = "res://scenes/menu_opcoes_principal.tscn"

func _on_btn_jogar_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_SCENE)

func _on_btn_opcoes_pressed() -> void:
	get_tree().change_scene_to_file(MENU_OPCOES_SCENE)
