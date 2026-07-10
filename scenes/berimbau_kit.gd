extends Node3D

# Ajuste no inspetor conforme orientação do modelo
@export var baqueta_rotacao_swing: Vector3 = Vector3(5.0, 5.0, -15.0)
@export var baqueta_duracao: float = 0.1
@export var dobrao_deslocamento_chiado: Vector3 = Vector3(0.0, 0.0, -0.17)
@export var dobrao_deslocamento_preso: Vector3 = Vector3(0.0, 0.0, -0.19)
@export var dobrao_duracao: float = 0.08

const COR_CONTORNO := Color(1.0, 0.85, 0.3, 1.0)
const CONTORNO_GROW := 0.015
const CONTORNO_JANELA_ATIVA := 0.25

@export var corda_raio: float = 0.015
@export var corda_cor: Color = Color(0.75, 0.75, 0.78)
@export var corda_vibracao_amplitude_graus: float = 0.7
@export var corda_vibracao_duracao: float = 0.15

@onready var baqueta = $Cylinder
@onready var dobrao = $Sphere_001
@onready var cabaca = $Cube_003
@onready var corda_topo: Marker3D = $CordaTopo
@onready var corda_cabaca: Marker3D = $CordaCabaca
@onready var corda_base: Marker3D = $CordaBase

var _baqueta_rot_original: Vector3
var _dobrao_pos_original: Vector3
var _dobrao_pressionado := false
var _dobrao_estado_preso := false
var _tempo_desde_interacao := 999.0
var _contorno_ativo := false
var _contorno_material: StandardMaterial3D
var _tween_contorno: Tween
var _tween_dobrao: Tween
var _tween_vibracao: Tween
var _corda_superior_container: Node3D

func _ready():
	_baqueta_rot_original = baqueta.rotation
	_dobrao_pos_original = dobrao.position
	_criar_contorno()
	_criar_corda()

func _process(delta):
	var preso_ativo = Input.is_action_pressed("dobrao_preso")
	var pressionado = preso_ativo or Input.is_action_pressed("dobrao_chiado")

	if pressionado and not _dobrao_pressionado:
		_dobrao_pressionado = true
		_dobrao_estado_preso = preso_ativo
		_pressionar_dobrao(preso_ativo)
	elif pressionado and _dobrao_pressionado and preso_ativo != _dobrao_estado_preso:
		_dobrao_estado_preso = preso_ativo
		_pressionar_dobrao(preso_ativo)
	elif not pressionado and _dobrao_pressionado:
		_dobrao_pressionado = false
		_soltar_dobrao()

	if Input.is_action_just_pressed("toque_baqueta"):
		_tocar_baqueta()

	if _contorno_ativo:
		_tempo_desde_interacao += delta
		if _tempo_desde_interacao > CONTORNO_JANELA_ATIVA:
			_contorno_ativo = false
			_esconder_contorno()

func _tocar_baqueta():
	var alvo = _baqueta_rot_original + Vector3(
		deg_to_rad(baqueta_rotacao_swing.x),
		deg_to_rad(baqueta_rotacao_swing.y),
		deg_to_rad(baqueta_rotacao_swing.z)
	)
	var tween = create_tween()
	tween.tween_property(baqueta, "rotation", alvo, baqueta_duracao)
	tween.tween_property(baqueta, "rotation", _baqueta_rot_original, baqueta_duracao * 1.5)
	_vibrar_corda()

func _pressionar_dobrao(preso: bool):
	if _tween_dobrao:
		_tween_dobrao.kill()
	var deslocamento = dobrao_deslocamento_preso if preso else dobrao_deslocamento_chiado
	_tween_dobrao = create_tween()
	_tween_dobrao.tween_property(dobrao, "position", _dobrao_pos_original + deslocamento, dobrao_duracao)

func _soltar_dobrao():
	if _tween_dobrao:
		_tween_dobrao.kill()
	_tween_dobrao = create_tween()
	_tween_dobrao.tween_property(dobrao, "position", _dobrao_pos_original, dobrao_duracao)

