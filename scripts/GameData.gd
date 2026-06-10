extends Node

# --- Constantes de Identificação ---
const BERIMBAU_VIOLA = "viola"
const BERIMBAU_MEDIO = "medio"
const BERIMBAU_GUNGA = "gunga"

const TIPO_SOLTO = 1
const TIPO_CHIADO = 2
const TIPO_PRESO = 3

# --- Multiplicador de Velocidade (1.0 = normal, 1.5 = lento, 0.7 = rápido) ---
var velocidade_atual = 1.0

# --- Configurações Selecionadas pelo Jogador ---
var berimbau_atual = BERIMBAU_VIOLA
var toque_nome_atual = "Angola"

# --- Banco de Dados dos Toques ---
# Cada nota: [tipo, intervalo_segundos]
# Tipos: 1 = Solto, 2 = Chiado, 3 = Preso
var toques = {
	"Angola": [
		[TIPO_CHIADO, 0.7],
		[TIPO_CHIADO, 0.7],
		[TIPO_SOLTO,  1.0],
		[TIPO_PRESO,  1.4],
	],
	"SaoBentoGrande": [
		[TIPO_CHIADO, 0.7],
		[TIPO_CHIADO, 0.7],
		[TIPO_PRESO,  1.0],
		[TIPO_SOLTO,  0.7],
		[TIPO_SOLTO,  0.7],
	],
	"SaoBentoPequeno": [
		[TIPO_CHIADO, 0.7],
		[TIPO_CHIADO, 0.7],
		[TIPO_PRESO,  1.0],
		[TIPO_SOLTO,  1.4],
	],
}

# Função para pegar o array do toque atual
func get_toque_atual_array():
	if toques.has(toque_nome_atual):
		return toques[toque_nome_atual]
	else:
		return toques["Angola"] # Fallback
