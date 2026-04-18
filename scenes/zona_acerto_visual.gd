extends Node2D

@export var x_solto: float = 200.0
@export var x_chiado: float = 400.0
@export var x_preso: float = 600.0

@export var cor_linha: Color = Color("#C8860A")
@export var cor_solto: Color = Color("#4CAF50")
@export var cor_chiado: Color = Color("#2196F3")
@export var cor_preso: Color = Color("#F44336")

const LINHA_ESPESSURA = 4.0
const LINHA_MARGEM = 40.0
const CIRCULO_RAIO = 22.0
const CIRCULO_BORDA = 3.0

func _draw() -> void:
	var x_inicio = x_solto - LINHA_MARGEM
	var x_fim = x_preso + LINHA_MARGEM

	draw_line(Vector2(x_inicio, 0), Vector2(x_fim, 0), cor_linha, LINHA_ESPESSURA)

	_desenhar_circulo(Vector2(x_solto, 0), cor_solto)
	_desenhar_circulo(Vector2(x_chiado, 0), cor_chiado)
	_desenhar_circulo(Vector2(x_preso, 0), cor_preso)

func _desenhar_circulo(pos: Vector2, cor: Color) -> void:
	draw_circle(pos, CIRCULO_RAIO, cor)
	draw_arc(pos, CIRCULO_RAIO, 0, TAU, 48, cor_linha, CIRCULO_BORDA)
