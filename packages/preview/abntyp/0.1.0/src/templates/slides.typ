// Template para Apresentacao de Slides Academicos
//
// IMPORTANTE: NAO EXISTE NORMA ABNT ESPECIFICA PARA SLIDES
//
// A ABNT (Associacao Brasileira de Normas Tecnicas) nao possui nenhuma norma
// dedicada a apresentacoes de slides. Nao ha regras oficiais para:
// - Fonte, tamanho ou espacamento
// - Layout ou quantidade de texto por slide
// - Estrutura ou organizacao do conteudo
// - Cores ou elementos visuais
//
// Este template oferece um formato padronizado para apresentacoes academicas
// baseado em boas praticas e convencoes comuns em instituicoes brasileiras,
// mas NAO representa uma exigencia normativa da ABNT.
//
// Normas ABNT que PODEM ser aplicadas em slides (quando relevante):
// - NBR 6023:2018 - Referencias bibliograficas (se houver citacoes)
// - NBR 10520:2023 - Citacoes em documentos (formato autor-data)
//
// Baseado no pacote Touying para Typst
// Documentacao: https://touying-typ.github.io/docs/intro/

#import "@preview/touying:0.6.1": *
#import themes.simple: *
#import themes.university: *

// Re-exportar funcoes de citacao do ABNTyp para uso em slides
#import "../references/citation.typ": citar, citar-autor, citar-multiplos, citar-etal, citar-entidade, citar-titulo

// =============================================================================
// TEMPLATE PRINCIPAL: slides()
// =============================================================================

/// Template principal para apresentacao de slides academicos
///
/// NOTA: Nao existe norma ABNT para slides. Este template segue boas praticas
/// academicas comuns no Brasil, mas nao representa exigencia normativa.
///
/// Parametros:
/// - titulo: titulo da apresentacao
/// - subtitulo: subtitulo (opcional)
/// - autor: nome do autor/apresentador
/// - orientador: orientador (opcional, para defesas de TCC/dissertacao/tese)
/// - instituicao: nome da instituicao
/// - departamento: departamento/programa (opcional)
/// - data: data da apresentacao (padrao: data atual)
/// - logo: logotipo da instituicao (opcional, imagem)
/// - proporcao: proporcao da tela ("16-9" ou "4-3", padrao: "16-9")
/// - fonte: fonte a usar (padrao: "Arial")
/// - cor-primaria: cor principal (padrao: azul institucional)
/// - cor-secundaria: cor secundaria (opcional)
#let slides(
  titulo: "",
  subtitulo: none,
  autor: "",
  orientador: none,
  instituicao: "",
  departamento: none,
  data: datetime.today(),
  logo: none,
  proporcao: "16-9",
  fonte: "Arial",
  cor-primaria: rgb("#003366"),
  cor-secundaria: rgb("#666666"),
  body,
) = {
  // Nota sobre ausencia de norma ABNT
  // (Este comentario serve como documentacao para quem ler o codigo-fonte)
  // A ABNT nao possui norma especifica para apresentacoes de slides.
  // As escolhas de formatacao neste template sao baseadas em:
  // 1. Boas praticas de design de apresentacoes
  // 2. Convencoes comuns em instituicoes academicas brasileiras
  // 3. Recomendacoes de legibilidade (fonte 18-24pt para corpo)

  // Configuracao do documento
  set document(
    title: titulo,
    author: autor,
  )

  // Configuracao de texto base
  set text(
    font: fonte,
    lang: "pt",
    region: "BR",
  )

  // Aplicar tema Touying com configuracoes academicas
  show: simple-theme.with(
    aspect-ratio: proporcao,
    primary: cor-primaria,
    secondary: cor-secundaria,
    footer: [#instituicao #h(1fr) #autor],
  )

  // Slide de titulo personalizado
  touying-slide-wrapper(self => {
    touying-slide(self: self, setting: body => {
      set align(center + horizon)
      body
    })[
      // Logo (se fornecido)
      #if logo != none {
        logo
        v(0.5em)
      }

      // Instituicao
      #text(size: 18pt, fill: cor-secundaria, upper(instituicao))

      #if departamento != none {
        linebreak()
        text(size: 14pt, fill: cor-secundaria, departamento)
      }

      #v(1em)

      // Titulo
      #text(size: 32pt, weight: "bold", fill: cor-primaria, titulo)

      // Subtitulo
      #if subtitulo != none {
        linebreak()
        v(0.3em)
        text(size: 20pt, fill: cor-secundaria, subtitulo)
      }

      #v(1.5em)

      // Autor
      #text(size: 18pt, autor)

      // Orientador (para defesas)
      #if orientador != none {
        linebreak()
        v(0.3em)
        text(size: 14pt)[Orientador(a): #orientador]
      }

      #v(1em)

      // Data
      #text(size: 14pt, fill: cor-secundaria)[
        #data.display("[day] de [month repr:long] de [year]")
      ]
    ]
  })

  // Conteudo da apresentacao
  body
}

