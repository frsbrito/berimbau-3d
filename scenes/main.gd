extends Node3D

# --- Constantes ---
var sons_viola_solto = [
	preload("res://assets/audio/berimbau-viola/solto/viola_solto_2.ogg"),
	preload("res://assets/audio/berimbau-viola/solto/viola_solto_3.ogg"),
	preload("res://assets/audio/berimbau-viola/solto/viola_solto_4.ogg"),
	preload("res://assets/audio/berimbau-viola/solto/viola_solto_5.ogg")
]
var sons_viola_chiado = [
	preload("res://assets/audio/berimbau-viola/chiado/viola_chiado_2.ogg"),
	preload("res://assets/audio/berimbau-viola/chiado/viola_chiado_3.ogg"),
	preload("res://assets/audio/berimbau-viola/chiado/viola_chiado_4.ogg")
]
var sons_viola_preso = [
	preload("res://assets/audio/berimbau-viola/preso/viola_preso_1.ogg"),
	preload("res://assets/audio/berimbau-viola/preso/viola_preso_2.ogg"),
	preload("res://assets/audio/berimbau-viola/preso/viola_preso_3.ogg")
]
var sons_medio_solto = [
	preload("res://assets/audio/berimbau-medio/solto/medio_solto_1.ogg"),
	preload("res://assets/audio/berimbau-medio/solto/medio_solto_2.ogg"),
]
var sons_medio_chiado = [
	preload("res://assets/audio/berimbau-medio/chiado/medio_chiado_1.ogg"),
	preload("res://assets/audio/berimbau-medio/chiado/medio_chiado_2.ogg"),
	preload("res://assets/audio/berimbau-medio/chiado/medio_chiado_3.ogg"),
	preload("res://assets/audio/berimbau-medio/chiado/medio_chiado_4.ogg"),
	preload("res://assets/audio/berimbau-medio/chiado/medio_chiado_5.ogg")
]
var sons_medio_preso = [
	preload("res://assets/audio/berimbau-medio/preso/medio_preso_1.ogg"),
	preload("res://assets/audio/berimbau-medio/preso/medio_preso_2.ogg"),
	preload("res://assets/audio/berimbau-medio/preso/medio_preso_3.ogg"),
	preload("res://assets/audio/berimbau-medio/preso/medio_preso_4.ogg"),
	preload("res://assets/audio/berimbau-medio/preso/medio_preso_5.ogg")
]
var sons_gunga_solto = [
	preload("res://assets/audio/berimbau-gunga/solto/gunga_solto_1.ogg")
]
var sons_gunga_chiado = [
	preload("res://assets/audio/berimbau-gunga/chiado/gunga_chiado_1.ogg"),
	preload("res://assets/audio/berimbau-gunga/chiado/gunga_chiado_2.ogg"),
	preload("res://assets/audio/berimbau-gunga/chiado/gunga_chiado_3.ogg"),
	preload("res://assets/audio/berimbau-gunga/chiado/gunga_chiado_4.ogg")
]
var sons_gunga_preso = [
	preload("res://assets/audio/berimbau-gunga/preso/gunga_preso_1.ogg"),
	preload("res://assets/audio/berimbau-gunga/preso/gunga_preso_2.ogg"),
]
const NOTA_SCENE = preload("res://scenes/nota.tscn")

# --- Referências de Nós (@onready) ---
@onready var sound_player = $SoundPlayer
#@onready var debug_label = $CanvasLayer/DebugLabel
@onready var hud = $CanvasLayer/HUD
@onready var pistas_container = $CanvasLayer/Pistas
@onready var pista_solto = $CanvasLayer/Pistas/Pista_Solto
@onready var pista_chiado = $CanvasLayer/Pistas/Pista_Chiado
@onready var pista_preso = $CanvasLayer/Pistas/Pista_Preso
@onready var timer_gerador = $Timer

# --- Variáveis do Jogo ---
var toque_index = 0
var notas_na_zona = []
var total_acertos = 0
var total_erros = 0
var total_notas_geradas = 0
var toque_atual_array = []

func _ready():
	toque_atual_array = GameData.get_toque_atual_array()

# --- Funções do Jogo ---
func _process(_delta):
	# Identifica o estado atual (1=Solto, 2=Chiado, 3=Preso)
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
			print("ERROU!")
		
		# Lógica do som a tocar de acordo com input
		tocar_som_berimbau(estado_atual_id)
		
	# Lógica da seleção de velocidade das notas
	if timer_gerador.wait_time != GameData.velocidade_atual:
		timer_gerador.wait_time = GameData.velocidade_atual
		
func tocar_som_berimbau(id_estado):
	var lista_de_sons = []
	var instrumento = GameData.berimbau_atual
	
	match instrumento:
		GameData.BERIMBAU_VIOLA:
			lista_de_sons = selecionar_lista_por_tipo(id_estado, sons_viola_solto, sons_viola_chiado, sons_viola_preso)
			
		GameData.BERIMBAU_MEDIO:
			lista_de_sons = selecionar_lista_por_tipo(id_estado, sons_medio_solto, sons_medio_chiado, sons_medio_preso)
			
		GameData.BERIMBAU_GUNGA:
			lista_de_sons = selecionar_lista_por_tipo(id_estado, sons_gunga_solto, sons_gunga_chiado, sons_gunga_preso)

	if lista_de_sons.size() > 0:
		sound_player.stream = lista_de_sons.pick_random()
		sound_player.pitch_scale = randf_range(0.99, 1.01)
		sound_player.play()
	
func selecionar_lista_por_tipo(id, lista_solto, lista_chiado, lista_preso):
	if id == 3:
		return lista_preso
	elif id == 2:
		return lista_chiado
	else:
		return lista_solto
	
# Função Timer que gera notas, qualifica e posiciona
func _on_timer_timeout():
	total_notas_geradas += 1
	
	var array_do_toque = GameData.get_toque_atual_array()
	
	if toque_index >= array_do_toque.size():
		toque_index = 0
		
	var tipo_da_nota = array_do_toque[toque_index]
	toque_index = (toque_index + 1) % array_do_toque.size()
	
	var nova_nota = NOTA_SCENE.instantiate()
	
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
