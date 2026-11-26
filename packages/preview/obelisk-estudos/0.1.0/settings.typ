// Padrões do pacote, combinação das configurações e estado resolvido.

#import "theme.typ": def-theme, themes

// Papel: por padrão, um retângulo na proporção 1 : sqrt(2) (A4).
#let def-paper-width = 21cm
#let def-paper = (
  width: def-paper-width,
  height: def-paper-width * calc.sqrt(2),
)

// Margens proporcionais à largura do papel. `e` (externa) recebe as notas laterais.
#let def-margin = (
  t: def-paper-width / 9,
  f: def-paper-width / 6,
  e: def-paper-width / 4,
  s: def-paper-width / 9,
)

#let def-side = (
  half-gutter: 0.3cm, // espaço entre o texto principal e as notas laterais
  margin: def-margin.s / 3, // espaço adicional até a borda do papel
)

// `step` define a grade de linhas: linhas de base consecutivas ficam separadas
// por esse valor. `ascender` é medido por `init` a partir da fonte do corpo.
#let def-texts = (
  size: 11pt,
  step: 7.5pt,
)

#let def-fonts = (
  body: "XCharter",
  math: "TeX Gyre Pagella Math",
  sans: "Hanken Grotesk",
  mono: "IBM Plex Mono",
)

#let def-headings = (
  h2: (
    sym: sym.circle.filled,
    dy: 0pt,
    size: 2,
  ),
  h3: (
    sym: sym.triangle.filled.small.b,
    dy: 0pt,
    size: 1.5,
  ),
  thm: (
    base: 1, // nível de título em que a numeração dos blocos reinicia
    numbering: "1.1.1", // <matéria>.<assunto>.<bloco>
  ),
)

// Preenche recursivamente entradas ausentes (ou `none`) com os valores padrão.
// Nenhum dos argumentos é alterado.
#let merge-defaults(user, defaults) = {
  if type(defaults) != dictionary {
    return if user == none { defaults } else { user }
  }
  if type(user) != dictionary {
    return defaults
  }
  let merged = (:)
  for (key, default) in defaults {
    merged.insert(key, merge-defaults(user.at(key, default: none), default))
  }
  for (key, value) in user {
    if not merged.keys().contains(key) {
      merged.insert(key, value)
    }
  }
  merged
}

// Combina a configuração do usuário com os padrões e deriva os valores
// calculados: área do texto, largura da margem lateral e dicionário do tema.
#let resolve-settings(paper, margin, side, texts, fonts, headings, theme) = {
  let s = merge-defaults(
    (
      paper: paper,
      margin: margin,
      side: side,
      texts: texts,
      fonts: fonts,
      headings: headings,
      theme: theme,
    ),
    (
      paper: def-paper,
      margin: def-margin,
      side: def-side,
      texts: def-texts,
      fonts: def-fonts,
      headings: def-headings,
      theme: def-theme,
    ),
  )

  if not themes.keys().contains(s.theme) {
    panic("Unknown theme: " + str(s.theme))
  }

  s.side.width = s.margin.e - s.side.margin - s.side.half-gutter
  s.body = (
    width: s.paper.width - s.margin.s - s.margin.e,
    height: s.paper.height - s.margin.t - s.margin.f,
  )
  s.theme = themes.at(s.theme)
  s
}

// Estado publicado por `init` e lido pelos demais módulos.
#let settings = state("obelisk:settings", none)
