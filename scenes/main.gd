extends Node3D

signal partida_encerrada(acertos: int, erros: int, total: int)

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

# Duração (segundos) que a nota leva para cair até a zona de acerto quando
# GameData.velocidade_atual == 1.0 (Equilibrado). Multiplicada pelo mesmo
# fator usado no intervalo das notas, para a queda visual continuar coerente
# com o ritmo escolhido (ver _on_timer_timeout).
const QUEDA_DURACAO_BASE = 1.6

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
@onready var lane_solto_visual  = $CanvasLayer/Lane_Solto
@onready var lane_chiado_visual = $CanvasLayer/Lane_Chiado
@onready var lane_preso_visual  = $CanvasLayer/Lane_Preso
@onready var hit_zone_visual    = $CanvasLayer/HitZone_Visual
@onready var julgamento_label   = $CanvasLayer/JulgamentoLabel
@onready var repique_label      = $CanvasLayer/RepiqueLabel
@onready var limite_flash_visual = $CanvasLayer/LimiteFlash
@onready var berimbau_kit        = $BerimbauKit

# --- Feedback visual ---
const COR_BASE_ZONA = Color(0.98, 0.85, 0.35, 0.85)
const COR_ACERTO    = Color(0.3, 0.95, 0.4, 0.9)
const COR_ERRO      = Color(0.95, 0.25, 0.25, 0.9)

const COR_LIMITE = Color(1.0, 1.0, 1.0, 0.16)

var _tween_zona: Tween
var _tween_julgamento: Tween
var _tween_repique: Tween
var _tween_limite: Tween
var _tweens_trilha: Dictionary = {}
var _julgamento_pos_y_base = 0.0

# --- Variáveis do Jogo ---
var toque_index = 0
var ciclo_atual: Array = []
var _ultimo_ciclo_foi_repique: bool = false
var notas_na_zona = []
var total_acertos = 0
var total_erros = 0
var total_notas_geradas = 0
var notas_ativas = 0
var aguardando_fim = false
var limite_notas = 40

func _ready():
	limite_notas = GameData.limite_notas_atual
	ciclo_atual = GameData.get_toque_atual_array()
	partida_encerrada.connect(hud._on_partida_encerrada)
	hud.finalizar_pressed.connect(finalizar_partida_manualmente)
	if is_instance_valid(touch_controls_node):
		touch_controls_node.limite_atingido.connect(_flash_limite)
		touch_controls_node.camera_interagida.connect(berimbau_kit._on_camera_interagida)
	if GameData.pratica_livre_ativa:
		timer_gerador.stop()
	_ajustar_layout()

func _ajustar_layout():
	var size = get_viewport().get_visible_rect().size
	var tc   = touch_controls_node

	# A área do dobrão é calculada uma única vez em touch_controls.gd (_get_regioes)
	# pra não haver risco de dessincronia com a zona de toque real.
	var dobrao_rect: Rect2
	if is_instance_valid(tc):
		dobrao_rect = tc._get_regioes().dobrao
	else:
		dobrao_rect = Rect2(0, size.y * 0.7, size.x * 0.45, size.y * 0.30)

	var dobrao_x    = dobrao_rect.position.x
	var dobrao_w    = dobrao_rect.size.x
	var dobrao_h    = dobrao_rect.size.y
	var zone_w      = dobrao_w / 3.0
	var dobrao_topo = dobrao_rect.position.y

	# Spawns das notas alinhados às colunas do dobrão, no topo da tela
	pista_solto.position  = Vector2(dobrao_x + zone_w * 0.5, -50.0)
	pista_chiado.position = Vector2(dobrao_x + zone_w * 1.5, -50.0)
	pista_preso.position  = Vector2(dobrao_x + zone_w * 2.5, -50.0)

	# CollisionShape cobre toda a área do dobrão
	zona_collision.scale    = Vector2(1, 1)
	zona_collision.position = Vector2(dobrao_x + dobrao_w / 2.0, dobrao_topo + dobrao_h / 2.0)
	(zona_collision.shape as RectangleShape2D).size = Vector2(dobrao_w, dobrao_h)

	# Trilhas visuais
	lane_solto_visual.position  = Vector2(dobrao_x, 0)
	lane_solto_visual.size      = Vector2(zone_w, dobrao_topo)
	lane_chiado_visual.position = Vector2(dobrao_x + zone_w, 0)
	lane_chiado_visual.size     = Vector2(zone_w, dobrao_topo)
	lane_preso_visual.position  = Vector2(dobrao_x + zone_w * 2, 0)
	lane_preso_visual.size      = Vector2(zone_w, dobrao_topo)
	hit_zone_visual.position    = Vector2(dobrao_x, dobrao_topo - 3)
	hit_zone_visual.size        = Vector2(dobrao_w, 5)

	julgamento_label.position = Vector2(0, size.y * 0.14)
	julgamento_label.size     = Vector2(size.x, 40.0)
	_julgamento_pos_y_base    = julgamento_label.position.y

	repique_label.position = Vector2(0, size.y * 0.04)
	repique_label.size     = Vector2(size.x, 50.0)

