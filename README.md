# Berimbau 3D

Simulador de prática livre de berimbau para ensino de capoeira.

Trabalho de Conclusão de Curso, Sistemas de Informação, UFOP.

## Sobre o projeto

Berimbau 3D é um jogo que simula a prática do berimbau, o instrumento que conduz o ritmo de uma roda de capoeira. O jogador escolhe um toque tradicional (Angola, São Bento Grande ou São Bento Pequeno), segura o dobrão contra o arame no momento certo e bate a baqueta no tempo, tentando reproduzir a cadência do instrumento.

O projeto é o software de apoio de uma monografia de TCC, mas foi construído para ser jogável e testado por praticantes de capoeira, não é uma prova de conceito puramente acadêmica.

## O que dá para fazer no jogo hoje

- Escolher entre 3 toques tradicionais de capoeira: Angola, São Bento Grande e São Bento Pequeno.
- Escolher o timbre do berimbau (viola, médio ou gunga), cada um com seu próprio banco de sons gravados.
- Ajustar a velocidade (lento, equilibrado, rápido) e o nível de repique (variações rítmicas ocasionais).
- Tocar com controles touch pensados para celular, com uma zona para o dobrão (solto, chiado, preso) e outra para a baqueta.
- Girar e aproximar a câmera ao redor do berimbau em 3D com gestos.
- Ver o resultado da partida (acertos, erros, precisão) ao final de cada rodada.

## Escopo do projeto

Este é um módulo único de prática livre, de propósito. O escopo está reduzido para viabilizar a entrega do TCC:

- Cobre exclusivamente o berimbau, sem pandeiro, atabaque, agogô ou outros instrumentos.
- Sem fases, progressão ou narrativa. Não é um modo história.
- Sem persistência de progresso entre sessões. Cada partida começa do zero.

## Stack técnica

- Motor: Godot Engine 4.7
- Linguagem: GDScript
- Renderização: perfil mobile, com compressão de textura ETC2/ASTC
- Modelo 3D: berimbau modelado em .glb, com baqueta, dobrão e cabaça animados em tempo real
- Áudio: amostras .ogg gravadas por timbre (viola, médio, gunga) e por articulação (solto, chiado, preso)
- Plataforma-alvo: Android. Uso em desktop é só para desenvolvimento e testes no editor.

## Rodando o projeto

1. Instale o Godot Engine 4.7.
2. Clone o repositório e abra a pasta pelo Godot (`project.godot` na raiz).
3. Rode a cena padrão do projeto (menu principal) com F5.
4. No editor, em desktop, os controles de dobrão/baqueta e a câmera respondem ao mouse como alternativa de teste. A experiência pensada para toque só é validada de fato em um celular Android real.

## Licença

Distribuído sob a licença MIT. Ver o arquivo LICENSE.

Desenvolvido por Felipe Ricardo Silva Brito, como parte do TCC em Sistemas de Informação, UFOP.
