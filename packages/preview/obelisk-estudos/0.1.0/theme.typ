// Sistema de temas: cada tema reúne as cores e os traços do documento.

// Padrão contínuo de listras brancas a 45° sobre uma cor de base, usado nos
// traços listrados dos ambientes do tema `monochrome`.
#let mono-stripes(
  bg,
  fg: white,
  spacing: 4pt,
  thickness: 1.4pt,
) = tiling(
  size: (spacing, spacing),
  {
    place(rect(width: 100%, height: 100%, fill: bg))
    place(line(
      start: (-50%, 100%),
      end: (100%, -50%),
      stroke: thickness + fg,
    ))
    place(line(
      start: (0%, 150%),
      end: (150%, 0%),
      stroke: thickness + fg,
    ))
  },
)

// O estilo de um ambiente pode ser uma cor ou `(color: .., pattern: ..)`.
// Esta função normaliza ambas as formas para `(label:, paint:)`.
#let theorem-style(theme, key) = {
  let style = theme.theorem.at(key)
  if type(style) == dictionary {
    (label: style.color, paint: style.pattern)
  } else {
    (label: style, paint: style)
  }
}

#let themes = (
  default: (
    page: white,
    text: black,
    line: luma(180),
    muted: luma(150),
    faint: luma(210),
    strong: luma(60),
    theorem: (
      theorem: rgb("#1e3a8a"),
      proposition: rgb("#5b21b6"),
      corollary: rgb("#0e7490"),
      lemma: rgb("#065f46"),
      definition: rgb("#991b1b"),
      example: rgb("#475569"),
      remark: rgb("#854d0e"),
    ),
  ),
  monochrome: (
    page: white,
    text: black,
    line: luma(180),
    muted: luma(150),
    faint: luma(210),
    strong: luma(60),
    theorem: (
      theorem: luma(40),
      proposition: (color: luma(40), pattern: mono-stripes(luma(40))),
      corollary: luma(110),
      lemma: (color: luma(110), pattern: mono-stripes(luma(110))),
      definition: luma(180),
      example: (color: luma(180), pattern: mono-stripes(luma(180))),
      remark: (color: luma(180), pattern: mono-stripes(luma(180))),
    ),
  ),
  // Flexoki claro (https://stephango.com/flexoki)
  flexoki-light: (
    page: rgb("#FFFCF0"),
    text: rgb("#100F0F"),
    line: rgb("#DAD8CE"),
    muted: rgb("#6F6E69"),
    faint: rgb("#E6E4D9"),
    strong: rgb("#282726"),
    theorem: (
      theorem: rgb("#205EA6"),
      proposition: rgb("#5E409D"),
      corollary: rgb("#24837B"),
      lemma: rgb("#66800B"),
      definition: rgb("#AF3029"),
      example: rgb("#6F6E69"),
      remark: rgb("#AD8301"),
    ),
  ),
  // Flexoki escuro (https://stephango.com/flexoki)
  flexoki-dark: (
    page: rgb("#100F0F"),
    text: rgb("#FFFCF0"),
    line: rgb("#565753"),
    muted: rgb("#6F6E69"),
    faint: rgb("#282726"),
    strong: rgb("#CECDC3"),
    theorem: (
      theorem: rgb("#4385BE"),
      proposition: rgb("#8B7EC8"),
      corollary: rgb("#3AA99F"),
      lemma: rgb("#879A39"),
      definition: rgb("#D14D41"),
      example: rgb("#6F6E69"),
      remark: rgb("#D0A215"),
    ),
  ),
  // Solarized claro (https://ethanschoonover.com/solarized/)
  solarized-light: (
    page: rgb("#FDF6E3"),
    text: rgb("#839496"),
    line: rgb("#EEE8D5"),
    muted: rgb("#93A1A1"),
    faint: rgb("#EEE8D5"),
    strong: rgb("#073642"),
    theorem: (
      theorem: rgb("#268BD2"),
      proposition: rgb("#6C71C4"),
      corollary: rgb("#2AA198"),
      lemma: rgb("#859900"),
      definition: rgb("#CB4B16"),
      example: rgb("#586E75"),
      remark: rgb("#B58900"),
    ),
  ),
  // GitHub claro
  github-light: (
    page: rgb("#FFFFFF"),
    text: rgb("#1F2328"),
    line: rgb("#D0D7DE"),
    muted: rgb("#656D76"),
    faint: rgb("#EAECF2"),
    strong: rgb("#1B1F23"),
    theorem: (
      theorem: rgb("#0969DA"),
      proposition: rgb("#8250DF"),
      corollary: rgb("#1A7F37"),
      lemma: rgb("#1A7F37"),
      definition: rgb("#CF222E"),
      example: rgb("#57606A"),
      remark: rgb("#9A6700"),
    ),
  ),
  // Atom One claro (https://github.com/atom/atom/tree/master/packages/one-light-syntax)
  one-light: (
    page: rgb("#FAFAFA"),
    text: rgb("#383A42"),
    line: rgb("#E5E5E6"),
    muted: rgb("#A0A1A7"),
    faint: rgb("#F0F0F1"),
    strong: rgb("#1B1D1E"),
    theorem: (
      theorem: rgb("#4078F2"),
      proposition: rgb("#A626A4"),
      corollary: rgb("#0184BC"),
      lemma: rgb("#50A14F"),
      definition: rgb("#E45649"),
      example: rgb("#A0A1A7"),
      remark: rgb("#C18401"),
    ),
  ),
  // Everforest claro médio (https://github.com/sainnhe/everforest)
  everforest-light: (
    page: rgb("#FDF6E3"),
    text: rgb("#5C6A72"),
    line: rgb("#E6E2CC"),
    muted: rgb("#829181"),
    faint: rgb("#EFEBD4"),
    strong: rgb("#5C6A72"),
    theorem: (
      theorem: rgb("#35A77C"),
      proposition: rgb("#DF69BA"),
      corollary: rgb("#3A94C5"),
      lemma: rgb("#8DA101"),
      definition: rgb("#F85552"),
      example: rgb("#829181"),
      remark: rgb("#DFA000"),
    ),
  ),
  // Catppuccin Latte (https://github.com/catppuccin/catppuccin)
  catppuccin-latte: (
    page: rgb("#EFF1F5"),
    text: rgb("#4C4F69"),
    line: rgb("#CCD0DA"),
    muted: rgb("#8C8FA1"),
    faint: rgb("#E6E9EF"),
    strong: rgb("#4C4F69"),
    theorem: (
      theorem: rgb("#8839EF"),
      proposition: rgb("#EA76CB"),
      corollary: rgb("#1E66F5"),
      lemma: rgb("#40A02B"),
      definition: rgb("#D20F39"),
      example: rgb("#9CA0B0"),
      remark: rgb("#DF8E1D"),
    ),
  ),
  // Rosé Pine Dawn (https://rosepinetheme.com)
  rose-pine-dawn: (
    page: rgb("#FAF4ED"),
    text: rgb("#575279"),
    line: rgb("#DFDAD9"),
    muted: rgb("#9893A5"),
    faint: rgb("#F2E9E1"),
    strong: rgb("#797593"),
    theorem: (
      theorem: rgb("#B4637A"),
      proposition: rgb("#907AA9"),
      corollary: rgb("#286973"),
      lemma: rgb("#56949F"),
      definition: rgb("#D7827E"),
      example: rgb("#797593"),
      remark: rgb("#EA9D34"),
    ),
  ),
  // Rosé Pine Moon (https://rosepinetheme.com)
  rose-pine-moon: (
    page: rgb("#232136"),
    text: rgb("#E0DEF4"),
    line: rgb("#44415A"),
    muted: rgb("#6E6A86"),
    faint: rgb("#393552"),
    strong: rgb("#908CAA"),
    theorem: (
      theorem: rgb("#EB6F92"),
      proposition: rgb("#C4A7E7"),
      corollary: rgb("#31748F"),
      lemma: rgb("#9CCFD8"),
      definition: rgb("#EBBCBA"),
      example: rgb("#908caa"),
      remark: rgb("#F6C177"),
    ),
  ),
  // Rosé Pine (https://rosepinetheme.com)
  rose-pine: (
    page: rgb("#191724"),
    text: rgb("#e0def4"),
    line: rgb("#403d52"),
    muted: rgb("#636a86"),
    faint: rgb("#21202e"),
    strong: rgb("#908caa"),
    theorem: (
      theorem: rgb("#eb6f92"),
      proposition: rgb("#c4a7e7"),
      corollary: rgb("#31748f"),
      lemma: rgb("#9ccfd8"),
      definition: rgb("#ebbcba"),
      example: rgb("#908caa"),
      remark: rgb("#f6c177"),
    ),
  ),
)

// Tema aplicado quando nenhum é especificado.
#let def-theme = "default"
