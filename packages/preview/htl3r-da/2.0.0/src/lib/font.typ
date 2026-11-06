#import "settings.typ" as settings

#let is-font-missing(font) = {
  measure(text(font: font, fallback: false)[WIDTH]).width == 0pt
}

/// Returns an array of missing fonts
#let check-missing-fonts() = {
  (
    settings.FONT_HEADING,
    settings.FONT_TEXT_BODY,
    settings.FONT_TEXT_DISPLAY,
    settings.FONT_TEXT_RAW,
  )
    .dedup()
    .filter(it => is-font-missing(it))
}