# --- Funções do Jogo ---
func _process(_delta):
	var estado_atual_id = GameData.TIPO_SOLTO
	if Input.is_action_pressed("dobrao_preso"):
		estado_atual_id = GameData.TIPO_PRESO
	elif Input.is_action_pressed("dobrao_chiado"):
		estado_atual_id = GameData.TIPO_CHIADO
	
	# Lógica do toque da baqueta
	if Input.is_action_just_pressed("toque_baqueta"):
		if GameData.pratica_livre_ativa:
			tocar_som_berimbau(estado_atual_id)
			return

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
			nota_acertada.marcar_acerto()
			hud.atualizar_hud(total_acertos, total_erros)
			_flash_zona(COR_ACERTO)
			_flash_trilha(nota_acertada.tipo, COR_ACERTO)
			_mostrar_julgamento("Acerto!", COR_ACERTO)
			_verificar_fim_de_partida()
		else:
			_flash_zona(COR_ERRO)
			_flash_trilha(estado_atual_id, COR_ERRO)
			_mostrar_julgamento("Errou", COR_ERRO)

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

	if not GameData.modo_livre_ativo() and total_notas_geradas > limite_notas:
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

	var distancia_queda = zona_collision.position.y - nova_nota.position.y
	var duracao_queda   = QUEDA_DURACAO_BASE * GameData.velocidade_atual
	var velocidade_queda = distancia_queda / duracao_queda

	pistas_container.add_child(nova_nota)
	nova_nota.setup(tipo_da_nota, velocidade_queda)
	timer_gerador.start(intervalo)

func _escolher_ciclo() -> Array:
	# Um repique nunca pode vir logo depois de outro: o ciclo seguinte a um
	# repique é sempre o toque base, para não perder a sonoridade do toque.
	if _ultimo_ciclo_foi_repique:
		_ultimo_ciclo_foi_repique = false
		return GameData.get_toque_atual_array()

	var prob = GameData.get_probabilidade_repique()
	if prob > 0.0 and randf() < prob:
		var rep = GameData.get_repique_aleatorio()
		if not rep.is_empty():
			_ultimo_ciclo_foi_repique = true
			_mostrar_banner_repique()
			return rep
	return GameData.get_toque_atual_array()

func _on_zona_de_acerto_area_entered(area: Area2D) -> void:
	notas_na_zona.append(area)
	if area.has_method("marcar_na_janela"):
		area.marcar_na_janela()

func _verificar_fim_de_partida() -> void:
	if aguardando_fim and notas_ativas == 0:
		set_process(false)
		var total_para_pontuacao = total_notas_geradas if GameData.modo_livre_ativo() else limite_notas
		partida_encerrada.emit(total_acertos, total_erros, total_para_pontuacao)

