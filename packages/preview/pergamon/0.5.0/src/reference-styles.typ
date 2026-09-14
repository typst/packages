#import "bibtypst.typ": *
#import "templating.typ": *
#import "bibstrings.typ": default-long-bibstring, default-short-bibstring
#import "printfield.typ": printfield, default-field-formats
#import "bib-util.typ": fd, ifdef, type-aliases, nn, concatenate-names



// If, else none. If the `guard` evaluates to `true`,
// evaluate `value-func` and return the result. Otherwise return `none`.
#let ifen(guard, value-func) = {
  if guard {
    value-func()
  } else {
    none
  }
}


// If a formatting function with the name "fn-name" (str) is defined
// in options, call that function; otherwise call the default-fn.
#let with-default(fn-name, default-fn) = {
  (reference, options) => {
    let fn = options.format-functions.at(fn-name, default: none)

    if fn == none {
      default-fn(reference, options)
    } else {
      fn(reference, options)
    }
  }
}

// biblatex.def authorstrg
#let authorstrg = with-default("authorstrg", (reference, options) => {
  printfield(reference, "authortype", options)
  // TODO - implement all the "strg" stuff correctly
})


#let language = with-default("language", (reference, options) => {
  printfield(reference, "language", options)
})


#let date-with-extradate = with-default("date-with-extradate", (reference, options) => {
  epsilons(
    printfield(reference, "parsed-date", options),
    printfield(reference, "extradate", options)
  )
})

// Adds date+extradate to a name if print-date-after-authors is true.
// The name could be generated from author, editor+others, etc.
#let maybe-with-date = with-default("maybe-with-date", (reference, options) => {
  name => {
    spaces(
      name,
      ifen(options.print-date-after-authors, () => (options.format-parens)(date-with-extradate(reference, options)))
    )
  }
})

// biblatex.def author
#let author = with-default("author", (reference, options) => {
  if fd(reference, "author", options) != none and options.use-author {
    fjoin(options.author-type-delim,
      printfield(reference, "author", options),
      authorstrg(reference, options)
    )
  } else {
    none
  }
})



// biblatex.def author/editor
#let author-editor = with-default("author-editor", (reference, options) => {
  if fd(reference, "author", options) != none and options.use-author {
    author(reference, options)
  } else {
    editor(reference, options)
  }
})

// biblatex.def editor+others
#let editor-others = with-default("editor-others", (reference, options) => {
  let editor = fd(reference, "parsed-editor", options)
  if options.use-editor and editor != none {
    let suffix = if editor.len() > 1 { options.bibstring.editors } else { options.bibstring.editor }
    [#printfield(reference, "parsed-editor", options), #suffix]
  } else {
    none
  }
})


// biblatex.def editor
#let editor = with-default("editor", (reference, options) => {
  // TODO - I am pointing this back to editor+others for now, but we should
  // probably disentangle the two once support for "+others" improves.
  editor-others(reference, options)
})


// biblatex.def translator+others
#let translator-others = with-default("translator-others", (reference, options) => {
  let translator = fd(reference, "parsed-translator", options)
  if options.use-translator and translator != none {
    let suffix = if translator.len() > 1 { options.bibstring.translators } else { options.bibstring.translator }
    [#printfield(reference, "parsed-translator", options), #suffix]
  } else {
    none
  }
})

// biblatex.def author/translator+others
#let author-translator-others = with-default("author-translator-others", (reference, options) => {
  if options.use-author and fd(reference, "author", options) != none {
    author(reference, options)
  } else {
    translator-others(reference, options)
  }
})


// standard.bbx volume+number+eid
#let volume-number-eid = with-default("volume-number-eid", (reference, options) => {
  let volume = printfield(reference, "volume", options)
  let number = printfield(reference, "number", options)

  let a = if volume == none and number == none {
    none
  } else if number == none {
    volume
  } else if volume == none {
    panic("Can't use 'number' without 'volume' (in " + reference.entry_key + ")!")
  } else {
    volume + options.volume-number-separator + number
  }

  fjoin(options.bibeidpunct, a, fd(reference, "eid", options))
})


#let type-number-location = with-default("type-number-location", (reference, options) => {
  let loc = if fd(reference, "location", options) != none { (options.format-parens)(printfield(reference, "location", options)) } else { none }
  spaces(
    printfield(reference, "type", options),
    printfield(reference, "number", options),
    loc
  )
})



// standard.bbx issue+date
#let issue-date = with-default("issue-date", (reference, options) => {
  spaces(
    printfield(reference, "issue", options),
    ifen(not options.print-date-after-authors, () => date-with-extradate(reference, options)),
    format: options.format-parens
  )
})

// biblatex.def issue
// -- in contrast to the original, we include the preceding colon here
#let issue = with-default("issue", (reference, options) => {
  let issuetitle = printfield(reference, "issuetitle", options)
  let issuesubtitle = printfield(reference, "issuesubtitle", options)

  if issuetitle == none and issuesubtitle == none {
    none
  } else {
    [: ]
    (options.periods)(
      fjoin(options.subtitlepunct, format: options.format-issuetitle, issuetitle, issuesubtitle),
      printfield(reference, "issuetitleaddon", options)
    )
  }
})

// standard.bbx journal+issuetitle
#let journal-issue-title = with-default("journal-issue-title", (reference, options) => {
  let jt = printfield(reference, "journaltitle", options)
  let jst = printfield(reference, "journalsubtitle", options)

  if jt == none and jst == none {
    none
  } else {
    let journaltitle = (options.periods)(
      fjoin(options.subtitlepunct, jt, jst, format: options.format-journaltitle),
      printfield(reference, "journaltitleaddon", options)
    )

    spaces(
      journaltitle,
      printfield(reference, "series", options),
      volume-number-eid(reference, options),
      issue-date(reference, options),
      issue(reference, options)
    )
  }
})

// biblatex.def periodical
#let periodical = with-default("periodical", (reference, options) => {
  (options.commas)(
    (options.format-issuetitle)(
      fjoin(options.subtitlepunct,
        printfield(reference, "title", options, style: "titlecase"),
        printfield(reference, "subtitle", options, style: "titlecase")
      )
    ),
    printfield(reference, "titleaddon", options)
  )
})

// standard.bbx title+issuetitle
#let title-issuetitle = with-default("title-issuetitle", (reference, options) => {
  spaces(
    (options.commas)(
      periodical(reference, options),
      printfield(reference, "series", options)
    ),
    volume-number-eid(reference, options),
    issue-date(reference, options),
    issue(reference, options)
  )
})

