#let icon-mapping = json("icons/mapping.json")

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

// Typst has no base64 encoder, but a data URL needs one for binary images.
#let base64(data) = {
  let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  let data = array(data)
  range(0, data.len(), step: 3)
    .map(i => {
      let chunk = data.slice(i, calc.min(i + 3, data.len()))
      let value = (chunk + (0, 0)).slice(0, 3).fold(0, (sum, byte) => sum * 256 + byte)
      range(4)
        .map(k => if k <= chunk.len() {
          alphabet.at(value.bit-rshift(18 - 6 * k).bit-and(63))
        } else { "=" })
        .join()
    })
    .join()
}

// The image type of a favicon by its first bytes: PNG, ICO or else SVG.
#let image-type(data) = {
  let start = array(data.slice(0, calc.min(4, data.len())))
  if start == (0x89, 0x50, 0x4E, 0x47) { "image/png" } else if start == (0, 0, 1, 0) {
    "image/x-icon"
  } else { "image/svg+xml" }
}

// Plain text of a title for the `<title>` of the website.
#let plain-text(it) = if type(it) == str { it } else if it.has("text") {
  plain-text(it.text)
} else if it.has("children") { it.children.map(plain-text).join() } else if it.has("body") {
  plain-text(it.body)
} else if it.func() == [ ].func() { " " } else { "" }

#let default-theme = yaml("../themes/default.theme.yaml")

#let themes = (
  default: default-theme,
  paper: yaml("../themes/paper.theme.yaml"),
  forest: yaml("../themes/forest.theme.yaml"),
  indigo: yaml("../themes/indigo.theme.yaml"),
  coral: yaml("../themes/coral.theme.yaml"),
)

#let diff-off = metadata((typtorial: "diff-off"))
#let diff-on = metadata((typtorial: "diff-on"))
// The download and theme buttons of the header, repeated inside the text. Only for the
// documentation of typtorial; `lib.typ` does not export them.
#let download-button = metadata((typtorial: "download-button"))
#let theme-button = metadata((typtorial: "theme-button"))

