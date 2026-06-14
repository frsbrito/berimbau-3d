extends Node

# --- Constantes de Identificação ---
const BERIMBAU_VIOLA = "viola"
const BERIMBAU_MEDIO = "medio"
const BERIMBAU_GUNGA = "gunga"

const TIPO_SOLTO = 1
const TIPO_CHIADO = 2
const TIPO_PRESO = 3

const REPIQUE_NENHUM = 0
const REPIQUE_BAIXO  = 1
const REPIQUE_MEDIO  = 2
const REPIQUE_ALTO   = 3

# --- Multiplicador de Velocidade (1.0 = normal, 1.5 = lento, 0.7 = rápido) ---
var velocidade_atual = 1.0

# --- Configurações Selecionadas pelo Jogador ---
var berimbau_atual   = BERIMBAU_VIOLA
var toque_nome_atual = "Angola"
var repique_nivel    = REPIQUE_NENHUM

# --- Banco de Dados dos Toques ---
# Cada nota: [tipo, intervalo_segundos]
# Tipos: 1 = Solto, 2 = Chiado, 3 = Preso
var toques = {
	"Angola": [
		[TIPO_CHIADO, 0.45],
		[TIPO_CHIADO, 0.45],
		[TIPO_SOLTO,  0.9],
		[TIPO_PRESO,  1.45],
	],
	"SaoBentoGrande": [
		[TIPO_CHIADO, 0.35],
		[TIPO_CHIADO, 0.35],
		[TIPO_PRESO,  0.45],
		[TIPO_SOLTO,  0.65],
		[TIPO_SOLTO,  0.85],
	],
	"SaoBentoPequeno": [
		[TIPO_CHIADO, 0.35],
		[TIPO_CHIADO, 0.35],
		[TIPO_PRESO,  0.45],
		[TIPO_SOLTO,  0.85],
	],
}

# --- Banco de Dados dos Repiques ---
# Variações do toque principal inseridas aleatoriamente
var repiques = {
	"Angola": [
		[[TIPO_SOLTO,  0.3], [TIPO_CHIADO, 0.3], [TIPO_SOLTO,  0.3], [TIPO_CHIADO, 0.45], [TIPO_PRESO,  1.45]],
		[[TIPO_PRESO,  0.4], [TIPO_PRESO,  0.4], [TIPO_CHIADO, 0.45], [TIPO_SOLTO,  1.45]],
	],
	"SaoBentoGrande": [
		[[TIPO_SOLTO,  0.25], [TIPO_SOLTO, 0.25], [TIPO_CHIADO, 0.35], [TIPO_PRESO, 0.45], [TIPO_SOLTO,  0.85]],
		[[TIPO_PRESO,  0.3],  [TIPO_CHIADO, 0.3], [TIPO_PRESO,  0.35], [TIPO_SOLTO, 0.65], [TIPO_SOLTO,  0.85]],
	],
	"SaoBentoPequeno": [
		[[TIPO_SOLTO,  0.25], [TIPO_CHIADO, 0.25], [TIPO_PRESO, 0.3], [TIPO_SOLTO, 0.85]],
		[[TIPO_PRESO,  0.3],  [TIPO_PRESO,  0.3],  [TIPO_SOLTO, 0.45], [TIPO_CHIADO, 0.85]],
	],
}

func get_toque_atual_array() -> Array:
	if toques.has(toque_nome_atual):
		return toques[toque_nome_atual]
	return toques["Angola"]

func get_probabilidade_repique() -> float:
	match repique_nivel:
		REPIQUE_BAIXO: return 0.15
		REPIQUE_MEDIO: return 0.40
		REPIQUE_ALTO:  return 0.70
	return 0.0

func get_repique_aleatorio() -> Array:
	if not repiques.has(toque_nome_atual):
		return []
	var lista = repiques[toque_nome_atual]
	if lista.is_empty():
		return []
	return lista[randi() % lista.size()]