// biblatex.def withothers
#let withothers = with-default("withothers", (reference, options) => {
  (options.periods)(
    ifdef(reference, "commentator", options, commentator => spaces(options.bibstring.withcommentator, commentator)),
    ifdef(reference, "annotator", options, annotator => spaces(options.bibstring.withannotator, annotator)),
    ifdef(reference, "introduction", options, introduction => spaces(options.bibstring.withintroduction, introduction)),
    ifdef(reference, "foreword", options, foreword => spaces(options.bibstring.withforeword, foreword)),
    ifdef(reference, "afterword", options, afterword => spaces(options.bibstring.withafterword, afterword))
  )
})

#let render-origlanguage(reference, bibstring-id, options) = {
  let origlanguage = fd(reference, "origlanguage", options)
  let value = options.bibstring.at(bibstring-id)

  if origlanguage == none {
    // no origlanguage defined in bib entry => delete the <fromlang> string
    value.replace("<fromlang> ", "")
  } else {
    // otherwise, expand <fromlang> into the actual origlanguages
    let language-list = origlanguage.split(regex("\s+and\s+")).map({ id => options.bibstring.at("from" + id, default: "from the " + id) })
    value.replace("<fromlang>", concatenate-names(language-list, options: options, maxnames: 99))
  }
}


// "Translated by X"
// biblatex.def bytranslator+others
#let bytranslator-others = with-default("bytranslator-others", (reference, options) => {
  let translator = {
    if fd(reference, "translator", (:)) != none and options.use-translator and reference.fields.labelnamesource != "translator" {
      let translatorname = printfield(reference, "translator", options)
      let by-string = render-origlanguage(reference, "bytranslator", options)
      spaces(by-string, translatorname)
      // TODO bibstring.byeditor should be expanded as in byeditor+othersstrg
    }
  }

  (options.periods)(
    translator,
    withothers(reference, options)
  )
})

// "Edited by X"
// biblatex.def byeditor+others
#let byeditor-others = with-default("byeditor-others", (reference, options) => {
  let editor = {
    if fd(reference, "editor", (:)) != none and options.use-editor and reference.fields.labelnamesource != "editor" {
      let editorname = printfield(reference, "editor", options)
      spaces(options.bibstring.byeditor, editorname)
      // TODO bibstring.byeditor should be expanded as in byeditor+othersstrg
    }
  }

  (options.periods)( // TODO: check how they are actually joined
    editor,
    // TODO: support editora etc.,  \usebibmacro{byeditorx}%
    bytranslator-others(reference, options)
  )
})

// "By X"
// biblatex.def byauthor
#let byauthor = with-default("byauthor", (reference, options) => {
  let author = {
    if fd(reference, "author", (:)) != none and options.use-author and reference.fields.labelnamesource != "author" {
      let name = printfield(reference, "author", options)
      spaces(options.bibstring.byauthor, name)
      // TODO bibstring.byeditor should be expanded as in byeditor+othersstrg
    }
  }

  // TODO: add \usebibmacro{bytypestrg}{author}{author}
  // (same as in the other by-X functions)
  author
})

// "By X"
// biblatex.def name alias, cf. biblatex.def line 1000
#let bybookauthor = with-default("bybookauthor", (reference, options) => byauthor(reference, options))

#let byholder = with-default("byholder", (reference, options) => printfield(reference, "holder", options))

#let byeditor = with-default("byeditor", (reference, options) => {
  if fd(reference, "editor", options) != none and options.use-editor and reference.fields.labelnamesource != "editor" {
    let name = printfield(reference, "editor", options)
    // TODO use \usebibmacro{bytypestrg}{editor}{editor}, not bibstring.byeditor
    spaces(options.bibstring.byeditor, name)
  } else {
    // TODO fall back to editorx
    none
  }
})

// standard.bbx note+pages
#let note-pages = with-default("note-pages", (reference, options) => {
  fjoin(options.bibpagespunct, printfield(reference, "note", options), printfield(reference, "pages", options))
})

// biblatex.def url+urldate
// In contrast to Biblatex, we distinguish two cases:
// - If we actually print an URL, we typeset "URL (accessed on DATE)", like Biblatex.
// - If there is an URL and we linked the title to it, we typeset "Accessed on DATE" here.
#let url-urldate = with-default("url-urldate", (reference, options) => {
  let urldate = fd(reference, "urldate", options)
  let url = fd(reference, "url", options)

  if url != none {
    if options.print-url {
      // "URL (accessed on DATE)"
      spaces(
        printfield(reference, "url", options),
        (options.format-parens)(printfield(reference, "urldate", options))
      )
    } else if options.link-titles {
      // "Accessed on DATE"
      printfield(reference, "urldate", options)
    }
  } else {
    none
  }
})

// standard.bbx doi+eprint+url
#let doi-eprint-url = with-default("doi-eprint-url", (reference, options) => {
  (options.periods)(
    if options.print-doi { printfield(reference, "doi", options) } else { none },
    if options.print-eprint { printfield(reference, "eprint", options) } else { none },
    url-urldate(reference, options)
    // if options.print-url { printfield(reference, "url", options) } else { none },
  )
})

// standard.bbx addendum+pubstate
#let addendum-pubstate = with-default("addendum-pubstate", (reference, options) => {
  (options.periods)(
    printfield(reference, "addendum", options),
    printfield(reference, "pubstate", options)
  )
})

#let maintitle = with-default("maintitle", (reference, options) => {
  (options.periods)(
    fjoin(options.subtitlepunct, 
      printfield(reference, "maintitle", options, style: "titlecase"), 
      printfield(reference, "mainsubtitle", options, style: "titlecase"), 
      format: options.format-maintitle),
    printfield(reference, "maintitleaddon", options)
  )

  // missing:  {\printtext[maintitle]{
})

#let booktitle = with-default("booktitle", (reference, options) => {
  (options.periods)(
    fjoin(options.subtitlepunct, 
      printfield(reference, "booktitle", options, style: "titlecase"), 
      printfield(reference, "booksubtitle", options, style: "titlecase"),
      format: options.format-booktitle),
    printfield(reference, "booktitleaddon", options)
  )

  // missing:  {\printtext[booktitle]{
})


// standard.bbx maintitle+booktitle
#let maintitle-booktitle = with-default("maintitle-booktitle", (reference, options) => {
  spaces(
    ifdef(reference, "maintitle", options, maintitle => {
      spaces(
        maintitle,
        ifdef(reference, "volume", options, volume => {
          [#printfield(reference, "volume", options)
           #printfield(reference, "part", options):]           
        })
      )
    }),
    booktitle(reference, options)
  )
})

