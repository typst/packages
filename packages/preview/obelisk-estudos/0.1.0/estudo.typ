// Ambientes de estudo que podem ser usados em qualquer disciplina.
#import "theorem.typ": make-environment

#let conceito = make-environment("Conceito", "CON", "definition")
#let norma = make-environment("Norma", "NORMA", "proposition")
#let jurisprudencia = make-environment("Jurisprudência", "JUR", "corollary")
#let questao = make-environment("Questão", "Q", "example")
#let caso_pratico = make-environment("Caso prático", "CASO", "remark")
#let dica = make-environment("Dica de prova", "DICA", "lemma")
