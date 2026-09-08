#import "@preview/hydra:0.6.3": hydra
#import "@preview/codly:1.3.0": *
#import "@preview/theorion:0.6.0": *

#let default-names = toml("config/names.toml")
#let default-styles = toml("config/styles.toml")
#let default-info = toml("config/info.toml").global

#let latin-coverage() = regex("[\\p{Latin}\\p{Mark}0-9.,:;!?()\\[\\]'’\\-–—]")

#let font-platform-for(styles) = {
  let platform = sys.inputs.at(
    "qooklet-font-platform",
    default: styles.at("font-platform", default: "windows"),
  )
  assert(
    platform in ("windows", "macos"),
    message: "qooklet-font-platform must be either \"windows\" or \"macos\"",
  )
  platform
}

#let font-role-options(styles, lang, role) = {
  let platform-fonts = styles.fonts.at(font-platform-for(styles))
  let roles = styles.at("font-roles").at(lang)
  let family = roles.at(role, default: roles.at("default", default: role))
  let font = platform-fonts.at(family, default: family)
  if lang == "zh" {
    let latin-font = font-role-options(styles, "cjk-latin", role).font
    return (font: ((name: latin-font, covers: latin-coverage()), font))
  }
  if font == "" { (:) } else { (font: font) }
}

#let cjk-latin-style(
  body,
  font: "",
  styles: default-styles,
  lang: "en",
  role: "",
  as-style: false,
  ..options,
) = {
  let base-options = if role == "" {
    if font == "" { (:) } else { (font: font) }
  } else {
    font-role-options(styles, lang, role)
  }
  let apply-cjk-latin = body => {
    if lang == "zh" and role != "" {
      let text-weight = options.named().at("weight", default: "regular")
      show latin-coverage(): set text(
        ..font-role-options(styles, "cjk-latin", role),
        weight: text-weight,
      )
    }
    body
  }
  if as-style {
    return apply-cjk-latin(body)
  }
  if lang == "zh" and role != "" {
    apply-cjk-latin(text(body, ..base-options, ..options))
  } else {
    text(body, ..base-options, ..options)
  }
}

#let tip = tip-block
#let note = note-block
#let quote = quote-block
#let warning = warning-block
#let caution = caution-block
