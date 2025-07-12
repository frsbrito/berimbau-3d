extends Node3D

# --- Constantes ---
const SOM_SOLTO = preload("res://assets/audio/som_solto.ogg")
const SOM_PRESO = preload("res://assets/audio/som_preso.ogg")
const SOM_CHIADO = preload("res://assets/audio/som_chiado.ogg")
const NOTA_SCENE = preload("res://scenes/nota.tscn")

# --- Referências de Nós (@onready) ---
@onready var sound_player = $SoundPlayer
#@onready var debug_label = $CanvasLayer/DebugLabel
@onready var hud = $CanvasLayer/HUD
@onready var pistas_container = $CanvasLayer/Pistas
@onready var pista_solto = $CanvasLayer/Pistas/Pista_Solto
@onready var pista_chiado = $CanvasLayer/Pistas/Pista_Chiado
@onready var pista_preso = $CanvasLayer/Pistas/Pista_Preso

# --- Variáveis do Jogo ---
var nomes_dos_sons = ["", "Solto", "Chiado", "Preso"]
var toque_de_angola = [2, 2, 1, 3]
var toque_index = 0
var notas_na_zona = []
var total_acertos = 0
var total_erros = 0
var total_notas_geradas = 0

# --- Funções do Jogo ---
func _process(_delta):
	# Lógica do estado do dobrão
	var estado_atual_id = 1
	if Input.is_action_pressed("dobrao_preso"):
		estado_atual_id = 3
	elif Input.is_action_pressed("dobrao_chiado"):
		estado_atual_id = 2
	
	# Chama atualização da interface para atualizar acertos e erros
	hud.atualizar_hud(total_acertos, total_erros)
	
	# Lógica do toque da baqueta
	if Input.is_action_just_pressed("toque_baqueta"):
		var nota_acertada = null
		for nota in notas_na_zona:
			if nota.tipo == estado_atual_id:
				nota_acertada = nota
				break 
		
		# Lógica de acerto e erro
		if nota_acertada != null:
			print("ACERTOU! (Tipo: ", nota_acertada.tipo, ")")
			total_acertos += 1
			notas_na_zona.erase(nota_acertada) 
			nota_acertada.queue_free()
		else:
			print("ERROU! (Nenhuma nota correspondente na zona)")
		
		# Lógica do som a tocar de acordo com input
		var som_a_tocar = SOM_SOLTO
		if estado_atual_id == 3:
			som_a_tocar = SOM_PRESO
		elif estado_atual_id == 2:
			som_a_tocar = SOM_CHIADO
		sound_player.stream = som_a_tocar
		sound_player.play()
	
# Função Timer que gera notas, qualifica e posiciona
func _on_timer_timeout():
	total_notas_geradas += 1
	
	var nova_nota = NOTA_SCENE.instantiate()
	var tipo_da_nota = toque_de_angola[toque_index]
	toque_index = (toque_index + 1) % toque_de_angola.size()
	
	if tipo_da_nota == 1:
		nova_nota.position = pista_solto.position
	elif tipo_da_nota == 2:
		nova_nota.position = pista_chiado.position
	else:
		nova_nota.position = pista_preso.position
	
	pistas_container.add_child(nova_nota)
	nova_nota.setup(tipo_da_nota)

func _on_zona_de_acerto_area_entered(area: Area2D) -> void:
	notas_na_zona.append(area)

func _on_zona_de_acerto_area_exited(area: Area2D) -> void:
	if notas_na_zona.has(area):
		total_erros += 1
		notas_na_zona.erase(area)
		area.queue_free()

func get_som_pelo_id(id):
	if id == 1:
		return SOM_SOLTO
	elif id == 2:
		return SOM_CHIADO
	else:
		return SOM_PRESO
