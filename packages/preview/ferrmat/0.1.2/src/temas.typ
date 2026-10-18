// src/temas.typ — Paletas × Estilos de layout para headings
//
// Uso rápido:
//   #import "src/temas.typ": tema-revista-vinho
//   #show: tema-revista-vinho
//
// Uso livre (qualquer combinação):
//   #import "src/temas.typ": estilo-revista, paleta-pastel
//   #show: estilo-revista.with(paleta-pastel)

#import "secoes.typ": formatar-secao

// ===========================================================================
// PALETAS DE CORES
// Chaves: primaria · secundaria · texto · fundo · sutil
// ===========================================================================

#let paleta-marinho  = (primaria: rgb("#1e2540"), secundaria: rgb("#e8a020"),
                        texto: rgb("#1e2540"),  fundo: rgb("#f0f0ee"), sutil: rgb("#ddddd8"))

#let paleta-vinho    = (primaria: rgb("#7b1d30"), secundaria: rgb("#b8880a"),
                        texto: rgb("#3a1520"),  fundo: rgb("#f5ece8"), sutil: rgb("#d8cfc4"))

#let paleta-bosque   = (primaria: rgb("#1e3d2a"), secundaria: rgb("#b89850"),
                        texto: rgb("#1a2a20"),  fundo: rgb("#eef4f0"), sutil: rgb("#c8d8cc"))

#let paleta-pastel   = (primaria: rgb("#b05868"), secundaria: rgb("#70a894"),
                        texto: rgb("#2e1c1e"),  fundo: rgb("#fdf0f2"), sutil: rgb("#e0c4c8"))


#let paleta-petroleo = (primaria: rgb("#0d3b3e"), secundaria: rgb("#1a9a8a"),
                        texto: rgb("#0a2a2c"),  fundo: rgb("#eaf4f4"), sutil: rgb("#9ecfcc"))

#let paleta-solar    = (primaria: rgb("#7a4200"), secundaria: rgb("#e8a820"),
                        texto: rgb("#2a1800"),  fundo: rgb("#fdf5e8"), sutil: rgb("#e8d8b0"))

#let paleta-ardosia  = (primaria: rgb("#3d4a5c"), secundaria: rgb("#e06030"),
                        texto: rgb("#242e3c"),  fundo: rgb("#f0f2f5"), sutil: rgb("#c8ced8"))

#let paleta-lilas    = (primaria: rgb("#4a2578"), secundaria: rgb("#d4a820"),
                        texto: rgb("#2a1048"),  fundo: rgb("#f5f0fc"), sutil: rgb("#d0c0e8"))

#let paleta-grafite  = (primaria: rgb("#1e1e1e"), secundaria: rgb("#949490"),
                        texto: rgb("#2a2a28"),  fundo: rgb("#ebebea"), sutil: rgb("#b8b8b4"))

#let paleta-festiva  = (primaria: rgb("#c04020"), secundaria: rgb("#d4880a"),
                        texto: rgb("#2a1008"),  fundo: rgb("#fef6ee"), sutil: rgb("#f0cca8"))

// ===========================================================================
// UTILITÁRIO INTERNO
// ===========================================================================

#let _num(it) = {
  if it.numbering == none { return none }
  numbering(it.numbering, ..counter(heading).at(it.location()))
}

// ===========================================================================
// ESTILOS DE LAYOUT
// Cada estilo recebe (paleta, fonte, numeracao, corpo).
// ===========================================================================

