#import "validacao.typ": exigir-elemento, exigir-texto, exigir-nome, exigir-id, exigir-peso, exigir-notas

#let pagina(numero, titulo: none, objetivo: none, estado: none, notas: (), ..linhas) = {
  assert(type(numero) == int and numero > 0, message: "Número da página deve ser um inteiro positivo.")
  assert(linhas.named().len() == 0, message: "Campo desconhecido em pagina: " + repr(linhas.named().keys()))
  let linhas = linhas.pos()
  assert(linhas.len() > 0, message: "Página deve conter pelo menos uma linha.")
  for item in linhas { exigir-elemento(item, "linha") }
  for valor in (titulo, objetivo, estado) {
    if valor != none { exigir-texto(valor, "Campo da página") }
  }
  exigir-notas(notas)
  (tipo: "pagina", numero: numero, titulo: titulo, objetivo: objetivo, estado: estado,
    notas: notas, linhas: linhas)
}

#let linha(peso: 1, id: none, notas: (), ..quadros) = {
  assert(quadros.named().len() == 0, message: "Campo desconhecido em linha: " + repr(quadros.named().keys()))
  let quadros = quadros.pos()
  assert(quadros.len() > 0, message: "Linha deve conter pelo menos um quadro.")
  for item in quadros { exigir-elemento(item, "quadro") }
  exigir-peso(peso)
  exigir-id(id)
  exigir-notas(notas)
  (tipo: "linha", peso: peso, id: id, notas: notas, quadros: quadros)
}

#let quadro(visual, id: none, peso: 1, plano: none, composicao: none, textos: (), notas: (), referencias: ()) = {
  exigir-texto(visual, "Descrição visual")
  exigir-id(id)
  exigir-peso(peso)
  for valor in (plano, composicao) {
    if valor != none { exigir-texto(valor, "Campo do quadro") }
  }
  assert(type(textos) == array, message: "textos deve ser um array.")
  for item in textos {
    assert(type(item) == dictionary and item.at("tipo", default: none) in ("fala", "legenda", "som"),
      message: "textos aceita fala, legenda ou som.")
  }
  exigir-notas(notas)
  assert(type(referencias) == array, message: "referencias deve ser um array de textos ou conteúdos Typst.")
  for item in referencias { exigir-texto(item, "Referência") }
  (tipo: "quadro", visual: visual, id: id, peso: peso, plano: plano, composicao: composicao,
    textos: textos, notas: notas, referencias: referencias)
}

#let fala(personagem, corpo, modo: "normal") = {
  exigir-nome(personagem, "personagem")
  exigir-nome(modo, "modo da fala")
  exigir-texto(corpo, "Fala")
  (tipo: "fala", personagem: personagem, modo: modo, corpo: corpo)
}

#let legenda(corpo) = {
  exigir-texto(corpo, "Legenda")
  (tipo: "legenda", corpo: corpo)
}

#let som(corpo) = {
  exigir-texto(corpo, "Som")
  (tipo: "som", corpo: corpo)
}

#let nota(categoria, corpo, estado: "aberta", autor: none) = {
  exigir-nome(categoria, "categoria")
  exigir-texto(corpo, "Nota")
  assert(estado in ("aberta", "resolvida", "descartada"),
    message: "Estado da nota deve ser aberta, resolvida ou descartada.")
  if autor != none { exigir-nome(autor, "autor") }
  (tipo: "nota", categoria: categoria, corpo: corpo, estado: estado, autor: autor)
}
