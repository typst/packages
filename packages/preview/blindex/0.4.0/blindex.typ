//============================================================================================//
//                                          Includes                                          //
//============================================================================================//

#import "./books.typ": iboo, bsort
#import "./lang.typ": ldict

//============================================================================================//
//                                    Book Info Retrieving                                    //
//============================================================================================//

/// Returns valid `language-tradition` values, to be passed as the corresponding named argument in user-facing functions.
///
/// === Examples
/// ```example
/// #block(width: 80mm)[
///   #for item in get-language-traditions() [
///     #box[#raw("\"" + item + "\""),]
///   ]
/// ]
/// ```
///
/// -> array
#let get-language-traditions() = {
  return ldict.at("1001").keys()
}

/// Returns valid biblical literature book `sorting-tradition` values, to be passed  as  the  corresponding  named  argument  in
/// user-facing functions like @mk-index.
///
/// === Examples
/// ```example
/// #block(width: 80mm)[
///   #for item in get-sorting-traditions() [
///     #box[#raw("\"" + item + "\""),]
///   ]
/// ]
/// ```
///
/// -> array
#let get-sorting-traditions() = {
  return bsort.keys()
}

/// Returns valid `book-abbrev` values, to be passed as the corresponding argument in user-facing functions.
///
/// === Examples
/// ```example
/// #block(width: 80mm)[
///   #for item in get-book-abbrevs("fr-TOB") [
///     #box[#raw("\"" + item + "\""),]
///   ]
/// ]
/// ```
///
/// -> array
#let get-book-abbrevs(
  /// The language-tradition for which to retrieve book abbreviations from (see @get-language-traditions) -> string
  language-tradition
) = {
  for KV in ldict.pairs() { (KV.at(1).at(language-tradition).at(0),) }
}

/// Helper  function  (not  user-facing)  that  converts  a  biblical  literature  book  abbreviation  (according  to  a   given
/// language-tradition) into an indexing dictionary.
///
/// -> dictionary
#let abbrev-to-dict(
  /// The biblical literature book abbreviation (according to a given language-tradition) -> string
  book-abbrev,
  /// The language-tradition in which the `book-abbrev` points to the intended book -> string
  language-tradition: "en-USX"
) = {
  // book-abbrev in language-tradition assertion
  let valid-book-abbrev = get-book-abbrevs(language-tradition)
  let error-msg = (
    "book abbreviation not found",
    "abbreviation...: '" + book-abbrev + "'",
    "language.......: '" + language-tradition + "'",
    "valid '" + language-tradition + "' abbreviations are:",
    "\"" + valid-book-abbrev.join("\", \"") + "\"",
  ).join("\n")
  assert(valid-book-abbrev.contains(book-abbrev), message: error-msg)
  // normal processing
  let abbrev-array = for (K, V) in ldict.pairs() {((..V.at(language-tradition), K),)}
  let match = (..abbrev-array.filter(x => x.at(0) == book-abbrev),)
  return for M in match {
    let SORT = for P in bsort.pairs() {
      (P.at(0): P.at(1).position(x => x == int(M.at(2))))
    }
    ((
      "book-abbrev": M.at(0),
      "full": M.at(1),
      "BUID": M.at(2),
      "lang": language-tradition,
      "STDN": iboo.at(M.at(2)),
      "SORT": SORT,
    ),)
  }
}

//============================================================================================//
//                                Biblical Literature Indexing                                //
//============================================================================================//

/// Biblical literature indexing marking function.
///
/// This function produces no visible output, but only adds to the document the appropriate indexing  #raw("#metadata()",  lang:
/// "typst").
/// 
/// This function is perhaps best used indirectly, through the  various  quoting  functions  (see  @ind-inl  and  @ind-blk,  for
/// instance).
///
/// -> none
#let blindex(
  /// The book abbreviation (see @get-book-abbrevs) -> string
  book-abbrev,
  /// The `[chapter:verse(s)]` entry -> content
  chapter-verse,
  /// The book abbreviation language-tradition (see @get-language-traditions) -> string
  language-tradition: "en-USX"
) = context [#metadata((
    ABRV: book-abbrev,
    LANG: language-tradition,
    DATA: abbrev-to-dict(book-abbrev, language-tradition: language-tradition),
    ENTR: chapter-verse,
    WHRE: here().position(),
  ))<bl_index>]

