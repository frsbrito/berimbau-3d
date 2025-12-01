extends Area2D

@export var speed = 300.0
var tipo = 0

const SPRITE_SOLTO = preload("res://assets/sprites/nota_solto.png")
const SPRITE_CHIADO = preload("res://assets/sprites/nota_chiado.png")
const SPRITE_PRESO = preload("res://assets/sprites/nota_preso.png")

@onready var sprite = $Sprite2D

func _process(delta):
	position.y += speed * delta

func setup(tipo_da_nota):
	if tipo_da_nota == 1:
		sprite.texture = SPRITE_SOLTO
	elif tipo_da_nota == 2:
		sprite.texture = SPRITE_CHIADO
	else:
		sprite.texture = SPRITE_PRESO
	tipo = tipo_da_nota
