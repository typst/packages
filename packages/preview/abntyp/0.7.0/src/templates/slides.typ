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

#import "@preview/touying:0.7.4": *
#import themes.simple: *

// Re-exportar funcoes de citacao do ABNTyp para uso em slides
#import "../references/citation.typ": citar, citar-autor, citar-multiplos, citar-etal, citar-entidade, citar-titulo
#import "../core/dates.typ": format-date

// Data da capa: texto/conteudo entra como veio; datetime sai em portugues ("5 de março de 2025")
#let _data-slide(data) = {
  assert(type(data) in (datetime, str, content), message: "slides: data: deve ser datetime(...), texto ou conteúdo")
  if type(data) == datetime { format-date(data) } else { data }
}

// Reduz o conteudo, so se for preciso, para caber na area livre do slide
// (sem isso o excesso vira outra pagina, sem titulo e sem rodape)
#let _cabe(corpo) = block(width: 100%, height: 1fr, layout(area => {
  let m = measure(width: area.width, corpo)
  align(center + horizon, if m.height > area.height {
    scale(area.height / m.height * 100%, reflow: true, corpo)
  } else {
    corpo
  })
}))

// Autor(es) como texto corrido; aceita um nome ou uma lista de nomes
#let _autores(autor) = if type(autor) == array { autor.join(", ", last: " e ") } else { autor }

// =============================================================================
// TEMPLATE PRINCIPAL: slides()
// =============================================================================

