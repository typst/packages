// Módulo de provas e exames acadêmicos (estilo exam.cls)

#import "caixas.typ": caixa

// ── Estado global ─────────────────────────────────────────────────

/// Acumulador de pontos por questão (para tabela-pontos).
#let _pontos-questao = state("ferrmat-pontos-questao", ())
/// Acumulador de todos os pontos (questão + sub-questão, para total-pontos).
#let _pontos-total = state("ferrmat-pontos-total", ())

/// Reseta contadores e acumuladores de pontos para uma nova prova no mesmo documento.
#let resetar-prova() = {
  counter("ferrmat-prova-questao").update(0)
  counter("ferrmat-prova-subquestao").update(0)
  _pontos-questao.update(())
  _pontos-total.update(())
}

// ── Helpers internos ──────────────────────────────────────────────

/// Formata número com vírgula brasileira (sem unidade).
#let _fmt-valor(pontos) = {
  let valor = float(pontos)
  if calc.fract(valor) == 0 {
    str(int(valor))
  } else {
    str(valor).replace(".", ",")
  }
}

/// Formata pontos com vírgula brasileira e plural correto.
/// Em PT-BR, singular para 0 < valor < 2: 0,5 ponto, 1 ponto, 1,5 ponto.
/// Plural para 0 ou valor >= 2: 0 pontos, 2 pontos, 2,5 pontos.
#let _formatar-pontos(pontos) = {
  let valor = float(pontos)
  let txt = _fmt-valor(pontos)
  let unidade = if valor > 0 and valor < 2 { "ponto" } else { "pontos" }
  txt + " " + unidade
}

/// Checkbox vazio reutilizável.
#let _checkbox() = box(
  rect(width: 0.8em, height: 0.8em, stroke: 0.5pt + black),
  baseline: 0.1em,
)

// ── Funções públicas ──────────────────────────────────────────────

