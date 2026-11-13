#import "i18n.typ": strings

#let ai-tools-table(tools, lang: "de", caption: auto) = {
  let translations = strings(lang)

  if tools == none or tools.len() == 0 {
    return
  }

  let cells = for (tool, usage) in tools {
    (
      tool,
      if type(usage) == array {
        list(..usage.map(item => [#item]))
      } else {
        usage
      },
    )
  }

  figure(
    table(
      columns: (1fr, 2fr),
      translations.ai-tools-col-tool,
      translations.ai-tools-col-usage,
      ..cells,
    ),
    caption: if caption == auto { translations.ai-tools-table-caption } else { caption },
    outlined: false,
    numbering: none,
  )
}

#let ai-acknowledgement(tools, lang: "de") = {
  let translations = strings(lang)

  if tools == none or tools.len() == 0 {
    return
  }
  heading(
     level: 1,
     numbering: none,
     outlined: true,
   )[#translations.ai-acknowledgement-title]
  ai-tools-table(tools, lang: lang)
}
