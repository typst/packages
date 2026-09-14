#import "bibtypst.typ": *
#import "templating.typ": *
#import "bibstrings.typ": default-bibstring
#import "printfield.typ": printfield
#import "bib-util.typ": fd, ifdef, type-aliases, nn, concatenate-list
#import "names.typ": family-names
#import "dates.typ": is-year-defined



// If, else none. If the `guard` evaluates to `true`,
// evaluate `value-func` and return the result. Otherwise return `none`.
#let ifen(guard, value-func) = {
  if guard {
    value-func()
  } else {
    none
  }
}

// biblatex.def authorstrg
#let authorstrg(reference, options) = {
  printfield(reference, "authortype", options)
  // TODO - implement all the "strg" stuff correctly
}

#let language(reference, options) = {
  printfield(reference, "language", options)
}


#let date(reference, options) = {
  epsilons(
    printfield(reference, "parsed-date", options),
    printfield(reference, "extradate", options)
  )
}

#let authors-with-year(reference, options) = {
  spaces(
    printfield(reference, "parsed-author", options),
    // reference.authors, // TODO - was \printnames{author}
    ifen(options.print-date-after-authors, () => (options.format-parens)(date(reference, options)))
  )
}

// biblatex.def author
#let author(reference, options) = {
  fjoin(options.author-type-delim,
    authors-with-year(reference, options),
    authorstrg(reference, options)
  )
}

// biblatex.def editor+others
#let editor-others(reference, options) = {
  if options.use-editor and fd(reference, "editor", options) != none {
    // TODO - choose between bibstring.editor and bibstring.editors depending on length of editor list
    [#printfield(reference, "parsed-editor", options), #options.bibstring.editor]
  } else {
    none
  }
}

// biblatex.def translator+others
#let translator-others(reference, options) = {
  if options.use-translator and fd(reference, "translator", options) != none {
    // TODO - choose between bibstring.editor and bibstring.editors depending on length of editor list
    [#printfield(reference, "parsed-translator", options), #options.bibstring.translator]
  } else {
    none
  }
}

// biblatex.def author/translator+others
#let author-translator-others(reference, options) = {
  if options.use-author and fd(reference, "author", options) != none {
    authors-with-year(reference, options)
  } else {
    translator-others(reference, options)
  }
}


// standard.bbx volume+number+eid
#let volume-number-eid(reference, options) = {
  let volume = printfield(reference, "volume", options)
  let number = printfield(reference, "number", options)

  let a = if volume == none and number == none {
    none
  } else if number == none {
    volume
  } else if volume == none {
    panic("Can't use 'number' without 'volume' (in " + reference.entry_key + "!")
  } else {
    volume + options.volume-number-separator + number
  }

  fjoin(options.bibeidpunct, a, fd(reference, "eid", options))
}





// standard.bbx issue+date
#let issue-date(reference, options) = {
  spaces(
    printfield(reference, "issue", options),
    ifen(not options.print-date-after-authors, () => date(reference, options)),
    format: options.format-parens
  )
}

// biblatex.def issue
// -- in contrast to the original, we include the preceding colon here
#let issue(reference, options) = {
  let issuetitle = fd(reference, "issuetitle", options)
  let issuesubtitle = fd(reference, "issuesubtitle", options)

  if issuetitle == none and issuesubtitle == none {
    none
  } else {
    [: ]
    (options.periods)(
      fjoin(options.subtitlepunct, format: options.format-issuetitle, issuetitle, issuesubtitle),
      printfield(reference, "issuetitleaddon", options)
    )
  }
}

