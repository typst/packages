#import "locale.typ": *

#let ai-usage-section(
  ai-usage-section-content,
  language,
) = {
  heading(level: 1, AI_USAGE_SECTION_TITLE.at(language))
  v(1em)

  if (ai-usage-section-content != none) {
    ai-usage-section-content
  }
}
