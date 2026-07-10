extends Node

# --- Constantes de Identificação ---
const BERIMBAU_VIOLA = "viola"
const BERIMBAU_MEDIO = "medio"
const BERIMBAU_GUNGA = "gunga"

const TIPO_SOLTO = 1
const TIPO_CHIADO = 2
const TIPO_PRESO = 3

# --- Cor de identificação por tipo de nota (fonte única para a UI) ---
# Paleta inspirada nas cores do Brasil (verde, amarelo, azul).
const COR_TIPO_SOLTO  = Color(0.11, 0.58, 0.35)
const COR_TIPO_CHIADO = Color(1.00, 0.83, 0.00)
const COR_TIPO_PRESO  = Color(0.05, 0.20, 0.55)

func cor_por_tipo(tipo: int) -> Color:
	match tipo:
		TIPO_CHIADO:
			return COR_TIPO_CHIADO
		TIPO_PRESO:
			return COR_TIPO_PRESO
		_:
			return COR_TIPO_SOLTO

const REPIQUE_NENHUM = 0
const REPIQUE_BAIXO  = 1
const REPIQUE_MEDIO  = 2
const REPIQUE_ALTO   = 3

# Modo da partida (não confundir com "modo_jogo" de menu_opcoes_principal.gd,
# que indica se o menu foi aberto de dentro de uma partida em andamento).
# MODO_PADRAO: a partida termina após limite_notas_atual notas.
# MODO_LIVRE: a partida não tem fim automático; só termina quando o jogador
# aperta "Finalizar" na HUD (ver main.gd, finalizar_partida_manualmente).
const MODO_PADRAO = 0
const MODO_LIVRE  = 1

# --- Multiplicador de Velocidade (1.0 = normal, 1.5 = lento, 0.7 = rápido) ---
var velocidade_atual = 1.0

# --- Configurações Selecionadas pelo Jogador ---
var berimbau_atual     = BERIMBAU_VIOLA
var toque_nome_atual   = "Angola"
var repique_nivel      = REPIQUE_NENHUM
var modo_partida       = MODO_PADRAO
var limite_notas_atual = 40

# Prática Livre: opção na coluna de Toque (não confundir com MODO_LIVRE acima,
# que é sobre a partida ter fim automático ou não). Quando ativa, não há
# nenhum toque/ritmo definido: nenhuma nota nasce, não há placar, e o jogador
# só toca o berimbau livremente pelo dobrão/baqueta (ver main.gd).
var pratica_livre_ativa = false