// ---------------------------------------------------------------------------
// PERIÓDICO — geométrico, sans, blocos fortes de fundo
// H1 faixa cheia caixa-alta · H2 barra grossa + fio cheio · H3 badge sólido
// H4 barra fina discreta · H5 corrido itálico sutil
// ---------------------------------------------------------------------------
#let estilo-periodico(paleta, fonte: "Linux Biolinum", numeracao: "1.1", corpo) = {
  let p = paleta
  show heading.where(level: 1): it => formatar-secao(it,
    forma: "faixa", fundo: p.primaria, cor: white, cor-numero: p.secundaria,
    peso: "bold", tamanho: 28pt, fonte: fonte, caixa: "alta",
    linha-abaixo: true, cor-linha: p.secundaria, espessura-barra: 3pt,
    quebra-pagina: true, espacamento-antes: 2em, espacamento-depois: 1.2em,
  )
  show heading.where(level: 2): it => formatar-secao(it,
    forma: "barra", cor: p.texto, cor-barra: p.secundaria, espessura-barra: 7pt,
    peso: "bold", tamanho: 17pt, fonte: fonte,
    linha-abaixo: true, cor-linha: p.sutil,
    espacamento-antes: 2.4em, espacamento-depois: 0.9em,
  )
  show heading.where(level: 3): it => formatar-secao(it,
    forma: "emblema", cor: white, fundo: p.primaria, raio: 2pt,
    peso: "bold", tamanho: 13pt, fonte: fonte,
    espacamento-antes: 1.6em, espacamento-depois: 0.6em,
  )
  show heading.where(level: 4): it => formatar-secao(it,
    forma: "barra", cor: p.texto, cor-barra: p.sutil.darken(20%), espessura-barra: 2pt,
    peso: "semibold", tamanho: 11pt, fonte: fonte,
    espacamento-antes: 1.2em, espacamento-depois: 0.4em,
  )
  show heading.where(level: 5): it => formatar-secao(it,
    forma: "corrido", cor: p.sutil.darken(30%), estilo: "italic", tamanho: 10pt, fonte: fonte,
    espacamento-antes: 0.9em, espacamento-depois: 0.2em,
  )
  set heading(numbering: numeracao)
  corpo
}

// ---------------------------------------------------------------------------
// JORNAL — editorial de jornal, réguas horizontais, números decorativos grandes
// H1 linha espessa + número gigante pálido à esq + título + linha fina
// H2 linha fina acima + bold
// H3 versalete + fio abaixo · H4 itálico bold · H5 itálico corrido
// ---------------------------------------------------------------------------
#let estilo-jornal(paleta, fonte: "Linux Libertine", numeracao: "1.1", corpo) = {
  let p = paleta
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    let num = _num(it)
    place(top, float: true, scope: "parent", clearance: 1.5em, {
      v(1.2em, weak: true)
      line(length: 100%, stroke: 2.5pt + p.primaria)
      v(0.4em)
      block(width: 100%, {
        if num != none {
          grid(
            columns: (auto, 1fr), column-gutter: 1.2em, align: horizon,
            text(fill: p.primaria.lighten(72%), size: 54pt, weight: "bold", font: fonte, num),
            { set text(fill: p.texto, size: 22pt, weight: "bold", font: fonte); upper(it.body) },
          )
        } else {
          set text(fill: p.texto, size: 22pt, weight: "bold", font: fonte)
          upper(it.body)
        }
      })
      v(0.4em)
      line(length: 100%, stroke: 0.7pt + p.primaria)
    })
  }
  show heading.where(level: 2): it => {
    let num = _num(it)
    v(2.4em, weak: true)
    line(length: 100%, stroke: 1.5pt + p.primaria)
    v(0.35em)
    block(width: 100%, {
      set text(fill: p.texto, size: 15pt, weight: "bold", font: fonte)
      if num != none { num; h(0.5em) }
      it.body
    })
    v(0.15em)
    line(length: 100%, stroke: 0.4pt + p.sutil)
    v(0.8em, weak: true)
  }
  show heading.where(level: 3): it => formatar-secao(it,
    forma: "bloco", cor: p.texto, peso: "bold", tamanho: 12pt, fonte: fonte, caixa: "alta",
    decoracao: { v(0.12em); line(length: 40%, stroke: 0.7pt + p.primaria) },
    espacamento-antes: 1.6em, espacamento-depois: 0.5em,
  )
  show heading.where(level: 4): it => formatar-secao(it,
    forma: "corrido", cor: p.texto, peso: "semibold", estilo: "italic", tamanho: 10.5pt, fonte: fonte,
    espacamento-antes: 1.1em, espacamento-depois: 0.2em,
  )
  show heading.where(level: 5): it => formatar-secao(it,
    forma: "corrido", cor: p.sutil.darken(40%), estilo: "italic", tamanho: 10pt, fonte: fonte,
    espacamento-antes: 0.8em, espacamento-depois: 0.2em,
  )
  set heading(numbering: numeracao)
  // Quando usado como #show: tema-jornal-X, set page aplica ao documento inteiro.
  // Para chamada direta, configure #set page(columns: 2) no nível do documento.
  set page(columns: 2)
  set columns(gutter: 1.5em)
  corpo
}