// standard.bbx maintitle+title
#let maintitle-title = with-default("maintitle-title", (reference, options) => {
  let maintitle = fd(reference, "maintitle", options)
  let title = fd(reference, "title", options)
  let print-maintitle = (maintitle != none) and (maintitle != title)

  let volume-prefix = if print-maintitle { epsilons(printfield(reference, "volume", options), printfield(reference, "part", options)) } else { none }

  let maintitle-str = if print-maintitle {
    (options.periods)(
      fjoin(
        options.subtitlepunct,
        printfield(reference, "maintitle", options),
        printfield(reference, "mainsubtitle", options),
        format: options.format-maintitle
      ),
      epsilons(
        printfield(reference, "volume", options), 
        printfield(reference, "part", options),
      )
    )
  } else { none }

    fjoin(":", maintitle-str, printfield(reference, "title", options)
  )
})


// standard.bbx event+venue+date
#let event-venue-date = with-default("event-venue-date", (reference, options) => {
  let format-parens = options.at("format-parens")

  spaces(
    (options.periods)(
      printfield(reference, "eventtitle", options),
      printfield(reference, "eventtitleaddon", options),
    ),
    format-parens(
      (options.commas)(
        printfield(reference, "venue", options),
        printfield(reference, "eventdate", options)
      )
    )
  )
})

#let volume-part-if-maintitle-undef = with-default("volume-part-if-maintitle-undef", (reference, options) => {
  if fd(reference, "maintitle", options) == none {
    epsilons(printfield(reference, "volume", options), printfield(reference, "part", options))
  } else {
    none
  }
})

// standard.bbx series+number
#let series-number = with-default("series-number", (reference, options) => {
  spaces(printfield(reference, "series", options), printfield(reference, "number", options))
})

#let xxx-location-date(reference, options, xxx) = {
  (options.commas)(
    fjoin(
      ":",
      printfield(reference, "location", options), // Biblatex: printlist{location}
      if xxx != none { printfield(reference, xxx, options) } else { none }
    ),
    ifen(not options.print-date-after-authors, () => date-with-extradate(reference, options))
  )
}

// standard.bbx publisher+location+date
#let publisher-location-date = with-default("publisher-location-date", 
    (reference, options) => xxx-location-date(reference, options, "publisher"))

// standard.bbx organization+location+date
#let organization-location-date = with-default("organization-location-date", (reference, options) => xxx-location-date(reference, options, "organization"))

// standard.bbx institution+location+date
#let institution-location-date = with-default("institution-location-date", (reference, options) => xxx-location-date(reference, options, "institution"))

#let location-date = with-default("location-date", (reference, options) => xxx-location-date(reference, options, none))

// chapter+pages
#let chapter-pages = with-default("chapter-pages", (reference, options) => {
  fjoin(options.bibpagespunct,
    printfield(reference, "chapter", options),
    printfield(reference, "eid", options),
    printfield(reference, "pages", options)
  )
})

// biblatex.def author/editor+others/translator+others
#let author-editor-others-translator-others = with-default("author-editor-others-translator-others", (reference, options) => {
  first-of(
    author(reference, options),
    editor-others(reference, options),
    translator-others(reference, options)
  )
})

// Panic if one of the specified fields is missing.
// A field specification can either be the name of a field (str),
// in which case that field must exist; or it can be an array of strings,
// in which case one of the fields in the array must exist.
// This is useful e.g. for the case ("date", "year") or ("author", "editor").
#let require-fields(reference, options, ..fields) = {
  for fieldspec in fields.pos() {
    let fieldspec-present = if type(fieldspec) == array {
      let one-is-present = false
      for field in fieldspec {
        if fd(reference, field, options) != none {
          one-is-present = true
        }
      }
      one-is-present
    } else {
      fd(reference, fieldspec, options) != none
    }

    if not fieldspec-present {
      panic(strfmt("Required field '{}' is missing in entry '{}'!", fieldspec, reference.entry_key))
    }
  }
}

#let title-with-language = with-default("title-with-language", (reference, options) => {
  (options.periods)(
    printfield(reference, "title", options),
    printfield(reference, "language", options)
  )
})


#let driver-article = with-default("driver-article", (reference, options) => {
    require-fields(reference, options, "author", "title", "journaltitle")
    // ("date", "year") don't have to be required - we just print "n.d." in that case

    // I am mapping \newunit to commas and \newblock to periods.
    // Perhaps this should be made configurable at some point.
    (options.periods)(
      maybe-with-date(reference, options)(
        author-translator-others(reference, options)
      ),
      title-with-language(reference, options),
      byauthor(reference, options),
      bytranslator-others(reference, options),
      printfield(reference, "version", options),
      (options.commas)(
        spaces(options.bibstring.in, journal-issue-title(reference, options)), // may print date
        byeditor-others(reference, options),
        note-pages(reference, options)
      ),
      if options.print-isbn { printfield(reference, "issn", options) } else { none },
      doi-eprint-url(reference, options),
      addendum-pubstate(reference, options)

      // TODO: support this at some point [1]
      //   \setunit{\bibpagerefpunct}\newblock
      // \usebibmacro{pageref}%
      // \newunit\newblock
      // \iftoggle{bbx:related}
      //   {\usebibmacro{related:init}%
      //   \usebibmacro{related}}
    )
})



#let driver-inproceedings = with-default("driver-inproceedings", (reference, options) => {
  require-fields(reference, options, "author", "title", "booktitle")

  (options.periods)(
    maybe-with-date(reference, options)(
      author-translator-others(reference, options)
    ),
    title-with-language(reference, options),
    byauthor(reference, options),
    spaces(options.bibstring.in, maintitle-booktitle(reference, options)),
    event-venue-date(reference, options),
    byeditor-others(reference, options),
    volume-part-if-maintitle-undef(reference, options),
    printfield(reference, "volumes", options),
    series-number(reference, options),
    printfield(reference, "note", options),
    (options.commas)(
      printfield(reference, "organization", options),
      publisher-location-date(reference, options),
    ),
    chapter-pages(reference, options),
    if options.print-isbn { printfield(reference, "isbn", options) } else { none },
    doi-eprint-url(reference, options),
    addendum-pubstate(reference, options)
    
    // TODO see [1] above
  )
})


