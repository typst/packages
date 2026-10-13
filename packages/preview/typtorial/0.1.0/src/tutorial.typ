// typtorial: step-by-step code tutorials as PDF slides or as a website.

// Maps file names, extensions and languages to the icons in `icons/`
// (Material Icon Theme, MIT license).
#let icon-mapping = json("icons/mapping.json")

// Icon matching the file name, falling back to the code block's language; `none` if nothing matches.
#let file-icon(file, lang) = {
  let name = lower(file.split("/").last())
  let parts = name.split(".")
  let icon = icon-mapping.filenames.at(name, default: none)
  // Longest extension first, so that `d.ts` is found before `ts`.
  for i in range(1, parts.len()) {
    if icon == none {
      icon = icon-mapping.extensions.at(parts.slice(i).join("."), default: none)
    }
  }
  if icon == none and lang != none {
    icon = icon-mapping.languages.at(lower(lang), default: none)
  }
  if icon != none { image("icons/" + icon + ".svg", height: 1.1em) }
}

// Default theme: applies to every tutorial that does not pass its own `theme`.
// The file must exist, but may be empty.
#let default-theme = yaml("../themes/default.theme.yaml")

// Themes that ship with the package, e.g. `tutorial.with(theme: themes.paper)`.
#let themes = (
  default: default-theme,
  paper: yaml("../themes/paper.theme.yaml"),
  crimson: yaml("../themes/crimson.theme.yaml"),
  signal: yaml("../themes/signal.theme.yaml"),
)

// Markers that switch the diff highlighting off and on again in the middle of a tutorial:
// write `#diff-off` before the code blocks that should be shown plainly, `#diff-on` after.
#let diff-off = metadata((typtorial: "diff-off"))
#let diff-on = metadata((typtorial: "diff-on"))

// Labels of the website's controls per language; English is the fallback.
#let copy-labels = (
  en: (copy: "Copy", copied: "Copied", step: "Step", theme: "Switch between light and dark", download: "Download source file", next: "Continue"),
  de: (copy: "Kopieren", copied: "Kopiert", step: "Schritt", theme: "Zwischen hell und dunkel wechseln", download: "Quelldatei herunterladen", next: "Weiter"),
)