// ---------------------------------------------------------------------------
// REVISTA — editorial de revista, dois painéis H1, réguas e barras ousadas
// H1 painel-número (primaria) + painel-título (fundo) lado a lado
// H2 régua acima + número colorido + acento espesso · H3 barra grossa secundaria
// H4 bloco colorido semibold · H5 corrido itálico secundaria
// ---------------------------------------------------------------------------
#let estilo-revista(paleta, fonte: "Linux Libertine", numeracao: "1.1", corpo) = {
  let p = paleta
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    let num = _num(it)
    v(1.5em, weak: true)
    if num != none {
      grid(
        columns: (1fr, 2fr),
        column-gutter: 0pt,
        block(
          width: 100%, height: 5.5cm,
          fill: p.primaria,
          inset: 0.6em,
          align(center + horizon,
            text(fill: p.secundaria, size: 88pt, weight: "bold", font: fonte, num)
          ),
        ),
        block(
          width: 100%, height: 5.5cm,
          fill: p.fundo,
          stroke: (left: 5pt + p.secundaria),
          inset: (left: 1.2em, right: 0.8em, y: 0.8em),
          align(left + horizon,
            text(fill: p.texto, size: 28pt, weight: "bold", font: fonte, it.body)
          ),
        ),
      )
    } else {
      block(
        width: 100%, fill: p.primaria,
        stroke: (bottom: 5pt + p.secundaria),
        inset: (x: 1.2em, y: 1em),
        text(fill: white, size: 32pt, weight: "bold", font: fonte, it.body)
      )
    }
    v(1.4em, weak: true)
  }
  // H2–H5: barra lateral em espessura decrescente — 8 · 5 · 3 · 1.5pt
  show heading.where(level: 2): it => {
    let num = _num(it)
    v(2.5em, weak: true)
    line(length: 100%, stroke: 0.6pt + p.sutil)
    v(0pt)
    block(
      width: 100%,
      stroke: (left: 28pt + p.secundaria),
      inset: (left: 1.8em, right: 0pt, y: 0.4em),
      {
        set text(fill: p.texto, size: 19pt, weight: "bold", font: fonte)
        if num != none { text(fill: p.secundaria, num); h(0.5em) }
        it.body
      },
    )
    v(1em, weak: true)
  }
  show heading.where(level: 3): it => formatar-secao(it,
    forma: "barra", cor: p.primaria, cor-barra: p.secundaria, espessura-barra: 16pt,
    peso: "bold", tamanho: 14pt, fonte: fonte, separador-numero: [ — ],
    espacamento-antes: 1.6em, espacamento-depois: 0.6em,
  )
  show heading.where(level: 4): it => formatar-secao(it,
    forma: "barra", cor: p.texto, cor-barra: p.primaria, espessura-barra: 8pt,
    peso: "semibold", tamanho: 11.5pt, fonte: fonte,
    espacamento-antes: 1.1em, espacamento-depois: 0.3em,
  )
  show heading.where(level: 5): it => formatar-secao(it,
    forma: "barra", cor: p.sutil.darken(40%), cor-barra: p.sutil, espessura-barra: 4pt,
    estilo: "italic", tamanho: 10pt, fonte: fonte,
    espacamento-antes: 0.8em, espacamento-depois: 0.2em,
  )
  set heading(numbering: numeracao)
  corpo
}