// standard.bbx journal+issuetitle
#let journal-issue-title(reference, options) = {
  let jt = fd(reference, "journaltitle", options)
  let jst = fd(reference, "journalsubtitle", options)

  if jt == none and jst == none {
    none
  } else {
    let journaltitle = (options.periods)(
      fjoin(options.subtitlepunct, jt, none, format: options.format-journaltitle),
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
}

// biblatex.def withothers
#let withothers(reference, options) = {
  (options.periods)(
    ifdef(reference, "commentator", options, commentator => spaces(options.bibstring.withcommentator, commentator)),
    ifdef(reference, "annotator", options, annotator => spaces(options.bibstring.withannotator, annotator)),
    ifdef(reference, "introduction", options, introduction => spaces(options.bibstring.withintroduction, introduction)),
    ifdef(reference, "foreword", options, foreword => spaces(options.bibstring.withforeword, foreword)),
    ifdef(reference, "afterword", options, afterword => spaces(options.bibstring.withafterword, afterword))
  )
}

// biblatex.def bytranslator+others
#let bytranslator-others(reference, options) = {
  let translator = printfield(reference, "parsed-translator", options)

  (options.periods)(
    // TODO bibstring.bytranslator should be expanded as in bytranslator+othersstrg
    ifdef(reference, "translator", options, translator => spaces(options.bibstring.bytranslator, translator)),
    withothers(reference, options)
  )
}

// biblatex.def byeditor+others
#let byeditor-others(reference, options) = {
  let editor = printfield(reference, "editor", options)

  (options.periods)(
    // TODO bibstring.byeditor should be expanded as in byeditor+othersstrg
    ifdef(reference, "editor", options, reference => spaces(options.bibstring.byeditor, editor)),

    // TODO: support editora etc.,  \usebibmacro{byeditorx}%

    bytranslator-others(reference, options)
  )
}

// standard.bbx note+pages
#let note-pages(reference, options) = {
  fjoin(options.bibpagespunct, printfield(reference, "note", options), printfield(reference, "pages", options))
}

// standard.bbx doi+eprint+url
#let doi-eprint-url(reference, options) = {
  (options.periods)(
    if options.print-doi { printfield(reference, "doi", options) } else { none },
    if options.print-eprint { printfield(reference, "eprint", options) } else { none },
    if options.print-url { printfield(reference, "url", options) } else { none },
  )
}

// standard.bbx addendum+pubstate
#let addendum-pubstate(reference, options) = {
  (options.periods)(
    printfield(reference, "addendum", options),
    printfield(reference, "pubstate", options)
  )
}

#let maintitle(reference, options) = {
  (options.periods)(
    fjoin(options.subtitlepunct, 
      printfield(reference, "maintitle", options, style: "titlecase"), 
      printfield(reference, "mainsubtitle", options, style: "titlecase")),
    printfield(reference, "maintitleaddon", options)
  )

  // missing:  {\printtext[maintitle]{
}

#let booktitle(reference, options) = {
  (options.periods)(
    fjoin(options.subtitlepunct, 
      printfield(reference, "booktitle", options, style: "titlecase"), 
      printfield(reference, "booksubtitle", options, style: "titlecase")),
    printfield(reference, "booktitleaddon", options)
  )

  // missing:  {\printtext[booktitle]{
}


// standard.bbx maintitle+booktitle
#let maintitle-booktitle(reference, options) = {
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
}

// standard.bbx maintitle+title
#let maintitle-title(reference, options) = {
  let maintitle = fd(reference, "maintitle", options)
  let title = fd(reference, "title", options)
  let print-maintitle = (maintitle != none) and (maintitle != title)

  let volume-prefix = if print-maintitle { epsilons(printfield(reference, "volume", options), printfield(reference, "part", options)) } else { none }

  let maintitle-str = if print-maintitle {
    (options.periods)(
      (options.periods)(
        printfield(reference, "maintitle", options),
        printfield(reference, "mainsubtitle", options)
      ),
      epsilons(
        printfield(reference, "volume", options), 
        printfield(reference, "part", options),
      )
    )
  } else { none }

    fjoin(":", maintitle-str, printfield(reference, "title", options)
  )
}

// TODO: "printeventdate" is referenced from event+venue+date,
// but I can't figure out where it is defined or what it means.
// It is _not_ the year, that comes later.
#let print-event-date(reference, options) = {
  // printfield(reference, "year", options)
  none
}