#let copy-labels = (
  en: (
    copy: "Copy",
    copied: "Copied",
    step: "Step",
    theme: "Switch between light and dark",
    download: "Download source file",
    next: "Continue",
  ),
  de: (
    copy: "Kopieren",
    copied: "Kopiert",
    step: "Schritt",
    theme: "Zwischen hell und dunkel wechseln",
    download: "Quelldatei herunterladen",
    next: "Weiter",
  ),
)

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
  favicon: auto,
  theme: (:),
  fonts: (:),
  sizes: (:),
  colors: (:),
  brand: (:),
  layout: (:),
  dark: (:),
  body,
) = {
  let overrides = (
    fonts: fonts,
    sizes: sizes,
    colors: colors,
    brand: brand,
    layout: layout,
    dark: dark,
  )
  // A package cannot open files of the document that uses it, so a file name is not enough.
  assert(
    type(theme) == dictionary,
    message: "theme must be a dictionary; load a theme file with yaml(\"my.theme.yaml\")",
  )
  let builtin = (
    fonts: (
      text: (
        "Hanken Grotesk",
        "Helvetica Neue",
        "Arial",
        "Liberation Sans",
        "DejaVu Sans",
      ),
      code: "DejaVu Sans Mono",
      brand: "Libertinus Serif",
    ),
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
  let has-dark = (
    dark-of(theme) != none or dark != (:) or theme.at("colors", default: none) == none
  )

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
      header: color("header"),
      header-text: or-text(color("header-text")),
      code-text: or-text(color("code-text")),
      gradient-end: color("background-gradient"),
      heading-bar: color("heading-background"),
      button: color("button"),
      button-text: color("button-text"),
      title-background: color("title-background"),
      title-text: or-text(color("title-text")),
      abstract-background: color("abstract-background"),
      abstract-text: or-text(color("abstract-text")),
      logo: if dark and logo-dark != auto { logo-dark } else { logo },
      // (background, bar)
      diff: if dark {
        (
          added: (rgb("#21372a"), rgb("#57a64a")),
          removed: (rgb("#45262a"), rgb("#d9634f")),
        )
      } else {
        (
          added: (rgb("#e6f4de"), rgb("#6cbf4b")),
          removed: (rgb("#fbe3de"), rgb("#e8705c")),
        )
      },
    )
  }
  let light-scheme = scheme(false)
  let dark-scheme = scheme(true)
  let dark-pdf = mode == "dark" and has-dark
  let colors = if dark-pdf { dark-scheme } else { light-scheme }

  let margin = 1.5cm
  let page-width = 297mm
  let page-height = 185.6mm
  let header-height = 1.9cm
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
  let text-top = setting("layout", "text-position") == "top"
  let has-title-page = setting("layout", "title-page") and title != none
  let abstract-on-title = (
    has-title-page and abstract != none and setting("layout", "abstract") == "with-title"
  )
  let has-abstract-page = abstract != none and not abstract-on-title
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
    let serif = (
      not first.contains("sans")
        and first.contains(regex("serif|times|georgia|garamond|modern|libertinus"))
    )
    let generic = if generic != auto { generic } else if serif { "serif" } else {
      "sans-serif"
    }
    (fonts.map(font => "\"" + font + "\"") + (generic,)).join(",")
  }
  let brand-text = setting("brand", "text")
  let labels = copy-labels.at(lang, default: copy-labels.en)

  set document(title: title) if title != none
  set page(
    width: page-width,
    height: page-height,
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

  let build(web) = {
    // Syntax colors for a dark code panel; the website recolors them with CSS instead.
    set raw(theme: "assets/dark.tmTheme") if not web and dark-pdf

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
            html.elem(
              "div",
              attrs: (class: "after"),
              range(step + 1, total + 1).map(dot).join(),
            )
          })
        }
        html.elem(
          "span",
          attrs: (class: if heading-bar != none { "bar" } else { "" }),
          it.body,
        )
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
        (
          align(horizon, text(
            font: brand-font,
            size: size("brand") * 1pt,
            weight: "medium",
            fill: fill,
            brand-text,
          )),
        )
      },
    )

    let header = block(
      width: 100%,
      height: header-height,
      inset: (x: margin),
      fill: header-fill,
      stroke: (bottom: 0.75pt + line-color),
      align(horizon, grid(
        columns: (1fr, auto),
        align: horizon,
        if title != none {
          let content = if title-uppercase { text(tracking: 0.04em, upper(title)) } else {
            title
          }
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

    // The lines of a block with their kind and line number, compared with `old` if given.
    let diff-lines(old, new) = {
      let changes = if old == none or not diff {
        new.map(line => ("same", line))
      } else {
        line-diff(old, new).filter(((kind, line)) => kind != "removed" or show-removed)
      }
      let lines = ()
      let number = 0
      for (kind, line) in changes {
        if kind != "removed" { number += 1 }
        lines.push((
          kind: if line.trim() == "" { "same" } else { kind },
          line: line,
          number: if kind == "removed" { "" } else { str(number) },
        ))
      }
      lines
    }

    // A code block of the lines from `start` to `end`; the PDF splits long blocks this way.
    let with-diff(lang, lines, start: 0, end: none) = {
      let lines = lines.slice(start, end)
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
              box(width: 2em, align(right, text(
                fill: code-text.transparentize(55%),
                number,
              )))
              h(1em)
              it.body
            },
          )
        }
      }
      raw(lines.map(line => line.line).join("\n"), lang: lang, block: true)
    }

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

    let slide(text, code) = grid(
      rows: (auto, 1fr),
      header,
      grid(
        columns: if code.len() == 0 { (1fr,) } else { (1fr, 1fr) },
        rows: 100%,
        align(
          if text-top { top } else { horizon },
          pad(left: margin + 1em, right: margin, y: margin, text),
        ),
        ..if code.len() > 0 {
          (
            block(
              width: 100%,
              height: 100%,
              inset: (left: 0.5cm, rest: 0.8cm),
              fill: code-background,
              stroke: if code-border {
                (
                  left: 0.75pt + line-color,
                  top: 0.75pt + line-color,
                  bottom: 0.75pt + line-color,
                )
              },
              radius: (top-left: corner-radius * 1cm, bottom-left: corner-radius * 1cm),
              code.join(v(1em)),
            ),
          )
        },
      ),
    )

    let next-button(target, arrow-fill) = link(label(target), circle(
      radius: 0.75cm,
      fill: accent,
      align(center + horizon, text(size: 26pt, fill: arrow-fill, sym.arrow.b)),
    ))

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

    let abstract-slide = {
      let fill = colors.abstract-background
      grid(
        rows: (auto, 1fr),
        header,
        block(width: 100%, height: 100%, fill: fill, {
          set text(fill: colors.abstract-text)
          align(center + horizon, block(width: 60%, align(left, text(
            size: 1.07em,
            abstract,
          ))))
        }),
      )
    }

    let intro-section(id, class, target, content) = html.elem(
      "section",
      attrs: (id: id, class: "intro " + class),
      {
        content
        if target != none {
          html.elem("a", attrs: (
            class: "next",
            href: "#" + target,
            aria-label: labels.next,
          ))
        }
      },
    )

    // `#diff-off` and `#diff-on` arrive as metadata markers between the other elements.
    let marker(el) = if el.func() == metadata and type(el.value) == dictionary {
      el.value.at("typtorial", default: none)
    }
    let is-empty(content) = content.all(item => {
      (
        item.el.func() in (parbreak, [ ].func())
          or marker(item.el) in ("diff-on", "diff-off")
      )
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

    // Blocks shown while the diff is switched off are left out of the comparison, so the next
    // block after `#diff-on` is compared with the last one shown before `#diff-off`.
    // Blocks are only compared with earlier steps, never with blocks of their own step.
    let diffing = true
    let previous = (:)
    let output = ()
    for (number, content) in steps.enumerate(start: 1) {
      // Code blocks in order of appearance.
      let blocks = ()
      let earlier = previous
      // Blocks without a file name are compared by their position among those of the step.
      let unnamed = 0
      for item in content {
        let kind = marker(item.el)
        if kind in ("diff-on", "diff-off") { diffing = kind == "diff-on" }
        if is-code(item.el) {
          let el = item.el
          let lines = el.text.split("\n")
          // Typst delivers the file name as the first code line; it only counts as a name if it
          // looks like one (a single word with an extension, e.g. `src/main.py`).
          let file = ""
          if lines.first().match(regex("^[\w./-]*\.\w+$")) != none {
            file = lines.remove(0)
          }
          let key = file
          if file == "" {
            key = "#" + str(unnamed)
            unnamed += 1
          }
          let changes = diff-lines(if diffing { earlier.at(key, default: none) }, lines)
          if diffing { previous.insert(key, lines) }
          blocks.push((
            name: if file != "" { file } else if el.lang != none { el.lang } else { "" },
            icon: file-icon(file, el.lang),
            lines: lines,
            lang: el.lang,
            changes: changes,
            restyle: item.restyle,
            body: (item.restyle)(with-diff(el.lang, changes)),
          ))
        }
      }
      // All blocks of a step form one entry; several of them are shown as tabs.
      let entries = if blocks.len() > 0 { ((blocks: blocks),) } else { () }
      let tab-name(block, index) = if block.name != "" { block.name } else {
        str(index + 1)
      }
      let head(block) = std.block(below: 1.2em, text(
        font: code-font,
        size: size("code") * 0.87pt,
        fill: code-text.transparentize(40%),
        {
          if block.icon != none { box(baseline: 0.22em, block.icon) + h(0.45em) }
          block.name
        },
      ))
      let web-block(block) = html.elem("div", attrs: (class: "block"), {
        html.elem(
          "button",
          attrs: (
            type: "button",
            data-code: block.lines.join("\n"),
            data-copy: labels.copy,
            data-copied: labels.copied,
          ),
          labels.copy,
        )
        if block.name != "" {
          html.elem("div", attrs: (class: "filename"), block.icon + block.name)
        }
        block.body
      })
      // The PDF shows one tab per page; the tab bar marks which one.
      let tab-bar(blocks, active) = std.block(
        width: 100%,
        below: 1.2em,
        stroke: (bottom: 0.75pt + line-color),
        {
          set text(font: code-font, size: size("code") * 0.87pt)
          blocks
            .enumerate()
            .map(((index, block)) => box(
              inset: (x: 0.7em, top: 0.2em, bottom: 0.7em),
              stroke: if index == active { (bottom: 2pt + accent) },
              text(
                fill: code-text.transparentize(if index == active { 0% } else { 55% }),
                {
                  if block.icon != none { box(baseline: 0.22em, block.icon) + h(0.45em) }
                  tab-name(block, index)
                },
              ),
            ))
            .join(h(0.3em))
        },
      )
      let text-items = content.filter(item => not is-code(item.el))
      let text-of(items) = {
        show heading.where(level: 1): step-heading.with(step: number, total: steps.len())
        show metadata: it => {
          let kind = marker(it)
          let button = (
            "download-button": if source != none { ("download", labels.download, "\u{2913}") },
            "theme-button": if has-dark { ("theme-toggle", labels.theme, "\u{25D0}") },
          ).at(kind, default: none)
          if button == none { it } else if web {
            let (class, label, _) = button
            html.elem("button", attrs: (
              type: "button",
              class: "header-button inline " + class,
              aria-label: label,
              title: label,
            ))
          } else {
            // Without a header button in the PDF the icon only stands for the one on the website.
            // Placed, so the circle does not push the lines apart.
            box(width: 1.1em, height: 0.7em, place(center + horizon, circle(
              radius: 0.55em,
              stroke: 0.75pt + accent,
              align(center + horizon, text(size: 0.75em, button.last())),
            )))
          }
        }
        show link: it => if web { it } else {
          underline(stroke: 1pt + accent, offset: 0.2em, it)
        }
        items.map(item => (item.restyle)(item.el)).join()
      }
      output.push(if web {
        section(number, text-of(text-items), entries.map(entry => if entry.blocks.len() == 1 {
          web-block(entry.blocks.first())
        } else {
          html.elem("div", attrs: (class: "tabs"), {
            html.elem(
              "div",
              attrs: (class: "tab-bar", role: "tablist"),
              entry
                .blocks
                .enumerate()
                .map(((index, block)) => {
                  html.elem(
                    "button",
                    attrs: (type: "button", role: "tab", class: "tab"),
                    block.icon + tab-name(block, index),
                  )
                })
                .join(),
            )
            entry
              .blocks
              .map(block => html.elem(
                "div",
                attrs: (class: "tab-panel", role: "tabpanel"),
                web-block(block),
              ))
              .join()
          })
        }))
      } else {
        // One view with every tab group on its first tab, then a view for each further tab.
        let views = ((0,) * entries.len(),)
        for (k, entry) in entries.enumerate() {
          for active in range(1, entry.blocks.len()) {
            let view = (0,) * entries.len()
            view.at(k) = active
            views.push(view)
          }
        }
        let content-height = page-height - header-height

        // Text longer than a page continues on the next one, split between paragraphs. A
        // heading stays with the paragraph after it.
        let text-width = (if entries.len() > 0 { page-width / 2 } else { page-width }) - 2 * margin - 1em
        let fits-text(items) = {
          measure(block(width: text-width, text-of(items))).height <= content-height - 2 * margin
        }
        let chunks = ()
        let chunk = ()
        for item in text-items {
          chunk.push(item)
          if item.el.func() == parbreak {
            chunks.push(chunk)
            chunk = ()
          }
        }
        chunks.push(chunk)
        let text-pages = ()
        let page-items = ()
        for chunk in chunks {
          if page-items.len() > 0 and not is-empty(chunk) and not fits-text(page-items + chunk) {
            text-pages.push(page-items)
            page-items = ()
          }
          page-items += chunk
        }
        text-pages.push(page-items)

        // Code longer than a page continues on the next one, split between lines; the file
        // name or tab bar is repeated above the rest.
        let code-of(parts) = parts.map(part => {
          part.top
          (part.block.restyle)(with-diff(part.block.lang, part.block.changes, start: part.start, end: part.end))
        })
        let fits-code(parts) = {
          measure(block(width: page-width / 2 - 1.3cm, code-of(parts).join(v(1em)))).height <= content-height - 1.6cm
        }
        let code-pages = ()
        for view in views {
          let parts = ()
          for (entry, active) in entries.zip(view) {
            let block = entry.blocks.at(active)
            let top = if entry.blocks.len() > 1 { tab-bar(entry.blocks, active) } else if block.name != "" { head(block) }
            let part(start, end) = (top: top, block: block, start: start, end: end)
            let total = block.changes.len()
            let start = 0
            while start < total {
              if fits-code(parts + (part(start, total),)) {
                parts.push(part(start, total))
                start = total
                continue
              }
              // The most lines that still fit: `low` fits, `high` does not.
              let (low, high) = (start, total)
              while high - low > 1 {
                let middle = calc.div-euclid(low + high, 2)
                if fits-code(parts + (part(start, middle),)) { low = middle } else { high = middle }
              }
              if low == start {
                if parts.len() > 0 {
                  code-pages.push(parts)
                  parts = ()
                  continue
                }
                // A single line taller than the page: show it anyway.
                low = start + 1
              }
              parts.push(part(start, low))
              code-pages.push(parts)
              parts = ()
              start = low
            }
          }
          if parts.len() > 0 or entries.len() == 0 { code-pages.push(parts) }
        }

        // Text and code advance together; the shorter one stays on its last page.
        range(calc.max(text-pages.len(), code-pages.len()))
          .map(index => {
            let text = text-of(text-pages.at(calc.min(index, text-pages.len() - 1)))
            let code = code-of(code-pages.at(calc.min(index, code-pages.len() - 1)))
            if index == 0 {
              [#metadata(none)#label("step-" + str(number))] + slide(text, code)
            } else {
              // The repeated heading must not show up a second time in the PDF outline.
              set heading(outlined: false, bookmarked: false)
              slide(text, code)
            }
          })
          .join(pagebreak())
      })
    }

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
        intro-section("abstract", "abstract-page", none, html.elem(
          "div",
          attrs: (class: "abstract"),
          abstract,
        ))
      } else {
        [#metadata(none)#label("abstract")] + abstract-slide
      })
    }
    let output = intro + output

    if web {
      // An own root element, as Typst only builds the head itself when there is none; the
      // favicon could not go in there otherwise.
      let icon = if favicon == auto { read("assets/favicon.svg", encoding: none) } else {
        favicon
      }
      html.elem("html", attrs: (lang: lang), {
        html.elem("head", {
          html.elem("meta", attrs: (charset: "utf-8"))
          html.elem("meta", attrs: (
            name: "viewport",
            content: "width=device-width, initial-scale=1",
          ))
          if title != none { html.elem("title", plain-text(title)) }
          if icon != none {
            html.elem("link", attrs: (
              rel: "icon",
              href: "data:" + image-type(icon) + ";base64," + base64(icon),
            ))
          }
              html.elem("style", read("assets/web.css"))
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
                gradient-end: if scheme.gradient-end != none { scheme.gradient-end } else {
                  scheme.background
                }.to-hex(),
                heading-bar: if scheme.heading-bar != none { scheme.heading-bar.to-hex() } else {
                  "transparent"
                },
                // Copy button: a color that stands out from the code panel needs no visible border.
                button: if scheme.button != none { scheme.button } else {
                  scheme.code-background
                }.to-hex(),
                button-border: if scheme.button != none
                  and scheme.button != scheme.code-background {
                  scheme.button
                } else {
                  scheme.line
                }.to-hex(),
                button-text: if scheme.button-text != none { scheme.button-text } else {
                  scheme.code-text
                }.to-hex(),
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
              )
                .pairs()
                .map(((name, value)) => "--" + name + ":" + value + ";")
                .join()
              html.elem("style", {
                ":root {"
                variables(light-scheme, false)
                "--corner-radius:" + str(corner-radius * 1.5) + "rem;"
                "--text-position:" + if text-top { "start" } else { "center" } + ";"
                // The stylesheet's sizes belong to the default sizes; scale them in proportion.
                "--size-text:" + str(calc.round(1.125 * size("text") / 14, digits: 3)) + "rem;"
                (
                  "--size-heading:"
                    + str(calc.round(1.2 * size("heading") / 15, digits: 3))
                    + "rem;"
                )
                "--size-title:" + str(calc.round(1.35 * size("title") / 17, digits: 3)) + "rem;"
                (
                  "--size-title-page:"
                    + str(calc.round(2.6 * size("title-page") / 30, digits: 3))
                    + "rem;"
                )
                "--size-brand:" + str(calc.round(1.6 * size("brand") / 20, digits: 3)) + "rem;"
                "--size-code:" + str(calc.round(0.8 * size("code") / 10.9, digits: 3)) + "rem;"
                "--font-text:" + css-fonts(text-font) + ";"
                "--font-code:" + css-fonts(code-font, generic: "monospace") + ";"
                "--font-brand:" + css-fonts(brand-font) + ";"
                "}"
                if has-dark {
                  ":root[data-theme=\"dark\"] {" + variables(dark-scheme, true) + "}"
                  "@media (prefers-color-scheme: dark) { :root:not([data-theme=\"light\"]) {"
                  variables(dark-scheme, true)
                  "} }"
                }
              })
        })
        html.elem("body", {
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
        })
      })
    } else {
      output.join(pagebreak())
    }
  }

  context build(target() == "html")
}