// ---------------------------------------------------------------------------
// BARRAS — formas arredondadas e barras coloridas, vibrante
// H1 faixa arredondada · H2 caixa com borda arredondada · H3 badge pill
// H4 bold colorido · H5 itálico colorido
// ---------------------------------------------------------------------------
#let estilo-barras(paleta, fonte: "Linux Biolinum", numeracao: "1.1", corpo) = {
  let p = paleta
  show heading.where(level: 1): it => formatar-secao(it,
    forma: "faixa", fundo: p.primaria, cor: white, cor-numero: p.secundaria,
    peso: "bold", tamanho: 26pt, fonte: fonte, raio: 8pt,
    quebra-pagina: true, espacamento-antes: 2em, espacamento-depois: 1.2em,
  )
  show heading.where(level: 2): it => {
    let num = _num(it)
    v(2.2em, weak: true)
    block(
      width: 100%, stroke: 3pt + p.primaria, radius: 6pt,
      inset: (x: 1em, y: 0.6em),
      {
        set text(fill: p.primaria, size: 17pt, weight: "bold", font: fonte)
        if num != none { num; h(0.5em) }
        it.body
      },
    )
    v(1em, weak: true)
  }
  show heading.where(level: 3): it => formatar-secao(it,
    forma: "emblema", cor: white, fundo: p.secundaria, raio: 10pt,
    peso: "bold", tamanho: 14pt, fonte: fonte,
    espacamento-antes: 1.6em, espacamento-depois: 0.6em,
  )
  show heading.where(level: 4): it => formatar-secao(it,
    forma: "barra", cor: p.texto, cor-barra: p.primaria, espessura-barra: 2pt,
    peso: "semibold", tamanho: 12pt, fonte: fonte,
    espacamento-antes: 1.2em, espacamento-depois: 0.4em,
  )
  show heading.where(level: 5): it => formatar-secao(it,
    forma: "corrido", cor: p.secundaria.darken(30%), estilo: "italic", tamanho: 10.5pt, fonte: fonte,
    espacamento-antes: 0.9em, espacamento-depois: 0.2em,
  )
  set heading(numbering: numeracao)
  corpo
}

// ---------------------------------------------------------------------------
// UNIVERSITÁRIO — acadêmico formal, serifado, hierarquia por réguas
// H1 centralizado caixa-alta + dupla régua · H2 bold + régua · H3–H4 bold/itálico
// ---------------------------------------------------------------------------
#let estilo-universitario(paleta, fonte: "Linux Libertine", numeracao: "1.1", corpo) = {
  let p = paleta
  show heading.where(level: 1): it => formatar-secao(it,
    forma: "bloco", cor: p.texto, peso: "bold", tamanho: 24pt, fonte: fonte,
    caixa: "alta", alinhamento: center, quebra-pagina: true,
    decoracao: {
      v(0.3em)
      line(length: 100%, stroke: 2pt + p.primaria)
      v(0.15em)
      line(length: 100%, stroke: 0.5pt + p.primaria)
    },
    espacamento-antes: 2em, espacamento-depois: 1.2em,
  )
  show heading.where(level: 2): it => {
    let num = _num(it)
    v(2.4em, weak: true)
    block(width: 100%, {
      if num != none {
        text(fill: p.primaria, size: 24pt, weight: "bold", font: fonte, num)
        h(0.7em)
      }
      text(fill: p.texto, size: 16pt, weight: "bold", font: fonte, it.body)
    })
    v(0.25em)
    line(length: 4em, stroke: 2pt + p.primaria)
    v(0.9em, weak: true)
  }
  show heading.where(level: 3): it => formatar-secao(it,
    forma: "faixa", fundo: p.primaria.lighten(88%), cor: p.primaria,
    peso: "bold", tamanho: 13pt, fonte: fonte,
    espacamento-antes: 1.6em, espacamento-depois: 0.6em,
  )
  show heading.where(level: 4): it => formatar-secao(it,
    forma: "bloco", cor: p.texto, peso: "semibold", estilo: "italic", tamanho: 11pt, fonte: fonte,
    espacamento-antes: 1.1em, espacamento-depois: 0.3em,
  )
  show heading.where(level: 5): it => formatar-secao(it,
    forma: "bloco", cor: p.sutil.darken(40%), estilo: "italic", tamanho: 10pt, fonte: fonte,
    espacamento-antes: 0.8em, espacamento-depois: 0.2em,
  )
  set heading(numbering: numeracao)
  corpo
}

