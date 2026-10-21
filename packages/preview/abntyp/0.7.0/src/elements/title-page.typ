// Folha de rosto conforme NBR 14724:2024
// Anverso: autor, título, natureza, orientador, local, ano

#import "../core/spacing.typ": nature-block, abnt-leading
#import "../core/metadata.typ"
#import "../core/page.typ": marcar-folha-rosto, marcar-ficha, abre-anverso

/// Cria folha de rosto conforme ABNT
#let folha-rosto(
  autor: none,
  titulo: none,
  subtitulo: none,
  natureza: none,        // Natureza do trabalho (dissertação, tese, TCC)
  objetivo: none,        // Objetivo (obtenção de grau)
  instituicao: none,
  area: none,            // Área de concentração
  orientador: none,      // Orientador
  coorientador: none,    // Coorientador
  volume: none,          // Número do volume, se houver mais de um (14724 4.2.1.1.1 d)
  local: none,
  ano: none,
) = {
  abre-anverso()
  set page(numbering: none)
  marcar-folha-rosto()

  context {
    let autor = metadata._resolve(autor, "autor")
    let titulo = metadata._resolve(titulo, "titulo")
    let subtitulo = metadata._resolve(subtitulo, "subtitulo")
    let natureza = metadata._resolve(natureza, "natureza")
    let objetivo = metadata._resolve(objetivo, "objetivo")
    let instituicao = metadata._resolve(instituicao, "instituicao")
    let area = metadata._resolve(area, "area")
    let orientador = metadata._resolve(orientador, "orientador")
    let coorientador = metadata._resolve(coorientador, "coorientador")
    let volume = metadata._resolve(volume, "volume")
    let local = metadata._resolve(local, "local")
    let ano = metadata._resolve(ano, "ano")

    set align(center)

    // Autor
    if autor != none {
      text(size: 12pt, upper(autor))
    }

    v(1fr)

    // Título (maiúsculas, negrito) + subtítulo
    metadata._render-titulo(titulo, subtitulo: subtitulo)

    // Volume (se houver)
    if volume != none {
      linebreak()
      linebreak()
      text(size: 12pt)[v. #volume]
    }

    v(2cm)

    // Natureza do trabalho (recuo de 8cm, espaço simples, corpo 12: 14724 5.1)
    if natureza != none or objetivo != none or orientador != none {
      set align(right)
      box(width: 8cm)[
        #set align(left)
        #set par(
          leading: abnt-leading(1),
          spacing: abnt-leading(1),
          first-line-indent: 0pt,
          justify: true,
        )

        #if natureza != none { natureza }
        #if objetivo != none { [ #objetivo] }
        #if instituicao != none { linebreak(); instituicao }
        #if area != none { linebreak(); [Área de concentração: #area] }

        #if orientador != none {
          linebreak()
          linebreak()
          [Orientador: #orientador]
        }

        #if coorientador != none {
          linebreak()
          [Coorientador: #coorientador]
        }
      ]
    }

    v(1fr)

    // Local e ano
    set align(center)
    if local != none {
      text(size: 12pt, upper(local))
      linebreak()
    }

    if ano != none {
      text(size: 12pt, metadata._str-safe(ano))
    }
  }

  pagebreak()
}

/// Verso da folha de rosto (ficha catalográfica)
/// Deve ocupar a parte inferior da página
#let ficha-catalografica(conteudo) = {
  set page(numbering: none)
  marcar-ficha()
  v(1fr)

  align(center)[
    #box(
      width: 12.5cm,
      height: 7.5cm,
      stroke: 0.5pt,
      inset: 0.5cm,
    )[
      #set text(size: 10pt)
      #set par(leading: abnt-leading(1), spacing: abnt-leading(1))
      #conteudo
    ]
  ]

  pagebreak()
}

/// Folha de aprovação (NBR 14724 4.2.1.3, elemento obrigatório): autor, título,
/// natureza, instituição, área de concentração, data de aprovação e banca
/// examinadora. Vai depois da folha de rosto (e da ficha, se houver). Os dados que
/// faltam vêm de `dados()`.
/// - data: data de aprovação (texto); sem ela sai uma linha em branco, para
///   preencher depois da defesa (a norma permite)
/// - banca: membros da banca; cada um é um dicionário
///   `(nome: "…", titulacao: "…", instituicao: "…")` ou um texto/conteúdo.
///   Cada membro ganha uma linha para a assinatura.
#let folha-aprovacao(
  autor: none,
  titulo: none,
  subtitulo: none,
  natureza: none,
  objetivo: none,
  instituicao: none,
  area: none,
  data: none,
  banca: (),
) = {
  abre-anverso()
  set page(numbering: none)

  context {
    let autor = metadata._resolve(autor, "autor")
    let titulo = metadata._resolve(titulo, "titulo")
    let subtitulo = metadata._resolve(subtitulo, "subtitulo")
    let natureza = metadata._resolve(natureza, "natureza")
    let objetivo = metadata._resolve(objetivo, "objetivo")
    let instituicao = metadata._resolve(instituicao, "instituicao")
    let area = metadata._resolve(area, "area")

    set par(
      leading: abnt-leading(1),
      spacing: abnt-leading(1),
      first-line-indent: 0pt,
    )

    align(center)[
      #if autor != none { upper(autor) }

      #v(1fr)

      #metadata._render-titulo(titulo, subtitulo: subtitulo)
    ]

    v(1.5cm)

    if natureza != none or objetivo != none {
      align(right, box(width: 8cm, align(left)[
        #set par(justify: true)
        #if natureza != none { natureza }
        #if objetivo != none { [ #objetivo] }
        #if instituicao != none { linebreak(); instituicao }
        #if area != none { linebreak(); [Área de concentração: #area] }
      ]))
    }

    v(1cm)

    [Aprovada em: #if data != none { data } else { [#h(1.5cm)/#h(1.5cm)/#h(2.5cm)] }]

    v(1cm)

    align(center)[
      BANCA EXAMINADORA

      #for membro in banca {
        v(1.5cm)
        line(length: 10cm, stroke: 0.5pt)
        if type(membro) == dictionary {
          let titulacao = membro.at("titulacao", default: none)
          if titulacao != none { [#titulacao ] }
          membro.at("nome", default: none)
          if "instituicao" in membro { linebreak(); membro.instituicao }
        } else { membro }
      }
    ]

    v(1fr)
  }

  pagebreak()
}

// Aliases curtos
#let rosto = folha-rosto
#let ficha = ficha-catalografica