# --- Contorno de seleção (técnica de casco invertido) ---
func _criar_contorno() -> void:
	_contorno_material = StandardMaterial3D.new()
	_contorno_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_contorno_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_contorno_material.albedo_color = Color(COR_CONTORNO.r, COR_CONTORNO.g, COR_CONTORNO.b, 0.0)
	_contorno_material.cull_mode = BaseMaterial3D.CULL_FRONT
	_contorno_material.grow = true
	_contorno_material.grow_amount = CONTORNO_GROW

	for mesh_instance in [baqueta, dobrao, cabaca]:
		var contorno = MeshInstance3D.new()
		contorno.mesh = mesh_instance.mesh
		contorno.material_override = _contorno_material
		mesh_instance.add_child(contorno)

# --- Corda/arame (verga -> cabaça -> verga) ---
func _criar_corda() -> void:
	var topo = corda_topo.position
	var ponto_cabaca = corda_cabaca.position
	var base = corda_base.position

	# Trecho de cima (vibra ao tocar): agrupado num container próprio,
	# pivotado no seu próprio centro, pra vibração não afetar o trecho de baixo.
	var centro_superior = (topo + ponto_cabaca) / 2.0
	_corda_superior_container = Node3D.new()
	_corda_superior_container.position = centro_superior
	add_child(_corda_superior_container)
	_criar_segmento_corda(topo - centro_superior, ponto_cabaca - centro_superior, _corda_superior_container)

	# Trecho de baixo (imóvel): direto na cena, sem container animável.
	_criar_segmento_corda(ponto_cabaca, base, self)

func _criar_segmento_corda(a: Vector3, b: Vector3, pai: Node3D) -> void:
	var direcao = b - a
	var comprimento = direcao.length()
	if comprimento < 0.001:
		return

	var mesh = CylinderMesh.new()
	mesh.top_radius = corda_raio
	mesh.bottom_radius = corda_raio
	mesh.height = comprimento

	var material = StandardMaterial3D.new()
	material.albedo_color = corda_cor
	material.metallic = 0.6
	material.roughness = 0.35
	mesh.material = material

	var segmento = MeshInstance3D.new()
	segmento.mesh = mesh

	var y_axis = direcao.normalized()
	var referencia = Vector3.RIGHT if absf(y_axis.dot(Vector3.RIGHT)) < 0.9 else Vector3.FORWARD
	var x_axis = referencia.cross(y_axis).normalized()
	var z_axis = x_axis.cross(y_axis).normalized()
	segmento.transform = Transform3D(Basis(x_axis, y_axis, z_axis), (a + b) / 2.0)

	pai.add_child(segmento)

func _vibrar_corda() -> void:
	if _tween_vibracao:
		_tween_vibracao.kill()
	_corda_superior_container.rotation = Vector3.ZERO

	var amplitude = deg_to_rad(corda_vibracao_amplitude_graus)
	var passos = 6
	_tween_vibracao = create_tween()
	for i in range(passos):
		var fator = 1.0 - float(i + 1) / passos
		var sinal = -1.0 if i % 2 == 0 else 1.0
		var alvo = Vector3(amplitude * sinal * fator, 0.0, amplitude * 0.6 * sinal * fator)
		_tween_vibracao.tween_property(_corda_superior_container, "rotation", alvo, corda_vibracao_duracao / passos)
	_tween_vibracao.tween_property(_corda_superior_container, "rotation", Vector3.ZERO, corda_vibracao_duracao / passos)

func _on_camera_interagida() -> void:
	_tempo_desde_interacao = 0.0
	if not _contorno_ativo:
		_contorno_ativo = true
		_mostrar_contorno()

func _mostrar_contorno() -> void:
	if _tween_contorno:
		_tween_contorno.kill()
	_tween_contorno = create_tween()
	_tween_contorno.tween_property(_contorno_material, "albedo_color:a", 1.0, 0.15)

func _esconder_contorno() -> void:
	if _tween_contorno:
		_tween_contorno.kill()
	_tween_contorno = create_tween()
	_tween_contorno.tween_property(_contorno_material, "albedo_color:a", 0.0, 0.5)
