#import "locale.typ": *

#let declaration-of-ai-usage(
  ai-tools,
  declaration-of-ai-usage-content,
  language,
) = {
  v(2em)
  text(size: 20pt, weight: "bold", DECLARATION_OF_AI_USAGE_TITLE.at(language))
  v(1em)

  if (declaration-of-ai-usage-content != none) {
    declaration-of-ai-usage-content
  } else if (ai-tools != none and ai-tools.len() > 0) {
    par(justify: true, DECLARATION_OF_AI_USAGE_TEXT.at(language))
    v(1em)
    text(weight: "semibold", DECLARATION_OF_AI_USAGE_TOOLS.at(language))
    v(0.5em)
    list(
      ..ai-tools.map(tool => if (type(tool) == array and tool.len() == 2) {
        link(tool.at(1), tool.at(0))
      } else {
        tool
      })
    )
  } else {
    par(justify: true, DECLARATION_OF_AI_USAGE_NONE.at(language))
  }
}
