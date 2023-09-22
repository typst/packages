#let syntastica-plugin = plugin("./syntastica_typst.wasm")

#let _show-highlights(highlights) = {
  for (index, line) in highlights.enumerate() {
    for (part, style) in line {
      if style == none {
        text(part)
        continue
      }
      let tmp = text(
        fill: rgb(style.color.red, style.color.green, style.color.blue),
        style: if style.italic { "italic" } else { "normal" },
        weight: if style.bold { "bold" } else { "regular" },
        part
      )
      if style.bg != none {
        tmp = highlight(tmp, fill: rgb(style.bg.red, style.bg.green, style.bg.blue))
      }
      if style.strikethrough {
        tmp = strike(tmp)
      }
      if style.underline {
        tmp = underline(tmp)
      }
      tmp
    }
    // don't add a line break after the last line, needed for inline code
    if index != highlights.len() - 1 {
      linebreak()
    }
  }
}

/// The main function to be used in show rules. For example:
///
/// ```typ
/// #show raw: syntastica.with(theme: "github::light")
/// ```
#let syntastica(it, theme: "one::light") = {
  if it.lang == none or syntastica-plugin.supports_lang(bytes(it.lang)).at(0) == 0 {
    it
  } else {
    _show-highlights(cbor.decode(syntastica-plugin.highlight(bytes(it.text), bytes(it.lang), bytes(theme))))
  }
}

#let languages() = {
  return cbor.decode(syntastica-plugin.all_languages())
}

#let themes() = {
  return cbor.decode(syntastica-plugin.all_themes())
}

#let theme-bg(theme) = {
  let color = cbor.decode(syntastica-plugin.theme_bg(bytes(theme)))
  if color == none { return none }
  return rgb(color.red, color.green, color.blue)
}

#let theme-fg(theme) = {
  let color = cbor.decode(syntastica-plugin.theme_fg(bytes(theme)))
  if color == none { return none }
  return rgb(color.red, color.green, color.blue)
}
