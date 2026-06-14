extends Node3D

signal partida_encerrada(acertos: int, erros: int, total: int)

const LIMITE_NOTAS = 40

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
@onready var hud = $CanvasLayer/HUD
@onready var pistas_container = $CanvasLayer/Pistas
@onready var pista_solto = $CanvasLayer/Pistas/Pista_Solto
@onready var pista_chiado = $CanvasLayer/Pistas/Pista_Chiado
@onready var pista_preso = $CanvasLayer/Pistas/Pista_Preso
@onready var timer_gerador = $Timer
@onready var zona_collision = $CanvasLayer/ZonaDeAcerto/CollisionShape2D
@onready var touch_controls_node = get_node_or_null("TouchControls")

# --- Variáveis do Jogo ---
var toque_index = 0
var ciclo_atual: Array = []
var notas_na_zona = []
var total_acertos = 0
var total_erros = 0
var total_notas_geradas = 0
var notas_ativas = 0
var aguardando_fim = false
func _ready():
	ciclo_atual = GameData.get_toque_atual_array()
	partida_encerrada.connect(hud._on_partida_encerrada)
	_ajustar_layout()

func _ajustar_layout():
	var size     = get_viewport().get_visible_rect().size
	var tc           = touch_controls_node
	var dlr          = tc.dobrao_largura_ratio          if is_instance_valid(tc) else 0.45
	var dar          = tc.dobrao_altura_ratio           if is_instance_valid(tc) else 0.30
	var dme          = tc.dobrao_margem_esquerda_ratio  if is_instance_valid(tc) else 0.0
	var offset_y     = size.y * (tc.dobrao_margem_inferior_ratio if is_instance_valid(tc) else 0.0)

	var dobrao_x    = size.x * dme
	var dobrao_w    = size.x * dlr
	var dobrao_h    = size.y * dar
	var zone_w      = dobrao_w / 3.0
	var dobrao_topo = size.y * (1.0 - dar) - offset_y

	# Spawns das notas alinhados às colunas do dobrão, no topo da tela
	pista_solto.position  = Vector2(dobrao_x + zone_w * 0.5, 50.0)
	pista_chiado.position = Vector2(dobrao_x + zone_w * 1.5, 50.0)
	pista_preso.position  = Vector2(dobrao_x + zone_w * 2.5, 50.0)

	# CollisionShape cobre toda a área do dobrão
	zona_collision.scale    = Vector2(1, 1)
	zona_collision.position = Vector2(dobrao_x + dobrao_w / 2.0, dobrao_topo + dobrao_h / 2.0)
	(zona_collision.shape as RectangleShape2D).size = Vector2(dobrao_w, dobrao_h)

# --- Funções do Jogo ---
func _process(_delta):
	var estado_atual_id = GameData.TIPO_SOLTO
	if Input.is_action_pressed("dobrao_preso"):
		estado_atual_id = GameData.TIPO_PRESO
	elif Input.is_action_pressed("dobrao_chiado"):
		estado_atual_id = GameData.TIPO_CHIADO
	
	# Lógica do toque da baqueta
	if Input.is_action_just_pressed("toque_baqueta"):
		var nota_acertada = null
		for nota in notas_na_zona:
			if nota.tipo == estado_atual_id:
				nota_acertada = nota
				break 
		
		# Lógica de acerto e erro
		if nota_acertada != null:
			total_acertos += 1
			notas_ativas -= 1
			notas_na_zona.erase(nota_acertada)
			nota_acertada.queue_free()
			hud.atualizar_hud(total_acertos, total_erros)
			_verificar_fim_de_partida()
		
		# Lógica do som a tocar de acordo com input
		tocar_som_berimbau(estado_atual_id)
		
		
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
	match id:
		GameData.TIPO_PRESO:
			return lista_preso
		GameData.TIPO_CHIADO:
			return lista_chiado
		_:
			return lista_solto
	
# Função Timer que gera notas, qualifica e posiciona
func _on_timer_timeout():
	total_notas_geradas += 1

	if total_notas_geradas > LIMITE_NOTAS:
		timer_gerador.stop()
		aguardando_fim = true
		_verificar_fim_de_partida()
		return

	if toque_index == 0:
		ciclo_atual = _escolher_ciclo()

	var nota_data    = ciclo_atual[toque_index]
	var tipo_da_nota = nota_data[0]
	var intervalo    = nota_data[1] * GameData.velocidade_atual
	toque_index = (toque_index + 1) % ciclo_atual.size()

	notas_ativas += 1
	var nova_nota = NOTA_SCENE.instantiate()
	
	match tipo_da_nota:
		GameData.TIPO_SOLTO:
			nova_nota.position = pista_solto.position
		GameData.TIPO_CHIADO:
			nova_nota.position = pista_chiado.position
		GameData.TIPO_PRESO:
			nova_nota.position = pista_preso.position
	
	pistas_container.add_child(nova_nota)
	nova_nota.setup(tipo_da_nota)
	timer_gerador.start(intervalo)

func _escolher_ciclo() -> Array:
	var prob = GameData.get_probabilidade_repique()
	if prob > 0.0 and randf() < prob:
		var rep = GameData.get_repique_aleatorio()
		if not rep.is_empty():
			return rep
	return GameData.get_toque_atual_array()

func _on_zona_de_acerto_area_entered(area: Area2D) -> void:
	notas_na_zona.append(area)

func _verificar_fim_de_partida() -> void:
	if aguardando_fim and notas_ativas == 0:
		set_process(false)
		partida_encerrada.emit(total_acertos, total_erros, LIMITE_NOTAS)

func _on_zona_de_acerto_area_exited(area: Area2D) -> void:
	if notas_na_zona.has(area):
		total_erros += 1
		notas_ativas -= 1
		notas_na_zona.erase(area)
		area.queue_free()
		hud.atualizar_hud(total_acertos, total_erros)
		_verificar_fim_de_partida()