// =============================================================================
// TEMPLATE PARA DEFESA DE TCC/DISSERTACAO/TESE
// =============================================================================

/// Template especializado para defesa de trabalho academico
///
/// NOTA: Nao existe norma ABNT para slides de defesa. Este template segue
/// convencoes comuns em bancas de defesa no Brasil.
///
/// Parametros adicionais alem de slides():
/// - grau: grau pretendido (ex: "Bacharel em Ciencia da Computacao")
/// - programa: programa de pos-graduacao (para mestrado/doutorado)
/// - banca: membros da banca (lista de nomes)
#let slides-defesa(
  titulo: "",
  subtitulo: none,
  autor: "",
  orientador: none,
  coorientador: none,
  instituicao: "",
  departamento: none,
  grau: none,
  programa: none,
  banca: (),
  data: datetime.today(),
  logo: none,
  proporcao: "16-9",
  fonte: "Arial",
  cor-primaria: rgb("#003366"),
  cor-secundaria: rgb("#666666"),
  body,
) = {
  // Configuracao do documento
  set document(
    title: titulo,
    author: autor,
  )

  set text(
    font: fonte,
    lang: "pt",
    region: "BR",
  )

  show: simple-theme.with(
    aspect-ratio: proporcao,
    primary: cor-primaria,
    secondary: cor-secundaria,
    footer: [#instituicao #h(1fr) Defesa de #if programa != none { "Dissertacao/Tese" } else { "TCC" }],
  )

  // Slide de titulo para defesa
  touying-slide-wrapper(self => {
    touying-slide(self: self, setting: body => {
      set align(center + horizon)
      body
    })[
      #if logo != none {
        logo
        v(0.3em)
      }

      #text(size: 16pt, fill: cor-secundaria, upper(instituicao))

      #if departamento != none {
        linebreak()
        text(size: 12pt, fill: cor-secundaria, departamento)
      }

      #if programa != none {
        linebreak()
        text(size: 12pt, fill: cor-secundaria, programa)
      }

      #v(0.8em)

      #text(size: 28pt, weight: "bold", fill: cor-primaria, titulo)

      #if subtitulo != none {
        linebreak()
        v(0.2em)
        text(size: 18pt, fill: cor-secundaria, subtitulo)
      }

      #v(1em)

      #text(size: 16pt, autor)

      #v(0.5em)

      #grid(
        columns: if coorientador != none { (1fr, 1fr) } else { (1fr,) },
        gutter: 1em,
        text(size: 12pt)[
          *Orientador(a):* \
          #orientador
        ],
        if coorientador != none {
          text(size: 12pt)[
            *Coorientador(a):* \
            #coorientador
          ]
        },
      )

      #v(0.5em)

      #if grau != none {
        text(size: 11pt, fill: cor-secundaria)[
          Trabalho apresentado para obtencao do grau de #grau
        ]
      }

      #v(0.3em)

      #text(size: 12pt, fill: cor-secundaria)[
        #data.display("[day] de [month repr:long] de [year]")
      ]
    ]
  })

  body

  // Slide final com agradecimentos (padrao em defesas)
  touying-slide-wrapper(self => {
    touying-slide(self: self, setting: body => {
      set align(center + horizon)
      body
    })[
      #text(size: 36pt, weight: "bold", fill: cor-primaria)[
        Obrigado!
      ]

      #v(1em)

      #text(size: 18pt)[Perguntas?]

      #v(2em)

      #if banca.len() > 0 {
        text(size: 14pt, fill: cor-secundaria)[
          *Banca Examinadora:* \
          #banca.join(" | ")
        ]
      }
    ]
  })
}

// =============================================================================
// FUNCOES AUXILIARES PARA SLIDES
// =============================================================================

/// Slide de sumario/agenda
///
/// Uso comum em apresentacoes academicas para mostrar estrutura
#let slide-sumario(
  titulo: "Sumario",
  itens: (),
  cor-primaria: rgb("#003366"),
) = {
  touying-slide-wrapper(self => {
    touying-slide(self: self)[
      #text(size: 24pt, weight: "bold")[#titulo]
      #v(0.5em)
      #set text(size: 20pt)
      #set enum(numbering: "1.", body-indent: 1em)

      #for (i, item) in itens.enumerate() {
        [#text(fill: cor-primaria, weight: "bold", str(i + 1) + ".") #item \ ]
        v(0.5em)
      }
    ]
  })
}