// ---------------------------------------------------------------------------
// CENTRALIZADO — tudo centrado, linhas acima e abaixo dos títulos
// Linhas e título ficam progressivamente menores de H1 a H5
// H1  90 % · 3 pt  →  H2  65 % · 2 pt  →  H3  45 % · 1.5 pt
//                  →  H4  28 % · 1 pt   →  H5  14 % · 0.5 pt
// ---------------------------------------------------------------------------
#let estilo-centralizado(paleta, fonte: "Linux Libertine", numeracao: "1.1", corpo) = {
  let p = paleta
  // Linha centrada: bloco de largura pct centralizado contendo line 100%
  let hl(pct, thick, cor) = block(
    width: 100%, above: 0pt, below: 0pt,
    align(center, block(width: pct, above: 0pt, below: 0pt,
      line(length: 100%, stroke: thick + cor)
    ))
  )
  // Bloco de texto centralizado
  let ct(size, weight, cor-texto, num, cor-num, body) = block(
    width: 100%, above: 0pt, below: 0pt,
    align(center, {
      set text(fill: cor-texto, size: size, weight: weight, font: fonte)
      if num != none { text(fill: cor-num, num); h(0.5em) }
      body
    })
  )

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    let num = _num(it)
    v(2em, weak: true)
    hl(90%, 3pt, p.primaria)
    v(0.5em)
    ct(24pt, "bold", p.texto, num, p.primaria, it.body)
    v(0.5em)
    hl(90%, 3pt, p.primaria)
    v(1.2em, weak: true)
  }
  show heading.where(level: 2): it => {
    let num = _num(it)
    v(2.2em, weak: true)
    hl(65%, 2pt, p.primaria)
    v(0.4em)
    ct(17pt, "bold", p.texto, num, p.primaria, it.body)
    v(0.4em)
    hl(65%, 2pt, p.primaria)
    v(1em, weak: true)
  }
  show heading.where(level: 3): it => {
    let num = _num(it)
    v(1.8em, weak: true)
    hl(45%, 1.5pt, p.primaria)
    v(0.35em)
    ct(14pt, "bold", p.texto, num, p.sutil.darken(30%), it.body)
    v(0.35em)
    hl(45%, 1.5pt, p.primaria)
    v(0.8em, weak: true)
  }
  show heading.where(level: 4): it => {
    let num = _num(it)
    v(1.4em, weak: true)
    hl(28%, 1pt, p.sutil.darken(20%))
    v(0.25em)
    ct(11.5pt, "semibold", p.texto, num, p.sutil.darken(20%), it.body)
    v(0.25em)
    hl(28%, 1pt, p.sutil.darken(20%))
    v(0.6em, weak: true)
  }
  show heading.where(level: 5): it => {
    let num = _num(it)
    v(1em, weak: true)
    hl(14%, 0.5pt, p.sutil)
    v(0.2em)
    block(width: 100%, above: 0pt, below: 0pt,
      align(center, {
        set text(fill: p.sutil.darken(40%), size: 10pt, style: "italic", font: fonte)
        if num != none { num; h(0.3em) }
        it.body
      })
    )
    v(0.2em)
    hl(14%, 0.5pt, p.sutil)
    v(0.5em, weak: true)
  }
  set heading(numbering: numeracao)
  corpo
}