# Chamado pelo botão "Finalizar" da HUD (só visível no modo livre): para a
# partida imediatamente, descartando sem punição qualquer nota ainda em
# queda (não conta como acerto nem erro), e mostra o placar na hora.
func finalizar_partida_manualmente() -> void:
	if aguardando_fim:
		return
	timer_gerador.stop()
	for nota in pistas_container.get_children():
		nota.queue_free()
	notas_na_zona.clear()
	notas_ativas = 0
	aguardando_fim = true
	_verificar_fim_de_partida()

func _on_zona_de_acerto_area_exited(area: Area2D) -> void:
	if notas_na_zona.has(area):
		total_erros += 1
		notas_ativas -= 1
		notas_na_zona.erase(area)
		if area.has_method("marcar_erro"):
			area.marcar_erro()
		_flash_zona(COR_ERRO)
		_flash_trilha(area.tipo, COR_ERRO)
		_mostrar_julgamento("Errou", COR_ERRO)
		hud.atualizar_hud(total_acertos, total_erros)
		_verificar_fim_de_partida()

# --- Feedback visual ---
func _flash_zona(cor: Color) -> void:
	if _tween_zona:
		_tween_zona.kill()
	hit_zone_visual.color = cor
	_tween_zona = create_tween()
	_tween_zona.tween_property(hit_zone_visual, "color", COR_BASE_ZONA, 0.25)

func _trilha_visual_por_tipo(tipo) -> ColorRect:
	match tipo:
		GameData.TIPO_CHIADO:
			return lane_chiado_visual
		GameData.TIPO_PRESO:
			return lane_preso_visual
		_:
			return lane_solto_visual

func _cor_base_trilha_por_tipo(tipo) -> Color:
	var base = GameData.cor_por_tipo(tipo)
	var alpha = 0.15 if tipo == GameData.TIPO_SOLTO else 0.18
	return Color(base.r, base.g, base.b, alpha)

func _flash_trilha(tipo, cor: Color) -> void:
	var trilha = _trilha_visual_por_tipo(tipo)
	var cor_base = _cor_base_trilha_por_tipo(tipo)
	if _tweens_trilha.has(tipo) and _tweens_trilha[tipo]:
		_tweens_trilha[tipo].kill()
	trilha.color = Color(cor.r, cor.g, cor.b, 0.55)
	var tween = create_tween()
	tween.tween_property(trilha, "color", cor_base, 0.35)
	_tweens_trilha[tipo] = tween

func _mostrar_julgamento(texto: String, cor: Color) -> void:
	if _tween_julgamento:
		_tween_julgamento.kill()
	julgamento_label.text = texto
	julgamento_label.modulate = Color(cor.r, cor.g, cor.b, 1.0)
	julgamento_label.position.y = _julgamento_pos_y_base
	julgamento_label.visible = true
	_tween_julgamento = create_tween()
	_tween_julgamento.tween_property(julgamento_label, "position:y", _julgamento_pos_y_base - 30.0, 0.4)
	_tween_julgamento.parallel().tween_property(julgamento_label, "modulate:a", 0.0, 0.4)
	_tween_julgamento.tween_callback(func(): julgamento_label.visible = false)

func _flash_limite() -> void:
	if _tween_limite:
		_tween_limite.kill()
	limite_flash_visual.color = COR_LIMITE
	_tween_limite = create_tween()
	_tween_limite.tween_property(limite_flash_visual, "color:a", 0.0, 0.25)

func _mostrar_banner_repique() -> void:
	if _tween_repique:
		_tween_repique.kill()
	repique_label.modulate.a = 1.0
	repique_label.visible = true
	_tween_repique = create_tween()
	_tween_repique.tween_interval(0.8)
	_tween_repique.tween_property(repique_label, "modulate:a", 0.0, 0.5)
	_tween_repique.tween_callback(func(): repique_label.visible = false)
