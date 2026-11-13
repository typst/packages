// touying-ufac-unofficial — code blocks. The theme does not depend on codly: without it, every block goes in the box of
// the theme (a light fill with a bar on the left, square corners), with the line numbers from Typst's `raw.line`, the
// language in a pill with its logo and the output of a program (`text`) in gray. With codly 2, which the deck imports
// and passes to the theme (`ufac-theme(codly: codly)`), the same look is applied through codly's own theme
// (`codly-ufac-theme`, plain data) and rules. Inside a colored box (an exercise, an `emph-box`) a block keeps its look.
#import "constants.typ": colors
#import "utils.typ": _tr, _words
#import "components.typ": icon

/// The syntax colors of the code blocks: a tmTheme with the palette of the theme and general scopes (comments in
/// green, strings in red, keywords in blue, numbers in ochre), which suits any language.
/// -> bytes
#let ufac-syntax = read("../assets/ufac.tmTheme", encoding: none)

/// Languages whose block is the output of a program: the gray box, without line numbers.
/// -> array
#let _output-langs = ("text", "txt", "output")

/// Colors of the box of a block: the bar, the fill and the thin border; blue for code, gray for an output. The same
/// everywhere: inside a colored box a block keeps its own look.
///
/// #test(`_box-colors("python").bar == colors.primary`, `_box-colors("text").bar == colors.neutral-dark`)
/// -> dictionary
#let _box-colors(
  /// Language of the block. -> str | none
  lang,
) = if lang in _output-langs {
  (bar: colors.neutral-dark, fill: colors.neutral.lighten(94%), edge: colors.neutral-lighter)
} else {
  (bar: colors.primary, fill: colors.primary.lighten(96%), edge: colors.primary.lighten(60%))
}

/// The languages the theme knows: the name in the pill of a block and its icon (a name of `icon`, content or `none`).
/// The languages with a logo show it; the shell (`bash`, `sh`) shows a colored terminal. `ufac-theme(code-languages:)`
/// adds languages or replaces any of them except the output, in the same format. The output (`text`, `txt`,
/// `output`) is "Saída" / "Output" / "Salida" in the language of the deck (`name: auto`).
///
/// #test(`code-languages.python.name == "Python"`, `code-languages.text.name == auto`,
///   `code-languages.bash.icon == "shell"`)
/// -> dictionary
#let code-languages = (
  python: (name: "Python", icon: "python"),
  py: (name: "Python", icon: "python"),
  typst: (name: "Typst", icon: "typst"),
  typ: (name: "Typst", icon: "typst"),
  matlab: (name: "MATLAB", icon: "matlab"),
  bash: (name: "Bash", icon: "shell"),
  sh: (name: "Shell", icon: "shell"),
  text: (name: auto, icon: "output"),
  txt: (name: auto, icon: "output"),
  output: (name: auto, icon: "output"),
)

/// An icon of height `size`, centered on the capitals of the text around it, as the icons of the pills.
/// -> content
#let _centered(
  /// Function of the absolute size that gives the icon. -> function
  make,
  /// Height of the icon. -> length
  size,
) = context {
  let cap = measure(text(top-edge: "cap-height", bottom-edge: "baseline")[X]).height
  let s = size.to-absolute()
  box(baseline: (s - cap) / 2, make(s))
}

/// Icon of a language, in `c` (the logos keep their colors), centered on the capitals of the name: the name of an
/// `icon` or content (the icon of the codly-languages package).
/// -> content | none
#let _lang-icon(
  /// Icon of the language. -> none | str | content
  ic,
  /// Color of a one-color icon. -> color
  c,
) = if ic == none { none } else if type(ic) == str {
  _centered(s => icon(ic, color: c, size: s, baseline: 0pt), 1em)
} else { _centered(s => box(height: s, ic), 1em) }