#let driver-incollection = with-default("driver-incollection", (reference, options) => {
  require-fields(reference, options, "author", "title", "booktitle")

  (options.periods)(
    maybe-with-date(reference, options)(
      author-translator-others(reference, options)
    ),
    title-with-language(reference, options),
    byauthor(reference, options),
    spaces(options.bibstring.in, maintitle-booktitle(reference, options)),
    byeditor-others(reference, options),
    (options.commas)(
      printfield(reference, "edition", options),
      volume-part-if-maintitle-undef(reference, options),
      printfield(reference, "volumes", options),
    ),
    series-number(reference, options),
    printfield(reference, "note", options),
    publisher-location-date(reference, options),
    chapter-pages(reference, options),
    if options.print-isbn { printfield(reference, "isbn", options) } else { none },
    doi-eprint-url(reference, options),
    addendum-pubstate(reference, options)
    
    // TODO see [1] above
  )
})


#let driver-book = with-default("driver-book", (reference, options) => {
  require-fields(reference, options, ("author", "editor", "translator"), "title")

  (options.periods)(
    maybe-with-date(reference, options)(
      author-editor-others-translator-others(reference, options)
    ),
    title-with-language(reference, options),
    byauthor(reference, options),
    byeditor-others(reference, options),
    (options.commas)(
      printfield(reference, "edition", options),
      volume-part-if-maintitle-undef(reference, options),
      printfield(reference, "volumes", options),
    ),
    series-number(reference, options),
    printfield(reference, "note", options),
    publisher-location-date(reference, options),
    (options.commas)(
      chapter-pages(reference, options),
      printfield(reference, "pagetotal", options),
    ),
    if options.print-isbn { printfield(reference, "isbn", options) } else { none },
    doi-eprint-url(reference, options),
    addendum-pubstate(reference, options)
    
    // TODO see [1] above
  )
})

#let driver-misc = with-default("driver-misc", (reference, options) => {
  require-fields(reference, options, ("author", "editor", "translator"), "title")

  (options.periods)(
    maybe-with-date(reference, options)(
      author-editor-others-translator-others(reference, options)
    ),
    title-with-language(reference, options),
    byauthor(reference, options),
    byeditor-others(reference, options),
    printfield(reference, "howpublished", options),
    (options.commas)(
      printfield(reference, "type", options),
      printfield(reference, "version", options),
      printfield(reference, "note", options),
    ),
    organization-location-date(reference, options),
    doi-eprint-url(reference, options),
    addendum-pubstate(reference, options)
    
    // TODO see [1] above
  )
})


#let driver-thesis = with-default("driver-thesis", (reference, options) => {
  require-fields(reference, options, "author", "title", "type", "institution")

  (options.periods)(
    maybe-with-date(reference, options)(
      author(reference, options)
    ),
    title-with-language(reference, options),
    byauthor(reference, options),
    printfield(reference, "note", options),
    (options.commas)(
      printfield(reference, "type", options),
      institution-location-date(reference, options),
    ),
    (options.commas)(
      chapter-pages(reference, options),
      printfield(reference, "pagetotal", options),
    ),
    if options.print-isbn { printfield(reference, "isbn", options) } else { none },
    doi-eprint-url(reference, options),
    addendum-pubstate(reference, options)
    
    // TODO see [1] above
  )
})



// @booklet - A work that is printed and bound, but without a named publisher or sponsoring institution
#let driver-booklet = with-default("driver-booklet", (reference, options) => {
    require-fields(reference, options, ("author", "editor"), "title")
    
    (options.periods)(
      maybe-with-date(reference, options)(
        author-editor-others-translator-others(reference, options),
      ),
      title-with-language(reference, options),
      byauthor(reference, options),
      byeditor-others(reference, options),
      printfield(reference, "howpublished", options),
      printfield(reference, "type", options),
      printfield(reference, "note", options),
      publisher-location-date(reference, options),
      chapter-pages(reference, options),
      printfield(reference, "pagetotal", options),
      doi-eprint-url(reference, options),
      addendum-pubstate(reference, options)
    )
})


#let driver-collection = with-default("driver-collection", (reference, options) => {
  require-fields(reference, options, ("author", "editor", "translator"), "title")

  (options.periods)(
    maybe-with-date(reference, options)(
      editor-others(reference, options)
    ),
    title-with-language(reference, options),
    byeditor-others(reference, options),
    (options.commas)(
      printfield(reference, "edition", options),
      volume-part-if-maintitle-undef(reference, options),
      printfield(reference, "volumes", options),
    ),
    series-number(reference, options),
    printfield(reference, "note", options),
    publisher-location-date(reference, options),
    (options.commas)(
      chapter-pages(reference, options),
      printfield(reference, "pagetotal", options),
    ),
    if options.print-isbn { printfield(reference, "isbn", options) } else { none },
    doi-eprint-url(reference, options),
    addendum-pubstate(reference, options)
  )
})

// @inbook - A part of a book which forms a self-contained unit with its own title
#let driver-inbook = with-default("driver-inbook", (reference, options) => {
    require-fields(reference, options, "author", "title", "booktitle")
    
    (options.periods)(
      maybe-with-date(reference, options)(
        author-translator-others(reference, options)
      ),
      title-with-language(reference, options),
      byauthor(reference, options),
      (options.periods)( // TODO periods makes no sense here
        spaces(options.bibstring.in, bybookauthor(reference, options)),
        maintitle-booktitle(reference, options),
        byeditor-others(reference, options),
      ),
      (options.commas)(
        printfield(reference, "edition", options),
        volume-part-if-maintitle-undef(reference, options),
        printfield(reference, "volumes", options),
      ),
      series-number(reference, options),
      note-pages(reference, options),
      publisher-location-date(reference, options),
      chapter-pages(reference, options),
      if options.print-isbn { printfield(reference, "isbn", options) } else { none },
      doi-eprint-url(reference, options),
      addendum-pubstate(reference, options)
    )
})

// @manual - Technical documentation
#let driver-manual = with-default("driver-manual", (reference, options) => {
    require-fields(reference, options, ("author", "editor"), "title")
    
    (options.periods)(
      maybe-with-date(reference, options)(
        author-editor(reference, options)
      ),
      title-with-language(reference, options),
      byauthor(reference, options),
      byeditor(reference, options),
      printfield(reference, "edition", options),
      series-number(reference, options),
      (options.commas)(
        printfield(reference, "type", options),
        printfield(reference, "version", options),
        printfield(reference, "note", options),
      ),
      printfield(reference, "organization", options),
      publisher-location-date(reference, options),
      (options.commas)(
        chapter-pages(reference, options),
        printfield(reference, "pagetotal", options),
      ),
      if options.print-isbn { printfield(reference, "isbn", options) } else { none },
      doi-eprint-url(reference, options),
      addendum-pubstate(reference, options)
    )
})