/// Template principal para apresentacao de slides academicos
///
/// NOTA: Nao existe norma ABNT para slides. Este template segue boas praticas
/// academicas comuns no Brasil, mas nao representa exigencia normativa.
///
/// Parametros:
/// - titulo: titulo da apresentacao (vazio deixa o titulo do PDF em branco)
/// - subtitulo: subtitulo (opcional)
/// - autor: nome do autor/apresentador, ou lista de nomes
/// - orientador: orientador (opcional, para defesas de TCC/dissertacao/tese)
/// - instituicao: nome da instituicao
/// - departamento: departamento/programa (opcional)
/// - data: data da apresentacao: `datetime(...)` (sai "20 de agosto de 2025"),
///   texto ou conteudo (sai como foi escrito); padrao: data atual
/// - logo: logotipo da instituicao (opcional, imagem; passe `image(..., alt: "...")`)
/// - proporcao: razao da tela "L-A": "16-9" (padrao), "4-3", "16-10"...
/// - fonte: fonte a usar (padrao: "Arial"). Sem Arial no sistema (ex.: servidor
///   Linux), o Typst avisa e cai numa serifada: passe `fonte: "Liberation Sans"`
/// - cor-primaria: cor principal (padrao: azul institucional); chega a todos os
///   slides auxiliares (`slide-*`)
/// - cor-secundaria: cor dos textos secundarios da capa; use contraste >= 4,5:1
///   sobre branco (as `cores-*` prontas ja respeitam)
/// - ..config: configuracoes do touying repassadas ao tema, p. ex.
///   `config-common(show-notes-on-second-screen: right)` para ver as
///   `#speaker-note[...]` ao lado do slide (sem isso elas nao aparecem no PDF)
///
/// Tamanhos: corpo 25 pt, titulos 30 pt, rodape 15 pt. Cada slide deve caber numa
/// pagina: o touying nao corta nem avisa, e o excesso (inclusive o que ainda esta
/// oculto por `#pause`) sai em outra pagina, sem titulo e sem rodape.
/// A capa e o slide 1 do contador "N / total", que conta slides, nao paginas.
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
  ..config,
  body,
) = {
  // Nota sobre ausencia de norma ABNT
  // (Este comentario serve como documentacao para quem ler o codigo-fonte)
  // A ABNT nao possui norma especifica para apresentacoes de slides.
  // As escolhas de formatacao neste template sao baseadas em:
  // 1. Boas praticas de design de apresentacoes
  // 2. Convencoes comuns em instituicoes academicas brasileiras
  // 3. Recomendacoes de legibilidade (corpo em 25 pt e texto auxiliar a partir de 16 pt)

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
    config-colors(secondary: cor-secundaria, neutral-light: luma(90)),
    footer: instituicao,
    footer-right: context [#_autores(autor) #h(1em) #utils.slide-counter.display() / #utils.last-slide-number],
    ..config,
  )

  // Slide de titulo personalizado
  touying-slide-wrapper(self => {
    touying-slide(self: self, setting: body => {
      set align(center + horizon)
      set par(spacing: 0.4em)
      body
    })[
      #_cabe[
        // Logo (se fornecido)
        #if logo != none {
          logo
          v(8pt)
        }

        // Instituicao
        #text(size: 20pt, fill: cor-secundaria, upper(instituicao))

        #if departamento != none {
          text(size: 16pt, fill: cor-secundaria, departamento)
        }

        #v(16pt)

        // Titulo
        #text(size: 32pt, weight: "bold", fill: cor-primaria, titulo)

        // Subtitulo
        #if subtitulo != none {
          text(size: 22pt, fill: cor-secundaria, subtitulo)
        }

        #v(24pt)

        // Autor
        #text(size: 20pt, _autores(autor))

        // Orientador (para defesas)
        #if orientador != none {
          text(size: 16pt)[Orientador(a): #orientador]
        }

        #v(16pt)

        // Data
        #text(size: 16pt, fill: cor-secundaria)[
          #_data-slide(data)
        ]
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
/// - coorientador: coorientador (opcional)
/// - grau: grau pretendido (ex: "Bacharel em Ciencia da Computacao")
/// - programa: programa de pos-graduacao (para mestrado/doutorado); com ele o
///   rodape diz "Defesa de Dissertação/Tese", sem ele "Defesa de TCC"
/// - banca: membros da banca (lista de nomes), no slide final "Obrigado!"
///   (o slide final sempre e anexado)
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
  ..config,
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
    config-colors(secondary: cor-secundaria, neutral-light: luma(90)),
    footer: instituicao,
    footer-right: context [Defesa de #if programa != none { "Dissertação/Tese" } else { "TCC" } #h(1em) #utils.slide-counter.display() / #utils.last-slide-number],
    ..config,
  )

  // Slide de titulo para defesa
  touying-slide-wrapper(self => {
    touying-slide(self: self, setting: body => {
      set align(center + horizon)
      set par(spacing: 0.4em)
      body
    })[
      #_cabe[
        #if logo != none {
          logo
          v(6pt)
        }

        #text(size: 18pt, fill: cor-secundaria, upper(instituicao))

        #if departamento != none {
          text(size: 16pt, fill: cor-secundaria, departamento)
        }

        #if programa != none {
          text(size: 16pt, fill: cor-secundaria, programa)
        }

        #v(14pt)

        #text(size: 28pt, weight: "bold", fill: cor-primaria, titulo)

        #if subtitulo != none {
          text(size: 20pt, fill: cor-secundaria, subtitulo)
        }

        #v(18pt)

        #text(size: 20pt, _autores(autor))

        #v(10pt)

        #grid(
          columns: if orientador != none and coorientador != none { (1fr, 1fr) } else { (1fr,) },
          gutter: 1em,
          ..(
            if orientador != none {
              (text(size: 16pt)[*Orientador(a):* \ #orientador],)
            },
            if coorientador != none {
              (text(size: 16pt)[*Coorientador(a):* \ #coorientador],)
            },
          ).filter(c => c != none).flatten(),
        )

        #v(10pt)

        #if grau != none {
          text(size: 16pt, fill: cor-secundaria)[
            Trabalho apresentado para obtenção do grau de #grau
          ]
        }

        #v(8pt)

        #text(size: 16pt, fill: cor-secundaria)[
          #_data-slide(data)
        ]
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
//
// Todas passam pela funcao `slide` do tema: ganham cabecalho, rodape e numero
// iguais aos dos slides de `==`, e o `titulo:` vira um `==` de verdade (aparece
// no indice do PDF). Com `titulo: ""` vale o `==` escrito antes da chamada.
// Cada slide deve caber numa pagina: o touying nao corta nem avisa, e o excesso
// sai em outra pagina sem titulo e sem rodape. `slide-citacao` e `slide-figura`
// se reduzem sozinhos; nos demais, limite o conteudo.

#let _slide-aux(titulo, centro: false, corpo) = {
  if titulo != none and titulo != "" { heading(depth: 2, titulo) }
  slide(
    config: if centro { config-common(subslide-preamble: none) } else { (:) },
    setting: if centro { body => { set align(center + horizon); body } } else { body => body },
    corpo,
  )
}

// Cor de destaque: a do tema (`cor-primaria` de `slides()`), salvo `cor-primaria:` na chamada
#let _cor(self, cor-primaria) = if cor-primaria == auto { self.colors.primary } else { cor-primaria }

