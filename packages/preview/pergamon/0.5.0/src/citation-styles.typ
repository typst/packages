#import "@preview/oxifmt:1.0.0": strfmt

#import "bibstrings.typ": default-long-bibstring, default-short-bibstring
#import "bib-util.typ": fd, ifdef, type-aliases, nn, concatenate-names
#import "names.typ": family-names
#import "dates.typ": is-year-defined


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


  let list-formatter(reference-dicts, form, options) = {
    let individual-form = "n"
    let individual-citations = reference-dicts.map(x => {
      if type(x) == str {
        [*?#x?*]
      } else {
        let lbl = x.at(0)
        let reference = x.at(1)
        link(label(lbl), formatter(reference, individual-form))
      }
    })

    let joined = individual-citations.join(citation-separator)
    if form != "n" {
      format-brackets(joined)
    } else {
      joined
    }
  }

  let label-generator(index, reference) = {
    let lastnames = family-names(reference.fields.labelname)

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
  citation-separator: "; ",

  /// When typesetting lists (e.g. author names), #bibtypst will use this
  /// delimiter to combine list items before the last one.
  /// 
  /// Will typically match the `list-middle-delim` argument of
  /// @format-reference.
  /// 
  /// -> str
  list-middle-delim: ", ",

  /// When typesetting lists (e.g. author names), #bibtypst will use this
  /// delimiter to combine the items of lists of length two.
  /// 
  /// Will typically match the `list-end-delim-two` argument of
  /// @format-reference.
  /// 
  /// -> str
  list-end-delim-two: " and ",

  /// When typesetting lists (e.g. author names), #bibtypst will use this
  /// delimiter in lists of length three of more to combine the final
  /// item in the list with the rest.
  /// 
  /// Will typically match the `list-end-delim-many` argument of
  /// @format-reference.
  /// 
  /// -> str
  list-end-delim-many: ", and ",
  
  /// Overrides entries in the bibstring table. The bibstring table is a dictionary
  /// that maps language-independent
  /// IDs of bibliographic constants (e.g. "in") to
  /// their language-dependent surface forms (such as "In: " or "edited by").
  /// The ID-form pairs you specify in the `bibstring` argument will overwrite
  /// the default entries.
  /// 
  /// Will typically match the `bibstring` argument of
  /// @format-reference.
  ///
  /// See the documentation for @default-long-bibstring in @sec:package:utility for
  /// more information on the bibstring table.
  /// 
  /// -> dictionary
  bibstring: (:),

  /// Selects whether the long or short versions of the bibstrings should be used
  /// by default. This controls the rendering of "et al." and "n.d.".
  /// Acceptable values are "long" and "short". See the documentation
  /// of @default-long-bibstring for details.
  /// 
  /// -> str
  bibstring-style: "short",

  /// Maximum number of names that are displayed in name lists (author, editor, etc.).
  /// If the actual number of names exceeds `maxnames`, only the first `maxnames`
  /// names are shown and `bibstring.andothers` ("et al.") is appended.
  ///
  /// This parameter is modeled after the `maxnames`/`maxcitenames` option
  /// in #biblatex. Just like `maxbibnames` is not necessarily the same as 
  /// `maxcitenames`, the value of `maxnames` here need not match the value
  /// of `maxnames` in @format-reference.
  ///
  /// -> int
  maxnames: 2,

  /// Minimum number of names that are displayed in name lists (author, editor, etc.).
  /// This can be used in conjunction with `maxnames` to create name lists like
  /// "Jones, Smith et al." (minnames = 2, maxnames = 2).
  ///
  /// `minnames` trumps `maxnames`: That is, if the name list is at least as long
  /// as `minnames`, the reference will show `minnames` names, even if this exceeds
  /// `maxnames`. In typical use cases, `minnames` will be less or equal than `maxnames`,
  /// so this situation will usually not occur.
  ///
  /// This parameter is modeled after the `minnames`/`mincitenames` option
  /// in #biblatex. Just like `minbibnames` is not necessarily the same as 
  /// `mincitenames`, the value of `minnames` here need not match the value
  /// of `names` in @format-reference.
  ///
  /// -> int
  minnames: 1,


) = {
  let default-bibstring = if bibstring-style == "short" { default-short-bibstring } else {default-long-bibstring }
  let options = (
    list-middle-delim: list-middle-delim,
    list-end-delim-two: list-end-delim-two,
    list-end-delim-many: list-end-delim-many,
    bibstring: default-bibstring + bibstring,
    minnames: minnames,
    maxnames: maxnames
  )
  
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
      [#authors-str#author-year-separator#year#extradate]
    } else { // auto or "p"
      format-parens([#authors-str#author-year-separator#year#extradate])
    }
  }

  let list-formatter(reference-dicts, form, options) = {
    let prefix = options.at("prefix", default: "")
    let suffix = options.at("suffix", default: "")

    let individual-form = if form == "p" or form == auto { "n" } else { form }
    let individual-citations = reference-dicts.map(x => {
      if type(x) == str {
        [*?#x?*]
      } else {
        let lbl = x.at(0)
        let reference = x.at(1)
        link(label(lbl), formatter(reference, individual-form))
      }
    })

    let joined = individual-citations.join(citation-separator)
    if form == "p" or form == auto {
      format-parens([#prefix#joined#suffix])
    } else {
      joined
    }
  }


  let label-generator(index, reference) = {
    let labelname = family-names(reference.fields.labelname)
    let year-defined = is-year-defined(reference)
    let year = if reference.fields.parsed-date != none and "year" in reference.fields.parsed-date {
      str(reference.fields.parsed-date.year)
    } else {
      options.bibstring.nodate
    }

    let extradate = if "extradate" in reference.fields {
      numbering("a", reference.fields.extradate + 1)
    } else {
      none
    }

    let authors-str = concatenate-names(labelname, options: options, minnames: options.minnames, maxnames: options.maxnames)

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

  let list-formatter(reference-dicts, form, options) = {
    let individual-form = "n"
    let individual-citations = reference-dicts.map(x => {
      if type(x) == str {
        [*?#x?*]
      } else {
        let lbl = x.at(0)
        let reference = x.at(1)
        link(label(lbl), formatter(reference, individual-form))
      }
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