#import "info.typ"

#let to-string(content) = {
  if type(content) == str {
    content
  } else if type(content) == int {
    content
  } else if content.has("text") {
    if type(content.text) == str {
      content.text
    } else {
      to-string(content.text)
    }
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  } else {
    ""
  }
}


#let to-ascii(s) = {
  let accents = (
    "á": "a",
    "é": "e",
    "í": "i",
    "ó": "o",
    "ú": "u",
    "Á": "a",
    "É": "e",
    "Í": "i",
    "Ó": "o",
    "Ú": "u",
    "ñ": "n",
    "Ñ": "n",
    "ü": "u",
    "Ü": "u",
    "ç": "c",
    "Ç": "c",
  )
  let out = lower(str(s))
  for (acc, clean) in accents {
    out = out.replace(acc, clean)
  }
  out.replace(regex("[^a-z0-9]"), "")
}

#let extract-title-keyword(title) = {
  let stopwords = (
    "el",
    "la",
    "los",
    "las",
    "un",
    "una",
    "unos",
    "unas",
    "de",
    "del",
    "al",
    "en",
    "para",
    "por",
    "con",
    "sin",
    "sobre",
    "entre",
    "hacia",
    "este",
    "esta",
    "estos",
    "estas",
    "the",
    "and",
    "for",
    "with",
    "from",
    "into",
  )

  let words = title.split(regex("\\s+")).map(w => to-ascii(w)).filter(w => w.len() >= 4 and not stopwords.contains(w))

  if words.len() > 0 { words.at(0) } else { "thesis" }
}

/// Conversión de mejor esfuerzo: presupone hasta dos apellidos y conserva las partículas que los preceden. Los nombres ambiguos deben indicarse explícitamente como "Apellidos, Nombres" con author en el generador.
#let normalize-author(raw-name) = {
  if raw-name == none { return none }

  let raw = str(to-string(raw-name)).replace(regex("\\s+"), " ").trim()
  // Solo se quitan tratamientos al comienzo; la escritura del nombre se conserva.
  let titles = regex("(?i)^(?:(?:dr|dra|prof|profa|ing|lic|msc|m\\.sc|phd|ph\\.d|mg|mgs|mtr|mag|arq|abg)\\.? +)+")
  raw = raw.replace(titles, "").trim()
  if raw == "" { return none }

  // Una coma indica que el usuario ya separó apellidos y nombres.
  if raw.contains(",") {
    return raw.split(",").map(part => part.trim()).join(", ")
  }

  let tokens = raw.split(" ")
  if tokens.len() == 1 { return raw }

  let particles = ("de", "del", "la", "las", "los", "da", "das", "do", "dos", "di", "du", "van", "von", "der", "den", "ter", "ten", "san", "santa")
  let surname-start(end) = {
    let start = end - 1
    while start > 0 and lower(tokens.at(start - 1)) in particles {
      start -= 1
    }
    start
  }

  let start = surname-start(tokens.len())
  if start > 1 {
    let second = surname-start(start)
    if second > 0 { start = second }
  }
  // No se inventa una separación si todo el nombre parece un apellido compuesto.
  if start == 0 { return raw }
  tokens.slice(start).join(" ") + ", " + tokens.slice(0, start).join(" ")
}

#let build-bibkey(normalized-author, year, title) = {
  let surnames = normalized-author.split(",").at(0).trim()
  let primary-surname = surnames.split(regex("\\s+")).at(0)
  let clean-surname = to-ascii(primary-surname)
  let clean-year = to-ascii(year)
  let title-kw = extract-title-keyword(title)

  clean-surname + clean-year + "-" + title-kw
}


#let format-biblatex(fields: (:), citation-key: "", indent-width: 12) = {
  let pad(str-val, width) = {
    str-val + " " * calc.max(1, width - str-val.len())
  }

  let lines = ("@thesis{" + citation-key + ",",)

  for (field, val) in fields.pairs() {
    if val != none {
      let clean-val = str(to-string(val)).trim()
      if clean-val != "" {
        lines.push("  " + pad(field, indent-width) + "= {" + clean-val + "},")
      }
    }
  }

  lines.push("}")
  lines.join("\n")
}

#let optional-string(value) = {
  if value == none {
    return none
  }

  let result = str(to-string(value)).trim()
  if result == "" { none } else { result }
}

#let supervisor-note(value) = {
  let entries = info.supervisor-entries(value)
  let notes = range(0, entries.len(), step: 2).map(index => {
    to-string(entries.at(index + 1)).trim() + " (" + to-string(entries.at(index)).trim() + ")"
  })
  if notes.len() == 0 { none } else { "Supervisión académica: " + notes.join("; ") }
}

