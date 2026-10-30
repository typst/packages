// Validação local usada pelos construtores; nenhuma dependência de apresentação.
#let exigir-elemento(valor, tipo) = {
  assert(type(valor) == dictionary and valor.at("tipo", default: none) == tipo,
    message: "Esperado um elemento " + tipo + ".")
}

#let exigir-texto(valor, campo) = {
  assert(type(valor) in (str, content), message: campo + " deve ser texto ou conteúdo Typst.")
}

#let exigir-nome(valor, campo) = {
  assert(type(valor) == str and valor.trim() != "", message: campo + " deve ser uma string não vazia.")
}

#let exigir-id(id) = {
  if id != none { exigir-nome(id, "id") }
}

#let exigir-peso(peso) = {
  assert(type(peso) in (int, float) and peso > 0 and peso < float("inf"),
    message: "peso deve ser um número finito maior que zero.")
}

#let exigir-notas(notas) = {
  assert(type(notas) == array, message: "notas deve ser um array, como (hq.nota(...)[...],).")
  for item in notas { exigir-elemento(item, "nota") }
}

// Aceita uma página ou um array. IDs de linhas e quadros compartilham o namespace.
#let validar(paginas) = {
  let paginas = if type(paginas) == dictionary { (paginas,) } else { paginas }
  assert(type(paginas) == array, message: "Informe uma página ou um array de páginas.")
  let ids = ()
  for pagina in paginas {
    exigir-elemento(pagina, "pagina")
    for linha in pagina.linhas {
      for elemento in (linha,) + linha.quadros {
        if elemento.id != none {
          assert(not (elemento.id in ids), message: "ID explícito duplicado: " + elemento.id)
          ids.push(elemento.id)
        }
      }
    }
  }
  paginas
}

// Inspeciona texto estático, inclusive dentro de ênfase, negrito e links.
// Não avalia context, imagens nem fórmulas: a contagem é um indicador editorial.
#let texto-simples(valor) = {
  if type(valor) == str { return valor }
  if type(valor) != content { return "" }
  let campos = valor.fields()
  if "text" in campos { return campos.text }
  if "children" in campos { return campos.children.map(texto-simples).join("", default: "") }
  if "body" in campos { return texto-simples(campos.body) }
  " "
}

#let contar-palavras(quadro) = {
  quadro.textos.map(item => texto-simples(item.corpo).matches(regex("\\S+")).len()).sum(default: 0)
}

#let avisos-quadro(quadro, limite-palavras: 60) = {
  let avisos = ()
  if texto-simples(quadro.visual).trim() == "" {
    avisos.push("Sem descrição visual em texto estático.")
  }
  let total = contar-palavras(quadro)
  if limite-palavras != none and total > limite-palavras {
    avisos.push(str(total) + " palavras nos textos do quadro; limiar editorial: " + str(limite-palavras) + ".")
  }
  avisos
}
