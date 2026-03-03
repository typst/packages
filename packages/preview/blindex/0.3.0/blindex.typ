//============================================================================================//
//                                          Includes                                          //
//============================================================================================//

#import "./books.typ": iboo, bsort
#import "./lang.typ": ldict

//============================================================================================//
//                                    Book Info Retrieving                                    //
//============================================================================================//

// abrv to dict -> dict
#let a2d(abrv, lang) = {
  let ret = ()
  for (KEY, VALUE) in ldict {
    let VAL = (abbr: VALUE.at(lang).at(0), full: VALUE.at(lang).at(1))
    if abrv == VAL.abbr {
      let SRT = (:)
      let BID = int(KEY)
      for SS in bsort.keys() {
        let DB = bsort.at(SS)
        let IDX = none
        for idx in range(DB.len()) {
          if DB.at(idx) == BID {
            IDX = idx
            break
          }
        }
        SRT.insert(SS, IDX)
      }
      ret.push((
          "BUID": KEY,            // Book's unique ID
          "lang": lang,           // Query's used {lang}
          "abrv": VAL.abbr,       // Query's used {abrv}
          "full": VAL.full,       // Book's full name
          "STDN": iboo.at(KEY),   // Book's Standard Name (English)
          "SORT": SRT,            // Book's index in existing sorting schemes
        )
      )
    }
  }
  return ret
}


//============================================================================================//
//                                Biblical Literature Indexing                                //
//============================================================================================//

// Biblical Literature Indexing
// The declaration spacing is to avoid spurious spacings in the document
#let blindex(abrv, lang, entry) = context [#metadata((
      ABRV: abrv,
      LANG: lang,
      DATA: a2d(abrv, lang),
      ENTR: entry,
      WHRE: here().position(),
    ))<bl_index>]

