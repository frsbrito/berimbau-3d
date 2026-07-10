extends Control

const MENU_PRINCIPAL_SCENE = "res://scenes/menus/menu_principal.tscn"

func _on_btn_voltar_pressed() -> void:
	get_tree().change_scene_to_file(MENU_PRINCIPAL_SCENE)
