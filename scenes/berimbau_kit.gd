extends Node3D

# Ajuste no inspetor conforme orientação do modelo
@export var baqueta_rotacao_swing: Vector3 = Vector3(-30.0, 0.0, 0.0)
@export var baqueta_duracao: float = 0.1
@export var dobrao_deslocamento: Vector3 = Vector3(0.0, 0.0, 0.1)
@export var dobrao_duracao: float = 0.08

@onready var baqueta = $Cylinder
@onready var dobrao = $Sphere_001

var _baqueta_rot_original: Vector3
var _dobrao_pos_original: Vector3
var _dobrao_pressionado := false

func _ready():
	_baqueta_rot_original = baqueta.rotation
	_dobrao_pos_original = dobrao.position

func _process(_delta):
	var pressionado = Input.is_action_pressed("dobrao_preso") or Input.is_action_pressed("dobrao_chiado")

	if pressionado and not _dobrao_pressionado:
		_dobrao_pressionado = true
		_pressionar_dobrao()
	elif not pressionado and _dobrao_pressionado:
		_dobrao_pressionado = false
		_soltar_dobrao()

	if Input.is_action_just_pressed("toque_baqueta"):
		_tocar_baqueta()

func _tocar_baqueta():
	var alvo = _baqueta_rot_original + Vector3(
		deg_to_rad(baqueta_rotacao_swing.x),
		deg_to_rad(baqueta_rotacao_swing.y),
		deg_to_rad(baqueta_rotacao_swing.z)
	)
	var tween = create_tween()
	tween.tween_property(baqueta, "rotation", alvo, baqueta_duracao)
	tween.tween_property(baqueta, "rotation", _baqueta_rot_original, baqueta_duracao * 1.5)

func _pressionar_dobrao():
	var tween = create_tween()
	tween.tween_property(dobrao, "position", _dobrao_pos_original + dobrao_deslocamento, dobrao_duracao)

func _soltar_dobrao():
	var tween = create_tween()
	tween.tween_property(dobrao, "position", _dobrao_pos_original, dobrao_duracao)