// standard.bbx event+venue+date
#let event-venue-date(reference, options) = {
  let format-parens = options.at("format-parens")

  spaces(
    (options.periods)(
      printfield(reference, "eventtitle", options),
      printfield(reference, "eventtitleaddon", options),
    ),
    format-parens(
      (options.commas)(
        printfield(reference, "venue", options),
        print-event-date(reference, options)
      )
    )
  )
}

#let volume-part-if-maintitle-undef(reference, options) = {
  if fd(reference, "maintitle", options) == none {
    epsilons(printfield(reference, "volume", options), printfield(reference, "part", options))
  } else {
    none
  }
}

// standard.bbx series+number
#let series-number(reference, options) = {
  spaces(printfield(reference, "series", options), printfield(reference, "number", options))
}

#let xxx-location-date(reference, options, xxx) = {
  (options.commas)(
    fjoin(
      ":",
      printfield(reference, "location", options), // Biblatex: printlist{location}
      printfield(reference, xxx, options)
    ),
    ifen(not options.print-date-after-authors, () => date(reference, options))
  )
}

// standard.bbx publisher+location+date
#let publisher-location-date(reference, options) = xxx-location-date(reference, options, "publisher")

// standard.bbx organization+location+date
#let organization-location-date(reference, options) = xxx-location-date(reference, options, "organization")

// standard.bbx institution+location+date
#let institution-location-date(reference, options) = xxx-location-date(reference, options, "institution")


// chapter+pages
#let chapter-pages(reference, options) = {
  fjoin(options.bibpagespunct,
    printfield(reference, "chapter", options),
    printfield(reference, "eid", options),
    printfield(reference, "pages", options)
  )
}

// biblatex.def author/editor+others/translator+others
#let author-editor-others-translator-others(reference, options) = {
  // TODO: implement the "useauthor" option
  first-of(
    author(reference, options),
    editor-others(reference, options),
    translator-others(reference, options)
  )

// \newbibmacro*{author/editor+others/translator+others}{%
//   \ifboolexpr{
//     test \ifuseauthor
//     and
//     not test {\ifnameundef{author}}
//   }
//     {\usebibmacro{author}}
//     {\ifboolexpr{
//        test \ifuseeditor
//        and
//        not test {\ifnameundef{editor}}
//      }
//        {\usebibmacro{editor+others}}
//        {\usebibmacro{translator+others}}}}
}

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


#let driver-article(reference, options) = {
    require-fields(reference, options, "author", "title", "journaltitle")
    // ("date", "year") don't have to be required - we just print "n.d." in that case

    // For now, I am mapping both \newunit and \newblock to periods.
    (options.periods)(
      author-translator-others(reference, options),
      printfield(reference, "title", options),
      language(reference, options),
      // TODO: \usebibmacro{byauthor}
      // TODO: \usebibmacro{bytranslator+others}
      //   - the "others" macros construct bibstring keys like "editorstrfo" to
      //     cover multiple roles of the same person at once
      printfield(reference, "version", options),
      spaces(options.bibstring.in, journal-issue-title(reference, options)),
      byeditor-others(reference, options),
      note-pages(reference, options),
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
}



#let driver-inproceedings(reference, options) = {
  require-fields(reference, options, "author", "title", "booktitle")

  // LIMITATION: If the date (= year) is followed directly by the pages, Biblatex separates
  // them with a comma rather than a period. I think is works because the \setunit in chapter+pages
  // can retroactively modify the end-of-unit marker from publisher+location+date. Bibtypst
  // can't do this without major changes to the way we concatenate strings, so we have to live 
  // with periods for now. (Same for @articles.)

  (options.periods)(
    author-translator-others(reference, options),
    printfield(reference, "title", options),
    language(reference, options),
    // TODO:   \usebibmacro{byauthor}%
    spaces(options.bibstring.in, maintitle-booktitle(reference, options)),
    event-venue-date(reference, options),
    byeditor-others(reference, options),
    volume-part-if-maintitle-undef(reference, options),
    printfield(reference, "volumes", options),
    series-number(reference, options),
    printfield(reference, "note", options),
    printfield(reference, "organization", options),
    publisher-location-date(reference, options),
    chapter-pages(reference, options),
    if options.print-isbn { printfield(reference, "isbn", options) } else { none },
    doi-eprint-url(reference, options),
    addendum-pubstate(reference, options)
    
    // TODO see [1] above
  )
}