/// Index-making (producing, typesetting) function.
///
/// This function produces a biblical literature index, at  the  point  of  call  in  the  document,  based  on  the  document's
/// #raw("#metadata()", lang: "typst") entries placed directly through @blindex calls, or indirectly through one of the  quoting
/// functions (see @ind-inl and @ind-blk, for instance).
/// 
/// Since indices are produced and placed at the point of call of this function, the user has full control on the index location
/// within the document. Moreover, there's no restriction on the number of times this function  can  be  called,  thus  allowing
/// multiple indices to be produced. This may be useful in polyglot documents, since it enables the  production  of  indices  of
/// multiple languages.
/// 
/// The index language, ordering of books (according to various traditions), and apprearance is controlable through the function
/// arguments.
///
#let mk-index(
  /// The language-tradition code for printing full  index  book  names  (see  @get-language-traditions).  This  can  be  freely
  /// specified regardless  of  the  tradition-language  used  to  marking  index  entries  along  the  document,  since  during
  /// index-marking, language-tradition book abbreviations are converted into generic  internal  representation  keys  that  are
  /// language-tradition independent, while during index making, the generic internal  representations  are  converted  back  to
  /// whatever specified language-tradition -> string
  language-tradition: "en-USX",
  /// The book sorting tradition (see  @get-sorting-traditions).  This  parameter  controls  the  _sorting  order_  of  biblical
  /// literature book entries. It is worth noting that most sorting traditions do not define book placements  for  all  biblical
  /// literature books (owing to the inclusion of deuterocanonical and apocripha books  only  in  certain  sorting  traditions).
  /// Therefore, apocripha or deutorocanonical books may _not be listed at all_ in some book  sorting  traditions,  since  their
  /// placement is not defined. The library includes the `code` and `USX` sorting traditions, which are  all-inclusive,  meaning
  /// indices made with these sorting traditions are guaranteed to include every indexed biblical  literature  citation  in  the
  /// document. -> string
  sorting-tradition: "USX",
  /// The number of columns for the index rendering. It is worth noting that while `typst` does not implement  automatic  column
  /// balancing, some situations may call for manual column balancing, which can be accomplished  externally  to  this  function
  /// call -> int
  cols: 2,
  /// The `gutter` argument for the `#columns` function call -> length
  gutter: 8pt,
  /// Font weight customizations for the book, text, and page elements of the index. -> dictionary
  book-text-page-weights: (book: "bold", text: "regular", page: "extrabold"),
  /// The pattern for the index leaders -> content
  pattern: [.],
  /// Flags whether to fully merge index book headings for books merged on given  language-traditions.  In  some  traditions,  a
  /// single book entry may contain multiple books of other traditions. For instance,  in  some  Catholic  traditions,  the  6th
  /// chapter of the book of "Baruch" is listes as a separate book---the "Letter of Jeremiah"---in other traditions. Since index
  /// metadata entries are made through the book abbreviation `book-abbrev` (see @get-book-abbrevs), there  might  be  a  1:many
  /// associations between abbreviation and actual book(s). Whenever this happens, the stored #raw("#metadata()", lang: "typst")
  /// actually contains an _array_ of books, and this option controls whether or not all books get merged or just the first  one
  /// (usually the most-encompassing) is displayed, i.e., using the example above, whether only "Baruch" or "Baruch / Letter  of
  /// Jeremiah" is listed as a book heading in the index. -> bool
  merged-book-headings-full: false,
  /// The book merging arguments for `join`. The entry `at(0)` is the positional  argument  for  `join`,  while  optional  entry
  /// `at(1)` is the named `last` argument for `join` -> array
  merged-book-headings-join: (" / ",),
) = context {
  let BIG  =  10000   // just above highest buid number, which is 9999
  let HUGE = 100000   // an order of magnitude (base 10) above BIG
  let index-dict = (:)
  let raw-blindex-metadata = query(<bl_index>) // An array of metadata
  for raw-entry in raw-blindex-metadata { // raw-entry is a metadata entry
    let raw-entry-value = raw-entry.value // raw-entry-value is the record placed by blindex(...)
    let book-entry-sorting-rank = raw-entry-value.DATA.at(0).SORT.at(sorting-tradition)
    if book-entry-sorting-rank != none {
      let book-headings = () // Most generic book headings (as some are mergings)
      if (raw-entry-value.DATA.len() > 1) and (merged-book-headings-full) { // Merged book display
        for dummy in raw-entry-value.DATA {
          book-headings.push(ldict.at(raw-entry-value.DATA.at(0).BUID).at(language-tradition).at(1))
        }
      } else { // Single book display
        book-headings.push(ldict.at(raw-entry-value.DATA.at(0).BUID).at(language-tradition).at(1))
      }
      let book-heading = if merged-book-headings-join.len() > 1 {
        book-headings.join(merged-book-headings-join.at(0), last: merged-book-headings-join.at(1))
      } else {
        book-headings.join(merged-book-headings-join.at(0))
      }
      let index-dict-key = if book-entry-sorting-rank != none { str(book-entry-sorting-rank + HUGE) } else { str(BIG + HUGE) }
      let index-dict-value = (raw-entry-value.ENTR, raw-entry-value.WHRE.page)
      // Populates index-dict
      if index-dict-key in index-dict {
        if index-dict-value not in index-dict.at(index-dict-key).at(1) {
          index-dict.at(index-dict-key).at(1).push(index-dict-value)
        }
      } else {
        index-dict.insert(index-dict-key, (book-heading, (index-dict-value,)))
      }
    }
  }
  let sorted-index-keys = index-dict.keys().sorted()
  columns(cols, gutter: gutter)[#{
    for sorted-key in sorted-index-keys {
      text(weight: book-text-page-weights.book, index-dict.at(sorted-key).at(0))
      linebreak()
      for index-entry-values in index-dict.at(sorted-key).at(1) {
        box(width: 1.2em)
        text(weight: book-text-page-weights.text, index-entry-values.at(0)) // ENTRY
        box(width: 0.3em)
        box(width: 1fr, repeat(align(center, box(width: 0.5em, pattern))))
        box(width: 1.8em, align(center, text(weight: book-text-page-weights.page, [#index-entry-values.at(1)]))) // PAGE
        linebreak()
      }
    }
  }]
}

//============================================================================================//
//                                Biblical Literature Quoting                                 //
//============================================================================================//

//--------------------------------------------------------------------------------------------//
//                                       Quote Settings                                       //
//--------------------------------------------------------------------------------------------//

#let pkg-pars = (
  // Formattings
  fmt: (
    box: (:),
    text: (:),
    block: (:),
    highlight: (:),
  ),
  // Quotings
  quo: (:),
)

// Default verse mark: ensure font, style, weight, size:
#pkg-pars.fmt.text.insert("ver",
  (font: "Noto Sans", style: "normal", weight: "black", size: 0.6em))
#pkg-pars.fmt.box.insert("ver",
  (baseline: pkg-pars.fmt.text.at("ver").size - 0.85em))
