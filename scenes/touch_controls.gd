extends Node

signal camera_interagida()
signal limite_atingido()
signal zoom_alterado(fracao: float)

@export var camera: Camera3D
@export var pivot: Vector3 = Vector3.ZERO
@export var orbit_sensitivity: float = 0.5
@export var zoom_sensitivity: float = 0.02
@export var zoom_scroll_step: float = 1.0
@export var zoom_min: float = 3.0
@export var zoom_max: float = 30.0

# Tamanho das zonas de controle (fração da tela)
@export var dobrao_largura_ratio: float = 0.3
@export var dobrao_altura_ratio: float = 0.2
@export var dobrao_margem_inferior_ratio: float = 0.25
@export var dobrao_margem_esquerda_ratio: float = 0.05
@export var baqueta_largura_ratio: float = 0.40
@export var baqueta_altura_ratio: float = 0.40
@export var baqueta_margem_inferior_ratio: float = 0.15
@export var baqueta_margem_direita_ratio: float = -0.04
@export var baqueta_raio_ratio: float = 0.42

# Alvo de toque mínimo (~48dp, recomendação de acessibilidade) convertido para
# pixels via DPI real do dispositivo, com piso para telas desktop de baixo DPI.
const ALVO_TOQUE_MINIMO_DP: float = 48.0

func _alvo_toque_minimo_px() -> float:
	var dpi = DisplayServer.screen_get_dpi()
	if dpi <= 0:
		dpi = 160
	return maxf(ALVO_TOQUE_MINIMO_DP * dpi / 160.0, 88.0)

var _yaw: float = 0.0
var _pitch: float = 0.0
var _distance: float = 15.0

# Toque de câmera e pinça
var _camera_touch_index: int = -1
var _pinch_touch_index: int = -1
var _pinch_last_distance: float = -1.0
var _touch_positions: Dictionary = {}

var _dobrao_touch_index: int = -1
var _baqueta_touch_index: int = -1
var _mouse_in_camera_region: bool = false

func _ready():
	if camera:
		_init_orbit_from_camera()

func _init_orbit_from_camera():
	var pos = camera.position - pivot
	_distance = pos.length()
	_yaw = atan2(pos.x, pos.z)
	_pitch = asin(clamp(pos.y / _distance, -1.0, 1.0))

func _get_regioes() -> Dictionary:
	var size = get_viewport().get_visible_rect().size
	var alvo_min = _alvo_toque_minimo_px()

	var dobrao_w = maxf(size.x * dobrao_largura_ratio, alvo_min)
	var dobrao_h = maxf(size.y * dobrao_altura_ratio, alvo_min)
	var dobrao_x = size.x * dobrao_margem_esquerda_ratio
	var dobrao_y = size.y - size.y * dobrao_margem_inferior_ratio - dobrao_h

	var baqueta_w = maxf(size.x * baqueta_largura_ratio, alvo_min)
	var baqueta_h = maxf(size.y * baqueta_altura_ratio, alvo_min)
	var baqueta_x = size.x - size.x * baqueta_margem_direita_ratio - baqueta_w
	var baqueta_y = size.y - size.y * baqueta_margem_inferior_ratio - baqueta_h

	return {
		"dobrao": Rect2(dobrao_x, dobrao_y, dobrao_w, dobrao_h),
		"baqueta": Rect2(baqueta_x, baqueta_y, baqueta_w, baqueta_h)
	}

func _baqueta_circulo(rect: Rect2) -> Dictionary:
	return {
		"centro": rect.get_center(),
		"raio": minf(rect.size.x, rect.size.y) * baqueta_raio_ratio
	}

func _toque_na_baqueta(pos: Vector2, rect: Rect2) -> bool:
	var circulo = _baqueta_circulo(rect)
	return pos.distance_to(circulo.centro) <= circulo.raio

func _input(event):
	var r = _get_regioes()

	if event is InputEventScreenTouch:
		_on_toque(event, r)
	elif event is InputEventScreenDrag:
		_on_arraste(event, r)
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(-zoom_scroll_step)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(zoom_scroll_step)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			_on_mouse_botao(event, r)
	elif event is InputEventMouseMotion:
		_on_mouse_movimento(event)