// @online - An online resource
#let driver-online = with-default("driver-online", (reference, options) => {
    require-fields(reference, options, ("author", "editor", "translator"), "title", ("url", "doi", "eprint"))
    
    (options.periods)(
      maybe-with-date(reference, options)(
        author-editor-others-translator-others(reference, options)
      ),
      title-with-language(reference, options),
      byauthor(reference, options),
      byeditor-others(reference, options),
      (options.commas)(
        printfield(reference, "version", options),
        printfield(reference, "note", options),
      ),
      printfield(reference, "organization", options),
      printfield(reference, "date", options),
      doi-eprint-url(reference, options),
      addendum-pubstate(reference, options)
    )
})

// @patent - A patent or patent request
#let driver-patent = with-default("driver-patent", (reference, options) => {
    require-fields(reference, options, "author", "title", "number")
    
    (options.periods)(
      maybe-with-date(reference, options)(
        author(reference, options)
      ),
      title-with-language(reference, options),
      byauthor(reference, options),
      type-number-location(reference, options),
      byholder(reference, options),
      printfield(reference, "note", options),
      printfield(reference, "date", options),
      doi-eprint-url(reference, options),
      addendum-pubstate(reference, options)
    )
})

// @periodical - A complete issue of a periodical
#let driver-periodical = with-default("driver-periodical", (reference, options) => {
    require-fields(reference, options, "editor")
    
    (options.periods)(
      maybe-with-date(reference, options)(
        editor(reference, options)
      ),
      (options.periods)(
        title-issuetitle(reference, options),
        language(reference, options),
      ),
      byeditor(reference, options),
      printfield(reference, "note", options),
      if options.print-isbn { printfield(reference, "issn", options) } else { none },
      doi-eprint-url(reference, options),
      addendum-pubstate(reference, options)
    )
})


#let driver-proceedings = with-default("driver-proceedings", (reference, options) => {
    require-fields(reference, options, "title")
    // editor can be optional - proceedings without editors exist
    
    (options.periods)(
      maybe-with-date(reference, options)(
        editor-others(reference, options)
      ),
      title-with-language(reference, options),
      event-venue-date(reference, options),
      byeditor-others(reference, options),
      (options.commas)(
        volume-part-if-maintitle-undef(reference, options),
        printfield(reference, "volumes", options),
      ),
      series-number(reference, options),
      printfield(reference, "note", options),
      (options.commas)(
        printlist(reference, "organization", options),
        publisher-location-date(reference, options)
      ),
      (options.commas)(
        chapter-pages(reference, options),
        printfield(reference, "pagetotal", options),
      ),
      if options.print-isbn { printfield(reference, "isbn", options) } else { none },
      doi-eprint-url(reference, options),
      addendum-pubstate(reference, options)
    )
})

#let driver-report = with-default("driver-report", (reference, options) => {
    require-fields(reference, options, "author", "title", "type", "institution")
    
    (options.periods)(
      maybe-with-date(reference, options)(
        author(reference, options)
      ),
      title-with-language(reference, options),
      byauthor(reference, options),
      spaces(
        printfield(reference, "type", options),
        printfield(reference, "number", options)
      ),
      (options.commas)(
        printfield(reference, "version", options),
        printfield(reference, "note", options),
      ),
      institution-location-date(reference, options),
      (options.commas)(
        chapter-pages(reference, options),
        printfield(reference, "pagetotal", options),
      ),
      if options.print-isbn { printfield(reference, "isrn", options) } else { none },
      doi-eprint-url(reference, options),
      addendum-pubstate(reference, options)
    )
})

#let driver-unpublished = with-default("driver-unpublished", (reference, options) => {
    require-fields(reference, options, "author", "title")
    
    (options.periods)(
      maybe-with-date(reference, options)(
        author(reference, options)
      ),
      title-with-language(reference, options),
      byauthor(reference, options),
      printfield(reference, "howpublished", options),
      printfield(reference, "type", options),
      event-venue-date(reference, options),
      printfield(reference, "note", options),
      location-date(reference, options),
      doi-eprint-url(reference, options),
      addendum-pubstate(reference, options)
    )
})

#let driver-dataset = with-default("driver-dataset", (reference, options) => {
    require-fields(reference, options, ("author", "editor", "translator"), "title")
    
    (options.periods)(
      maybe-with-date(reference, options)(
        author-editor-others-translator-others(reference, options)
      ),
      title-with-language(reference, options),
      byauthor(reference, options),
      byeditor-others(reference, options),
      // type/edition/version are separated by \newunit in the Biblatex source,
      // but they are separated by periods in the actual Biblatex output - not sure why
      printfield(reference, "type", options),
      printfield(reference, "edition", options),
      printfield(reference, "version", options),
      series-number(reference, options),
      printfield(reference, "note", options),
      (options.commas)(
        printfield(reference, "organization", options),
        publisher-location-date(reference, options)
      ),
      doi-eprint-url(reference, options),
      addendum-pubstate(reference, options)
    )
})

#let driver-dummy = with-default("driver-dummy", (reference, options) => {
  // "misc" defined as catch-all driver in standard.bbx, line 752
  driver-misc(reference, options)
})

// We only need to declare drivers for the basic Biblatex entry types;
// the others are mapped down using the `type-aliases` mechanism in
// format-reference (e.g. www -> online, phdthesis -> thesis(type: phd).
#let bibliography-drivers = (
  "article": driver-article,
  "book": driver-book,
  "booklet": driver-booklet,
  "collection": driver-collection,
  "inbook": driver-inbook,
  "incollection": driver-incollection,
  "inproceedings": driver-inproceedings,
  "dataset": driver-dataset,
  "manual": driver-manual,
  "misc": driver-misc,
  "online": driver-online,
  "patent": driver-patent,
  "periodical": driver-periodical,
  "proceedings": driver-proceedings,
  "report": driver-report,
  "thesis": driver-thesis,
  "unpublished": driver-unpublished,

  // bibliography aliases, standard.bbx lines 740 ff.
  "mvbook": driver-book,
  "bookinbook": driver-inbook,
  "suppbook": driver-inbook,
  "mvcollection": driver-collection,
  "suppcollection": driver-incollection,
  "mvproceedings": driver-proceedings,
  "reference": driver-collection,
  "mvreference": driver-collection,
  "inreference": driver-incollection,
  "suppperiodical": driver-article,
  "review": driver-article,
  "software": driver-misc
)


