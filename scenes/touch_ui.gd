extends Node2D

@export var touch_controls: Node

const COR_BAQUETA = Color(1.00, 1.00, 1.00, 0.55)
const COR_BAQUETA_ATIVO = Color(1.00, 1.00, 1.00, 0.90)
const COR_BORDA   = Color(1.00, 1.00, 1.00, 0.45)
const COR_TEXTO   = Color(1.00, 1.00, 1.00, 1.00)
const COR_TEXTO_ESCURO = Color(0.05, 0.05, 0.05, 1.00)
const COR_DOBRAO  = Color(1.00, 1.00, 1.00, 1.00)

const FONT_SIZE = 22
const FONT_SIZE_DOBRAO = 12

var _dobrao_pos: Vector2 = Vector2.ZERO
var _inicializado: bool = false

var _chiado_ativo: bool = false
var _preso_ativo: bool = false
var _baqueta_ativo: bool = false

const ZOOM_JANELA_VISIVEL = 0.35
var _zoom_fracao: float = 0.5
var _zoom_tempo_restante: float = 0.0

func _ready():
	if touch_controls:
		touch_controls.zoom_alterado.connect(_on_zoom_alterado)

func _on_zoom_alterado(fracao: float):
	_zoom_fracao = fracao
	_zoom_tempo_restante = ZOOM_JANELA_VISIVEL

func _process(delta):
	_chiado_ativo = Input.is_action_pressed("dobrao_chiado")
	_preso_ativo  = Input.is_action_pressed("dobrao_preso")
	_baqueta_ativo = Input.is_action_pressed("toque_baqueta")

	if _zoom_tempo_restante > 0.0:
		_zoom_tempo_restante -= delta

	var size = get_viewport().get_visible_rect().size
	var rects = _get_rects(size)
	var zone_w = rects.dobrao.size.x / 3.0
	var center_y = rects.dobrao.position.y + rects.dobrao.size.y / 2.0

	var target_x: float
	if _preso_ativo:
		target_x = rects.dobrao.position.x + zone_w * 2.5
	elif _chiado_ativo:
		target_x = rects.dobrao.position.x + zone_w * 1.5
	else:
		target_x = rects.dobrao.position.x + zone_w * 0.5

	var target = Vector2(target_x, center_y)
	if not _inicializado:
		_dobrao_pos = target
		_inicializado = true
	else:
		_dobrao_pos = _dobrao_pos.lerp(target, delta * 14.0)

	queue_redraw()

func _draw():
	var size = get_viewport().get_visible_rect().size
	var rects = _get_rects(size)
	_desenhar_dobrao(rects.dobrao)
	_desenhar_baqueta(rects.baqueta)
	_desenhar_zoom_indicador(size)

func _get_rects(size: Vector2) -> Dictionary:
	if touch_controls:
		return touch_controls._get_regioes()
	return {
		"dobrao": Rect2(0, size.y * 0.7, size.x * 0.45, size.y * 0.30),
		"baqueta": Rect2(size.x * 0.6, size.y * 0.75, size.x * 0.35, size.y * 0.25)
	}

func _desenhar_dobrao(rect: Rect2):
	var zone_w = rect.size.x / 3.0
	var zonas = [
		{"offset": 0.0,        "tipo": GameData.TIPO_SOLTO,  "alpha": 0.55, "label": "SOLTO",  "ativo": not _chiado_ativo and not _preso_ativo},
		{"offset": zone_w,     "tipo": GameData.TIPO_CHIADO, "alpha": 0.60, "label": "CHIADO", "ativo": _chiado_ativo},
		{"offset": zone_w * 2, "tipo": GameData.TIPO_PRESO,  "alpha": 0.60, "label": "PRESO",  "ativo": _preso_ativo},
	]

	for zona in zonas:
		var zone_rect = Rect2(rect.position + Vector2(zona.offset, 0), Vector2(zone_w, rect.size.y))
		var base = GameData.cor_por_tipo(zona.tipo)
		var cor = Color(base.r, base.g, base.b, zona.alpha)
		if zona.ativo:
			cor = Color(cor.r + 0.15, cor.g + 0.15, cor.b + 0.15, minf(cor.a + 0.25, 1.0))
		draw_rect(zone_rect, cor)
		draw_rect(zone_rect, COR_BORDA, false, 2.5)

		var font = ThemeDB.fallback_font
		var label_pos = Vector2(zone_rect.position.x, zone_rect.position.y + FONT_SIZE + 6)
		draw_string(font, label_pos, zona.label, HORIZONTAL_ALIGNMENT_CENTER, zone_w, FONT_SIZE, COR_TEXTO)

	# Círculo do dobrão (a "moeda")
	var raio = minf(rect.size.y * 0.28, zone_w * 0.38)
	draw_circle(_dobrao_pos, raio, COR_DOBRAO)
	draw_arc(_dobrao_pos, raio, 0, TAU, 40, Color(0, 0, 0, 0.35), 2.0)

	var font = ThemeDB.fallback_font
	var label_pos = Vector2(_dobrao_pos.x - raio, _dobrao_pos.y + FONT_SIZE_DOBRAO * 0.35)
	draw_string(font, label_pos, "Dobrão", HORIZONTAL_ALIGNMENT_CENTER, raio * 2.0, FONT_SIZE_DOBRAO, COR_TEXTO_ESCURO)

func _desenhar_baqueta(rect: Rect2):
	var cor = COR_BAQUETA_ATIVO if _baqueta_ativo else COR_BAQUETA
	var center = rect.get_center()
	var raio_ratio = touch_controls.baqueta_raio_ratio if touch_controls else 0.42
	var raio = minf(rect.size.x, rect.size.y) * raio_ratio
	if _baqueta_ativo:
		raio *= 1.08

	# Glow externo quando ativo
	if _baqueta_ativo:
		draw_arc(center, raio + 10, 0, TAU, 48, Color(1.0, 1.0, 1.0, 0.25), 8.0)

	# Círculo interno mais escuro para dar profundidade
	draw_circle(center, raio, Color(cor.r * 0.5, cor.g * 0.5, cor.b * 0.5, cor.a))
	draw_circle(center, raio * 0.88, cor)

	# Bordas
	draw_arc(center, raio, 0, TAU, 48, COR_BORDA, 3.0)
	draw_arc(center, raio * 0.88, 0, TAU, 48, Color(1.0, 1.0, 1.0, 0.12), 1.5)

	var font = ThemeDB.fallback_font
	draw_string(font, Vector2(rect.position.x, center.y + FONT_SIZE * 0.45), "BAQUETA", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, FONT_SIZE + 4, COR_TEXTO_ESCURO)

func _desenhar_zoom_indicador(size: Vector2):
	if _zoom_tempo_restante <= 0.0:
		return
	var alpha = clampf(_zoom_tempo_restante / ZOOM_JANELA_VISIVEL, 0.0, 1.0)
	var largura = 18.0
	var x = size.x * 0.93
	var topo = size.y * 0.22
	var base = size.y * 0.42
	var altura = base - topo
	var preenchido = altura * _zoom_fracao

	draw_rect(Rect2(x, topo, largura, altura), Color(1, 1, 1, 0.18 * alpha))
	draw_rect(Rect2(x, base - preenchido, largura, preenchido), Color(0.95, 0.82, 0.30, 0.85 * alpha))
	draw_rect(Rect2(x, topo, largura, altura), Color(COR_BORDA.r, COR_BORDA.g, COR_BORDA.b, COR_BORDA.a * alpha), false, 2.0)