/// Slide de secao (divisor)
///
/// Usado para marcar inicio de nova secao da apresentacao
#let slide-secao(
  titulo: "",
  subtitulo: none,
  cor-primaria: rgb("#003366"),
) = {
  touying-slide-wrapper(self => {
    touying-slide(self: self, setting: body => {
      set align(center + horizon)
      body
    })[
      #text(size: 36pt, weight: "bold", fill: cor-primaria, titulo)

      #if subtitulo != none {
        v(0.5em)
        text(size: 20pt, fill: cor-primaria.lighten(30%), subtitulo)
      }
    ]
  })
}

/// Slide com citacao em destaque
///
/// Para apresentar citacoes importantes de forma visual
/// Segue NBR 10520:2023 para formato da citacao
#let slide-citacao(
  quote: "",
  autor: "",
  ano: "",
  pagina: none,
  cor-primaria: rgb("#003366"),
) = {
  touying-slide-wrapper(self => {
    touying-slide(self: self, setting: body => {
      set align(center + horizon)
      body
    })[
      #box(
        width: 80%,
        inset: 2em,
        stroke: (left: 4pt + cor-primaria),
        fill: cor-primaria.lighten(95%),
      )[
        #set text(size: 22pt, style: "italic")
        #set par(leading: 1.2em)
        "#quote"
      ]

      #v(1em)

      // Formato NBR 10520:2023 para citacao
      #text(size: 16pt, fill: cor-primaria)[
        (#upper(autor), #ano#if pagina != none [, p. #pagina])
      ]
    ]
  })
}

/// Slide de referencias
///
/// NOTA: As referencias em slides devem seguir NBR 6023:2018
/// Este e um dos poucos aspectos onde uma norma ABNT se aplica
#let slide-referencias(
  titulo: "Referencias",
  itens: (),
) = {
  touying-slide-wrapper(self => {
    touying-slide(self: self)[
      #text(size: 24pt, weight: "bold")[#titulo]
      #v(0.5em)
      #set text(size: 14pt)
      #set par(
        hanging-indent: 1em,
        first-line-indent: 0pt,
        leading: 0.8em,
      )

      // Nota sobre a norma aplicavel
      #text(size: 10pt, fill: gray)[
        _Formatacao conforme NBR 6023:2018_
      ]

      #v(0.5em)

      #for item in itens {
        item
        v(0.3em)
      }
    ]
  })
}

/// Slide de figura com fonte
///
/// Quando incluir figuras de terceiros, a fonte deve ser citada
/// seguindo as normas de citacao (NBR 10520:2023)
#let slide-figura(
  titulo: none,
  imagem: none,
  legenda: none,
  origem: none,
  ano-fonte: none,
) = {
  touying-slide-wrapper(self => {
    touying-slide(self: self)[
      #if titulo != none {
        text(size: 24pt, weight: "bold", titulo)
        v(0.5em)
      }
      #align(center)[
        #if imagem != none { imagem }

        #if legenda != none {
          v(0.5em)
          text(size: 14pt, weight: "bold", legenda)
        }

        #if origem != none {
          v(0.3em)
          text(size: 12pt, fill: gray)[
            Fonte: #if ano-fonte != none {
              [(#upper(origem), #ano-fonte)]
            } else {
              origem
            }
          ]
        }
      ]
    ]
  })
}

/// Slide comparativo (duas colunas)
#let slide-comparativo(
  titulo: "",
  titulo-esquerda: "",
  conteudo-esquerda: [],
  titulo-direita: "",
  conteudo-direita: [],
  cor-primaria: rgb("#003366"),
) = {
  touying-slide-wrapper(self => {
    touying-slide(self: self)[
      #text(size: 24pt, weight: "bold")[#titulo]
      #v(0.5em)
      #grid(
        columns: (1fr, 1fr),
        gutter: 2em,

        // Coluna esquerda
        [
          #align(center)[
            #text(weight: "bold", fill: cor-primaria, size: 18pt, titulo-esquerda)
          ]
          #v(0.5em)
          #conteudo-esquerda
        ],

        // Coluna direita
        [
          #align(center)[
            #text(weight: "bold", fill: cor-primaria, size: 18pt, titulo-direita)
          ]
          #v(0.5em)
          #conteudo-direita
        ],
      )
    ]
  })
}