/// Pill of the language of a block: white, with the border and the text in `c`, the icon and the name. The border is the
/// color lightened 55%: a darker one weighed on the slide, mostly on a reduced one, where the PDF viewer draws the thin
/// stroke with a whole pixel.
/// -> content | none
#let _label(
  /// The languages, see `code-languages`. -> dictionary
  langs,
  /// Language of the block. -> str | none
  lang,
  /// Color of the pill. -> color
  c,
) = {
  let l = if type(lang) == str { langs.at(lang, default: none) }
  if l == none { return none }
  let ic = _lang-icon(l.at("icon", default: none), c)
  let name = l.at("name", default: lang)
  text(size: 0.72em, weight: "bold", fill: c, box(fill: white, stroke: 0.6pt + c.lighten(55%), radius: 0.42em,
    inset: (x: 0.55em, y: 0.28em), {
      if ic != none { ic; h(0.3em) }
      if name == auto { _tr("output") } else { name }
    }))
}

/// The UFAC theme for codly 2, a dictionary in the format of its themes, for `codly.theme(..)`: the theme exports only
/// data and codly applies it. The blue box (the bar on the left is drawn by a rule of the theme, since codly's border is
/// the same on the four sides), the line numbers in light blue, the file name on a light blue band, the highlights in the
/// colors of the theme and the syntax colors of `ufac-syntax`. `ufac-theme(codly: codly)` applies it; it is exported
/// for a document that applies codly by itself.
/// -> dictionary
#let codly-ufac-theme = {
  let c = colors.primary
  (
    syntax: ufac-syntax,
    fill: c.lighten(96%),
    stroke: 0.5pt + c.lighten(60%),
    radius: 0pt,
    inset: (x: 0.3em, y: 0.16em),
    muted: c.lighten(45%),
    accent: c,
    language-colors: false,
    header-fill: c.lighten(88%),
    highlight-colors: (colors.secondary, colors.quaternary, colors.tertiary, colors.primary, colors.neutral),
    highlight: (radius: 0pt),
    number: (text: (size: 0.8em)),
    // the language pill that codly draws, for a language the theme does not know; the theme draws the pill of the
    // others (`_label`, through `lang-show_`)
    lang: (fill: _ => white, stroke: _ => 0.6pt + c.lighten(55%), radius: 0.42em,
      inset: (x: 0.45em, y: 0.15em), text: (size: 0.72em, weight: "bold", fill: c)),
    file: (fill: none, stroke: none, radius: 0pt, text: (size: 0.8em, weight: "bold", fill: c.darken(30%))),
    block: (padding: (left: 0.45em, right: 0.3em, y: 0.25em)),
  )
}

/// `codly-ufac-theme` in the gray box of the output of a program.
/// -> dictionary
#let _codly-output-theme = codly-ufac-theme + (
  fill: colors.neutral.lighten(94%),
  stroke: 0.5pt + colors.neutral-lighter,
  muted: colors.neutral-dark,
  accent: colors.neutral-dark,
  lang: codly-ufac-theme.lang + (stroke: _ => 0.6pt + colors.neutral-dark.lighten(55%),
    text: (size: 0.72em, weight: "bold", fill: colors.neutral-dark)),
)