func _on_toque(event: InputEventScreenTouch, r: Dictionary):
	if event.pressed:
		_touch_positions[event.index] = event.position

		if r.dobrao.has_point(event.position):
			if _dobrao_touch_index == -1:
				_dobrao_touch_index = event.index
				_atualizar_dobrao(event.position.x, r.dobrao)
		elif _toque_na_baqueta(event.position, r.baqueta):
			if _baqueta_touch_index == -1:
				_baqueta_touch_index = event.index
				Input.action_press("toque_baqueta")
		else:
			if _camera_touch_index == -1:
				_camera_touch_index = event.index
			elif _pinch_touch_index == -1:
				_pinch_touch_index = event.index
				_pinch_last_distance = _touch_positions[_camera_touch_index].distance_to(event.position)
	else:
		_touch_positions.erase(event.index)

		if event.index == _camera_touch_index:
			_camera_touch_index = -1
			# promove o dedo de pinça para câmera se ainda estiver na tela
			if _pinch_touch_index != -1:
				_camera_touch_index = _pinch_touch_index
				_pinch_touch_index = -1
				_pinch_last_distance = -1.0
		elif event.index == _pinch_touch_index:
			_pinch_touch_index = -1
			_pinch_last_distance = -1.0
		elif event.index == _dobrao_touch_index:
			_dobrao_touch_index = -1
			Input.action_release("dobrao_chiado")
			Input.action_release("dobrao_preso")
		elif event.index == _baqueta_touch_index:
			_baqueta_touch_index = -1
			Input.action_release("toque_baqueta")

func _on_arraste(event: InputEventScreenDrag, r: Dictionary):
	_touch_positions[event.index] = event.position

	if _pinch_touch_index != -1 and (event.index == _camera_touch_index or event.index == _pinch_touch_index):
		if _camera_touch_index in _touch_positions and _pinch_touch_index in _touch_positions:
			var dist = _touch_positions[_camera_touch_index].distance_to(_touch_positions[_pinch_touch_index])
			if _pinch_last_distance > 0:
				_zoom((dist - _pinch_last_distance) * zoom_sensitivity)
				_pinch_last_distance = dist
	elif event.index == _camera_touch_index:
		_orbitar(event.relative)
	elif event.index == _dobrao_touch_index:
		_atualizar_dobrao(event.position.x, r.dobrao)

func _atualizar_dobrao(touch_x: float, dobrao_rect: Rect2):
	Input.action_release("dobrao_chiado")
	Input.action_release("dobrao_preso")
	var x_local = touch_x - dobrao_rect.position.x
	var zone_w = dobrao_rect.size.x / 3.0
	if x_local < zone_w:
		pass  # SOLTO, sem action
	elif x_local < zone_w * 2.0:
		Input.action_press("dobrao_chiado")
	else:
		Input.action_press("dobrao_preso")

func _on_mouse_botao(event: InputEventMouseButton, r: Dictionary):
	if event.pressed:
		if r.dobrao.has_point(event.position):
			_atualizar_dobrao(event.position.x, r.dobrao)
		elif _toque_na_baqueta(event.position, r.baqueta):
			Input.action_press("toque_baqueta")
		else:
			_mouse_in_camera_region = true
	else:
		_mouse_in_camera_region = false
		Input.action_release("toque_baqueta")
		Input.action_release("dobrao_chiado")
		Input.action_release("dobrao_preso")

func _on_mouse_movimento(event: InputEventMouseMotion):
	if _mouse_in_camera_region and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_orbitar(event.relative)

func _zoom(delta: float):
	var alvo = _distance + delta
	var novo = clamp(alvo, zoom_min, zoom_max)
	if novo != alvo:
		limite_atingido.emit()
	_distance = novo
	_atualizar_camera()
	camera_interagida.emit()
	zoom_alterado.emit(_zoom_fracao())

func _zoom_fracao() -> float:
	return (_distance - zoom_min) / (zoom_max - zoom_min)

func _orbitar(delta: Vector2):
	_yaw += deg_to_rad(delta.x) * orbit_sensitivity
	var alvo_pitch = _pitch - deg_to_rad(delta.y) * orbit_sensitivity
	var novo_pitch = clamp(alvo_pitch, deg_to_rad(-80.0), deg_to_rad(80.0))
	if novo_pitch != alvo_pitch:
		limite_atingido.emit()
	_pitch = novo_pitch
	_atualizar_camera()
	camera_interagida.emit()

func _atualizar_camera():
	if not camera:
		return
	var x = _distance * cos(_pitch) * sin(_yaw)
	var y = _distance * sin(_pitch)
	var z = _distance * cos(_pitch) * cos(_yaw)
	camera.position = pivot + Vector3(x, y, z)
	camera.look_at(pivot)