// ---------------------------------------------------------------------------
// CAOS — caos controlado: cada nível usa linguagem visual completamente diferente
// H1 banda cinemática + número fantasma · H2 réguas duplas assimétricas
// H3 badge arredondado (UI no doc) · H4 número gigante flutuante
// H5 pílula dividida (cor | texto) · H6 símbolo decorativo + itálico
// ---------------------------------------------------------------------------
#let estilo-caos(paleta, fonte: "Linux Biolinum", numeracao: "1.1", corpo) = {
  let p = paleta

  // H1 — banda de cor cheia, número fantasma ao fundo, faixa secundária abaixo
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    let num = _num(it)
    v(0pt, weak: true)
    block(width: 100%, above: 0pt, below: 0pt, clip: true, {
      block(width: 100%, fill: p.primaria, above: 0pt, below: 0pt, inset: 0pt, {
        if num != none {
          place(right + horizon, dx: 0.5em,
            text(fill: p.primaria.lighten(36%), size: 150pt, weight: "bold", font: fonte, num))
        }
        pad(left: 1.8em, right: 8.5em, top: 1.15em, bottom: 1.15em,
          text(fill: p.fundo, size: 30pt, weight: "bold", font: fonte, it.body))
      })
      block(width: 100%, height: 0.55em, fill: p.secundaria, above: 0pt, below: 0pt)
      block(width: 100%, height: 0.15em, fill: p.primaria.lighten(55%), above: 0pt, below: 0pt)
    })
    v(1.6em, weak: true)
  }

  // H2 — número fantasma grande ao lado + título bold com sublinhado (ex-H4 escalado)
  show heading.where(level: 2): it => {
    let num = _num(it)
    v(2.4em, weak: true)
    if num != none {
      grid(
        columns: (auto, 1fr), column-gutter: 0.5em, align: horizon,
        text(fill: p.primaria.lighten(58%), size: 60pt, weight: "bold", font: fonte, num),
        block(width: 100%, stroke: (bottom: 2.5pt + p.primaria), inset: (bottom: 0.3em),
          text(fill: p.texto, size: 17pt, weight: "bold", font: fonte, it.body)),
      )
    } else {
      block(width: 100%, stroke: (bottom: 2.5pt + p.primaria), inset: (bottom: 0.3em),
        text(fill: p.texto, size: 17pt, weight: "bold", font: fonte, it.body))
    }
    v(0.85em, weak: true)
  }

  // H3 — badge arredondado: caixa colorida com texto branco (UI invadindo o documento)
  show heading.where(level: 3): it => {
    let num = _num(it)
    v(1.8em, weak: true)
    block(above: 0pt, below: 0pt,
      box(fill: p.primaria, radius: 5pt, inset: (x: 1em, y: 0.48em),
        text(fill: p.fundo, size: 13pt, weight: "bold", font: fonte, {
          if num != none { num; h(0.5em) }
          it.body
        })
      )
    )
    v(0.88em, weak: true)
  }

  // H4 — pílula dividida: metade esquerda colorida (número/ícone) · metade direita (título)
  show heading.where(level: 4): it => {
    let num = _num(it)
    v(1.2em, weak: true)
    block(above: 0pt, below: 0pt,
      box(stroke: 1pt + p.primaria, radius: 4pt, inset: 0pt, clip: true,
        grid(
          columns: (auto, auto),
          box(fill: p.primaria, inset: (x: 0.6em, y: 0.4em),
            text(fill: p.fundo, size: 10pt, weight: "bold", font: fonte,
              if num != none { num } else { "◆" }
            )
          ),
          box(fill: p.fundo, inset: (x: 0.75em, y: 0.4em),
            text(fill: p.texto, size: 10.5pt, weight: "semibold", style: "italic", font: fonte,
              it.body
            )
          ),
        )
      )
    )
    v(0.48em, weak: true)
  }

  // H5 — caixa tracejada: moldura pontilhada ao redor do título
  show heading.where(level: 5): it => {
    let num = _num(it)
    v(1.5em, weak: true)
    block(above: 0pt, below: 0pt,
      box(
        stroke: (paint: p.primaria, dash: "dashed", thickness: 1.5pt),
        radius: 3pt,
        inset: (x: 0.85em, y: 0.38em),
        text(fill: p.texto, size: 11.5pt, weight: "semibold", font: fonte, {
          if num != none { text(fill: p.primaria, weight: "bold", num); h(0.5em) }
          it.body
        })
      )
    )
    v(0.55em, weak: true)
  }

  // H6 — diamante decorativo colorido + texto pequeno itálico
  show heading.where(level: 6): it => {
    let num = _num(it)
    v(1em, weak: true)
    block(above: 0pt, below: 0pt, {
      text(fill: p.secundaria, size: 13pt, weight: "bold", "◆ ")
      text(fill: p.texto.lighten(18%), size: 10pt, style: "italic", font: fonte, {
        if num != none { num; h(0.3em) }
        it.body
      })
    })
    v(0.35em, weak: true)
  }

  set heading(numbering: numeracao)
  corpo
}

