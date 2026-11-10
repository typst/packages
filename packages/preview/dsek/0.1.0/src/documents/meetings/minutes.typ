#import "../plain-document.typ": plain-document
#import "../../lib/_mod.typ": *
#import "../../lib/utils/date.typ": custom-date-format

#let attendance(..names) = {
  show grid.cell: set par(justify: false)
  grid(
    columns: (auto, auto, 1fr, auto),
    align: (auto, auto, auto, right),
    row-gutter: 0.55em,
    column-gutter: 1em,
    stroke: none,
    ..names
      .pos()
      .enumerate()
      .map(xi => {
        let (i, name-pos) = xi
        let (name, position, when) = if type(name-pos) == array {
          if (name-pos.len() == 1) {
            (..name-pos, none, (:))
          } else if (name-pos.len() == 2) {
            if type(name-pos.at(1)) == dictionary {
              required-keys(name-pos.at(1), (), allowed: ("from", "to"), fn: "attendance")
              (name-pos.at(0), none, name-pos.at(1))
            } else {
              (..name-pos, (:))
            }
          } else if (name-pos.len() == 3) {
            required-keys(name-pos.at(2), (), allowed: ("from", "to"), fn: "attendance")
            name-pos
          } else {
            assert(
              name-pos.len() <= 3,
              message: "attendance: attendee entry has "
                + str(name-pos.len())
                + " elements, expected at most 3\n  hint: each entry is either just a name, (name, position) or (name, position, (from?: ..., to?: ...)), e.g."
                + "\n   - \"Truls Teknolog\" "
                + "\n   - (\"Truls Teknolog\", \"Kårkontakt\") "
                + "\n   - (\"Truls Teknolog\", \"Kårkontakt\", (from: [@tmfö]))",
              +"\n   - (\"Truls Teknolog\", \"Kårkontakt\", (to: [@utskottsrapporter]))",
              +"\n   - (\"Truls Teknolog\", \"Kårkontakt\", (from: [@tmfö], to: [@utskottsrapporter]))",
            )
            name-pos
          }
        } else {
          (name-pos, none, (:))
        }

        (
          if i == 0 [*#translate("Närvaro", "Attendance"):*],
          context [
            // q) why headings?
            // a) you can pass along hidden data with supplement
            // meaning you can access mandates directly from the reference :)
            // also you can make it behave exactly like text
            #show heading: set text(font: text.font, weight: text.weight, size: text.size)
            #set heading(depth: ref-id.person, numbering: none, outlined: false)
            #heading(name, supplement: position) #label(to-label(name))
          ],
          position,
          {
            let (from, to) = (when.at("from", default: none), when.at("to", default: none))
            context [
              #if (from, to) != (none, none) { translate-str("närvarande", "present") }
              #if from != none and to == none [
                #translate-str("fr.o.m", "from") #from
              ] else if from == none and to != none [
                #translate-str("t.o.m", "until") #to
              ] else if from != none and to != none [
                #from -- #to
              ] else []
            ]
          },
          // if when.len() == 0 [] else [
          //   #box(width: 1.5em, align(right, when.at("from", default: none)))
          //   #sym.dash.en
          //   #box(width: 1.5em, align(left, when.at("to", default: none)))
          // ],
        )
      })
      .flatten()
  )
}