func modo_livre_ativo() -> bool:
	return modo_partida == MODO_LIVRE

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
# Cada repique é um bloco de notas completo que substitui o ciclo do toque normal
# quando sorteado (ver get_probabilidade_repique/get_repique_aleatorio e
# _escolher_ciclo em main.gd). O bloco em "notas" deve ser construído a partir
# do toque base (ver dicionário "toques" acima), aplicando UMA OU MAIS das
# variações abaixo:
#   - inserção: acrescenta nota(s) extra(s) que não existem no toque base
#     (o bloco fica com mais notas que o original)
#   - substituição: troca uma ou mais notas do toque base por outra(s)
#     (o bloco pode ficar com mais, menos ou o mesmo número de notas)
#   - mudança de tempo: mantém as mesmas notas do toque base, só altera o
#     intervalo de uma ou mais delas
#
# "descricao" existe só para facilitar comparar o bloco com o toque base ao
# editar/ajustar por ouvido, não é lida em nenhum lugar do código.
#
# Para adicionar um novo repique a um toque existente: acrescentar mais um
# dicionário {"descricao": ..., "notas": [...]} na lista correspondente.
# Para criar repiques de um toque novo: adicionar uma chave nova aqui com o
# mesmo nome usado em GameData.toques.
var repiques = {
	"Angola": [
		# Toque base: [CHIADO 0.45] [CHIADO 0.45] [SOLTO 0.9] [PRESO 1.45]
		{
			"descricao": "Insere um solto e um chiado extras logo após a primeira nota",
			"notas": [
				[TIPO_CHIADO, 0.45],
				[TIPO_SOLTO,  0.3],
				[TIPO_CHIADO, 0.3],
				[TIPO_CHIADO, 0.45],
				[TIPO_SOLTO,  0.9],
				[TIPO_PRESO,  1.45],
			],
		},
		{
			"descricao": "Substitui a nota solto (3ª) por duas notas preso mais curtas",
			"notas": [
				[TIPO_CHIADO, 0.45],
				[TIPO_CHIADO, 0.45],
				[TIPO_PRESO,  0.4],
				[TIPO_PRESO,  0.4],
				[TIPO_PRESO,  1.45],
			],
		},
		{
			"descricao": "Mesmas notas do toque base, só acelera a primeira chiado (0.45s para 0.25s)",
			"notas": [
				[TIPO_CHIADO, 0.25],
				[TIPO_CHIADO, 0.45],
				[TIPO_SOLTO,  0.9],
				[TIPO_PRESO,  1.45],
			],
		},
	],
	"SaoBentoGrande": [
		# Toque base: [CHIADO 0.35] [CHIADO 0.35] [PRESO 0.45] [SOLTO 0.65] [SOLTO 0.85]
		{
			"descricao": "Insere um solto extra entre a segunda chiado e o preso",
			"notas": [
				[TIPO_CHIADO, 0.35],
				[TIPO_CHIADO, 0.35],
				[TIPO_SOLTO,  0.25],
				[TIPO_PRESO,  0.45],
				[TIPO_SOLTO,  0.65],
				[TIPO_SOLTO,  0.85],
			],
		},
		{
			"descricao": "Substitui a nota preso (3ª) por preso e chiado mais curtos",
			"notas": [
				[TIPO_CHIADO, 0.35],
				[TIPO_CHIADO, 0.35],
				[TIPO_PRESO,  0.3],
				[TIPO_CHIADO, 0.3],
				[TIPO_SOLTO,  0.65],
				[TIPO_SOLTO,  0.85],
			],
		},
	],
	"SaoBentoPequeno": [
		# Toque base: [CHIADO 0.35] [CHIADO 0.35] [PRESO 0.45] [SOLTO 0.85]
		{
			"descricao": "Insere um solto extra entre o preso e o solto final",
			"notas": [
				[TIPO_CHIADO, 0.35],
				[TIPO_CHIADO, 0.35],
				[TIPO_PRESO,  0.45],
				[TIPO_SOLTO,  0.25],
				[TIPO_SOLTO,  0.85],
			],
		},
		{
			"descricao": "Substitui a segunda nota chiado por duas notas preso mais curtas",
			"notas": [
				[TIPO_CHIADO, 0.35],
				[TIPO_PRESO,  0.3],
				[TIPO_PRESO,  0.3],
				[TIPO_PRESO,  0.45],
				[TIPO_SOLTO,  0.85],
			],
		},
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
	return lista[randi() % lista.size()]["notas"]

# --- Nomes amigáveis das opções atuais (fonte única para exibição em UI) ---
func nome_toque_atual() -> String:
	if pratica_livre_ativa:
		return "Prática Livre"
	match toque_nome_atual:
		"SaoBentoGrande":  return "São Bento Grande"
		"SaoBentoPequeno": return "São Bento Pequeno"
		_: return "Angola"

func nome_berimbau_atual() -> String:
	match berimbau_atual:
		BERIMBAU_MEDIO: return "Médio"
		BERIMBAU_GUNGA: return "Gunga"
		_: return "Viola"

func nome_velocidade_atual() -> String:
	if velocidade_atual >= 1.4:
		return "Lento"
	elif velocidade_atual <= 0.7:
		return "Rápido"
	return "Equilibrado"

func nome_repique_nivel() -> String:
	match repique_nivel:
		REPIQUE_BAIXO: return "Baixo"
		REPIQUE_MEDIO: return "Médio"
		REPIQUE_ALTO:  return "Alto"
		_: return "Nenhum"

func nome_duracao_partida() -> String:
	if modo_livre_ativo():
		return "Livre"
	return str(limite_notas_atual) + " notas"