// Default passage quoting: ensure font, style, weight
#pkg-pars.fmt.text.insert("quo",
  (font: ("EB Garamond", "Libertinus Serif"), style: "normal", weight: "regular"))
#pkg-pars.fmt.highlight.insert("quo",
  (fill: rgb("A0A0A040")))
#pkg-pars.fmt.highlight.insert("blk",
  (fill: none))
// Default citation mark: ensure style, weight
#pkg-pars.fmt.text.insert("ref",
  (style: "normal", weight: "regular"))
#pkg-pars.fmt.highlight.insert("ref",
  (fill: none))
// Default block options:
#pkg-pars.fmt.block.insert("quo",
  (width: 90%, inset: 4pt, fill: rgb("A0A0A040")))
#pkg-pars.fmt.block.insert("ref",
  (width: 90%, inset: 4pt, fill: none))

// Default smart quotes options:
#pkg-pars.quo.insert("def",
  (enabled: true, double: true,))
#pkg-pars.quo.insert("single",
  (enabled: true, double: false,))
#pkg-pars.quo.insert("plain",
  (enabled: false,))
#pkg-pars.quo.insert("alt",
  (enabled: true, alternative: true, quotes: (
    single: ("\u{2018}", "\u{2019}"),
    double: ("\u{201C}", "\u{201D}"),)))

