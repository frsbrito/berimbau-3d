extends Node3D

const SOM_SOLTO = preload("res://assets/audio/som_solto.ogg")
const SOM_PRESO = preload("res://assets/audio/som_preso.ogg")
const SOM_CHIADO = preload("res://assets/audio/som_chiado.ogg")

@onready var sound_player = $SoundPlayer
@onready var debug_label = $CanvasLayer/DebugLabel

var nomes_dos_sons = ["", "Solto", "Chiado", "Preso"]

func _process(_delta):
	var estado_atual_id = 1
	if Input.is_action_pressed("dobrao_preso"):
		estado_atual_id = 3
	elif Input.is_action_pressed("dobrao_chiado"):
		estado_atual_id = 2
	
	debug_label.text = "Estado Pronto: " + nomes_dos_sons[estado_atual_id]
	
	if Input.is_action_just_pressed("toque_baqueta"):
		var som_a_tocar = SOM_SOLTO
		if estado_atual_id == 3:
			som_a_tocar = SOM_PRESO
		elif estado_atual_id == 2:
			som_a_tocar = SOM_CHIADO
		
		sound_player.stream = som_a_tocar
		sound_player.play()