// ===========================================================================
// TEMAS PRONTOS — pares curados de estilo + paleta
// Uso: #show: tema-revista-vinho
//      #show: tema-revista-vinho.with(numeracao: "I")
// ===========================================================================

// Nórdico (geométrico, sans)
#let tema-periodico-marinho  = estilo-periodico.with(paleta-marinho)
#let tema-periodico-petroleo    = estilo-periodico.with(paleta-petroleo)
#let tema-periodico-ardosia  = estilo-periodico.with(paleta-ardosia)
#let tema-periodico-lilas    = estilo-periodico.with(paleta-lilas)
#let tema-periodico-bosque   = estilo-periodico.with(paleta-bosque)
#let tema-periodico-festiva  = estilo-periodico.with(paleta-festiva)

// Jornal (editorial de jornal)
#let tema-jornal-grafite   = estilo-jornal.with(paleta-grafite)
#let tema-jornal-vinho     = estilo-jornal.with(paleta-vinho)
#let tema-jornal-petroleo     = estilo-jornal.with(paleta-petroleo)

// Revista (editorial de revista)
#let tema-revista-vinho    = estilo-revista.with(paleta-vinho)
#let tema-revista-pastel   = estilo-revista.with(paleta-pastel)
#let tema-revista-lilas    = estilo-revista.with(paleta-lilas)
#let tema-revista-grafite   = estilo-revista.with(paleta-grafite)
#let tema-revista-bosque   = estilo-revista.with(paleta-bosque)
#let tema-revista-festiva  = estilo-revista.with(paleta-festiva)

// Infantil (arredondado, educacional)
#let tema-barras-solar   = estilo-barras.with(paleta-solar)
#let tema-barras-pastel  = estilo-barras.with(paleta-pastel)
#let tema-barras-lilas   = estilo-barras.with(paleta-lilas)
#let tema-barras-bosque  = estilo-barras.with(paleta-bosque)
#let tema-barras-festiva = estilo-barras.with(paleta-festiva)

// Universitário (acadêmico, serifado)
#let tema-universitario-marinho  = estilo-universitario.with(paleta-marinho)
#let tema-universitario-vinho    = estilo-universitario.with(paleta-vinho)
#let tema-universitario-grafite  = estilo-universitario.with(paleta-grafite)
#let tema-universitario-bosque   = estilo-universitario.with(paleta-bosque)
#let tema-universitario-ardosia  = estilo-universitario.with(paleta-ardosia)

// Profissional (corporativo, sans)
#let tema-centralizado-grafite   = estilo-centralizado.with(paleta-grafite)
#let tema-centralizado-pastel    = estilo-centralizado.with(paleta-pastel)
#let tema-centralizado-ardosia   = estilo-centralizado.with(paleta-ardosia)
#let tema-centralizado-solar     = estilo-centralizado.with(paleta-solar)

// Caos (caos controlado, cada nível com linguagem visual diferente)
#let tema-caos-grafite   = estilo-caos.with(paleta-grafite)
#let tema-caos-festiva   = estilo-caos.with(paleta-festiva)
#let tema-caos-ardosia   = estilo-caos.with(paleta-ardosia)
#let tema-caos-lilas     = estilo-caos.with(paleta-lilas)
#let tema-caos-solar     = estilo-caos.with(paleta-solar)

// Aliases para compatibilidade com secoes.typ
#let tema-periodico = tema-periodico-marinho
#let tema-vinho   = estilo-periodico.with(paleta-vinho, fonte: "Linux Libertine")
#let tema-bosque  = estilo-universitario.with(paleta-bosque, fonte: "Linux Biolinum")