/// Code blocks through codly 2: the two themes (code and output), the language pills of the theme, the file icon
/// before the file name, the bar on the left and the rule that turns every block into codly's. `codly` is the module the
/// deck imported; a module of codly 1 (or anything else) is an error that tells what to import.
/// -> content
#let _with-codly(
  /// The module of codly 2. -> module
  codly,
  /// The languages, see `code-languages`. -> dictionary
  langs,
  /// The deck. -> content
  body,
) = {
  let names = dictionary(codly)
  assert("new" in names and "theme" in names, message: "ufac-theme: codly is the module of codly 2 "
    + "(#import \"@preview/codly:2.0.0\" as codly); codly 1 is not supported")
  show: codly.theme(codly-ufac-theme)
  // the languages in codly's format, the icon already as content in the color of its box
  let languages = langs.pairs().map(((k, l)) => {
    let c = _box-colors(k).bar
    let name = l.at("name", default: k)
    (k, (name: if name == auto { _tr("output") } else { name }, color: c,
      icon: _lang-icon(l.at("icon", default: none), c)))
  }).to-dict()
  show: codly.lang-set_(languages: languages)
  // the language pill drawn by `_label`, as without codly: the key of the language comes in the `body` of codly's
  // element, read through the elembic module codly exposes (`codly.e`)
  let pill = codly.lang-show_(it => {
    let lang = codly.e.fields(it).at("body", default: none)
    let label = _label(langs, lang, _box-colors(lang).bar)
    if label == none { it } else { label }
  })
  show: pill
  // the file name with the file icon before it
  show: codly.file-show_(it => [#_centered(s => icon("file", size: s, color: colors.primary, baseline: 0pt), 1em) #it])
  // the bar on the left, by a rule on codly's element (also for a `codly.new(..)` written in the deck). codly's `diff`
  // builds inner passes, which have the field `__diff-pass` and get no bar
  show: codly.show_(it => {
    let f = codly.e.fields(it)
    if f.at("__diff-pass", default: none) != none { return it }
    let lang = f.at("lang", default: auto)
    let lang = if lang == auto and type(f.body) == content and f.body.has("lang") { f.body.lang } else { lang }
    block(width: 100%, stroke: (left: 2.5pt + _box-colors(lang).bar), clip: true, it)
  })
  // the syntax colors on the plain blocks too: the `syntax` of codly's theme only reaches a `codly.new(..)` written in
  // the deck, and a plain block reaches the rule below with Typst's default colors already set
  show raw.where(block: true): set raw(theme: ufac-syntax)
  show raw.where(block: true): it => if it.lang in _output-langs {
    show: codly.theme(_codly-output-theme)
    // the theme of the output brings codly's own pill back: the pill of the theme again, as on the other blocks
    show: pill
    show: codly.set_(number-enabled: false)
    codly.new(it)
  } else { codly.new(it) }
  body
}

/// Code blocks without codly: the box of the theme around the block (the bar, the fill and the thin border, in the
/// color of code or output), the language pill at the top right (the first line leaves its width free), the line numbers
/// from `raw.line` (not in an output) and the syntax colors of `ufac-syntax`.
/// -> content
#let _native(
  /// The languages, see `code-languages`. -> dictionary
  langs,
  /// The deck. -> content
  body,
) = {
  show raw.where(block: true): set raw(theme: ufac-syntax)
  show raw.where(block: true): it => {
    let k = _box-colors(it.lang)
    block(width: 100%, fill: k.fill, stroke: (left: 2.5pt + k.bar, top: 0.5pt + k.edge, right: 0.5pt + k.edge,
      bottom: 0.5pt + k.edge), inset: (left: 0.6em, right: 0.4em, y: 0.45em), breakable: true, {
        let label = _label(langs, it.lang, k.bar)
        if label != none { place(top + right, label) }
        // the first line leaves the width of the pill free, so a long one wraps before it instead of running under it
        context {
          let free = if label != none { measure(label).width + 0.4em }
          let first(l) = if l.number == 1 and free != none { box(width: 1fr, l.body); h(free) } else { box(width: 1fr, l.body) }
          if it.lang in _output-langs {
            show raw.line: l => if l.number == 1 and free != none { first(l) } else { l }
            it
          } else {
            // the code of a line in a box with the rest of the width: a line that wraps continues under the code, not
            // under the number, and the number stays on the baseline of the first line
            show raw.line: l => {
              box(width: 1.4em, align(right, text(fill: k.bar.lighten(45%), size: 0.8em, str(l.number))))
              h(0.7em)
              first(l)
            }
            it
          }
        }
      })
  }
  body
}

/// The code rules of the deck: codly 2 when the deck passed it (`self.store.codly`), the native box otherwise, with the
/// languages of the theme completed by `ufac-theme(code-languages:)`.
/// -> content
#let _code-rules(
  /// Touying's `self`, or a stand-in with `store`. -> dictionary
  self,
  /// The deck. -> content
  body,
) = {
  let extra = self.store.at("code-languages", default: (:))
  let langs = code-languages + extra.pairs().map(((k, l)) => (k, (name: l.at("name", default: k),
    icon: l.at("icon", default: none)))).to-dict()
  // the output keeps the name and the icon of the theme, even when the deck's dictionary has a `text`; its name is the
  // word of the language of the deck, read here: inside a code block `text.lang` is not the deck's
  let out = _words(self.store.at("lang", default: "pt")).output
  let langs = langs + _output-langs.map(k => (k, code-languages.at(k) + (name: out))).to-dict()
  let codly = self.store.at("codly", default: none)
  if codly == none { _native(langs, body) } else { _with-codly(codly, langs, body) }
}
