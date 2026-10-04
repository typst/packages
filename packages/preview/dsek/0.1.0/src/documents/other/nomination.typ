#import "../plain-document.typ": plain-document
#import "../../lib/_mod.typ": *

/// #set raw(lang: "typst")
/// Creates a nomination proposal (valförslag) document. Apply with `#show: valförslag.with(...)` or `#show: nomination-proposal.with(...)`.
///
/// - Candidates are grouped by position via the `candidates` dictionary and laid out in
///   two columns. Free-form content (headings, paragraphs) can be mixed in below them.
/// - Author signatures are appended automatically.
///
/// === Example
/// ```typst
/// #import "@preview/dsek:0.1.0": *
/// #import strings: valb
///
/// #show: valförslag.with(
///   title: "Nomineringar till Presidiet",
///   meeting: "S23",
///   candidates: (
///     "Ordförande": "Trula Teknolog",
///     "Vice Ordförande": "Truls Teknolog",
///     "posten Posten": (
///       "J. Doe",
///       "Nomen Nescio",
///       "[REDACTED]",
///     ),
///   ),
///   authors: (
///     // position defaults to "Sektionsmedlem" / "Guild member",
///     // message defaults to "Lund, dag som ovan" / "Lund, day as above"
///     (name: "Råsa Pantern", position: valb.ordf),
///   ),
///   stats: (
///     "Ordförande": [0 -- 4],
///     "Vice Ordförande": [5 -- 9],
///     "posten Posten": [250 -- 254],
///   ),
/// )
///
/// Dessa personer gjorde bättre ifrån sig på sina intervjuer än någon annan.
///
/// // extra space is inserted before this paragraph automatically
/// Med hänvisning till den utförliga motivationen ovan yrkar jag därmed på
/// - att välja in dessa tjommar till respektive post // becomes: *att* välja...
/// ```
///
/// - title (content): The title of the document, e.g. `[Nominering till HTM1]`.
/// - meeting (str, content): The meeting for which the document was written, e.g. `"HTM1"`.
/// - candidates (dict): Positions mapped to a nominee or a list of nominees, e.g.
///                      `("Ordförande": "Trula Teknolog", "Vice Ordförande": ("Truls", "Trula"))`.
/// - stats (dict, none): Optional applicant counts per position, rendered as a
///                       "Valstatistik"/"Selection statistics" appendix. Keys must match `candidates`.
/// - authors (array): Signatories. Each signatory dict must have at least the key `name`, optionally `message`, `position` and `signature`.
/// - lang (str): The language of the document (same format as `text.lang`).
///               Only "sv" and "en" are supported.
/// - date (datetime): The date at which the document was written.
/// - body (content): The body of the document.
///
/// -> content
#let nomination-proposal(
  title: none,
  meeting: none,
  authors: (),
  candidates: none,
  stats: none,
  lang: "sv",
  date: datetime.today(),
  body,
) = {
  required(title, "title", fn: "nomination-proposal", hint: "document title, e.g. title: \"Val av Utvecklare\"")
  required(meeting, "meeting", fn: "nomination-proposal", hint: "short meeting identifier, e.g. meeting: \"S12\"")
  required(
    candidates,
    "candidates",
    fn: "nomination-proposal",
    hint: "dict of position -> nominee or list of nominees, e.g `candidates: (\"Vice pubmästare\": (\"Truls\", \"Trula\"))`",
  )
  required(
    authors,
    "authors",
    fn: "nomination-proposal",
    hint: "list of author dicts, e.g. authors: ((name: \"Truls Teknolog\"),)",
  )

  let nomination-name = translate("Valförslag", "Nomination proposal")

  show: plain-document.with(
    title: title,
    doc-type: nomination-name,
    lang: lang,
    meeting: meeting,
    date: date,
  )
  show par: move-par
  set heading(numbering: none)

  let candidates = candidates.map(names => if type(names) != array { (names,) } else { names })

  columns(2, {
    let pairs = candidates.pairs()
    let half = int(calc.ceil(pairs.len() / 2))
    let render(entries) = {
      for (position, candidates) in entries [
        *#position* #if candidates.len() >= 4 [(#candidates.len()#context translate-str(" st", ""))]
        #for candidate in candidates [
          - #candidate
        ]
      ]
    }
    render(pairs.slice(0, half))
    colbreak()
    render(pairs.slice(half))
  })

  v(1em)
  body

  author-signatures(authors)

  if stats != none {
    assert(
      type(stats) == dictionary,
      message: "`stats` must be a dictionary of position -> number of applicants, e.g `(\"Vice pubmästare\": [0--4])`",
    )
    required-keys(
      stats,
      candidates.keys(),
      fn: "nomination-proposal",
      hint: "If providing applicant statistics, all positions must be accounted for",
    )
    context appendix(translate-str("Valstatistik", "Selection statistics"))[
      #translate-str(
        "Nedan presenteras antalet personer som genomgick valprocessen i intervall om storlek fem.",
        "The number of individuals who underwent the selection process is presented below in intervals of five.",
      )
      #v(1em)
      #columns(2)[
        #let pairs = stats.pairs()
        #let half = int(calc.ceil(pairs.len() / 2))
        #let render(entries) = {
          for (position, amount) in entries [
            *#position*: #amount #translate-str("st", "")
            #v(0.5em)
          ]
        }
        #render(pairs.slice(0, half))
        #colbreak()
        #render(pairs.slice(half))
      ]
    ]
  }
}

/// Swedish binding for `nomination-proposal`
#let valförslag = nomination-proposal