/// Slide de sumario/agenda
///
/// Uso comum em apresentacoes academicas para mostrar estrutura
/// - titulo: titulo do slide (padrao: "Sumário")
/// - itens: lista de textos; cerca de 6 cabem na pagina
/// - cor-primaria: cor dos numeros (padrao: a do tema)
#let slide-sumario(
  titulo: "Sumário",
  itens: (),
  cor-primaria: auto,
) = _slide-aux(titulo, self => {
  let cor = _cor(self, cor-primaria)
  set text(size: 20pt)

  for (i, item) in itens.enumerate() {
    [#text(fill: cor, weight: "bold", str(i + 1) + ".") #item \ ]
    v(0.5em)
  }
})

/// Slide de secao (divisor)
///
/// Usado para marcar inicio de nova secao da apresentacao
/// (`= Titulo` tambem cria um slide de secao, no estilo do tema)
#let slide-secao(
  titulo: "",
  subtitulo: none,
  cor-primaria: auto,
) = _slide-aux("", centro: true, self => {
  let cor = _cor(self, cor-primaria)
  text(size: 36pt, weight: "bold", fill: cor, titulo)

  if subtitulo != none {
    v(0.5em)
    text(size: 24pt, fill: cor, subtitulo)
  }
})

/// Slide com citacao em destaque
///
/// Para apresentar citacoes importantes de forma visual. A chamada usa `citar`
/// (NBR 10520:2023: "(Silva, 2020, p. 12)"; escreva o sobrenome so com a inicial
/// maiuscula). O destaque grande e em italico e uma adaptacao para projecao: nao
/// e o formato de citacao direta longa (recuada, letra menor, sem aspas, 7.1.1).
/// Citacoes longas diminuem sozinhas para caber no slide.
#let slide-citacao(
  quote: "",
  autor: "",
  ano: "",
  pagina: none,
  cor-primaria: auto,
) = {
  assert(quote != "" and autor != "", message: "slide-citacao: informe quote: e autor:")
  _slide-aux("", centro: true, self => {
    let cor = _cor(self, cor-primaria)
    _cabe[
      #box(
        width: 80%,
        inset: 2em,
        stroke: (left: 4pt + cor),
        fill: cor.lighten(95%),
      )[
        #set text(size: 22pt, style: "italic")
        #set par(leading: 1.2em)
        "#quote"
      ]

      #v(1em)

      #text(size: 18pt, fill: cor, citar(autor, ano, pagina: pagina))
    ]
  })
}

/// Slide de referencias
///
/// As referencias sao digitadas por voce: formate-as pela NBR 6023:2018
/// (margem esquerda, sem recuo, titulo em negrito). Cerca de 5 cabem na pagina.
#let slide-referencias(
  titulo: "Referências",
  itens: (),
) = _slide-aux(titulo, [
  #set text(size: 16pt)
  #set par(first-line-indent: 0pt, leading: 0.8em)
  #show strong: it => text(fill: black, weight: "bold", it.body)

  #for item in itens {
    item
    v(0.6em)
  }
])

/// Slide de figura com fonte
///
/// Quando incluir figuras de terceiros, a fonte deve ser citada
/// (NBR 10520:2023). Passe `image(..., alt: "descrição")`: sem ela o PDF
/// acessivel (`--pdf-standard ua-1`) da erro. Imagens altas diminuem sozinhas.
#let slide-figura(
  titulo: none,
  imagem: none,
  legenda: none,
  origem: none,
  ano-fonte: none,
) = _slide-aux(titulo, _cabe[
  #align(center)[
    #if imagem != none { imagem }

    #if legenda != none {
      v(0.5em)
      text(size: 16pt, weight: "bold", legenda)
    }

    #if origem != none {
      v(0.3em)
      text(size: 16pt, fill: luma(90))[
        Fonte: #if ano-fonte != none {
          citar(origem, ano-fonte)
        } else {
          origem
        }
      ]
    }
  ]
])

/// Slide comparativo (duas colunas)
#let slide-comparativo(
  titulo: "",
  titulo-esquerda: "",
  conteudo-esquerda: [],
  titulo-direita: "",
  conteudo-direita: [],
  cor-primaria: auto,
) = _slide-aux(titulo, self => {
  let cor = _cor(self, cor-primaria)
  grid(
    columns: (1fr, 1fr),
    gutter: 2em,

    // Coluna esquerda
    [
      #align(center)[
        #text(weight: "bold", fill: cor, size: 20pt, titulo-esquerda)
      ]
      #v(0.5em)
      #conteudo-esquerda
    ],

    // Coluna direita
    [
      #align(center)[
        #text(weight: "bold", fill: cor, size: 20pt, titulo-direita)
      ]
      #v(0.5em)
      #conteudo-direita
    ],
  )
})

