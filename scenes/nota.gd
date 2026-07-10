extends Area2D

@export var speed = 500.0
var tipo = 0
var _marcada = false
var _tween_janela: Tween

const SPRITE_SOLTO = preload("res://assets/sprites/notas/solto.png")
const SPRITE_CHIADO = preload("res://assets/sprites/notas/chiado.png")
const SPRITE_PRESO = preload("res://assets/sprites/notas/preso.png")

@onready var sprite = $Sprite2D

func _process(delta):
	position.y += speed * delta
	if position.y > get_viewport_rect().size.y + 100:
		queue_free()

func setup(tipo_da_nota, velocidade_queda := 0.0):
	if velocidade_queda > 0.0:
		speed = velocidade_queda
	match tipo_da_nota:
		GameData.TIPO_SOLTO:
			sprite.texture = SPRITE_SOLTO
		GameData.TIPO_CHIADO:
			sprite.texture = SPRITE_CHIADO
		GameData.TIPO_PRESO:
			sprite.texture = SPRITE_PRESO
	tipo = tipo_da_nota

# Pulso contínuo enquanto a nota está dentro da janela de tempo de acerto
func marcar_na_janela():
	if _marcada:
		return
	if _tween_janela:
		_tween_janela.kill()
	_tween_janela = create_tween()
	_tween_janela.set_loops(0)
	_tween_janela.tween_property(sprite, "modulate", Color(1.4, 1.4, 1.4), 0.15)
	_tween_janela.tween_property(sprite, "modulate", Color(1, 1, 1), 0.15)

func marcar_acerto():
	if _marcada:
		return
	_marcada = true
	if _tween_janela:
		_tween_janela.kill()
	set_process(false)
	var tween = create_tween()
	tween.tween_property(self, "scale", scale * 1.6, 0.12)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.12)
	tween.tween_callback(queue_free)

func marcar_erro():
	if _marcada:
		return
	_marcada = true
	if _tween_janela:
		_tween_janela.kill()
	sprite.modulate = Color(1.0, 0.35, 0.35)
	create_tween().tween_property(sprite, "modulate:a", 0.0, 0.4)
