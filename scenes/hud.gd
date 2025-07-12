extends Control

@onready var acertos_label = $AcertosLabel
@onready var erros_label = $ErrosLabel
@onready var porcentagem_label = $PorcentagemLabel

func atualizar_hud(acertos, erros):
	acertos_label.text = "Acertos: " + str(acertos)
	erros_label.text = "Erros: " + str(erros)
	
	var total_resolvido = acertos + erros
	var porcentagem = 0
	
	if total_resolvido > 0:
		porcentagem = (float(acertos) / total_resolvido) * 100
	
	porcentagem_label.text = "Precisão: " + ("%.f" % porcentagem) + "%"
