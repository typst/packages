// Normalize paper metadata and derive publication defaults before rendering.

#import "frontmatter.typ": normalize-author, parse-ccs
#import "journals.typ": lookup-journal
#import "strings.typ": lang-record
#import "doi.typ": normalize-doi

#let resolve-publication(journal, doi, fix-quirks: false) = (
  journal: lookup-journal(journal),
  doi: if doi == none {
    none
  } else {
    let bare = if fix-quirks { normalize-doi(doi) } else { doi }
    (bare: bare, url: "https://doi.org/" + bare)
  },
)

#let resolve-conference(cfg, conference) = if conference == auto {
  if cfg.kind == "proceedings" {
    (name: "ACM Conference", short: "Conference'17",
     date: "July 2017", venue: "Washington, DC, USA")
  } else {
    none
  }
} else {
  conference
}

#let resolve-booktitle(conference, booktitle) = if booktitle != none {
  booktitle
} else if conference != none and conference.at("name", default: none) != none {
  let name = conference.name
  let short = conference.at("short", default: none)
  if short != none and short != name {
    [Proceedings of #name (#short)]
  } else {
    [Proceedings of #name]
  }
}

#let resolve-translations(lang, translations) = {
  let main-lang = if lang.main != none { lang.main } else { "english" }
  let fields = ("title", "subtitle", "keywords", "abstract")
  for (language, entry) in translations {
    let _ = lang-record(language)
    assert(language != main-lang,
      message: "faithful-acmart: `translations` includes the main language "
        + repr(language) + "; it is for OTHER languages (main is `language`).")
    for field in entry.keys() {
      assert(field in fields,
        message: "faithful-acmart: `translations." + language + "` has unknown field "
          + repr(field) + "; expected any of " + repr(fields) + ".")
    }
  }
  let pick(field) = translations.pairs()
    .filter(pair => field in pair.at(1))
    .map(pair => (pair.at(0), pair.at(1).at(field)))
  (
    title: pick("title"),
    subtitle: pick("subtitle"),
    keywords: pick("keywords"),
    abstract: pick("abstract"),
  )
}

#let document-fields(authors, anonymous, keywords) = (
  authors: if anonymous {
    ("Anonymous Author(s)",)
  } else {
    authors.map(author => author.name).filter(name => type(name) == str)
  },
  keywords: if type(keywords) == array {
    keywords.filter(keyword => type(keyword) == str)
  } else if type(keywords) == str {
    (keywords,)
  } else {
    ()
  },
)

#let resolve-metadata(cfg, lang, data) = {
  let authors = data.authors.map(normalize-author)
  assert(authors.filter(a => a.corresponding).len() <= 1,
    message: "faithful-acmart: at most one author may set `corresponding: true`, "
      + "matching acmart's \\correspondingauthor.")
  let translated = resolve-translations(lang, data.translations)
  let publication = resolve-publication(data.journal, data.doi, fix-quirks: cfg.fix-quirks)
  let conference = resolve-conference(cfg, data.conference)
  let booktitle = resolve-booktitle(conference, data.booktitle)
  let copyright-year = if data.copyright-year != none {
    data.copyright-year
  } else {
    data.acm-year
  }
  let document = document-fields(authors, data.anonymous, data.keywords)

  let meta = data + (
    authors: authors,
    ccs: parse-ccs(data.ccs),
    translated-title: translated.title,
    translated-subtitle: translated.subtitle,
    translated-keywords: translated.keywords,
    translated-abstract: translated.abstract,
    journal: publication.journal,
    doi: publication.doi,
    conference: conference,
    booktitle: booktitle,
    copyright-year: copyright-year,
  )
  let _ = meta.remove("translations")
  (
    meta: meta,
    document: document,
    force-screen: publication.journal.screen,
  )
}
