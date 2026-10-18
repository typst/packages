#let _arno-pro-font-name(font) = {
  if type(font) == str {
    lower(font)
  } else {
    ""
  }
}

#let _is-arno-pro-font(font) = {
  if type(font) == array {
    font.any(family => _is-arno-pro-font(family))
  } else {
    _arno-pro-font-name(font).contains("arno pro")
  }
}

#let _is-arno-pro-semibold(font, weight) = {
  let font-name = _arno-pro-font-name(font)
  if font-name.contains("smbd") {
    true
  } else if type(weight) == str {
    lower(weight) == "semibold"
  } else {
    weight == 600
  }
}

#let arno-pro-optical-font(size, font: "Arno Pro", weight: "regular") = {
  if type(font) == array {
    return font.map(family => {
      if _is-arno-pro-font(family) {
        arno-pro-optical-font(size, font: family, weight: weight)
      } else {
        family
      }
    })
  }

  let semibold = _is-arno-pro-semibold(font, weight)

  if size <= 8.5pt {
    if semibold { "Arno Pro Smbd Caption" } else { "Arno Pro Caption" }
  } else if size <= 10.9pt {
    if semibold { "Arno Pro Smbd SmText" } else { "Arno Pro SmText" }
  } else if size <= 14pt {
    if semibold { "Arno Pro Smbd" } else { "Arno Pro" }
  } else if size <= 21.5pt {
    if semibold { "Arno Pro Smbd Subhead" } else { "Arno Pro Subhead" }
  } else {
    if semibold { "Arno Pro Smbd Display" } else { "Arno Pro Display" }
  }
}

#let arno-pro-optical-text(it) = context {
  if _is-arno-pro-font(text.font) {
    set text(
      font: arno-pro-optical-font(
        text.size,
        font: text.font,
        weight: text.weight,
      ),
    )
    it
  } else {
    it
  }
}
