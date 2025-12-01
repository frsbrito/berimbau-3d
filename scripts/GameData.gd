extends Node

# --- Constantes de Identificação ---
const BERIMBAU_VIOLA = "viola"
const BERIMBAU_MEDIO = "medio"
const BERIMBAU_GUNGA = "gunga"

const TIPO_SOLTO = 1
const TIPO_CHIADO = 2
const TIPO_PRESO = 3

# --- Configurações Selecionadas pelo Jogador ---
var berimbau_atual = BERIMBAU_VIOLA
var toque_nome_atual = "Angola"

# --- Banco de Dados dos Toques (Partituras) ---
# 1 = Solto, 2 = Chiado, 3 = Preso
var toques = {
	"Angola": [2, 2, 1, 3], # Chiado, Chiado, Solto, Preso
	"SaoBentoGrande": [2, 2, 3, 1, 1],
	"SaoBentoPequeno": [2, 2, 3, 1]
}

# Função para pegar o array do toque atual
func get_toque_atual_array():
	if toques.has(toque_nome_atual):
		return toques[toque_nome_atual]
	else:
		return toques["Angola"] # Fallback
