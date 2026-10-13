
#let get_translation(translations) = {
  if type(translations) != dictionary {
    return translations
  }

  context {
    let current_lang = if text.lang != none and text.lang in translations {
      text.lang
    } else {
      "es"
    }

    let localized_string = translations.at(
      current_lang,
      default: translations.at("es", default: ""),
    )

    if localized_string == "" {
      localized_string = translations.at("es", default: "")
    }

    localized_string
  }
}

#let translated_terms = (
  area: (
    es: "Área de",
    en: "Area of",
  ),
  page: (
    es: "Página",
    en: "Page"
  ),
  of: (
    es: "de",
    en: "of",
  ),
  tfg: (
    es: "Trabajo Fin de Grado",
    en: "Final Degree Project",
  ),
  supervisor: (
    es: "Tutor",
    en: "Thesis Advisor",
  ),
  uniovi: (
    es: "Universidad de Oviedo",
    en: "University of Oviedo",
  ),
)