#let insert-optional(dict, key, value) = {
  if value != none {
    dict.insert(key, value)
  }
}

/// Genera la entrada BibLaTeX de la tesis en formato `.bib`.
/// - author: Nombre en formato "Apellidos, Nombres". Si es none, se normaliza automáticamente.
/// - bibkey: Clave de citación personalizada. Si es none, se genera `apellidoAÑO-palabra`.
#let generate(author: none, bibkey: none, url: none, doi: none, edition: none) = context {
  let final-author = if author != none {
    author
  } else {
    normalize-author(info.author-name.get())
  }

  let work-title = info.work-title.get()
  let thesis-type = info.thesis-modality.get()

  let raw-date = info.work-date.get()
  let year = if type(raw-date) == datetime {
    str(raw-date.year())
  } else {
    let m = str(raw-date).match(regex("\b(19|20)\d{2}\b"))
    if m != none { m.text } else { str(raw-date) }
  }

  let final-key = if bibkey != none {
    to-ascii(bibkey)
  } else {
    build-bibkey(final-author, year, to-string(work-title))
  }

  let raw-keywords = info.keywords.get()
  let formatted-keywords = if type(raw-keywords) == array {
    raw-keywords.join(", ")
  } else {
    raw-keywords
  }

  let data = (
    author: final-author,
    title: work-title,
    type: thesis-type,
    institution: info.university.get(),
    department: info.faculty.get(),
    location: info.city.get(),
    date: year,
    langid: "spanish",
    language: "spanish",
    abstract: info.work-abstract.get(),
    keywords: formatted-keywords,
    degree: info.degree-level.get() + " en " + info.degree-program.get(),
    pagetotal: info.work-pages.final(),
    note: supervisor-note(info.supervisor.get()),
    url: optional-string(url),
    doi: optional-string(doi),
    edition: edition,
  )

  let biblatex = format-biblatex(
    fields: data,
    citation-key: final-key,
    indent-width: 12,
  )

  return asset("thesis.bib", bytes(biblatex))
}

/// Genera la entrada Hayagriva de la tesis en formato `.yml`.
///
/// - author: Autor en formato "Apellidos, Nombres".
/// - citation-key: Clave personalizada de citación.
/// - call-number: Signatura topográfica de la biblioteca.
/// - supervisor-role: Si es none, omite la nota de supervisión; los roles se toman de los datos de la portada.
#let generate-hayagriva(
  author: none,
  citation-key: none,
  call-number: none,
  archive: none,
  archive-location: none,
  url: none,
  doi: none,
  edition: none,
  supervisor-role: "director",
) = context {
  let final-author = if author != none {
    optional-string(author)
  } else {
    normalize-author(info.author-name.get())
  }

  let work-title = optional-string(info.work-title.get())
  let thesis-type = optional-string(info.thesis-modality.get())

  let raw-date = info.work-date.get()
  let year = if type(raw-date) == datetime {
    str(raw-date.year())
  } else {
    let m = str(raw-date).match(regex("\b(19|20)\d{2}\b"))
    if m != none { m.text } else { str(raw-date) }
  }

  let final-key = if citation-key != none {
    to-ascii(citation-key)
  } else {
    build-bibkey(final-author, year, work-title)
  }

  let university = optional-string(info.university.get())
  let city = optional-string(info.city.get())
  let supervision-note = supervisor-note(info.supervisor.get())
  let abstract = optional-string(info.work-abstract.get())

  // Hayagriva thesis metadata.
  let data = (
    type: "thesis",
    title: work-title,
    author: final-author,
    date: int(year),
    language: "es-BO",
    abstract: abstract,
    genre: thesis-type,
    organization: university,
    location: city,
    archive: "Biblioteca de la " + university,
    archive-location: city,
  )

  // La biblioteca y su ubicación son conocidas; las opciones permiten sustituirlas. No se presupone una edición.
  for (key, value) in (archive: archive, archive-location: archive-location, url: url) {
    if optional-string(value) != none { data.insert(key, optional-string(value)) }
  }
  if edition != none { data.insert("edition", edition) }
  if optional-string(doi) != none {
    data.insert("serial-number", (doi: optional-string(doi)))
  }

  let pages = info.work-pages.final()
  if pages != none {
    data.insert("page-total", pages)
  }

  if call-number != none {
    data.insert("call-number", call-number)
  }

  if supervision-note != none and supervisor-role != none {
    data.insert("note", supervision-note)
  }

  let entries = (:)
  entries.insert(final-key, data)

  let output = yaml.encode(entries)

  asset("thesis.yaml", output)
}