//--------------------------------------------------------------------------------------------//
//                                      Quote Functions                                       //
//--------------------------------------------------------------------------------------------//

/// Verse number formatting function
///
/// === Examples
/// ```example
/// #set text(font: "Libertinus Serif")
/// #block(width: 80mm)[
///   #ver[1]In the beginning God created the heavens and the earth.
/// ]
/// ```
///
/// -> content
#let ver(
  /// Formatting named args that can be passed to a ```typst #text(..text-pars)``` function call -> dictionary
  text-pars: pkg-pars.fmt.text.ver,
  /// Formatting named args that can be passed to a ```typst #box(..box-pars)``` function call -> dictionary
  box-pars: pkg-pars.fmt.box.ver,
  /// The contents added meant for spacing between the rendered verse mark and the following contents in  the  calling  context.
  /// Note that in the provided example no space was left between the  function  call  closing  parenthesis  and  the  following
  /// contents, so that the exact spacing `content` is produced -> content
  spc: [#h(0.2em)],
  /// The verse mark to render -> int | string | content
  body,
) = {
  box(..box-pars, text(..text-pars, body + spc))
}

/// Helper function for fully controlled highlighted and formatting of `body` quoting.
///
/// This function in only concerned with biblical literature passage formatting: full text and highlight specifications, without
/// any "dressings" --- such as smart-quoting, biblical literature referencing, bibliography citation, or  indexing;  therefore,
/// it has seldom cases of direct user-facing usage.
///
/// Both `#text` and `#highlight` formatting abilities are complete for maximum usability, which makes this function a central
/// component of the higher-level (user-facing) quoting-referencing-citing-indexing functions.
///
/// === Example
///
/// The rare function user-facing usage includes the repeating of immediate-context, previous, fully-qualified quoted passage
/// excerpts within a discussion, such as:
///
/// ```example
/// #set text(font: "Libertinus Serif")
/// #block(width: 80mm)[
///   we've seen that
///   #quo-high([all kindreds of the earth
///     shall wail because of him]),
///   (speaking of Jesus), therefore...
/// ]
/// ```
///
/// -> content
#let quo-high(
  /// Formatting named args that can be passed to a ```typst #text(..quo-text-pars)``` function call -> dictionary
  quo-text-pars: pkg-pars.fmt.text.quo,
  /// Formatting named args that can be passed to a ```typst #highlight(..quo-highlight-pars)``` function call -> dictionary
  quo-highlight-pars: pkg-pars.fmt.highlight.quo,
  /// The excerpt or passage to be rendered -> content
  body,
) = {
  [#highlight(..quo-highlight-pars, text(..quo-text-pars, body))]
}

/// Helper function for fully controlled (smart-)quoting, highlighted and formatting of `body` quoting.
///
/// This function expands upon @quo-high() by optionally smart-quoting its generated contents.
///
/// === Example
///
/// ```example
/// #set text(font: "Libertinus Serif")
/// #block(width: 80mm)[
///   The shortest verse of the New Testament is
///   #quo-quot[Jesus wept.]
/// ]
/// ```
///
/// -> content
#let quo-quot(
  /// The excerpt or passage to be rendered -> content
  body,
  /// Formatting named args that can be passed to a ```typst #text(..quo-text-pars)``` function call -> dictionary
  quo-text-pars: pkg-pars.fmt.text.quo,
  /// Formatting named args that can be passed to a ```typst #highlight(..quo-highlight-pars)``` function call -> dictionary
  quo-highlight-pars: pkg-pars.fmt.highlight.quo,
  /// Smartquote parameters that can be passed to a ```typst #set smartquote(..quote-pars)``` function call -> dictionary
  quote-pars: pkg-pars.quo.at("def"),
  /// The opening quote -> content
  oquot: ["],
  /// The closing quote -> content
  cquot: ["],
) = {
  set text(..quo-text-pars)
  set smartquote(..quote-pars)
  [#oquot#highlight(..quo-highlight-pars, body)#cquot]
}

/// Helper function for biblical  literature  passage  referencing,  according  to  various  language-traditions,  and  optional
/// bibliography citing.
///
/// This function isn't meant for direct user-facing usage.
///
/// -> content
#let ref-bare(
  /// The biblical literature book abbreviation (see @get-book-abbrevs()) -> string
  book-abbrev,
  /// The referencing passage such as `[1:1--7]` > contents
  passage,
  /// The language-tradition in which the `book-abbrev` is valid (see @get-language-traditions()) -> string
  language-tradition: "en-USX",
  /// The biblical literature version (usually translation/source acronym) -> string | none
  version: none,
  /// The bibliography citation label or `none`, for no citation -> label | none
  cite-label: none,
  /// Named args (pars) that can be passed to a ```typst #cite(..cite-pars, cite-label)``` function call -> dictionary
  cite-pars: (supplement: none, form: "normal", style: auto),
  /// Formatting named args that can be passed to a ```typst #set text(..ref-text-pars)``` function call -> dictionary
  ref-text-pars: pkg-pars.fmt.text.ref,
  /// Separator (from previous content) -> content
  ref-sep: [ ---],
) = {
  let mk-cit() = { if cite-label != none [ #cite(..cite-pars, cite-label)] }
  set text(..ref-text-pars)
  [#ref-sep~#abbrev-to-dict(book-abbrev, language-tradition: language-tradition).at(0).full~#passage]
  if version == none { mk-cit() } else { [ (#version#mk-cit())] }
}

/*----------------------------------------------------------------------------*/
/*                     Main User-Facing Quoting Functions                     */
/*----------------------------------------------------------------------------*/

/// Indexed inline quoting-referencing(-citing) function.
///
/// This is one of the main user-facing functions of this library, meant  for  fully  configurable  inline  biblical  literature
/// quoting, referencing, optional citation, and indexing.
///
/// === Example
///
/// ```example
/// #set text(font: "Noto Sans")
/// #block(width: 80mm)[
///   It is written that
///   #ind-inl([Abraham believed God, and it was reckoned unto him for
///     righteousness,], "GAL", [3:6], version: "ASV")
///   therefore...
/// ]
/// ```
///
/// -> content
#let ind-inl(
  /// The excerpt or passage to be rendered -> content
  body,
  /// The biblical literature book abbreviation (see @get-book-abbrevs()) -> string
  book-abbrev,
  /// The referencing passage such as `[1:1--7]` > contents
  passage,
  /// The language-tradition in which the `book-abbrev` is valid (see @get-language-traditions()) -> string
  language-tradition: "en-USX",
  /// The biblical literature version (usually translation/source acronym) -> string | none
  version: none,
  /// The bibliography citation label or `none`, for no citation -> label | none
  cite-label: none,
  /// Named args (pars) that can be passed to a ```typst #cite(..cite-pars, cite-label)``` function call -> dictionary
  cite-pars: (supplement: none, form: "normal", style: auto),
  /// Formatting named args that can be passed to a ```typst #text(..ref-text-pars)``` function call -> dictionary
  ref-text-pars: pkg-pars.fmt.text.ref,
  /// Separator (from previous content) -> content
  ref-sep: [ ---],
  /// Formatting named args that can be passed to a ```typst #text(..quo-text-pars)``` function call -> dictionary
  quo-text-pars: pkg-pars.fmt.text.quo,
  /// Formatting named args that can be passed to a ```typst #highlight(..quo-highlight-pars)``` function call -> dictionary
  quo-highlight-pars: pkg-pars.fmt.highlight.quo,
  /// Smartquote parameters that can be passed to a ```typst #set smartquote(..quote-pars)``` function call -> dictionary
  quote-pars: pkg-pars.quo.at("def"),
  /// The opening quote -> content
  oquot: ["],
  /// The closing quote -> content
  cquot: ["],
) = {
  quo-quot(
    body,
    quo-text-pars: quo-text-pars,
    quo-highlight-pars: quo-highlight-pars,
    quote-pars: quote-pars,
    oquot: oquot,
    cquot: cquot,
  )
  ref-bare(
    book-abbrev,
    passage,
    language-tradition: language-tradition,
    version: version,
    cite-label: cite-label,
    cite-pars: cite-pars, 
    ref-text-pars: ref-text-pars,
    ref-sep: ref-sep,
  )
  blindex(
    book-abbrev,
    passage,
    language-tradition: language-tradition,
  )
}

/// Indexed blocked quoting-referencing(-citing) function.
///
/// This is one of the main user-facing functions of this library, meant for  fully  configurable  blocked  biblical  literature
/// quoting, referencing, optional citation, and indexing.
///
/// === Example
///
/// ```example
/// #set text(font: "Noto Sans")
/// #block(width: 80mm)[
///   The Revelation of Jesus Christ affirms:
///   #ind-blk([Behold, he cometh with the clouds; and every eye shall
///     see him, and they that pierced him; and all the tribes of the
///     earth shall mourn over him. Even so, Amen.],
///     "REV", [1:7], version: "ASV")
///   therefore...
/// ]
/// ```
///
/// -> content
#let ind-blk(
  /// The excerpt or passage to be rendered -> content
  body,
  /// The biblical literature book abbreviation (see @get-book-abbrevs()) -> string
  book-abbrev,
  /// The referencing passage such as `[1:1--7]` > contents
  passage,
  /// The language-tradition in which the `book-abbrev` is valid (see @get-language-traditions()) -> string
  language-tradition: "en-USX",
  /// The biblical literature version (usually translation/source acronym) -> string | none
  version: none,
  /// The bibliography citation label or `none`, for no citation -> label | none
  cite-label: none,
  /// Named args (pars) that can be passed to a ```typst #cite(..cite-pars, cite-label)``` function call -> dictionary
  cite-pars: (supplement: none, form: "normal", style: auto),
  /// Formatting named args that can be passed to a ```typst #text(..ref-text-pars)``` function call -> dictionary
  ref-text-pars: pkg-pars.fmt.text.ref,
  /// Separator (from previous content) -> content
  ref-sep: [#h(1fr)---],
  /// Formatting named args that can be passed to a ```typst #text(..quo-text-pars)``` function call -> dictionary
  quo-text-pars: pkg-pars.fmt.text.quo,
  /// Formatting named args that can be passed to a ```typst #highlight(..quo-highlight-pars)``` function call -> dictionary
  quo-highlight-pars: pkg-pars.fmt.highlight.blk,
  /// Smartquote parameters that can be passed to a ```typst #set smartquote(..quote-pars)``` function call -> dictionary
  quote-pars: pkg-pars.quo.at("def"),
  /// The opening quote -> content
  oquot: [],
  /// The closing quote -> content
  cquot: [],
  /// Formatting named args that can be passed to a ```typst #block(..quo-block-pars)``` function call -> dictionary
  quo-block-pars: pkg-pars.fmt.block.quo,
  /// Formatting named args that can be passed to a ```typst #block(..ref-block-pars)``` function call -> dictionary
  ref-block-pars: pkg-pars.fmt.block.ref,
) = {
  align(center,
    stack(dir: ttb,
      block(..quo-block-pars,
        align(left,
          quo-quot(
            body,
            quo-text-pars: quo-text-pars,
            quo-highlight-pars: quo-highlight-pars,
            quote-pars: quote-pars,
            oquot: oquot,
            cquot: cquot,
          )
        )
      ),
      block(..ref-block-pars,
        align(left,
          ref-bare(
            book-abbrev,
            passage,
            language-tradition: language-tradition,
            version: version,
            cite-label: cite-label,
            cite-pars: cite-pars, 
            ref-text-pars: ref-text-pars,
            ref-sep: ref-sep,
          )
        )
      )
    )
  )
  blindex(
    book-abbrev,
    passage,
    language-tradition: language-tradition,
  )
}