#let driver-incollection(reference, options) = {
  require-fields(reference, options, "author", "title", "editor", "booktitle")

  (options.periods)(
    author-translator-others(reference, options),
    printfield(reference, "title", options),
    language(reference, options),
    // TODO:   \usebibmacro{byauthor}%
    spaces(options.bibstring.in, maintitle-booktitle(reference, options)),
    byeditor-others(reference, options),
    printfield(reference, "edition", options),
    volume-part-if-maintitle-undef(reference, options),
    printfield(reference, "volumes", options),
    series-number(reference, options),
    printfield(reference, "note", options),
    publisher-location-date(reference, options),
    chapter-pages(reference, options),
    if options.print-isbn { printfield(reference, "isbn", options) } else { none },
    doi-eprint-url(reference, options),
    addendum-pubstate(reference, options)
    
    // TODO see [1] above
  )
}


#let driver-book(reference, options) = {
  // TODO - it's probably okay if there is an editor rather than an author
  require-fields(reference, options, "author", "title")

  (options.periods)(
    author-editor-others-translator-others(reference, options),
    maintitle-title(reference, options),
    language(reference, options),
    // TODO:  \usebibmacro{byauthor}%
    byeditor-others(reference, options),
    printfield(reference, "edition", options),
    volume-part-if-maintitle-undef(reference, options),
    printfield(reference, "volumes", options),
    series-number(reference, options),
    printfield(reference, "note", options),
    publisher-location-date(reference, options),
    chapter-pages(reference, options),
    printfield(reference, "pagetotal", options),
    if options.print-isbn { printfield(reference, "isbn", options) } else { none },
    doi-eprint-url(reference, options),
    addendum-pubstate(reference, options)
    
    // TODO see [1] above
  )
}

#let driver-misc(reference, options) = {
  require-fields(reference, options, "author", "title")

  (options.periods)(
    author-editor-others-translator-others(reference, options),
    printfield(reference, "title", options),
    language(reference, options),
    // TODO:  \usebibmacro{byauthor}%
    byeditor-others(reference, options),
    printfield(reference, "howpublished", options),
    printfield(reference, "type", options),
    printfield(reference, "version", options),
    printfield(reference, "note", options),
    organization-location-date(reference, options), // XX
    doi-eprint-url(reference, options),
    addendum-pubstate(reference, options)
    
    // TODO see [1] above
  )
}


#let driver-thesis(reference, options) = {
  require-fields(reference, options, "author", "title", "type", "institution")

  (options.periods)(
    author(reference, options),
    printfield(reference, "title", options),
    language(reference, options),
    // TODO:  \usebibmacro{byauthor}%
    printfield(reference, "note", options),
    printfield(reference, "type", options),
    institution-location-date(reference, options),
    chapter-pages(reference, options),
    printfield(reference, "pagetotal", options),
    if options.print-isbn { printfield(reference, "isbn", options) } else { none },
    doi-eprint-url(reference, options),
    addendum-pubstate(reference, options)
    
    // TODO see [1] above
  )

}