/// Slide de metodologia
///
/// Formato comum para apresentar metodologia de pesquisa
#let slide-metodologia(
  titulo: "Metodologia",
  tipo-pesquisa: none,
  abordagem: none,
  procedimentos: (),
  instrumentos: (),
  cor-primaria: rgb("#003366"),
) = {
  touying-slide-wrapper(self => {
    touying-slide(self: self)[
      #text(size: 24pt, weight: "bold")[#titulo]
      #v(0.5em)
      #grid(
        columns: (1fr, 1fr),
        gutter: 1.5em,
        row-gutter: 1em,

        if tipo-pesquisa != none {
          [
            #text(weight: "bold", fill: cor-primaria)[Tipo de Pesquisa] \
            #tipo-pesquisa
          ]
        },

        if abordagem != none {
          [
            #text(weight: "bold", fill: cor-primaria)[Abordagem] \
            #abordagem
          ]
        },

        if procedimentos.len() > 0 {
          [
            #text(weight: "bold", fill: cor-primaria)[Procedimentos] \
            #list(..procedimentos)
          ]
        },

        if instrumentos.len() > 0 {
          [
            #text(weight: "bold", fill: cor-primaria)[Instrumentos] \
            #list(..instrumentos)
          ]
        },
      )
    ]
  })
}

/// Slide de resultados com destaque numerico
#let slide-resultado-numerico(
  titulo: "Resultados",
  itens: (), // Lista de (valor, descricao)
  cor-primaria: rgb("#003366"),
) = {
  touying-slide-wrapper(self => {
    touying-slide(self: self)[
      #text(size: 24pt, weight: "bold")[#titulo]
      #v(0.5em)
      #set align(center)

      #if itens.len() > 0 {
        grid(
          columns: itens.len(),
          gutter: 2em,

          ..itens.map(item => {
            box(
              inset: 1em,
              [
                #text(size: 48pt, weight: "bold", fill: cor-primaria, item.at(0)) \
                #text(size: 14pt, item.at(1))
              ]
            )
          })
        )
      }
    ]
  })
}

// =============================================================================
// FUNCOES DE ANIMACAO (TOUYING)
// =============================================================================

// Re-exportar funcoes de animacao do Touying para conveniencia
// Estas permitem revelacao progressiva de conteudo

/// Pausa - conteudo apos #pause aparece no proximo clique
/// Exemplo:
/// - Primeiro item
/// #pause
/// - Segundo item (aparece depois)
#let slide-pause = pause

/// Revelacao condicional
/// only(2)[Este texto so aparece no passo 2]
/// only("2-")[Este texto aparece do passo 2 em diante]
/// only("1, 3")[Este texto aparece nos passos 1 e 3]
#let slide-only = only

/// Revelacao com espaco reservado
/// uncover(2)[Este texto fica invisivel ate o passo 2, mas ocupa espaco]
#let slide-uncover = uncover

// =============================================================================
// ESTILOS DE COR PRE-DEFINIDOS
// =============================================================================

/// Cores institucionais comuns em universidades brasileiras
#let cores-usp = (primary: rgb("#004A8F"), secondary: rgb("#FFB81C"))
#let cores-unicamp = (primary: rgb("#003366"), secondary: rgb("#C41230"))
#let cores-unesp = (primary: rgb("#1E3A5F"), secondary: rgb("#B8860B"))
#let cores-ufrj = (primary: rgb("#003366"), secondary: rgb("#FF6600"))
#let cores-ufmg = (primary: rgb("#003366"), secondary: rgb("#FFD700"))
#let cores-ufrgs = (primary: rgb("#003366"), secondary: rgb("#C8102E"))
#let cores-ufsc = (primary: rgb("#003366"), secondary: rgb("#007A33"))
#let cores-ufpr = (primary: rgb("#003366"), secondary: rgb("#C8102E"))
#let cores-unb = (primary: rgb("#003366"), secondary: rgb("#006633"))
#let cores-ufpe = (primary: rgb("#800000"), secondary: rgb("#FFD700"))

// Cores neutras para uso geral
#let cores-academico = (primary: rgb("#003366"), secondary: rgb("#666666"))
#let cores-moderno = (primary: rgb("#2C3E50"), secondary: rgb("#E74C3C"))
#let cores-clean = (primary: rgb("#34495E"), secondary: rgb("#3498DB"))

// =============================================================================
// DOCUMENTACAO E AVISOS
// =============================================================================

/// Funcao para inserir nota sobre ausencia de norma ABNT
/// Pode ser usada no primeiro slide ou em slide de metodologia
#let nota-sem-norma-abnt() = {
  text(size: 10pt, fill: gray, style: "italic")[
    Nota: A ABNT nao possui norma especifica para apresentacoes de slides. \
    Este formato segue boas praticas academicas, nao exigencias normativas.
  ]
}

/// Aviso sobre citacoes em slides
/// Para uso quando houver citacoes na apresentacao
#let aviso-citacoes() = {
  text(size: 10pt, fill: gray, style: "italic")[
    Citacoes formatadas conforme NBR 10520:2023. \
    Referencias conforme NBR 6023:2018.
  ]
}
