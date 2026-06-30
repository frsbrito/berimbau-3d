extends Node2D

@export var touch_controls: Node

const COR_SOLTO   = Color(0.55, 0.55, 0.55, 0.55)
const COR_CHIADO  = Color(0.20, 0.55, 0.90, 0.60)
const COR_PRESO   = Color(0.85, 0.25, 0.15, 0.60)
const COR_BAQUETA = Color(0.90, 0.72, 0.10, 0.55)
const COR_BAQUETA_ATIVO = Color(1.00, 0.88, 0.20, 0.90)
const COR_BORDA   = Color(1.00, 1.00, 1.00, 0.45)
const COR_TEXTO   = Color(1.00, 1.00, 1.00, 1.00)
const COR_DOBRAO  = Color(0.95, 0.82, 0.30, 1.00)

const FONT_SIZE = 22

var _dobrao_pos: Vector2 = Vector2.ZERO
var _inicializado: bool = false

var _chiado_ativo: bool = false
var _preso_ativo: bool = false
var _baqueta_ativo: bool = false

func _process(delta):
	_chiado_ativo = Input.is_action_pressed("dobrao_chiado")
	_preso_ativo  = Input.is_action_pressed("dobrao_preso")
	_baqueta_ativo = Input.is_action_pressed("toque_baqueta")

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

func _get_rects(size: Vector2) -> Dictionary:
	var dlr  = touch_controls.dobrao_largura_ratio          if touch_controls else 0.45
	var dar  = touch_controls.dobrao_altura_ratio           if touch_controls else 0.30
	var blr  = touch_controls.baqueta_largura_ratio         if touch_controls else 0.35
	var bar  = touch_controls.baqueta_altura_ratio          if touch_controls else 0.25
	var dmi  = touch_controls.dobrao_margem_inferior_ratio   if touch_controls else 0.0
	var dme  = touch_controls.dobrao_margem_esquerda_ratio   if touch_controls else 0.0
	var bmi  = touch_controls.baqueta_margem_inferior_ratio  if touch_controls else 0.0
	var bmd  = touch_controls.baqueta_margem_direita_ratio   if touch_controls else 0.0
	return {
		"dobrao": Rect2(
			size.x * dme,
			size.y * (1.0 - dar) - size.y * dmi,
			size.x * dlr,
			size.y * dar
		),
		"baqueta": Rect2(
			size.x * (1.0 - blr) - size.x * bmd,
			size.y * (1.0 - bar) - size.y * bmi,
			size.x * blr,
			size.y * bar
		)
	}

func _desenhar_dobrao(rect: Rect2):
	var zone_w = rect.size.x / 3.0
	var zonas = [
		{"offset": 0.0,        "cor": COR_SOLTO,  "label": "SOLTO",  "ativo": not _chiado_ativo and not _preso_ativo},
		{"offset": zone_w,     "cor": COR_CHIADO, "label": "CHIADO", "ativo": _chiado_ativo},
		{"offset": zone_w * 2, "cor": COR_PRESO,  "label": "PRESO",  "ativo": _preso_ativo},
	]

	for zona in zonas:
		var zone_rect = Rect2(rect.position + Vector2(zona.offset, 0), Vector2(zone_w, rect.size.y))
		var cor = zona.cor
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
	draw_arc(_dobrao_pos, raio, 0, TAU, 40, Color(1, 1, 1, 0.5), 2.0)

func _desenhar_baqueta(rect: Rect2):
	var cor = COR_BAQUETA_ATIVO if _baqueta_ativo else COR_BAQUETA
	var center = rect.get_center()
	var raio = minf(rect.size.x, rect.size.y) * 0.42
	if _baqueta_ativo:
		raio *= 1.08

	# Glow externo quando ativo
	if _baqueta_ativo:
		draw_arc(center, raio + 10, 0, TAU, 48, Color(1.0, 0.88, 0.20, 0.25), 8.0)

	# Círculo interno mais escuro para dar profundidade
	draw_circle(center, raio, Color(cor.r * 0.5, cor.g * 0.5, cor.b * 0.5, cor.a))
	draw_circle(center, raio * 0.88, cor)

	# Bordas
	draw_arc(center, raio, 0, TAU, 48, COR_BORDA, 3.0)
	draw_arc(center, raio * 0.88, 0, TAU, 48, Color(1.0, 1.0, 1.0, 0.12), 1.5)

	var font = ThemeDB.fallback_font
	draw_string(font, Vector2(rect.position.x, center.y + FONT_SIZE * 0.45), "TOCAR", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, FONT_SIZE + 4, COR_TEXTO)
