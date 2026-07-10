extends Control

const MENU_PRINCIPAL_SCENE = "res://scenes/menus/menu_principal.tscn"
const HISTORIA_SCENE = "res://scenes/menus/menu_historia.tscn"
const BERIMBAU_RODA_SCENE = "res://scenes/menus/menu_berimbau_roda.tscn"
const TIMBRES_SCENE = "res://scenes/menus/menu_timbres.tscn"
const TOQUES_REPIQUE_SCENE = "res://scenes/menus/menu_toques_repique.tscn"

func _on_btn_historia_pressed() -> void:
	get_tree().change_scene_to_file(HISTORIA_SCENE)

func _on_btn_berimbau_roda_pressed() -> void:
	get_tree().change_scene_to_file(BERIMBAU_RODA_SCENE)

func _on_btn_timbres_pressed() -> void:
	get_tree().change_scene_to_file(TIMBRES_SCENE)

func _on_btn_toques_repique_pressed() -> void:
	get_tree().change_scene_to_file(TOQUES_REPIQUE_SCENE)

func _on_btn_voltar_pressed() -> void:
	get_tree().change_scene_to_file(MENU_PRINCIPAL_SCENE)