/// Cabeçalho de prova com identificação, campos e caixa de nota.
#let cabecalho-prova(
  instituicao: none,
  departamento: none,
  disciplina: none,
  professor: none,
  data: none,
  titulo: "Prova",
  instrucoes: none,
  logo: none,
  logo-largura: 2cm,
  campos: ("Nome", "Turma"),
  campo-nota: true,
  nota-largura: 2.5cm,
  cor: black,
  espessura: 1pt,
) = {
  // Informações da prova
  let info-items = ()
  if instituicao != none { info-items.push(text(weight: "bold", size: 1.1em, instituicao)) }
  if departamento != none { info-items.push(departamento) }
  if disciplina != none { info-items.push([*Disciplina:* #disciplina]) }
  if professor != none { info-items.push([*Professor:* #professor]) }
  if data != none { info-items.push([*Data:* #data]) }

  let info-block = {
    if logo != none {
      grid(
        columns: (logo-largura + 0.5cm, 1fr),
        align: (center + horizon, left),
        box(width: logo-largura, logo),
        stack(dir: ttb, spacing: 0.4em, ..info-items),
      )
    } else {
      stack(dir: ttb, spacing: 0.4em, ..info-items)
    }
  }

  // Bloco principal
  caixa(
    borda: "completa",
    cor: cor,
    espessura: espessura,
    raio: 0pt,
    preenchimento: white,
    titulo-fundo: white,
    {
      // Título centralizado
      align(center, text(weight: "bold", size: 1.3em, titulo))
      v(0.5em)

      // Info + nota
      if campo-nota {
        grid(
          columns: (1fr, nota-largura + 1em),
          column-gutter: 0.5em,
          align: (left, center),
          info-block,
          {
            rect(
              width: nota-largura,
              height: nota-largura,
              stroke: espessura + cor,
              align(center + horizon, {
                place(top + center, dy: 0.3em, text(size: 0.85em, weight: "bold", [Nota]))
              }),
            )
          },
        )
      } else {
        info-block
      }

      // Campos de preenchimento
      if campos != none and campos.len() > 0 {
        v(0.6em)
        for campo in campos {
          grid(
            columns: (auto, 1fr),
            column-gutter: 0.3em,
            align: (left, bottom),
            text(weight: "bold", campo + ":"),
            line(length: 100%, stroke: 0.5pt + cor),
          )
          v(0.3em)
        }
      }
    },
  )

  // Instruções
  if instrucoes != none {
    v(0.3em)
    caixa(
      borda: "completa",
      cor: cor,
      espessura: 0.5pt,
      raio: 0pt,
      preenchimento: white,
      titulo: text(weight: "bold", [Instruções]),
      titulo-fundo: luma(235),
      instrucoes,
    )
  }

  v(0.8em)
}

/// Questão numerada com pontos opcionais e espaço de resposta.
#let questao(
  body,
  pontos: none,
  separador: true,
  espaco: none,
  formato-pontos: auto,
  recuo: 0pt,
  negrito: true,
) = {
  counter("ferrmat-prova-questao").step()
  counter("ferrmat-prova-subquestao").update(0)

  if pontos != none {
    let p = float(pontos)
    _pontos-questao.update(old => { old.push(p); old })
    _pontos-total.update(old => { old.push(p); old })
  }

  context {
    let num = counter("ferrmat-prova-questao").get().first()

    // Separador (exceto questão 1)
    if separador and num > 1 {
      line(length: 100%, stroke: 0.3pt + luma(180))
      v(0.5em)
    }

    // Cabeçalho da questão
    let label = if negrito { [*Questão #num*] } else { [Questão #num] }

    if pontos != none {
      let fmt = if formato-pontos == auto { _formatar-pontos } else { formato-pontos }
      let pts-text = if negrito { [*(#fmt(pontos))*] } else { [(#fmt(pontos))] }
      grid(
        columns: (auto, 1fr, auto),
        align: (left + bottom, center + bottom, right + bottom),
        column-gutter: 0.3em,
        label,
        box(width: 100%, repeat[#h(0.15em)─]),
        pts-text,
      )
    } else {
      label
    }

    pad(left: recuo, body)
  }

  // Espaço de resposta
  if espaco != none {
    espaco-resposta(altura: espaco)
  }
}

/// Sub-questão com letras (a, b, c...).
#let subquestao(
  body,
  pontos: none,
  recuo: 1.5em,
  negrito: false,
) = {
  counter("ferrmat-prova-subquestao").step()

  if pontos != none {
    _pontos-total.update(old => { old.push(float(pontos)); old })
  }

  context {
    let num = counter("ferrmat-prova-subquestao").get().first()
    let letra = numbering("a)", num)

    let pts-text = if pontos != none {
      [ \[#_formatar-pontos(pontos)\]]
    }

    pad(left: recuo, {
      if negrito {
        [*#letra#pts-text* ]
      } else {
        [#letra#pts-text ]
      }
      body
    })
  }
}

/// Alternativas de múltipla escolha.
#let alternativas(
  ..opcoes,
  marcador: "letra",
  horizontal: false,
  colunas: auto,
  recuo: 1.5em,
  espacamento: 0.6em,
) = {
  let items = opcoes.pos()
  let n = items.len()

  let entries = items.enumerate().map(((i, item)) => {
    let prefixo = if marcador == "caixa" {
      [#_checkbox() #h(0.2em)]
    } else {
      numbering("(A)", i + 1) + [ ]
    }
    [#prefixo#item]
  })

  let cols = if colunas != auto {
    colunas
  } else if horizontal {
    n
  } else {
    1
  }

  pad(left: recuo, {
    if cols == 1 {
      stack(dir: ttb, spacing: espacamento, ..entries)
    } else {
      grid(
        columns: (1fr,) * calc.min(cols, n),
        column-gutter: espacamento,
        row-gutter: espacamento,
        ..entries,
      )
    }
  })
}

/// Questões de verdadeiro ou falso.
#let verdadeiro-falso(
  ..afirmacoes,
  marcador: "parenteses",
  recuo: 1.5em,
  espacamento: 0.6em,
) = {
  let items = afirmacoes.pos()

  let entries = items.map(item => {
    let prefixo = if marcador == "caixa" {
      [#_checkbox() V #h(0.3em) #_checkbox() F #h(0.5em)]
    } else {
      [(#h(1.2em)) #h(0.3em)]
    }
    [#prefixo#item]
  })

  pad(left: recuo, {
    stack(dir: ttb, spacing: espacamento, ..entries)
  })
}

/// Linhas horizontais para resposta.
#let preencher-linhas(
  altura: 3cm,
  espacamento: 0.8cm,
  cor: luma(180),
  espessura: 0.5pt,
) = {
  let n = calc.floor(altura / espacamento)
  block(width: 100%, height: altura, clip: true, {
    for i in range(n) {
      v(espacamento)
      line(length: 100%, stroke: espessura + cor)
    }
  })
}

/// Linhas pontilhadas para resposta.
#let preencher-pontilhado(
  altura: 3cm,
  espacamento: 0.8cm,
  cor: luma(180),
  espessura: 0.5pt,
  traco: 1pt,
  intervalo: 2pt,
) = {
  let n = calc.floor(altura / espacamento)
  block(width: 100%, height: altura, clip: true, {
    for i in range(n) {
      v(espacamento)
      line(
        length: 100%,
        stroke: stroke(paint: cor, thickness: espessura, dash: ("dot", traco, intervalo)),
      )
    }
  })
}

/// Grade quadriculada para resposta.
#let preencher-grade(
  altura: 3cm,
  celula: 0.5cm,
  cor: luma(200),
  espessura: 0.3pt,
) = {
  rect(
    width: 100%,
    height: altura,
    stroke: espessura + cor,
    fill: tiling(size: (celula, celula), {
      place(line(start: (0%, 100%), end: (100%, 100%), stroke: espessura + cor))
      place(line(start: (100%, 0%), end: (100%, 100%), stroke: espessura + cor))
    }),
  )
}

/// Espaço em branco para resposta.
#let espaco-resposta(
  altura: 3cm,
  borda: none,
  cor-borda: luma(200),
) = {
  let s = if borda == "completa" {
    0.5pt + cor-borda
  } else if borda == "pontilhada" {
    stroke(paint: cor-borda, thickness: 0.5pt, dash: "dashed")
  } else {
    none
  }
  block(width: 100%, height: altura, stroke: s)
}

/// Exibe o total de pontos acumulados (soma de questões + sub-questões).
#let total-pontos(
  formato: auto,
  peso: "bold",
) = context {
  let pts = _pontos-total.get()
  let soma = if pts.len() == 0 { 0 } else { pts.fold(0, (a, b) => a + b) }
  if formato == auto {
    text(weight: peso, [Total: #_formatar-pontos(soma)])
  } else {
    text(weight: peso, (formato)(soma))
  }
}

/// Tabela de pontuação com uma coluna por questão (somente pontos de `questao()`).
#let tabela-pontos(
  titulo-questao: "Questão",
  titulo-total: "Total",
  cor-cabecalho: luma(230),
) = context {
  let pts = _pontos-questao.get()
  if pts.len() == 0 { return }

  let n = pts.len()
  let soma = pts.fold(0, (a, b) => a + b)

  // Abreviar cabeçalho quando muitas questões
  let label = if n > 6 { "Q" } else { titulo-questao }

  // Linha 1: cabeçalhos
  let header = range(n).map(i => [#label #(i + 1)])
  header.push(titulo-total)

  // Linha 2: pontos (valor numérico apenas, sem "pontos")
  let pontos-row = pts.map(p => _fmt-valor(p))
  pontos-row.push(_fmt-valor(soma))

  // Linha 3: nota (vazia, com altura para escrita manual)
  let nota-row = range(n + 1).map(_ => block(height: 1.5em))

  table(
    columns: (auto,) * (n + 1),
    stroke: 0.5pt,
    align: center + horizon,
    inset: 0.5em,
    fill: (_, row) => if row == 0 { cor-cabecalho },
    table.header(..header),
    ..pontos-row,
    ..nota-row,
  )
}