/// The standard reference style. It is modeled after the standard
/// bibliography style of #biblatex.
///
/// A call to `format-reference` takes a number of options as argument
/// and returns a function that will take
/// arguments `index` and `reference` and return a rendered reference.
/// This function is suitable as an argument to the `format-reference` parameter
/// of `print-bibliography`, and will control how the references in this
/// bibliography are rendered. See the documentation of `print-bibliography`
/// for a more detailed specification of the `format-reference` function in general.
/// 
/// Most of the options of `format-reference` have sensible default values.
/// The one exception is the mandatory named argument `reference-label`,
/// which you obtain from your citation style.
#let format-reference(
    /// The reference labeler that should be used for this bibliography;
    /// see @sec:custom-styles for a detailed explanation.
    /// 
    /// The reference labeler typically comes from a citation style (e.g.
    /// _authoryear_, _numeric_, _alphabetic_).
    /// 
    /// Unlike the other parameters of `format-reference`, you _must_ pass
    /// a meaningful argument for this parameter. If you leave it at the default
    /// value of `none`, Typst will not even show you a proper error message;
    /// it will just say "warning: layout did not converge within 5 attempts".
    /// 
    /// -> function
    reference-label: none,

    /// Selectively highlights certain bibliography entries. The parameter
    /// is a function that is applied at the final stage of the rendering process,
    /// where the whole rest of the entry has already been rendered. This is
    /// an opportunity to e.g. mark certain entries in the bibliography by
    /// boldfacing them or prepending them with a marker symbol. See
    /// @sec:highlighting for an example.
    /// 
    /// The highlighting function accepts arguments `rendered-reference`
    /// (`str` or `content` representing the reference as it is printed),
    /// `index` (position of the reference in the bibliography), and
    /// `reference` (the reference dictionary). It returns `content`.
    /// The default implementation simply returns the `rendered-reference`
    /// unmodified.
    /// 
    /// -> function
    highlight: (rendered-reference, index, reference) => rendered-reference,

    /// If `true`, titles are rendered as hyperlinks pointing to the reference's
    /// DOI or URL. When both are defined, the DOI takes precedence.
    /// -> bool
    link-titles: true,

    /// Array of reference identifiers that should be printed at the end of 
    /// the bibliography entry. The array contains a list of strings; possible
    /// values are `"doi"`, `"url"`, and `"eprint"`. For each bib entry, these
    /// values are considered in the order in which they appear in the array,
    /// and the first value that is defined as a key in the bib entry is printed.
    /// 
    /// `print-identifiers` acts as a flexible version of the `print-url`,
    /// `print-doi`, and `print-eprint` parameters. For the first `X` in the array
    /// that is defined in the bib entry, it effectively sets `print-X` to `true`.
    /// The values of the other `print-X` parameters are left unchanged;
    /// thus, you could e.g. still force the rendering of `eprint` by
    /// setting `print-eprint` to `true`, even if `print-identifiers`
    /// matches on the DOI instead.
    /// 
    /// -> array
    print-identifiers: (),

    /// If `true`, prints the reference's URL at the end of the bibliography entry.
    /// -> bool
    print-url: false,

    /// If `true`, prints the reference's DOI at the end of the bibliograph entry.
    /// -> bool
    print-doi: false,

    /// If `true`, prints the reference's eprint information at the end of the
    /// bibliography entry. This could be a reference to arXiv or JSTOR.
    /// -> bool
    print-eprint: true,

    /// If `true`, prints the reference's author if it is defined.
    /// -> bool
    use-author: true,

    /// If `true`, prints the reference's translator if it is defined.
    /// See also `name-fields` in @print-bibliography.
    /// 
    /// -> bool
    use-translator: true,

    /// If `true`, prints the reference's editor if it is defined.
    /// See also `name-fields` in @print-bibliography.
    /// 
    /// -> bool
    use-editor: true,

    /// If `true`, #bibtypst will print the date right after the authors, e.g.
    /// 'Smith (2020). "A cool paper".' If `false`, #bibtypst will follow the
    /// normal behavior of #biblatex and place the date towards the end of the
    /// reference.
    /// -> bool
    print-date-after-authors: false,

    /// When #bibtypst renders a reference, the title is processed by Typst's
    /// #link("https://typst.app/docs/reference/foundations/eval/")[eval] function.
    /// The `eval-mode` argument you specify here is passed as the `mode` argument
    /// to `eval`. 
    /// 
    /// The default value of `"markup"` renders the title as if it were ordinary
    /// Typst content, typesetting e.g. mathematical expressions correctly.
    /// 
    /// -> str
    eval-mode: "markup",

    /// The `scope` argument that is passed to the `eval` call (see `eval-mode`).
    /// This allows you to call Typst functions from within the #bibtex entries.
    /// 
    /// -> dictionary
    eval-scope: (:),

    /// When typesetting lists (e.g. author names), #bibtypst will use this
    /// delimiter to combine list items before the last one.
    /// -> str
    list-middle-delim: ", ",

    /// When typesetting lists (e.g. author names), #bibtypst will use this
    /// delimiter to combine the items of lists of length two.
    /// -> str
    list-end-delim-two: " and ",

    /// When typesetting lists (e.g. author names), #bibtypst will use this
    /// delimiter in lists of length three of more to combine the final
    /// item in the list with the rest.
    /// -> str
    list-end-delim-many: ", and ",

    /// String that is used to combine the name of an author with the author
    /// type, e.g. "Smith, editor".
    /// -> str
    author-type-delim: ",",

    /// String that is used to combine a title with a subtitle.
    /// -> str
    subtitlepunct: ".",

    /// Renders the title and subtitle of a journal as content.
    /// The default argument typesets it in italics.
    /// 
    /// Certain titles (journaltitle, issuetitle, maintitle, booktitle)
    /// can be combined with subtitles (e.g. journalsubtitle). The title and
    /// subtitle are joined by `subtitlepunct` to obtain e.g. "Journal title: subtitle".
    /// The subtitlepunct needs to be formatted the same as the title and
    /// subtitle, but its formatting cannot be controlled by `format-fields`. This is
    /// why #pergamon offers parameters such as `format-journaltitle` to format
    /// the entire concatenated title and subtitle.
    ///     
    /// -> function
    format-journaltitle: it => emph(it),

    /// Renders the title of a special issue as content. The default argument
    /// typesets it in italics.
    /// 
    /// See `format-journaltitle` for further explanation.
    /// 
    /// -> function
    format-issuetitle: it => emph(it),

    /// Renders the main title of a multi-volume work as content. The default argument
    /// typesets it in italics.
    /// 
    /// See `format-journaltitle` for further explanation.
    /// 
    /// -> function
    format-maintitle: it => emph(it),

    /// Renders the title of a book as content. The default argument
    /// typesets it in italics.
    /// 
    /// See `format-journaltitle` for further explanation.
    /// 
    /// -> function
    format-booktitle: it => emph(it),

    /// Overrides the way individual fields in the reference are rendered.
    /// The argument is a dictionary that maps the names of fields in a #bibtex
    /// entry to _extended field formatters_, i.e. functions that compute
    /// Typst content and take the following positional parameters:
    /// - `dffmt`: the _default_ field formatter, which is applied if no 
    ///   more specific field formatter is specified through `format-fields`.
    /// - `value`: the value of the field in the #bibtex entry.
    /// - `reference`: the reference dictionary, cf. @sec:reference.
    /// - `field`: the name of the field.
    /// - `options`: a dictionary containing all the options that were passed
    ///   to `format-reference` as arguments.
    /// - `style`: an optional style specification for the field.
    /// 
    /// If you do not override the rendering of a field, #pergamon
    /// uses a default field formatter, i.e. a function that computes content
    /// from the `value`, `reference`, `field`, `options`, and `style`
    /// parameters explained above. This default field formatter is passed
    /// as the first argument (`dffmt`) to the extended field formatter
    /// explained above.
    /// 
    /// Some examples of how `format-fields` can be used are shown in 
    /// @sec:styling-individual-references.
    /// 
    /// -> dictionary
    format-fields: (:),

    /// Overrides the way that the complex formatting in the reference style
    /// is handled. 
    /// 
    /// The default #pergamon reference style relies on a variety
    /// of functions with signature `(reference, options) → content` to render
    /// pieces of the reference in the bibliography. For instance, the function
    /// `driver-article` typesets a #bibtex entry of type `article`.
    /// 
    /// By passing a dictionary
    /// with an entry `function-name: function` in this parameter, you can
    /// override the default implementations of these formatting functions.
    /// To find the function names that can be overriden, look for functions
    /// that start with `with-default` in #link("https://github.com/alexanderkoller/pergamon/blob/main/src/reference-styles.typ")[reference-styles.typ].
    /// 
    /// The `format-functions` parameter allows you to deeply customize the
    /// way #pergamon displays references, without having to implement your
    /// own reference style from scratch. It applies to larger spans of
    /// content in the references -- in contrast to `format-fields`, which
    /// affects the formatting of individual #bibtex fields. 
    /// See @sec:customizing-style for examples.
    /// 
    /// -> dictionary
    /// 
    format-functions: (:),
  
    /// Wraps text in round brackets. The argument needs to be a function
    /// that takes one argument (`str` or `content`) and returns `content`.
    /// 
    /// It is essential that if the argument is `none`, the function must
    /// also return `none`. This can be achieved conveniently with the `nn`
    /// function wrapper, see @sec:package:utility.
    /// 
    /// -> function
    format-parens: nn(it => [(#it)]),

    /// Wraps text in square brackets. The argument needs to be a function
    /// that takes one argument (`str` or `content`) and returns `content`.
    /// 
    /// It is essential that if the argument is `none`, the function must
    /// also return `none`. This can be achieved conveniently with the `nn`
    /// function wrapper, see @sec:package:utility.
    /// 
    /// -> function
    format-brackets: nn(it => [[#it]]),

    /// Wraps text in double quotes. The argument needs to be a function
    /// that takes one argument (`str` or `content`) and returns `content`.
    /// 
    /// It is essential that if the argument is `none`, the function must
    /// also return `none`. This can be achieved conveniently with the `nn`
    /// function wrapper, see @sec:package:utility.
    /// 
    /// -> function    
    format-quotes: nn(it => ["#it"]),

    /// The format in which names (of authors, editors, etc.) are printed.
    /// This is an arbitrary string which may contain the placeholders `{given}`
    /// and `{family}`; these will be replaced by the person's actual name parts.
    /// You can use `{g}` and `{f}` for the first letters of the given and family
    /// name, respectively.
    /// 
    /// Instead of a string, you can also pass a dictionary in this argument.
    /// The keys are name types ("author", "editor", etc.), and the values are
    /// name format strings as explained above. The style will use a default
    /// format of `"{given} {family}"` for name types that you did not specify.
    /// 
    /// -> str | dictionary
    name-format: "{given} {family}",

    /// Separator symbol for "volume" and "number" fields, e.g. in `@article`s.
    /// -> str
    volume-number-separator: ".",

    /// Separator symbol that connects the EID (Scopus Electronic Identifier)
    /// from other journal information.
    /// -> str
    bibeidpunct: ",",

    /// Separator symbol that connects the "pages" field with related information.
    /// -> str
    bibpagespunct: ",",

    /// If `true`, prints the ISBN or ISSN of the reference if it is defined.
    /// -> bool
    print-isbn: false,

    /// Selects whether the long or short versions of the bibstrings should be used
    /// by default. Acceptable values are "long" and "short". See the documentation
    /// of @default-long-bibstring for details.
    /// 
    /// -> str
    bibstring-style: "long",

    /// Overrides entries in the bibstring table. The bibstring table is a dictionary
    /// that maps language-independent
    /// IDs of bibliographic constants (e.g. "in") to  
    /// their language-dependent surface forms (such as "In: " or "edited by").
    /// The ID-form pairs you specify in the `bibstring` argument will overwrite
    /// the default entries.
    /// 
    /// See the documentation for @default-long-bibstring in @sec:package:utility for
    /// more information on the bibstring table.
    /// -> dictionary
    bibstring: (:),

    /// An array of additional fields which will be printed at the end of each
    /// bibliography entry. Fields can be specified either as a string, in which case
    /// the field with that name is printed using the reference style's normal rules.
    /// Alternatively, they can be
    /// specified as a function `(reference, options) -> content`, in which case the
    /// returned content will be printed directly. Instead of an array, you can also
    /// pass `none` to indicate that no additional fields need to be printed.
    /// 
    /// For example, both of these will work:
    /// ```
    /// additional-fields: ("award",)
    /// 
    /// additional-fields: ((reference, options) => 
    ///    ifdef(reference, "award", (:), award => [*#award*]),)
    /// ```
    /// 
    /// -> array | none
    additional-fields: none,

    /// A specification of field names that should not be printed. References are treated
    /// as if they do not contain values for these fields, even if the #bibtex file
    /// defines them. 
    /// 
    /// You can pass an array of strings here. These field names will be suppressed in
    /// all references.
    /// 
    /// Alternatively, you can pass a dictionary that maps entry types to arrays of strings.
    /// `("inproceedings": ("editor", "location"))` means that the editor and location fields
    /// will not be printed in `inproceedings` references, but may be printed in other
    /// entry types. You can use the special key `"*"` to suppress fields in _all_ entry types.
    /// 
    /// Finally, you can also pass  `none` to indicate that
    /// no fields should be suppressed.
    /// 
    /// -> array | dictionary | none
    suppress-fields: none,

    /// Specifies how string or content elements are joined using period symbols.
    /// This corresponds roughly (but not precisely) to blocks in #biblatex.
    /// 
    /// If you specify a string here, this string will be used to join
    /// the elements. #bibtypst will avoid duplicating connector symbols, i.e.
    /// it will not print a period if the preceding symbol was already a period.
    /// 
    /// Alternatively, you can specify an array `(connector, skip-chars)`, where
    /// `connector` is the period symbol. The connector is skipped if the
    /// preceding character occurs in the string `skip-chars`.
    /// 
    /// -> str | array
    period: (".", ".,?!;:"),

    /// Function that joins an arbitrary number of strings or contents with a 
    /// comma symbol. 
    /// This corresponds roughly (but not precisely) to units in #biblatex.
    /// 
    /// See the documentation for `period` for details.
    /// 
    /// -> str | array
    comma: ",",

    /// Maximum number of names that are displayed in name lists (author, editor, etc.).
    /// If the actual number of names exceeds `maxnames`, only the first `maxnames`
    /// names are shown and `bibstring.andothers` ("et al.") is appended.
    /// 
    /// This parameter is modeled after the `maxnames`/`maxbibnames` option
    /// in #biblatex.
    /// 
    /// -> int
    maxnames: 9999,

    /// Minimum number of names that are displayed in name lists (author, editor, etc.).
    /// This can be used in conjunction with `maxnames` to create name lists like
    /// "Jones, Smith et al." (minnames = 2, maxnames = 2). 
    /// 
    /// `minnames` trumps `maxnames`: That is, if the name list is at least as long
    /// as `minnames`, the reference will show `minnames` names, even if this exceeds
    /// `maxnames`. In typical use cases, `minnames` will be less or equal than `maxnames`,
    /// so this situation will usually not occur.
    /// 
    /// This parameter is modeled after the `minnames`/`minbibnames` option
    /// in #biblatex.
    /// 
    /// -> int
    minnames: 9999,

  ) = {
    // construct fjoin functions for periods and commas
    let sentence-final-punctuation = ".!?"
    let make-fjoin-function(separator) = {
      if type(separator) == function {
        // In contrast to the official documentation, you can also pass the
        // fjoin function directly as an argument. But this is complicated,
        // so let's keep it a secret.
        separator
      } else if type(separator) == str {
        (..x) => fjoin(separator, ..x, skip-if: separator, capitalize-after: sentence-final-punctuation)
      } else if type(separator) == array {
        (..x) => fjoin(separator.at(0), ..x, skip-if: separator.at(1), capitalize-after: sentence-final-punctuation)
      } else {
        (..x) => fjoin(".", ..x, skip-if: ".", capitalize-after: sentence-final-punctuation)
      }
    }

    let commas = make-fjoin-function(comma)
    let periods = make-fjoin-function(period)
    
    let formatter(index, reference) = {
      // Unfortunately, this still causes "layout did not converge" errors, rather
      // than just printing the error message.
      if reference-label == none {
        panic("Please specify a reference-label argument for format-reference.")
      }

      let suppressed-fields = (:)
      if type(suppress-fields) == array {
        for field in suppress-fields {
          suppressed-fields.insert(field, 1)
        }
      } else if type(suppress-fields) == dictionary {
        let general-suppress-fields = suppress-fields.at("*", default: ())
        for field in general-suppress-fields {
          suppressed-fields.insert(field, 1)
        }

        let type-suppress-fields = suppress-fields.at(reference.entry_type, default: ())
        for field in type-suppress-fields {
          suppressed-fields.insert(field, 1)
        }
      }

      // determine field selected by print-identifiers
      let print-identifiers-field = none
      for fieldname in print-identifiers {
        if lower(fieldname) in reference.fields {
          print-identifiers-field = lower(fieldname)
          break
        }
      }

      // construct field-formats
      let field-formatters = default-field-formats
      for (field, formatter) in format-fields {
        // resolve field name aliases to their basic form, e.g. "autor" to "parsed-author"
        while type(field-formatters.at(field, default: none)) == str {
          field = field-formatters.at(field)
        }

        let default-formatter = field-formatters.at(field, default: (value, reference, field, options, style) => value)
        field-formatters.insert(field, formatter.with(default-formatter))
      }

      let default-bibstring = if lower(bibstring-style) == "short" { default-short-bibstring } else { default-long-bibstring }

      let options = (
        link-titles: link-titles,
        eval-mode: eval-mode,
        eval-scope: eval-scope,
        use-author: use-author,
        use-translator: use-translator,
        use-editor: use-editor,
        author-type-delim: author-type-delim,
        list-middle-delim: list-middle-delim,
        list-end-delim-two: list-end-delim-two,
        list-end-delim-many: list-end-delim-many,
        subtitlepunct: subtitlepunct,
        format-journaltitle: format-journaltitle,
        format-issuetitle: format-issuetitle,
        format-booktitle: format-booktitle,
        format-maintitle: format-maintitle,
        format-parens: format-parens,
        format-brackets: format-brackets,
        format-quotes: format-quotes,
        field-formatters: field-formatters,
        format-functions: format-functions,
        name-format: name-format,
        bibeidpunct: bibeidpunct,
        bibpagespunct: bibpagespunct,
        print-isbn: print-isbn,
        print-url: print-url or print-identifiers-field == "url",
        print-doi: print-doi or print-identifiers-field == "doi",
        print-eprint: print-eprint or print-identifiers-field == "eprint",
        print-date-after-authors: print-date-after-authors,
        volume-number-separator: volume-number-separator,
        bibstring: default-bibstring + bibstring,
        suppressed-fields: suppressed-fields,
        periods: periods,
        commas: commas,
        minnames: minnames,
        maxnames: maxnames
      )

      // process type aliases
      if reference.entry_type in type-aliases {
        reference = type-aliases.at(reference.entry_type)(reference)
      }

      // typeset reference
      let driver = bibliography-drivers.at(lower(reference.entry_type), default: driver-dummy)
      let ret = driver(reference, options)

      // add additional fields, if specified
      if additional-fields != none {
        for field in additional-fields {
          if type(field) == str {
            let value = printfield(reference, field, options)
            ret = periods(ret, value)
          } else if type(field) == function {
            let value = field(reference, options)
            ret = periods(ret, value)
          }
        }
      }

      // add label if requested
      let lbl = reference-label(index, reference)
      let finished = fjoin(".", ret, finish-with-connector: true, skip-if: ".,?!;:")
      let highlighted = [#parbreak()#highlight(finished, reference, index)]

      if lbl == none {
        ([#highlighted],)
      } else {
        (lbl, highlighted)
      }
  }

  formatter
}