// Index making. {BSS} is the Book Sorting Scheme, a key of the {bsort} dict, defined at
// "./books.typ" and written to <metadata>.<bl_index>.<instance>.at(i).at(buid).DATA.SORT
#let mk-index(lang: "en-3",
  cols: 1, gutter: 8pt, wgt: (bk: "bold", tx: "regular", pg: "extrabold"), pattern: [.],
  merged-book-headings-full: true, mbhf-join: (" / ",),
  sorting-tradition: "Oecumenic-Bible", exclude-missing: false,
) = context {
  let BIG  =  100000
  let HUGE = 1000000
  let idxDict = (:)
  let rawList = query(<bl_index>) // An array of metadata
  for __e in rawList { // __e is a metadata entry
    let __r = __e.value // __r is the record placed by blindex(...)
    let booSort = __r.DATA.at(0).SORT.at(sorting-tradition)
    if (not exclude-missing) or (booSort != none) {
      let booHArr = () // Most generic book heading (as some are mergings)
      if (__r.DATA.len() > 1) and (merged-book-headings-full) { // Merged book display
        for __d in __r.DATA {
          booHArr.push(__d.full)
        }
      } else { // Single book display
        booHArr.push(ldict.at(__r.DATA.at(0).BUID).at(lang).at(1))
      }
      let booHead = if mbhf-join.len() > 1 {
        booHArr.join(mbhf-join.at(0), last: mbhf-join.at(1))
      } else {
        booHArr.join(mbhf-join.at(0))
      }
      let the_Key = if booSort != none { str(booSort + HUGE) } else { str(BIG + HUGE) }
      let the_Val = (__r.ENTR, __r.WHRE.page)
      // Populates idxDict
      if the_Key in idxDict {
        if the_Val not in idxDict.at(the_Key).at(1) {
          idxDict.at(the_Key).at(1).push(the_Val)
        }
      } else {
        idxDict.insert(the_Key, (booHead, (the_Val,)))
      }
    }
  }
  let sorKeys = idxDict.keys().sorted()
  columns(cols, gutter: gutter)[
    #for SK in sorKeys {
      text(weight: wgt.bk, idxDict.at(SK).at(0))
      linebreak()
      for VL in idxDict.at(SK).at(1) {
        box(width: 1.2em)
        text(weight: wgt.tx, VL.at(0)) // ENTRY
        box(width: 0.3em)
        box(width: 1fr, repeat(align(center, box(width: 0.5em, pattern))))
        box(width: 1.8em, align(center, text(weight: wgt.pg, [#VL.at(1)]))) // PAGE
        linebreak()
      }
    }
  ]
}


//============================================================================================//
//                                Biblical Literature Quoting                                 //
//============================================================================================//

//--------------------------------------------------------------------------------------------//
//                                       Quote Settings                                       //
//--------------------------------------------------------------------------------------------//

#let pkg-pars = (
  fmt: (
    ver: (
      font: ("Noto Sans", ),
      style: "normal",
      weight: "black",
      size: 0.6em,
    ),
    quo: (
      font: ("EB Garamond", "Libertinus Serif"),
      style: "normal",
      weight: "regular",
    ),
    cit: (
      font: ("Crimson Pro", "Libertinus Serif"),
      style: "normal",
      weight: "regular",
    ),
  ),
  quo: (
    double: true,
    enabled: true,
    alternative: false,
    quotes: (
      single: auto, // ("\u{2018}", "\u{2019}"),
      double: auto, // ("\u{201C}", "\u{201D}"),
    )
  ),
  bkg: (
    quo: rgb("D0D0D0FF"),
    cit: none,
  ),
)

//--------------------------------------------------------------------------------------------//
//                                      Quote Functions                                       //
//--------------------------------------------------------------------------------------------//

#let ver(body, fmt: pkg-pars.fmt.ver, spc: [#h(0.2em)]) = {
  box(baseline: fmt.size - 0.85em)[#text(..fmt)[#body#spc]]
}

// "raw" Quoting of Biblical Literature
#let rq(body,
        lan: "en",
        fmt: pkg-pars.fmt.quo,
        bkg: pkg-pars.bkg.quo,
        quo: pkg-pars.quo,
        opq: ["],
        clq: ["]) = {
  set text(lang: lan)
  set smartquote(..quo)
  [#opq#highlight(fill: bkg, text(..fmt)[#body])#clq]
}

// "line" Citation of Biblical Literature
#let lc(abrv, lang, pssg, version: none, cite: none,
        lan: "en",
        fmt: pkg-pars.fmt.cit,
        sep: [ ---]) = {
  set text(lang: lan)
  if version == none {
    text(..fmt)[#sep~#a2d(abrv, lang).at(0).full~#pssg#{if cite != none [ #cite]}]
  }
  else {
    text(..fmt)[#sep~#a2d(abrv, lang).at(0).full~#pssg (#version#{if cite != none [ #cite]})]
  }
}

// "inline" Quoting of Biblical Literature
#let iq(body, abrv, lang, pssg, version: none, cite: none, qlang: "en", clang: "en",
        quo: (fmt: pkg-pars.fmt.quo, bkg: pkg-pars.bkg.quo, quo: pkg-pars.quo, opq: ["], clq: ["]),
        cit: (fmt: pkg-pars.fmt.cit, )) = {
  rq(body, lan: qlang, ..quo)
  lc(abrv, lang, pssg, version: version, cite: cite, lan: clang, ..cit)
  blindex(abrv, lang, pssg)
}

// "block" Quoting of Biblical Literature
#let bq(body, abrv, lang, pssg, version: none, cite: none, qlang: "en", clang: "en",
        quo: (fmt: pkg-pars.fmt.quo, bkg: none, quo: pkg-pars.quo, opq: [], clq: []),
        cit: (fmt: pkg-pars.fmt.cit, ),
        blk: (wid: 90%, ins: 4pt, bkg: pkg-pars.bkg.quo, cit: pkg-pars.bkg.cit)) = {
  align(center,
    stack(dir: ttb,
      block(width: blk.wid, fill: blk.bkg, inset: blk.ins,
            align(left)[#rq(body, ..quo)]),
      block(width: blk.wid, fill: blk.cit, inset: blk.ins,
            align(right)[#lc(abrv, lang, pssg, version: version, cite: cite, ..cit, sep: [])]),
      blindex(abrv, lang, pssg)
    )
  )
}


