
#let default-styles = (
  cy: (
    alignment: (
      address-field: left,
      date-field: right,
      headings: center,
      reference-field: left,
      valediction: right,
    ),
    date: (
      format: "[day padding:none] [month repr:long] [year]",
    ),
    components: (
      place-name: (
        display: false,
      ),
      return-address-field: (
        display: true,
      ),
    ),
  ),
  de: (
    alignment: (
      address-field: left,
      date-field: right,
      headings: left,
      reference-field: left,
      valediction: left,
    ),
    date: (
      format: "[day padding:none]. [month repr:long] [year]",
    ),
    components: (
      place-name: (
        display: true,
        pattern: "[place-name], den"
      ),
      return-address-field: (
        display: true,
      ),
    ),
  ),
  en-GB: (
    alignment: (
      address-field: left,
      date-field: right,
      headings: center,
      reference-field: left,
      valediction: right,
    ),
    date: (
      format: "[day padding:none] [month repr:long] [year]",
    ),
    components: (
      place-name: (
        display: false,
      ),
      return-address-field: (
        display: true,
      ),
    ),
  ),
  en: (
    alignment: (
      address-field: left,
      date-field: right,
      headings: left,
      reference-field: left,
      valediction: left,
    ),
    date: (
      format: "[month repr:long] [day padding:none], [year]",
    ),
    components: (
      place-name: (
        display: false,
      ),
      return-address-field: (
        display: true,
      ),
    ),
  ),
  es: (
    alignment: (
      address-field: left,
      date-field: right + top,
      headings: left,
      reference-field: left,
      valediction: right,
    ),
    date: (
      format: "[day padding:none] de [month repr:long] de [year]",
    ),
    components: (
      place-name: (
        display: true,
      ),
      return-address-field: (
        display: false,
      ),
    ),
  ),
  es-ES: (
    alignment: (
      address-field: left,
      date-field: right + horizon,
      headings: left,
      reference-field: right + bottom,
      valediction: left,
    ),
    date: (
      format: "[day padding:none] de [month repr:long] de [year]",
    ),
    components: (
      place-name: (
        display: true,
      ),
      return-address-field: (
        display: false,
      ),
    ),
  ),
  fr: (
    alignment: (
      address-field: right,
      date-field: right,
      headings: left,
      reference-field: right + horizon,
      valediction: right,
    ),
    date: (
      format: "[day padding:none] [month repr:long] [year]",
    ),
    components: (
      place-name: (
        display: true,
        pattern: "A [place-name], le"
      ),
      return-address-field: (
        display: false,
      ),
    ),
  ),
)

#let strings = (
  cy: (
    reference:   "Cyf:",
    carbon-copy: "c.c.:",
    enclosed-sg: "amg.:",
    enclosed-pl: "amg.:",
    page-xy:     "Tudalen [X] o [Y]",
    months: (
      "1": "Ionawr",
      "2": "Chwefror",
      "3": "Mawrth",
      "4": "Ebrill",
      "5": "Mai",
      "6": "Mehefin",
      "7": "Gorffennaf",
      "8": "Awst",
      "9": "Medi",
      "10": "Hydref",
      "11": "Tachwedd",
      "12": "Rhagfyr",
    )
  ),
  de: (
    reference:   "Referenz:",
    carbon-copy: "In Kopie:",
    enclosed-sg: "Anhang:",
    enclosed-pl: "Anhänge:",
    page-xy:     "Seite [X] von [Y]",
    months: (
      "1": "Januar",
      "2": "Februar",
      "3": "März",
      "4": "April",
      "5": "Mai",
      "6": "Juni",
      "7": "Juli",
      "8": "August",
      "9": "September",
      "10": "Oktober",
      "11": "November",
      "12": "Dezember",
    )
  ),
  de-AT: (
    reference:   "Referenz:",
    carbon-copy: "In Kopie:",
    enclosed-sg: "Anhang:",
    enclosed-pl: "Anhänge:",
    page-xy:     "Seite [X] von [Y]",
    months: (
      "1": "Jänner",
      "2": "Feber",
      "3": "März",
      "4": "April",
      "5": "Mai",
      "6": "Juni",
      "7": "Juli",
      "8": "August",
      "9": "September",
      "10": "Oktober",
      "11": "November",
      "12": "Dezember",
    )
  ),
  en: (
    reference:   "Ref:",
    carbon-copy: "cc:",
    enclosed-sg: "encl:",
    enclosed-pl: "encl:",
    page-xy:     "Page [X] of [Y]",
    months: (
      "1": "January",
      "2": "February",
      "3": "March",
      "4": "April",
      "5": "May",
      "6": "June",
      "7": "July",
      "8": "August",
      "9": "September",
      "10": "October",
      "11": "November",
      "12": "December",
    )
  ),
  es: (
    reference:   "ref.:",
    carbon-copy: "c.c.",
    enclosed-sg: "Anexo:",
    enclosed-pl: "Anexos:",
    page-xy:     "Página [X] de [Y]",
    months: (
      "1": "enero",
      "2": "febrero",
      "3": "marzo",
      "4": "abril",
      "5": "mayo",
      "6": "junio",
      "7": "julio",
      "8": "agosto",
      "9": "septiembre",
      "10": "octubre",
      "11": "noviembre",
      "12": "diciembre",
    )
  ),
  fr: (
    reference:   "Réf:",
    carbon-copy: "cc:",
    enclosed-sg: "pj:",
    enclosed-pl: "pj:",
    page-xy:     "page [X] sur [Y]",
    months: (
      "1": "janvier",
      "2": "février",
      "3": "mars",
      "4": "avril",
      "5": "mai",
      "6": "juin",
      "7": "juillet",
      "8": "août",
      "9": "septembre",
      "10": "octobre",
      "11": "novembre",
      "12": "décembre",
    )
  ),
)

#let get-strings(locale) = {
  let full-locale = locale.lang + "-" + locale.region
  if full-locale in strings {
    strings.at(full-locale)
  } else if locale.lang in strings {
    strings.at(locale.lang)
  } else {
    strings.at("en")
  }
}

#let localise-date(date, format, locale) = {
  let months = get-strings(locale).months
  format = format.replace(regex("\[\s*month [^\]]*repr:long(?: [^\]]*)*\]"), months.at(str(date.month())))
  date.display(format)
}
