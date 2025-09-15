#import "@preview/nth:1.0.1": *
#import "@preview/oxifmt:1.0.0": strfmt
#import "bib-util.typ": fd, ifdef, concatenate-list
#import "templating.typ": *
#import "names.typ": format-name
#import "bib-util.typ": is-integer
#import "dates.typ": is-year-defined


#let eprint(reference, options) = {
  let eprint-type = fd(reference, "eprinttype", options)

  ifdef(reference, "eprint", options, eprint => {
    if eprint-type != none and lower(eprint-type) == "hdl" {
      [HDL: #link("http://hdl.handle.net/" + eprint, eprint)]
    } else if eprint-type != none and lower(eprint-type) == "arxiv" {
      let suffix = ifdef(reference, "eprintclass", options, eprintclass => options.at("format-brackets")(eprintclass))
      [arXiv: #link("https://arxiv.org/abs/" + eprint, spaces(eprint, suffix))]
    } else if eprint-type != none and lower(eprint-type) == "jstor" {
      [JSTOR: #link("http://www.jstor.org/stable/" + eprint, eprint)]
    } else if eprint-type != none and lower(eprint-type) == "pubmed" {
      [PMID: #link("http://www.ncbi.nlm.nih.gov/pubmed/" + eprint, eprint)]
    } else if eprint-type != none and (lower(eprint-type) == "googlebooks" or lower(eprint-type) == "google books") {
      [Google Books: #link("http://books.google.com/books?id=" + eprint, eprint)]
    } else {
      let suffix = ifdef(reference, "eprintclass", options, eprintclass => options.at("format-brackets")(eprintclass))
      let eprint-type = if eprint-type == none { "eprint" } else { eprint-type }
      [#eprint-type: #link(eprint, spaces(eprint, suffix))]
    }
  })
}

// make title a hyperlink if DOI or URL are defined
#let link-title(reference, options) = {
  let title = if options.eval-mode == none { 
    reference.fields.title.trim() 
    } else { 
      eval(reference.fields.title.trim(), mode: options.eval-mode, scope: options.eval-scope) 
    }

  if not options.link-titles {
    title 
  } else if "doi" in reference.fields {
    link("https://doi.org/" + reference.fields.doi)[#title]
  } else if "url" in reference.fields {
    link(reference.fields.url)[#title]
  } else {
    title
  }
}

// Prints a list of author names. Names are formatted and concatenated
// as specified in the options. `name-parts-array` is an array of name-parts dictionaries.
#let print-name(name-parts-array, options) = {
  concatenate-list(name-parts-array.map(d => format-name(d, format-str: options.name-format)), options)
}

#let month-bibstring-keys = (
   "january", "february", "march", "april", "may", "june", 
   "july", "august", "september", "october", "november", "december"
)
 
#let print-date(date-dict, options) = {
  let month-entry = date-dict.at("month", default: none)

  // Special treatment for "month": It could not be suppressed in parse-date
  // (that was too early, we didn't have the format-reference options yet),
  // so we have to do it here. :/
  if "month" in options.suppressed-fields {
    month-entry = none
  }

  let month-str = if month-entry != none {
    if type(month-entry) == int {
      options.bibstring.at(month-bibstring-keys.at(month-entry - 1))
    } else {
      month-entry
    }
  } else {
    none
  }

  if "day" in date-dict {
    strfmt("{} {} {}", date-dict.day, month-str, date-dict.year)
  } else if month-str != none {
    strfmt("{} {}", month-str, date-dict.year)
  } else if "year" in date-dict {
    str(date-dict.year)
  } else {
    options.bibstring.nodate
  }
}

#let field-formats = (
  // Used in the bibliography and bibliography lists

  "doi": (value, reference, field, options, style) => {
    [DOI: #link("https://doi.org/" + value)]
  },

  "edition": (value, reference, field, options, style) => {
    if is-integer(value) {
      spaces(nth(int(value)), options.bibstring.edition)
    } else {
      value
    }
  },

  "eprint": (value, reference, field, options, style) => {
    eprint(reference, options)
  },

  "issn": (value, reference, field, options, style) => {
    spaces("ISSN", value)
  },

  "isbn": (value, reference, field, options, style) => {
    spaces("ISBN", value)
  },

  "isrn": (value, reference, field, options, style) => {
    spaces("ISRN", value)
  },

  "pages": (value, reference, field, options, style) => {
    if value.contains("-") or value.contains(sym.dash.en) {
      // Typst biblatex library converts "--" into an endash "–"
      spaces(options.bibstring.pages, value)
    } else {
      spaces(options.bibstring.page, value)
    }
  },

  "volume": (value, reference, field, options, style) => {
    if reference.entry_type in ("article", "periodical") {
      value
    } else {
      spaces(options.bibstring.volume, value)
    }
  },

  "file": (value, reference, field, options, style) => {
    raw(value)
  },

  "journaltitle": (value, reference, field, options, style) => {
    options.at("format-journaltitle")(value)
  },

  "issuetitle": (value, reference, field, options, style) => {
    options.at("format-issuetitle")(value)
  },

  "maintitle": (value, reference, field, options, style) => {
    emph(value)
  },

  "mainsubtitle": (value, reference, field, options, style) => {
    emph(value)
  },


  "booktitle": (value, reference, field, options, style) => {
    emph(value)
  },

  "chapter": (value, reference, field, options, style) => {
    spaces(options.bibstring.chapter, value)
  },

  "part": (value, reference, field, options, style) => {
    // physical part of a logical volume
    "." + value
  },

  "series": (value, reference, field, options, style) => {
    if reference.entry_type in ("article", "periodical") {
      // series of a journal
      if is-integer(value) {
        spaces(nth(int(value)), options.bibstring.jourser)
      } else {
        options.bibstring.at(value, default: value)
      }
    } else {
      // publication series
      value
    }
  },

  "pubstate": (value, reference, field, options, style) => {
    options.bibstring.at(value, default: value)
  },

  "title": (value, reference, field, options, style) => {
    let bib-type = reference.entry_type
    let title = link-title(reference, options)

    if bib-type in ("article", "inbook", "incollection", "inproceedings", "patent", "thesis", "unpublished") {
      options.at("format-quotes")(title)
    } else if bib-type in ("suppbook", "suppcollection", "suppperiodical") {
      title
    } else {
      emph(title)
    }
  },

  "type": (value, reference, field, options, style) => {
    options.bibstring.at(value, default: value)
  },

  "url": (value, reference, field, options, style) => {
    [URL: #link(value, value)]
  },

  "urldate": (value, reference, field, options, style) => {
    options.at("format-parens")([#options.bibstring.urlseen #value])
  },

  "version": (value, reference, field, options, style) => {
    spaces(options.bibstring.version, value)
  },

  "volumes": (value, reference, field, options, style) => {
    spaces(value, options.bibstring.volumes)
  },

  "date": "parsed-date",

  "parsed-date": (value, reference, field, options, style) => {
    print-date(value, options)
  },

  "extradate": (value, reference, field, options, style) => {
    if is-year-defined(reference) {      
      numbering("a", value+1)
    } else {
      (options.format-brackets)(numbering("a", value+1))
    }
  },

  "author": "parsed-author",

  "parsed-author": (value, reference, field, options, style) => {
    print-name(value, options)
  },

  "editor": "parsed-editor",

  "parsed-editor": (value, reference, field, options, style) => {
    print-name(value, options)
  },

  "translator": "parsed-translator",
  
  "parsed-translator": (value, reference, field, options, style) => {
    print-name(value, options)
  },

  "language": (value, reference, field, options, style) => {
    if value == none {
      none
    } else {
      let language-list = value.split(regex("\s+and\s+"))
      concatenate-list(language-list, options) + " XXX"
    }
  }
  /*
  TODO currently unsupported:

  \DeclareFieldFormat{month}{\mkbibmonth{#1}}
  \DeclareFieldFormat{pagetotal}{\mkpagetotal[bookpagination]{#1}}
  \DeclareFieldFormat{related}{#1}
  \DeclareFieldFormat{related:multivolume}{#1}
  \DeclareFieldFormat{related:origpubin}{\mkbibparens{#1}}
  \DeclareFieldFormat{related:origpubas}{\mkbibparens{#1}}
  \DeclareFieldFormat{relatedstring:default}{#1\printunit{\relatedpunct}}
  \DeclareFieldFormat{relatedstring:reprintfrom}{#1\addspace}
  */
)



#let printfield(reference, field, options, style: none) = {
  let value = fd(reference, field, options)
  
  if value == none {
    none
  } else {
    field = lower(field)

    let printed = if field in field-formats {
      let format = field-formats.at(field)

      // resolve format aliases, e.g. "editor" to "parsed-editor"
      while type(format) == str {
        field = format
        format = field-formats.at(field)
        value = fd(reference, field, options)
      }

      format(value, reference, field, options, style)
    } else {
      value
    }

    if options.eval-mode != none and type(printed) == str {
      printed = eval(printed, mode: options.eval-mode, scope: options.eval-scope)
    }

    printed
  }
}