#let driver-dummy(reference, options) = {
  [UNSUPPORTED REFERENCE (key=#reference.entry_key, bibtype=#reference.entry_type)]
}

// TODO resolve type aliases (phdthesis -> thesis)

#let bibliography-drivers = (
  "article": driver-article,
  "inproceedings": driver-inproceedings,
  "incollection": driver-incollection,
  "book": driver-book,
  "misc": driver-misc,
  "thesis": driver-thesis
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
    /// Note that support for "authors" that are not the author is currently
    /// weak. See #link("https://github.com/alexanderkoller/bibtypst/issues/28")[issue 28]
    /// to track progress on this.
    /// -> bool
    use-translator: true,

    /// If `true`, prints the reference's editor if it is defined.
    /// Note that support for "authors" that are not the author is currently
    /// weak. See #link("https://github.com/alexanderkoller/bibtypst/issues/28")[issue 28]
    /// to track progress on this.
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

    /// Renders the title of a journal as content. The default argument
    /// typesets it in italics.
    /// -> function
    format-journaltitle: it => emph(it),

    /// Renders the title of a special issue as content. The default argument
    /// typesets it in italics.
    /// -> function
    format-issuetitle: it => emph(it),
  
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
    /// -> str
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

    /// The bibstring table. This is a dictionary that maps language-independent
    /// IDs of bibliographic constants (such as "In: " or "edited by") to
    /// their language-dependent surface forms. Replace some or all of the values
    /// with your own surface forms to control the way the bibliography is rendered.
    /// -> dict
    bibstring: default-bibstring,

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
  ) = {
    // construct fjoin functions for periods and commas
    let make-fjoin-function(separator) = {
      if type(separator) == function {
        // In contrast to the official documentation, you can also pass the
        // fjoin function directly as an argument. But this is complicated,
        // so let's keep it a secret.
        separator
      } else if type(separator) == str {
        (..x) => fjoin(separator, ..x, skip-if: separator)
      } else if type(separator) == array {
        (..x) => fjoin(separator.at(0), ..x, skip-if: separator.at(1))
      } else {
        (..x) => fjoin(".", ..x, skip-if: ".")
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
        format-parens: format-parens,
        format-brackets: format-brackets,
        format-quotes: format-quotes,
        name-format: name-format,
        bibeidpunct: bibeidpunct,
        bibpagespunct: bibpagespunct,
        print-isbn: print-isbn,
        print-url: print-url,
        print-doi: print-doi,
        print-eprint: print-eprint,
        print-date-after-authors: print-date-after-authors,
        volume-number-separator: volume-number-separator,
        bibstring: bibstring,
        suppressed-fields: suppressed-fields,
        periods: periods,
        commas: commas,
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
      let highlighted = highlight(finished, reference, index)

      if lbl == none {
        ([#highlighted],)
      } else {
        (lbl, highlighted)
      }
  }

  formatter
}




//////////////////////////////////////////////////////////////////////////
//
// Builtin citation styles:
// alphabetic, numeric, authoryear
// 
////////////////////////////////////////////////////////////////////////////

#let label-parts-alphabetic(reference) = {
  let extradate = if "extradate" in reference.fields {
    numbering("a", reference.fields.extradate + 1)
  } else {
    ""
  }

  (reference.label, extradate)
}

/// The _alphabetic_ citation style renders citations in a form like "[BK20]". The citation string
/// consists of a sequence of the first letters of the authors' family names. 
/// See @fig:example-alphabetic for an example.
/// 
/// If there are
/// too many authors, the symbol "+" is appended to the citation string to indicate
/// "et al.", e.g. "[YDZ+25]". What constitutes "too many" is controlled by the `maxalphanames` parameter.
/// 
/// If there is only one author, the first few characters of the author name are displayed instead,
/// as in "[Knu90]". The number of characters is controlled by the `labelalpha` parameter.
/// 
/// If more than one reference would receive the same citation string under this policy,
/// the style appends an "extradate" character. For example, if two papers would receive
/// the label "[BDF+20]", then the first one (in the sorting order of the bibliography)
/// will be replaced by "[BDF+20a]" and the second one by "[BDF+20b]".
/// 
/// The function `format-citation-alphabetic` returns a dictionary with keys
/// `format-citation`, `label-generator`, and `reference-label`. You can use the values
/// under these keys as arguments to `refsection`, `print-bibliography`, and `format-reference`,
/// respectively.
#let format-citation-alphabetic(
    /// The maximum number of authors that will be printed in a citation string.
    /// If the actual number of authors exceeds this value, the symbol specified under
    /// `labelalphaothers` below will be appended to indicate "et al".
    /// -> int
    maxalphanames: 3, 

    /// The maximum number of characters that will be printed for single-authored papers.
    /// -> int
    labelalpha: 3, 

    /// The "et al" character that is appended if the number of authors exceeds the
    /// value of the `maxalphanames` parameter.
    /// -> str
    labelalphaothers: "+",

    /// The string that separates the author and year in the `p` citation form.
    /// -> str
    citation-separator: ", ",

    /// Wraps text in square brackets. The argument needs to be a function
    /// that takes one argument (`str` or `content`) and returns `content`.
    /// 
    /// It is essential that if the argument is `none`, the function must
    /// also return `none`. This can be achieved conveniently with the `nn`
    /// function wrapper, see @sec:package:utility.
    /// 
    /// -> function
    format-brackets: nn(it => [[#it]])
  ) = {
  let formatter(reference-dict, form) = {
    let (reference-label, extradate) = label-parts-alphabetic(reference-dict.reference)

    if form == "n" {
      [#reference-label#extradate]
    } else {
      return [[#reference-label#extradate]]
    }
  }


  let list-formatter(reference-dicts, form) = {
    let individual-form = "n"
    let individual-citations = reference-dicts.map(x => {
      let lbl = x.at(0)
      let reference = x.at(1)
      link(label(lbl), formatter(reference, individual-form))
    })

    let joined = individual-citations.join(citation-separator)
    if form != "n" {
      format-brackets(joined)
    } else {
      joined
    }
  }

  let label-generator(index, reference) = {
    // TODO - handle the case with no authors
    let lastnames = family-names(reference.fields.parsed-author)

    let abbreviation = if lastnames.len() == 1 {
      lastnames.at(0).slice(0, labelalpha)
    } else {
      let first-letters = lastnames.map(s => s.at(0)).join("")
      if lastnames.len() > maxalphanames {
        first-letters.slice(0, maxalphanames) + labelalphaothers
      } else {
        first-letters
      }
    }

    let year = if is-year-defined(reference) {
      str(reference.fields.parsed-date.year).slice(-2)
    } else {
      ""
    }

    let lbl = strfmt("{}{}", abbreviation, year) // calc.rem(paper-year(reference), 100))
    (lbl, lbl)
  }

  let reference-label(index, reference) = {
    let (reference-label, extradate) = label-parts-alphabetic(reference)
    [[#reference-label#extradate]]
  }

  ("format-citation": list-formatter, "label-generator": label-generator, "reference-label": reference-label)
}



/// The _authoryear_ citation style renders citations in a form like "(Bender and Koller 2020)".
/// The citation string consists of a sequence of the authors' family names.
/// See @fig:example-authoryear
/// for an example.
/// 
/// If a paper has more than two authors, only the first author will be printed,
/// together with the symbol "et al.".
/// 
/// If more than one reference would receive the same citation string under this policy,
/// the style appends an "extradate" character. For example, if two papers would receive
/// the label "(Yao et al. 2025)", then the first one (in the sorting order of the bibliography)
/// will be replaced by "(Yao et al. 2025a)" and the second one by "(Yao et al. 2025b)".
/// 
/// The _authoryear_ citation style supports a particularly rich selection of citation forms
/// (see @fig:citation-forms).
/// 
/// The function `format-citation-authoryear` returns a dictionary with keys
/// `format-citation`, `label-generator`, and `reference-label`. You can use the values
/// under these keys as arguments to `refsection`, `print-bibliography`, and `format-reference`,
/// respectively.
#let format-citation-authoryear(
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

  /// The string that separates the author and year in the `p` citation form.
  /// -> str
  author-year-separator: " ",

  /// Separator symbol to connect the citations for the different keys.
  /// -> str
  citation-separator: "; "
) = {
  
  let formatter(reference-dict, form) = {
    // access precomputed information that was stored in the label field
    let (authors-str, year, extradate) = reference-dict.reference.at("label")
    let year-defined = is-year-defined(reference-dict.reference)
    let extradate = if extradate == none {
      // no extradate, so use empty string
      ""
    } else if year-defined {
      // year is defined - no need to wrap extradate in brackets
      extradate
    } else if form in ("t", "g", "p", auto) {
      // extradate is inside parentheses
      format-brackets(extradate)
    } else {
      format-parens(extradate)
    }

    if form == "name" {
      authors-str
    } else if form == "year" {
      [#year#extradate]
    } else if form == "t" {
      // can't concatenate with strfmt because format-parens(year) is not a string
      [#authors-str #format-parens([#year#extradate])]
    } else if form == "g" {
      [#authors-str\'s #format-parens(year)]
    } else if form == "n" {
      [#authors-str #year#extradate]
    } else { // auto or "p"
      format-parens([#authors-str#author-year-separator#year#extradate])
    }
  }

  let list-formatter(reference-dicts, form) = {
    let individual-form = if form == "p" or form == auto { "n" } else { form }
    let individual-citations = reference-dicts.map(x => {
      let lbl = x.at(0)
      let reference = x.at(1)
      link(label(lbl), formatter(reference, individual-form))
    })

    let joined = individual-citations.join(citation-separator)
    if form == "p" or form == auto {
      format-parens(joined)
    } else {
      joined
    }
  }

  let label-generator(index, reference) = {
    let parsed-authors = family-names(reference.fields.parsed-author)
    let year-defined = is-year-defined(reference)
    let year = if reference.fields.parsed-date != none and "year" in reference.fields.parsed-date {
      str(reference.fields.parsed-date.year)
    } else {
      "n.d." // TODO localize this through bibstring
    }

    let extradate = if "extradate" in reference.fields {
      numbering("a", reference.fields.extradate + 1)
    } else {
      none
    }

    let authors-str = if parsed-authors.len() == 1 {
      parsed-authors.at(0)
    } else if parsed-authors.len() == 2 {
      strfmt("{} and {}", parsed-authors.at(0), parsed-authors.at(1))
    } else {
      parsed-authors.at(0) + " et al."
    }

    let lbl = (authors-str, year, extradate)
    let lbl-repr = strfmt("{} {}{}", authors-str, year, extradate)

    (lbl, lbl-repr)
  }

  ("format-citation": list-formatter, "label-generator": label-generator, "reference-label": (index, reference) => none)
}

/// The _numeric_ citation style renders citations in a form like "[1]".
/// The citation string is the position of the reference in the bibliography.
/// See @fig:example-output
/// for an example.
/// 
/// The function `format-citation-numeric` returns a dictionary with keys
/// `format-citation`, `label-generator`, and `reference-label`. You can use the values
/// under these keys as arguments to `refsection`, `print-bibliography`, and `format-reference`,
/// respectively.
#let format-citation-numeric(
    /// The string that separates the author and year in the `p` citation form.
    /// -> str
    citation-separator: ", ",

    /// Wraps text in square brackets. The argument needs to be a function
    /// that takes one argument (`str` or `content`) and returns `content`.
    /// 
    /// It is essential that if the argument is `none`, the function must
    /// also return `none`. This can be achieved conveniently with the `nn`
    /// function wrapper, see @sec:package:utility.
    /// 
    /// -> function
    format-brackets: nn(it => [[#it]])
  ) = {
  let formatter(reference-dict, form) = {
    let lbl = reference-dict.reference.label

    if form == "n" {
      [#{reference-dict.index+1}]
    } else {
      return [[#{reference-dict.index+1}]]
    }
  }

  let list-formatter(reference-dicts, form) = {
    let individual-form = "n"
    let individual-citations = reference-dicts.map(x => {
      let lbl = x.at(0)
      let reference = x.at(1)
      link(label(lbl), formatter(reference, individual-form))
    })

    let joined = individual-citations.join(citation-separator)
    if form != "n" {
      format-brackets(joined)
    } else {
      joined
    }
  }

  let label-generator(index, reference) = {
    (index + 1, str(index + 1))
  }

  let reference-label(index, reference) = {
    [[#reference.label]]
  }

  ("format-citation": list-formatter, "label-generator": label-generator, "reference-label": reference-label)
}