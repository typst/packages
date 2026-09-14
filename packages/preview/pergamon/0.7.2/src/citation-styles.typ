#import "@preview/oxifmt:1.0.0": strfmt

#import "bibstrings.typ": default-long-bibstring, default-short-bibstring
#import "bib-util.typ": fd, ifdef, type-aliases, nn, concatenate-names
#import "names.typ": family-names
#import "dates.typ": is-year-defined
#import "templating.typ": fjoin

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
    /// `labelalphaothers` below will be appended to indicate that the author
    /// list was truncated.
    /// 
    /// -> int
    maxalphanames: 3, 

    /// The number of author initials to keep when author lists are truncated
    /// because their length exceeded `maxalphanames`. With minalphanames = 2,
    /// you get "[AB+26]"; with minalphanames = 3, you get "[ABC+26]".
    /// 
    /// Note that `maxalphanames` controls _whether_ long author lists get
    /// truncated, and `minalphanames` controls _how many_ authors get included
    /// in the truncated author list. Therefore, `minalphanames` can never be
    /// greater than `maxalphanames`. If you pass a larger value, it will instead
    /// be set to `maxalphanames`.
    /// 
    /// If you pass `none` (the default), `minalphanames` defaults to `maxalphanames`.
    /// 
    /// -> int | none
    minalphanames: none,

    /// The maximum number of characters that will be printed for single-authored papers.
    /// -> int
    labelalpha: 3, 

    /// The "et al" character that is appended if the number of authors exceeds the
    /// value of the `maxalphanames` parameter.
    /// 
    /// Note that this argument really has to be a string, not content,
    /// because it is used in the construction of the reference labels.
    /// 
    /// -> str
    labelalphaothers: "+",

    /// The string that separates the author and year in the `p` citation form.
    /// 
    /// -> str | content
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

    // correct minalphanames
    minalphanames = if minalphanames == none {
      maxalphanames
    } else if minalphanames > maxalphanames {
      maxalphanames
    } else {
      minalphanames
    }

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
        first-letters.slice(0, minalphanames) + labelalphaothers
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
  /// 
  /// -> str | content
  author-year-separator: " ",

  /// Separator symbol to connect the citations for the different keys.
  /// -> str | content
  citation-separator: "; ",

  /// The string that separates the prefix from the citation.
  /// -> str
  prefix-separator: " ",

  /// The string that separates the suffix from the citation.
  /// -> str
  suffix-separator: ", ",

  /// When typesetting lists (e.g. author names), #bibtypst will use this
  /// delimiter to combine list items before the last one.
  /// 
  /// Will typically match the `list-middle-delim` argument of
  /// @format-reference.
  /// 
  /// -> str | content
  list-middle-delim: ", ",

  /// When typesetting lists (e.g. author names), #bibtypst will use this
  /// delimiter to combine the items of lists of length two.
  /// 
  /// Will typically match the `list-end-delim-two` argument of
  /// @format-reference.
  /// 
  /// -> str | content
  list-end-delim-two: " and ",

  /// When typesetting lists (e.g. author names), #bibtypst will use this
  /// delimiter in lists of length three of more to combine the final
  /// item in the list with the rest.
  /// 
  /// Will typically match the `list-end-delim-many` argument of
  /// @format-reference.
  /// 
  /// -> str | content
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
    let prefix = options.at("prefix", default: none)
    let suffix = options.at("suffix", default: none)

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
    let joined-with-affixes = fjoin(suffix-separator,
      fjoin(prefix-separator, prefix, joined),
      suffix
    )

    if form == "p" or form == auto {
      format-parens(joined-with-affixes)
    } else {
      joined-with-affixes
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
/// 
/// Note that the `label-generator` of this citation style takes an optional argument
/// `format-string` that controls how the numeric index (1, 2, 3, ...) is translated into
/// the actual label. You can pass an oxifmt format string; by default it is `"{}"`, such that
/// the index is rendered without any changes. If you want e.g. labels J01, J02, ...,
/// you can pass `label-generator.with(format-string: "J{:02}")` to `print-bibliography`
/// instead. Note that the numeric citation style still assumes that the labels of all
/// references are different; there is no support for extradates like in the authoryear style.
/// Thus you should probably make sure that `{}` occurs in the format string somewhere.
#let format-citation-numeric(
    /// Determines whether sequences of subsequent citation indices
    /// should be compacted into a range. If `true`, a citation [1, 2, 3, 5, 6]
    /// is instead rendered as [1--3, 5--6].
    /// 
    /// Note that the citation style does not do anything particular to sort
    /// the citation indices within the same citation. The citation [3, 2, 1] 
    /// will still be rendered as [3, 2, 1] and not as [1--3].
    /// 
    /// -> bool
    compact: false,

    /// The string that separates the different citations when `cite`
    /// is called with multiple references (e.g. [1, 3, 15]).
    /// 
    /// -> str | content
    citation-separator: ", ",

    /// The string that separates the two ends of a range, if
    /// the `compact` parameter is set to `true`.
    /// 
    /// -> str | content
    compact-separator: [--],

    /// Wraps text in square brackets. The argument needs to be a function
    /// that takes one argument (`str` or `content`) and returns `content`.
    /// 
    /// It is essential that if the argument is `none`, the function must
    /// also return `none`. This can be achieved conveniently with the `nn`
    /// function wrapper, see @sec:package:utility.
    /// 
    /// -> function
    format-brackets: nn(it => [[#it]]),
  ) = {
  let list-formatter(reference-dicts, form, options) = {
    let individual-citations = reference-dicts.map(x => {
      if type(x) == str {
        [*?#x?*]
      } else {
        let lbl = x.at(0) // str: label to link to (refid-key)
        let reference = x.at(1) // dict: augmented reference dictionary
        // reference.reference.label: any = first value from label-generator
        // reference.reference.label-repr: str = second value from label-generator
        
        let (index, format-string) = reference.reference.label
        let formatted = strfmt(format-string, index)
        (index, link(label(lbl), formatted))
      }
    })

    let joined = if compact {
      // If "compact" is requested, we suppress subsequent numbers and
      // replace them with hyphens: 1, 2, 3, 5, 6 becomes [1-3, 5-6].
      // This requires a bit of indexing gymnastics.
      let pieces = ()

      for (i, cit) in individual-citations.enumerate() {
        if type(cit) == array {
          let this-ix = cit.at(0)
          
          // index of previous citation in group, if exists
          let prev-ix = if i > 0 and type(individual-citations.at(i - 1)) == array {
            individual-citations.at(i - 1).at(0)
          } else {
            -100
          }

          // index of next citation in group, if exists
          let next-ix = if i < individual-citations.len() - 1 and type(individual-citations.at(i + 1)) == array {
            individual-citations.at(i+1).at(0)
          } else {
            -100
          }

          if i == 0 {
            // first element in citation doesn't get a separator
            pieces.push(cit.at(1))
          } else if prev-ix == this-ix - 1 {
            // continue range
            if next-ix == this-ix + 1 {
              // ignore this citation, it is inside a compact range
            } else {
              // last citation of compact range
              pieces.push(compact-separator)
              pieces.push(cit.at(1))
            }
          } else {
            // start new range
            pieces.push(citation-separator)
            pieces.push(cit.at(1))
          }
        } else {
          // undefined citation - not an array
          if i > 0 {
            pieces.push(citation-separator)
          }
          pieces.push(cit)
        }
      }

      pieces.join("")
    } else {
      // non-compact
      individual-citations.map(x => if type(x) == array { x.at(1) } else { x }).join(citation-separator)
    }

    if form != "n" {
      format-brackets(joined)
    } else {
      joined
    }
  }

  let label-generator(index, reference, format-string: "{}") = {
    ((index + 1, format-string), str(index + 1))
  }

  let reference-label(index, reference) = {
    let (index, format-string) = reference.label
    let formatted = strfmt(format-string, index)
    [[#formatted]]
  }

  ("format-citation": list-formatter, "label-generator": label-generator, "reference-label": reference-label)
}