/// Slide de metodologia
///
/// Formato comum para apresentar metodologia de pesquisa
#let slide-metodologia(
  titulo: "Metodologia",
  tipo-pesquisa: none,
  abordagem: none,
  procedimentos: (),
  instrumentos: (),
  cor-primaria: auto,
) = _slide-aux(titulo, self => {
  let cor = _cor(self, cor-primaria)
  let procedimentos = if procedimentos == none { () } else { procedimentos }
  let instrumentos = if instrumentos == none { () } else { instrumentos }
  set text(size: 20pt)
  grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    row-gutter: 1em,

    if tipo-pesquisa != none {
      [
        #text(weight: "bold", fill: cor)[Tipo de Pesquisa] \
        #tipo-pesquisa
      ]
    },

    if abordagem != none {
      [
        #text(weight: "bold", fill: cor)[Abordagem] \
        #abordagem
      ]
    },

    if procedimentos.len() > 0 {
      [
        #text(weight: "bold", fill: cor)[Procedimentos] \
        #list(..procedimentos)
      ]
    },

    if instrumentos.len() > 0 {
      [
        #text(weight: "bold", fill: cor)[Instrumentos] \
        #list(..instrumentos)
      ]
    },
  )
})

/// Slide de resultados com destaque numerico
/// - itens: lista de pares `(valor, descricao)`, ex.: `(("92%", "acurácia"), (3, "rodadas"))`
#let slide-resultado-numerico(
  titulo: "Resultados",
  itens: (), // Lista de (valor, descricao)
  cor-primaria: auto,
) = {
  for item in itens {
    assert(type(item) == array and item.len() == 2, message: "slide-resultado-numerico: cada item deve ser um par (valor, descrição)")
  }
  _slide-aux(titulo, self => {
    let cor = _cor(self, cor-primaria)
    set align(center)

    if itens.len() > 0 {
      grid(
        columns: itens.len(),
        gutter: 2em,

        ..itens.map(item => {
          box(
            inset: 1em,
            [
              #text(size: 48pt, weight: "bold", fill: cor)[#item.at(0)] \
              #text(size: 18pt)[#item.at(1)]
            ]
          )
        })
      )
    }
  })
}

// =============================================================================
// FUNCOES DE ANIMACAO (TOUYING)
// =============================================================================

/// Muda de slide de forma explicita.
/// - `#novo-slide()` — comeca um novo slide, sem titulo
/// - `#novo-slide(titulo: "Titulo")` — novo slide com titulo (equivale a `== Titulo`)
/// - o conteudo pode vir em seguida, entre colchetes: `#novo-slide(titulo: "X")[...]`
#let novo-slide(titulo: none, ..corpo) = {
  if titulo != none { heading(depth: 2, titulo) } else { pagebreak() }
  corpo.pos().join()
}

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

/// Sugestoes de cores no estilo de universidades brasileiras (sem fonte oficial:
/// confira o manual de identidade da sua instituicao).
/// A cor secundaria vira cor de TEXTO na capa; as prontas foram escurecidas ate
/// contraste >= 4,5:1 sobre branco (WCAG AA), por isso nao sao o tom exato da marca.
#let cores-usp = (primary: rgb("#004A8F"), secondary: rgb("#996E11"))
#let cores-unicamp = (primary: rgb("#003366"), secondary: rgb("#C41230"))
#let cores-unesp = (primary: rgb("#1E3A5F"), secondary: rgb("#996F09"))
#let cores-ufrj = (primary: rgb("#003366"), secondary: rgb("#C95100"))
#let cores-ufmg = (primary: rgb("#003366"), secondary: rgb("#8A7400"))
#let cores-ufrgs = (primary: rgb("#003366"), secondary: rgb("#C8102E"))
#let cores-ufsc = (primary: rgb("#003366"), secondary: rgb("#007A33"))
#let cores-ufpr = (primary: rgb("#003366"), secondary: rgb("#C8102E"))
#let cores-unb = (primary: rgb("#003366"), secondary: rgb("#006633"))
#let cores-ufpe = (primary: rgb("#800000"), secondary: rgb("#8A7400"))

// Cores neutras para uso geral
#let cores-academico = (primary: rgb("#003366"), secondary: rgb("#666666"))
#let cores-moderno = (primary: rgb("#2C3E50"), secondary: rgb("#D24537"))
#let cores-clean = (primary: rgb("#34495E"), secondary: rgb("#2A7BB1"))

// =============================================================================
// DOCUMENTACAO E AVISOS
// =============================================================================

/// Funcao para inserir nota sobre ausencia de norma ABNT
/// Pode ser usada no primeiro slide ou em slide de metodologia
#let nota-sem-norma-abnt() = {
  text(size: 16pt, fill: luma(90), style: "italic")[
    Nota: A ABNT não possui norma específica para apresentações de slides. \
    Este formato segue boas práticas acadêmicas, não exigências normativas.
  ]
}

/// Aviso sobre citacoes em slides
/// Para uso quando houver citacoes na apresentacao
#let aviso-citacoes() = {
  text(size: 16pt, fill: luma(90), style: "italic")[
    Citações e referências: NBR 10520:2023 e NBR 6023:2018 (aplicadas pelo autor, não pelo template).
  ]
}
