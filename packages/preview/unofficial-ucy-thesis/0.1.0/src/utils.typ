#import "@preview/linguify:0.5.0": linguify

#let lang-db = toml("./lang.toml")

#let t = key => linguify(key, from: lang-db)

#let tl(key, lang) = lang-db.lang.at(lang).at(key)

/// Read a field from a `localized-info` entry, falling back to a `lang.toml` key.
#let localized-field(info, lang, key, default-key) = {
  info.at(key, default: tl(default-key, lang))
}

/// Set once by `ucy-thesis` from `primary-lang`; read via `primary-t` / heading helpers.
#let ucy-lang = state("ucy-lang", "en")

#let primary-t(key) = context {
  tl(key, ucy-lang.get())
}

#let extract-name(person) = {
  person.at("first-name") + " " + person.at("last-names")
}

#let join-names(names) = {
  names.join(", ", last: t("separator-last"))
}

#let author-names(authors) = authors.map(extract-name)

#let advisor-label = advisors => {
  if advisors.len() == 1 {
    t("advisor")
  } else {
    t("supervisor") + "s"
  }
}

/// Placeholder shown when no `logo-image` is supplied (UCY logos are not bundled).
#let logo-placeholder(lang: "en") = {
  box(
    width: 70%,
    height: 4cm,
    stroke: 0.75pt + gray,
    inset: 1em,
    align(center + horizon)[
      #text(size: 11pt, fill: gray.darken(30%))[
        #if lang == "el" [
          Λογότυπο Πανεπιστημίου Κύπρου
        ] else [
          University of Cyprus logo
        ]
      ]
      #v(0.4em)
      #text(size: 9pt, fill: gray)[Add your own file via `logo-image` (see README).]
    ],
  )
}

/// Cover logo: pass `logo-image` with an image you are allowed to use. Preset `logo` is ignored.
#let resolve-logo(logo: "general", logo-image: none, lang: none) = context {
  let lang = if lang != none { lang } else { ucy-lang.get() }
  if logo-image != none {
    if type(logo-image) == str {
      image(logo-image)
    } else {
      logo-image
    }
  } else {
    logo-placeholder(lang: lang)
  }
}

#let format-date(date, lang: "en") = {
  text(lang: lang, date.display("[month repr:long] [year]"))
}

/// Thesis titles are always shown in capital letters (ADE cover style).
#let thesis-title(title) = upper(title)