// `title`: title of the tutorial, shown at the top left of every page.
// `lang`: language of the tutorial's text, e.g. "en" or "de".
// `mode`: "light" or "dark"; picks the color scheme of the PDF. The website contains both
//         and follows the reader's system setting, with a button to switch.
// `abstract`: short summary shown before the first step, on its own page or below the title
//             on the title page, depending on the theme.
// `source`: text of the tutorial's source file, e.g. `read("my-tutorial.typ")`; the website
//           then offers it as a download under the name `source-name`.
// `diff`: compare each code block with the previous block of the same file and highlight
//         the changes; `false` shows every block plainly, e.g. for unrelated excerpts.
//         While it is on, `#diff-off` and `#diff-on` in the text switch it for a stretch.
// `show-removed`: show removed code lines highlighted in red; `false` drops them.
// `logo`: image shown at the top right, e.g. `image("logo.svg")`; `logo-dark` is the variant
//         for the dark color scheme and defaults to `logo`.
// `theme`: fonts, colors, brand text and layout, e.g. `yaml("my.theme.yaml")`.
//           Each setting is looked up there first, then in the package's
//           `themes/default.theme.yaml` and finally in the built-in defaults below. A `dark`
//           section with its own `colors` holds the values for the dark color scheme.
// `fonts`, `sizes`, `colors`, `brand`, `layout`, `dark`: the same settings as in a theme file, given
//           directly, e.g. `colors: (accent: "#239dad")`. They override the theme file.
#let tutorial(
  title: none,
  lang: "en",
  mode: "light",
  abstract: none,
  source: none,
  source-name: "tutorial.typ",
  diff: true,
  show-removed: true,
  logo: none,
  logo-dark: auto,
  theme: (:),
  fonts: (:),
  sizes: (:),
  colors: (:),
  brand: (:),
  layout: (:),
  dark: (:),
  body,
) = {
  // Settings passed directly rank above the theme file.
  let overrides = (fonts: fonts, sizes: sizes, colors: colors, brand: brand, layout: layout, dark: dark)
  // A package cannot open files of the document that uses it, so a file name is not enough.
  assert(
    type(theme) == dictionary,
    message: "theme must be a dictionary; load a theme file with yaml(\"my.theme.yaml\")",
  )
  let builtin = (
    fonts: (
      text: ("Hanken Grotesk", "Helvetica Neue", "Arial", "Liberation Sans", "DejaVu Sans"),
      code: "DejaVu Sans Mono",
      brand: "Libertinus Serif",
    ),
    // Font sizes in pt; the website scales its own sizes by the same proportions.
    sizes: (text: 14, heading: 15, title: 17, title-page: 30, brand: 20, code: 10.9),
    colors: (
      background: "#fdfdfd",
      text: "#19181f",
      accent: "#239dad",
      heading: "#239dad",
      line: "#e4e5ea",
      code-background: "#eff0f3",
      header: none,
      header-text: none,
      code-text: none,
      background-gradient: none,
      button: "#127885",
      button-text: "#ffffff",
      heading-background: none,
      title-background: none,
      title-text: none,
      abstract-background: none,
      abstract-text: none,
    ),
    brand: (text: "typtorial"),
    layout: (
      dots: false,
      corner-radius: 0.5,
      code-border: false,
      title-underline: false,
      title-uppercase: false,
      text-position: "center",
      title-page: true,
      abstract: "with-title",
    ),
    dark: (
      colors: (
        background: "#15141a",
        text: "#e4e5ea",
        accent: "#3fb8c8",
        heading: "#3fb8c8",
        line: "#2e2d36",
        code-background: "#1f1e26",
        button: "#127885",
        button-text: "#ffffff",
      ),
    ),
  )
  let dark-of(source) = if source != none { source.at("dark", default: none) }
  // The dark scheme prefers `dark` values, but a theme's own light value still beats the
  // default dark one, so a theme without a `dark` section keeps its look.
  let setting(group, name, dark: false) = {
    let sources = if dark {
      (
        dark-of(overrides),
        dark-of(theme),
        overrides,
        theme,
        dark-of(default-theme),
        dark-of(builtin),
        default-theme,
        builtin,
      )
    } else {
      (overrides, theme, default-theme, builtin)
    }
    for source in sources {
      let values = if source != none { source.at(group, default: none) }
      let value = if values != none { values.at(name, default: none) }
      if value != none { return value }
    }
  }
  // A dark scheme exists if the theme brings one or leaves the colors to the defaults.
  let has-dark = dark-of(theme) != none or dark != (:) or theme.at("colors", default: none) == none

  // All colors and the logo of one color scheme.
  let scheme(dark) = {
    let color(name) = {
      let value = setting("colors", name, dark: dark)
      if value != none { rgb(value) }
    }
    let text-color = color("text")
    let or-text(value) = if value == none { text-color } else { value }
    (
      background: color("background"),
      text: text-color,
      line: color("line"),
      accent: color("accent"),
      heading: color("heading"),
      code-background: color("code-background"),
      // Without its own color the header lets the background (including the gradient) show through.
      header: color("header"),
      // Text colors for header and code panel, in case their background needs a different one.
      header-text: or-text(color("header-text")),
      code-text: or-text(color("code-text")),
      // With a second color the background fades into it from top left to bottom right.
      gradient-end: color("background-gradient"),
      // With this color a step's heading sits on a bar.
      heading-bar: color("heading-background"),
      button: color("button"),
      button-text: color("button-text"),
      // Title page and abstract page may have their own background and text color.
      title-background: color("title-background"),
      title-text: or-text(color("title-text")),
      abstract-background: color("abstract-background"),
      abstract-text: or-text(color("abstract-text")),
      logo: if dark and logo-dark != auto { logo-dark } else { logo },
      // Background and bar of added and removed code lines.
      diff: if dark {
        (added: (rgb("#21372a"), rgb("#57a64a")), removed: (rgb("#45262a"), rgb("#d9634f")))
      } else {
        (added: (rgb("#e6f4de"), rgb("#6cbf4b")), removed: (rgb("#fbe3de"), rgb("#e8705c")))
      },
    )
  }
  let light-scheme = scheme(false)
  let dark-scheme = scheme(true)
  // A theme without a dark scheme stays light even if dark mode is requested.
  let dark-pdf = mode == "dark" and has-dark
  let colors = if dark-pdf { dark-scheme } else { light-scheme }

  let margin = 1.5cm
  let background = colors.background
  let text-color = colors.text
  let line-color = colors.line
  let accent = colors.accent
  let heading-color = colors.heading
  let code-background = colors.code-background
  let header-fill = colors.header
  let header-text = colors.header-text
  let code-text = colors.code-text
  let gradient-end = colors.gradient-end
  let heading-bar = colors.heading-bar
  let brand-logo = colors.logo
  let show-dots = setting("layout", "dots")
  let corner-radius = setting("layout", "corner-radius")
  let code-border = setting("layout", "code-border")
  let title-underline = setting("layout", "title-underline")
  let title-uppercase = setting("layout", "title-uppercase")
  // Heading and explanation of a step sit in the vertical center or at the top.
  let text-top = setting("layout", "text-position") == "top"
  // Pages before the first step: a title page, and the abstract on it or on a page of its own.
  let has-title-page = setting("layout", "title-page") and title != none
  let abstract-on-title = has-title-page and abstract != none and setting("layout", "abstract") == "with-title"
  let has-abstract-page = abstract != none and not abstract-on-title
  // A font is one family or a list of fallbacks; Typst uses the first one that is installed.
  let font-list(name) = {
    let value = setting("fonts", name)
    if type(value) == str { (value,) } else { value }
  }
  let size(name) = setting("sizes", name)
  let text-font = font-list("text")
  let code-font = (font-list("code") + ("DejaVu Sans Mono",)).dedup()
  let brand-font = font-list("brand")
  // For the website: the same list, ending in the generic family that fits its first font,
  // because a browser only knows the fonts installed on the reader's machine.
  let css-fonts(fonts, generic: auto) = {
    let first = lower(fonts.first())
    let serif = not first.contains("sans") and first.contains(regex("serif|times|georgia|garamond|modern|libertinus"))
    let generic = if generic != auto { generic } else if serif { "serif" } else { "sans-serif" }
    (fonts.map(font => "\"" + font + "\"") + (generic,)).join(",")
  }
  let brand-text = setting("brand", "text")
  let labels = copy-labels.at(lang, default: copy-labels.en)

  set document(title: title) if title != none
  set page(
    width: 297mm,
    height: 185.6mm,
    margin: 0pt,
    fill: if gradient-end != none {
      gradient.linear(background, gradient-end, angle: 32deg)
    } else {
      background
    },
  )
  set text(lang: lang, size: size("text") * 1pt, font: text-font, fill: text-color)
  set par(leading: 0.6em)
  show raw: set text(font: code-font, size: size("code") * 1pt)
  show raw.where(block: true): set text(fill: code-text)

  // Build the document: `web` selects between website (HTML) and pages (PDF).
  let build(web) = {
    // Syntax colors for a dark code panel; the website recolors them with CSS instead.
    set raw(theme: "assets/dark.tmTheme") if not web and dark-pdf

    // Step heading: accent dot on the left, small dots for the steps before and after.
    let step-heading(step: 1, total: 1, it) = if web {
      let dot(target) = html.elem("a", attrs: (
        href: "#step-" + str(target),
        aria-label: labels.step + " " + str(target),
      ))
      html.elem("h2", {
        if show-dots {
          html.elem("nav", {
            html.elem("div", attrs: (class: "before"), range(1, step).map(dot).join())
            html.elem("span", attrs: (class: "current"))
            html.elem("div", attrs: (class: "after"), range(step + 1, total + 1).map(dot).join())
          })
        }
        html.elem("span", attrs: (class: if heading-bar != none { "bar" } else { "" }), it.body)
      })
    } else {
      block(below: 0.8em, {
        // Small dot with an enlarged click area that jumps to its step.
        let dot(target) = link(label("step-" + str(target)), box(
          width: 0.62em,
          height: 0.62em,
          align(center + horizon, circle(radius: 0.12em, fill: line-color)),
        ))
        if show-dots {
          place(dx: -1.25em, dy: 0.05em, circle(radius: 0.32em, fill: accent))
          for k in range(step - 1) {
            place(dx: -1.24em, dy: -0.64em - k * 0.62em, dot(step - 1 - k))
          }
          for k in range(total - step) {
            place(dx: -1.24em, dy: 0.76em + k * 0.62em, dot(step + 1 + k))
          }
        }
        // Sized relative to the surrounding text, so a show rule in the tutorial can scale it.
        let content = text(
          // Typst already enlarges level-1 headings by 1.4; take that factor out again.
          size: size("heading") / size("text") / 1.4 * 1em,
          weight: "semibold",
          fill: heading-color,
          it.body,
        )
        // With a bar color: every line of the heading gets its own bar.
        if heading-bar != none {
          set par(leading: 0.95em)
          pad(left: 0.45em, y: 0.3em, highlight(
            fill: heading-bar,
            extent: 0.45em,
            top-edge: 1.15em,
            bottom-edge: -0.5em,
            content,
          ))
        } else {
          content
        }
      })
    }

    // Brand at the top right: logo and text.
    let brand-mark(fill) = stack(
      dir: ltr,
      spacing: 0.4cm,
      // Logo at most 1 cm high and 5.5 cm wide, so that wide wordmarks fit as well.
      ..if brand-logo != none {
        (
          align(horizon, context {
            let size = measure(brand-logo)
            set image(width: 5.5cm) if size.width / size.height > 5.5
            set image(height: 1cm) if size.width / size.height <= 5.5
            brand-logo
          }),
        )
      },
      ..if brand-text != "" {
        (align(horizon, text(font: brand-font, size: size("brand") * 1pt, weight: "medium", fill: fill, brand-text)),)
      },
    )

    // Header with the tutorial title and the brand.
    let header = block(
      width: 100%,
      height: 1.9cm,
      inset: (x: margin),
      fill: header-fill,
      stroke: (bottom: 0.75pt + line-color),
      align(horizon, grid(
        columns: (1fr, auto),
        align: horizon,
        if title != none {
          let content = if title-uppercase { text(tracking: 0.04em, upper(title)) } else { title }
          text(size: size("title") * 1pt, fill: header-text, if title-underline {
            underline(stroke: 1.5pt + accent, offset: 0.3em, content)
          } else {
            content
          })
        },
        brand-mark(header-text),
      )),
    )

    let is-code(el) = el.func() == raw and el.at("block", default: false)

    // Line-based diff via LCS: list of (kind, line) with kind "same", "added" or "removed".
    let line-diff(old, new) = {
      let (n, m) = (old.len(), new.len())
      let t = ((0,) * (m + 1),) * (n + 1)
      for i in range(n - 1, -1, step: -1) {
        for j in range(m - 1, -1, step: -1) {
          t.at(i).at(j) = if old.at(i) == new.at(j) {
            t.at(i + 1).at(j + 1) + 1
          } else {
            calc.max(t.at(i + 1).at(j), t.at(i).at(j + 1))
          }
        }
      }
      let (i, j) = (0, 0)
      let changes = ()
      while i < n or j < m {
        if i < n and j < m and old.at(i) == new.at(j) {
          changes.push(("same", new.at(j)))
          i += 1
          j += 1
        } else if i < n and (j == m or t.at(i + 1).at(j) >= t.at(i).at(j + 1)) {
          changes.push(("removed", old.at(i)))
          i += 1
        } else {
          changes.push(("added", new.at(j)))
          j += 1
        }
      }
      changes
    }

    // Typeset a code block with line numbers and highlight the diff to the previous state (`old`):
    // changed lines get a bar on the left edge and a light background.
    let with-diff(code, old, new) = {
      let changes = if old == none or not diff {
        new.map(line => ("same", line))
      } else {
        line-diff(old, new).filter(((kind, line)) => kind != "removed" or show-removed)
      }
      // Per displayed line: kind of highlight and line number in the source file.
      // Removed lines have no number, blank lines are not highlighted.
      let lines = ()
      let number = 0
      for (kind, line) in changes {
        if kind != "removed" { number += 1 }
        lines.push((
          kind: if line.trim() == "" { "same" } else { kind },
          number: if kind == "removed" { "" } else { str(number) },
        ))
      }
      show raw.line: it => {
        let (kind, number) = lines.at(it.number - 1)
        if web {
          html.elem("span", attrs: (class: "line " + kind, data-nr: number), it.body)
        } else {
          let (light, bar) = colors.diff.at(kind, default: (none, none))
          box(
            width: 100%,
            fill: light,
            stroke: if bar != none { (left: 2.5pt + bar) },
            outset: (y: 0.3em),
            {
              box(width: 2em, align(right, text(fill: code-text.transparentize(55%), number)))
              h(1em)
              it.body
            },
          )
        }
      }
      raw(changes.map(((kind, line)) => line).join("\n"), lang: code.lang, block: true)
    }

    // Typeset a step as a section of the website.
    let section(number, text, code) = html.elem(
      "section",
      attrs: (
        id: "step-" + str(number),
        class: if code.len() == 0 { "step no-code" } else { "step" },
      ),
      {
        html.elem("div", attrs: (class: "explanation"), text)
        if code.len() > 0 { html.elem("div", attrs: (class: "code"), code.join()) }
      },
    )

    // Typeset a page: text on the left, code (if any) in the panel on the right.
    let slide(text, code) = grid(
      rows: (auto, 1fr),
      header,
      grid(
        columns: if code.len() == 0 { (1fr,) } else { (1fr, 1fr) },
        rows: 100%,
        align(if text-top { top } else { horizon }, pad(left: margin + 1em, right: margin, y: margin, text)),
        ..if code.len() > 0 {
          (
            block(
              width: 100%,
              height: 100%,
              inset: (left: 0.5cm, rest: 0.8cm),
              fill: code-background,
              stroke: if code-border {
                (left: 0.75pt + line-color, top: 0.75pt + line-color, bottom: 0.75pt + line-color)
              },
              radius: (top-left: corner-radius * 1cm, bottom-left: corner-radius * 1cm),
              code.join(v(1em)),
            ),
          )
        },
      ),
    )

    // Round button with an arrow that leads on to `target`.
    let next-button(target, arrow-fill) = link(label(target), circle(
      radius: 0.75cm,
      fill: accent,
      align(center + horizon, text(size: 26pt, fill: arrow-fill, sym.arrow.b)),
    ))

    // Title page: large centered title, optionally with the abstract below it.
    let title-slide(target) = {
      let fill = colors.title-background
      block(width: 100%, height: 100%, fill: fill, {
        place(top + right, dx: -margin, dy: 0.45cm, brand-mark(colors.title-text))
        set text(fill: colors.title-text)
        align(center + horizon, block(width: 76%, {
          text(size: size("title-page") * 1pt, title)
          if abstract-on-title {
            v(0.6cm)
            block(width: 78%, align(left, abstract))
          }
          v(1cm)
          next-button(target, if fill != none { fill } else { background })
        }))
      })
    }

    // Abstract page: the regular header above the abstract in a centered column.
    let abstract-slide = {
      let fill = colors.abstract-background
      grid(
        rows: (auto, 1fr),
        header,
        block(width: 100%, height: 100%, fill: fill, {
          set text(fill: colors.abstract-text)
          align(center + horizon, block(width: 60%, align(left, text(size: 1.07em, abstract))))
        }),
      )
    }

    // The same pages as sections of the website; with a `target` an arrow button leads on to it.
    let intro-section(id, class, target, content) = html.elem(
      "section",
      attrs: (id: id, class: "intro " + class),
      {
        content
        if target != none {
          html.elem("a", attrs: (class: "next", href: "#" + target, aria-label: labels.next))
        }
      },
    )

    // `#diff-off` and `#diff-on` arrive as metadata markers between the other elements.
    let marker(el) = if el.func() == metadata and type(el.value) == dictionary {
      el.value.at("typtorial", default: none)
    }
    let is-empty(content) = content.all(item => {
      item.el.func() in (parbreak, [ ].func()) or marker(item.el) != none
    })

    // Set and show rules written in the tutorial wrap everything after them in a `styled`
    // element. Unwrap those, but remember per element how to put its styles back on.
    let flatten(content, restyle) = {
      if content.has("child") and content.has("styles") {
        flatten(content.child, it => restyle(content.func()(it, content.styles)))
      } else if content.has("children") {
        content.children.map(child => flatten(child, restyle)).flatten()
      } else {
        ((el: content, restyle: restyle),)
      }
    }

    // Split the document into steps at every level-1 heading.
    let steps = ()
    let current = ()
    for item in flatten(body, it => it) {
      if item.el.func() == heading and item.el.depth == 1 {
        if not is-empty(current) { steps.push(current) }
        current = ()
      }
      current.push(item)
    }
    if not is-empty(current) { steps.push(current) }

    // Compare every code block with the previous state of the same file, across steps as well.
    // The file name optionally follows the language: ```typst my-tutorial.typ
    // Blocks shown while the diff is switched off are left out of the comparison, so the next
    // block after `#diff-on` is compared with the last one shown before `#diff-off`.
    let diffing = true
    let previous = (:)
    let output = ()
    for (number, content) in steps.enumerate(start: 1) {
      let code = ()
      for item in content {
        let el = item.el
        if marker(el) != none { diffing = marker(el) == "diff-on" }
        if not is-code(el) { continue }
        let lines = el.text.split("\n")
        // Typst delivers the file name as the first code line; it only counts as a name if it
        // looks like one (a single word with an extension, e.g. `src/main.py`).
        let file = ""
        if lines.first().match(regex("^[\w./-]*\.\w+$")) != none {
          file = lines.remove(0)
        }
        let restyle = item.restyle
        let block = restyle(with-diff(el, if diffing { previous.at(file, default: none) }, lines))
        if diffing { previous.insert(file, lines) }
        // Above the code: the file name, or the language if there is none; preceded by the icon.
        let name = if file != "" { file } else if el.lang != none { el.lang } else { "" }
        let icon = file-icon(file, el.lang)
        // On the website a button copies the code exactly as written in the source file.
        code.push(if web {
          html.elem("div", attrs: (class: "block"), {
            html.elem(
              "button",
              attrs: (
                type: "button",
                data-code: lines.join("\n"),
                data-copy: labels.copy,
                data-copied: labels.copied,
              ),
              labels.copy,
            )
            if name != "" { html.elem("div", attrs: (class: "filename"), icon + name) }
            block
          })
        } else if name != "" {
          std.block(below: 1.2em, text(font: code-font, size: size("code") * 0.87pt, fill: code-text.transparentize(40%), {
            if icon != none { box(baseline: 0.22em, icon) + h(0.45em) }
            name
          }))
          block
        } else {
          block
        })
      }
      let text = {
        show heading.where(level: 1): step-heading.with(step: number, total: steps.len())
        // Links in the explanation are underlined in the accent color.
        show link: it => if web { it } else { underline(stroke: 1pt + accent, offset: 0.2em, it) }
        content.filter(item => not is-code(item.el)).map(item => (item.restyle)(item.el)).join()
      }
      output.push(if web {
        section(number, text, code)
      } else {
        [#metadata(none)#label("step-" + str(number))] + slide(text, code)
      })
    }

    // Title page and abstract page come before the steps.
    let intro = ()
    if has-title-page {
      let target = if has-abstract-page { "abstract" } else { "step-1" }
      intro.push(if web {
        intro-section("title", "title-page", target, {
          html.elem("h1", title)
          if abstract-on-title { html.elem("div", attrs: (class: "abstract"), abstract) }
        })
      } else {
        title-slide(target)
      })
    }
    if has-abstract-page {
      intro.push(if web {
        intro-section("abstract", "abstract-page", none, html.elem("div", attrs: (class: "abstract"), abstract))
      } else {
        [#metadata(none)#label("abstract")] + abstract-slide
      })
    }
    let output = intro + output

    if web {
      html.elem("style", read("assets/web.css"))
      // The settings from `theme` override the stylesheet's defaults.
      let variables(scheme, dark) = (
        background: scheme.background.to-hex(),
        text: scheme.text.to-hex(),
        line: scheme.line.to-hex(),
        accent: scheme.accent.to-hex(),
        heading: scheme.heading.to-hex(),
        code-background: scheme.code-background.to-hex(),
        header: if scheme.header != none {
          scheme.header.to-hex()
        } else {
          "linear-gradient(122deg, var(--background), var(--gradient-end)) fixed"
        },
        header-text: scheme.header-text.to-hex(),
        code-text: scheme.code-text.to-hex(),
        gradient-end: if scheme.gradient-end != none { scheme.gradient-end } else { scheme.background }.to-hex(),
        heading-bar: if scheme.heading-bar != none { scheme.heading-bar.to-hex() } else { "transparent" },
        // Copy button: a color that stands out from the code panel needs no visible border.
        button: if scheme.button != none { scheme.button } else { scheme.code-background }.to-hex(),
        button-border: if scheme.button != none and scheme.button != scheme.code-background {
          scheme.button
        } else {
          scheme.line
        }.to-hex(),
        button-text: if scheme.button-text != none { scheme.button-text } else { scheme.code-text }.to-hex(),
        code-border: if code-border { scheme.line.to-hex() } else { "transparent" },
        added: scheme.diff.added.at(0).to-hex(),
        added-bar: scheme.diff.added.at(1).to-hex(),
        removed: scheme.diff.removed.at(0).to-hex(),
        removed-bar: scheme.diff.removed.at(1).to-hex(),
        // The syntax colors are made for a light panel; in the dark scheme they get inverted.
        syntax-filter: if dark { "invert(1) hue-rotate(180deg)" } else { "none" },
        title-background: if scheme.title-background != none {
          scheme.title-background.to-hex()
        } else {
          "transparent"
        },
        title-text: scheme.title-text.to-hex(),
        abstract-background: if scheme.abstract-background != none {
          scheme.abstract-background.to-hex()
        } else {
          "transparent"
        },
        abstract-text: scheme.abstract-text.to-hex(),
        logo-light: if dark { "none" } else { "block" },
        logo-dark: if dark { "block" } else { "none" },
      ).pairs().map(((name, value)) => "--" + name + ":" + value + ";").join()
      html.elem("style", {
        ":root {"
        variables(light-scheme, false)
        "--corner-radius:" + str(corner-radius * 1.5) + "rem;"
        "--text-position:" + if text-top { "start" } else { "center" } + ";"
        // The stylesheet's sizes belong to the default sizes; scale them in proportion.
        "--size-text:" + str(calc.round(1.125 * size("text") / 14, digits: 3)) + "rem;"
        "--size-heading:" + str(calc.round(1.2 * size("heading") / 15, digits: 3)) + "rem;"
        "--size-title:" + str(calc.round(1.35 * size("title") / 17, digits: 3)) + "rem;"
        "--size-title-page:" + str(calc.round(2.6 * size("title-page") / 30, digits: 3)) + "rem;"
        "--size-brand:" + str(calc.round(1.6 * size("brand") / 20, digits: 3)) + "rem;"
        "--size-code:" + str(calc.round(0.8 * size("code") / 10.9, digits: 3)) + "rem;"
        "--font-text:" + css-fonts(text-font) + ";"
        "--font-code:" + css-fonts(code-font, generic: "monospace") + ";"
        "--font-brand:" + css-fonts(brand-font) + ";"
        "}"
        // Dark scheme: chosen explicitly with the button, or by the system unless light is chosen.
        if has-dark {
          ":root[data-theme=\"dark\"] {" + variables(dark-scheme, true) + "}"
          "@media (prefers-color-scheme: dark) { :root:not([data-theme=\"light\"]) {"
          variables(dark-scheme, true)
          "} }"
        }
      })
      html.elem("header", {
        html.elem(
          "span",
          attrs: (
            class: "title"
              + if title-underline { "" } else { " no-underline" }
              + if title-uppercase { " uppercase" } else { "" },
          ),
          title,
        )
        html.elem("span", attrs: (class: "brand"), {
          if source != none {
            html.elem("button", attrs: (
              type: "button",
              class: "header-button download",
              aria-label: labels.download,
              title: labels.download,
              data-source: source,
              data-name: source-name,
            ))
          }
          if has-dark {
            html.elem("button", attrs: (
              type: "button",
              class: "header-button theme-toggle",
              aria-label: labels.theme,
              title: labels.theme,
            ))
          }
          // Both logos are embedded; the stylesheet shows the one matching the color scheme.
          if light-scheme.logo != none {
            html.elem("span", attrs: (class: "logo-light"), light-scheme.logo)
          }
          if dark-scheme.logo != none {
            html.elem("span", attrs: (class: "logo-dark"), dark-scheme.logo)
          }
          brand-text
        })
      })
      html.elem("main", output.join())
      html.elem("script", read("assets/web.js"))
    } else {
      output.join(pagebreak())
    }
  }

  context build(target() == "html")
}
