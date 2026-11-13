// HTML export can't lay out drawings (cetz, plots); render them to inline SVG there.
#let framed(body) = context if target() == "html" { html.frame(body) } else { body }

// Paper templates float their title block and style headings as run-ins; HTML export drops both, so the HTML target gets its own.
#let html-paper(template, style: auto, ..args, body) = {
  let named = args.named()
  context if target() == "html" {
    if style != none { html.elem("style", if style == auto { read("paper.css") } else { style }) }
    if "title" in named { html.elem("h1", named.title) }
    if "authors" in named { html.elem("p", attrs: (class: "authors"), named.authors.map(a => a.name).join(", ")) }
  }
  show: template.with(..args)
  show heading: it => context if target() == "html" {
    let nums = counter(heading).get()
    // typst suffixes every level with the pattern's last suffix ("I.A.a)" gives "I)"); cut the pattern after this level's own one instead.
    let n = if type(it.numbering) == str {
      let syms = it.numbering.matches(regex("[1aAiIαΑ*一壹あいアイ가ㄱ①⓵]"))
      numbering(it.numbering.slice(0, if it.level < syms.len() { syms.at(it.level).start } else { it.numbering.len() }), ..nums) + " "
    } else if it.numbering != none { numbering(it.numbering, ..nums) + " " }
    html.elem("h" + str(calc.min(it.level + 1, 6)), [#n#it.body])
  } else { it }
  body
}