/// #set raw(lang: "typst")
/// Creates a meeting minutes (protokoll) document. Apply with `#show: protokoll.with(...)` or `#show: minutes.with(...)`.
///
/// === Notes
/// - The body uses `/ Term: description` syntax where each term is an agenda item title and the
///   description is the item text. Inside an item, term items are formatted normally.
/// - Items are automatically numbered as §1, §2, … and can be cross-referenced with
///   `@item` (resolves to "§N") or `@item[]` (resolves to "§N Item").
/// - Attendees are auto-labelled so they can be referenced with `@name` or `@name[]`
///   (to include position) anywhere in the document.
///
/// === Example:
/// ```typst
/// #import "@preview/dsek:0.1.0": *
/// #import strings: infu, styr
///
/// #show: protokoll.with(
///   meeting: "S06",
///   attendees: (
///     ("Truls Teknolog", styr.ordf),
///     ("Trula Teknolog", infu.ansv),
///     ("Råsa Pantern", "Sektionsmaskot", (from: [@tid-och-sätt], to: [@val-av-justerare])),
///     "Pelle Postlös", // name only, no position
///   ),
///   attested: false, // default; set to true to remove watermark
///   chair: [@trulsteknolog],
///   secretary: [@trulateknolog],
///   reviewers: ([@pellepostlös],), // one or more
/// )
///
/// / OFMÖ:
///   @trulsteknolog[] förklarade mötet öppnat 12:15. // Ordförande Truls Teknolog förklarade...
///
/// / Tid och sätt:
///   Tid och sätt godkändes.
///
/// / Val av justerare:
///   Mötet beslöt
///   - att välja @pellepostlös till justerare // *att* välja Pelle Postlös till...
///
/// / Information från kollegierna:
///   / InfoK: Ingen ny information. // normal terms
///
/// / Veckans roliga punkt:
///   @trulateknolog drog en ordvits.
///
/// / Uppföljning\: Veckans roliga punkt:
///
///   @pellepostlös yrkade på
///   - att stryka @veckans-roliga-punkt från protokollet
///   Mötet avslog yrkandet.
///
///   @trulateknolog yrkade på
///   - att åligga @pellepostlös att "komma på något bättre själv då" med uppföljning till nästa styrelsemöte.
///   Mötet biföll yrkandet.
///
/// / OFMA:
///   @trulsteknolog förklarade mötet avslutat 12:18
///
/// Efter mötet såg beslutsuppföljningslistan ut enligt följande:
///
/// #followup(
///   ("S03", [Hitta den försvunna sektionsdiamanten], [Råsa Pantern], "HTM1"),
///   ("S06", [Kom på en bättre ordvits än Trula], [@pellepostlös], "S07"),
/// )
/// ```
///
/// - meeting (str, content): The meeting for which the document was written, e.g. `"HTM1"`.
/// - attendees (array): Attendee list. Each entry is a `name` string/content,
///                      or a 2-element `(name, position)` array. Positions can be entered manually or taken
///                      from the `strings` module.
/// - chair (content): Meeting chair, shown in the signature block.
/// - secretary (content): Meeting secretary, shown in the signature block.
/// - reviewers (array): Optional minute reviewers, shown in the signature block.
/// - meeting-type (content, auto): The type of meeting, e.g. `"Styrelsemöte"` or `"Studierådsmöte"`.
///                                 If set to `auto`, the meeting type is detected from the the `meeting`
///                                 parameter -- `SXX` gives "Styrelsemöte" and `SRDXX` gives "Studierådsmöte"
///                                 (where `X` is a digit).
/// - attested (bool): Shows "OJUSTERAT"/"UNATTESTED" watermark when `false`.
/// - lang (str): The language of the document (same format as `text.lang`).
///               Only "sv" and "en" are supported.
/// - date (datetime): The date at which the document was written.
/// - body (content): The body of the document.
///
/// -> content
#let minutes(
  meeting: none,
  attendees: (),
  chair: none,
  secretary: none,
  reviewers: (),
  meeting-type: auto,
  attested: false,
  lang: "sv",
  date: datetime.today(),
  body,
) = context {
  required(meeting, "meeting", fn: "minutes", hint: "short meeting identifier, e.g. meeting: \"HTM1\"")
  required(
    attendees,
    "attendees",
    fn: "minutes",
    hint: "array of (name, position) pairs, e.g. ((\"Truls Teknolog\", \"Kårkontakt\"),)",
  )
  assert(
    type(attendees) == array,
    message: "minutes: `attendees` must be an array, not "
      + str(type(attendees))
      + "\n  hint: each entry is (name, position) or just a name, e.g. (\"Truls Teknolog\", \"Kårkontakt\") or just \"Truls Teknolog\"",
  )
  required(chair, "chair", fn: "minutes")
  required(secretary, "secretary", fn: "minutes")

  let check-presiders(author) = if type(author) == dictionary {
    required-keys(
      author,
      ("name",),
      allowed: ("name", "position", "message", "signature"),
      fn: "author-signatures",
      hint: "each author dict needs at least `name`, e.g. (name: \"Truls Teknolog\", position: \"Gammal och dryg\") -- `position`, `message`, and `signature` are optional (but have default values)",
    )
    author
  } else {
    (name: author)
  }

  let chair = check-presiders(chair)
  let secretary = check-presiders(secretary)

  let watermark = if not attested {
    set align(center + horizon)
    show rotate: set block(width: 150%)
    rotate(-45deg, text(
      size: 100pt,
      fill: luma(93%),
      weight: "bold",
      translate("OJUSTERAT", "UNATTESTED"),
    ))
  }

  set page(background: watermark)

  let reviewers = if type(reviewers) == array { reviewers } else { (reviewers,) }
  let minutes-name = translate("Protokoll", "Meeting minutes")
  let meeting-time = custom-date-format(date, pattern: "long", lang: lang)
  let meeting-type = detect-meeting-type(meeting, meeting-type)

  show terms: minutes-fmt
  show: plain-document.with(
    title: [#minutes-name #translate("för", "of") #meeting-type #meeting, #meeting-time],
    doc-type: minutes-name,
    meeting: meeting,
    lang: lang,
    date: date,
  )

  set document(title: [#minutes-name #meeting], author: to-text(secretary))

  attendance(..attendees)
  v(2em)
  body
  v(1em)

  table(
    stroke: none,
    columns: 4,
    row-gutter: 2em,
    signature(
      translate("Vid protokollet", "Recorded by"),
      secretary.name,
      translate("Mötessekreterare", "Meeting secretary"),
      image: secretary.at("signature", default: none),
    ),
    signature(
      translate("Vid mötet", "Presided by"),
      chair.name,
      translate("Mötesordförande", "Meeting chair"),
      image: chair.at("signature", default: none),
    ),
    ..reviewers.map(reviewer => context {
      signature(
        translate("Justeras", "Attested by"),
        reviewer,
        translate("Justerare", "Minute reviewer"),
      )
    }),
  )
}

/// Swedish binding for `minutes`
#let protokoll = minutes
