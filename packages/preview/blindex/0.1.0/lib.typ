//============================================================================================//
//                                          Includes                                          //
//============================================================================================//

#import "./books.typ": iBoo, bSort
#import "./lang.typ": lDict

//============================================================================================//
//                                    Book Info Retrieving                                    //
//============================================================================================//

// abrv to dict -> dict
#let a2d(abrv, lang) = {
  let ret = ()
  for (KEY, VALUE) in lDict {
    let VAL = (abbr: VALUE.at(lang).at(0), full: VALUE.at(lang).at(1))
    if abrv == VAL.abbr {
      let SRT = (:)
      let BID = int(KEY)
      for SS in bSort.keys() {
        let DB = bSort.at(SS)
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
          "STDN": iBoo.at(KEY),   // Book's Standard Name (English)
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
#let blindex(abrv, lang, entry) = context [
  #metadata((
      ABRV: abrv,
      LANG: lang,
      DATA: a2d(abrv, lang),
      ENTR: entry,
      WHRE: here().position(),
    ))<bl_index>
]

// Index making. {BSS} is the Book Sorting Scheme, a key of the {bSort} dict, defined at
// "./books.typ" and written to <metadata>.<bl_index>.<instance>.at(i).at(bUID).DATA.SORT
#let mkIndex(
  cols: 2, gutter: 8pt, wgt: (bk: "bold", tx: "regular", pg: "extrabold"), pattern: [.],
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
          booHArr.push(__d.full) } } else { // Single book display
        booHArr.push(__r.DATA.at(0).full) }
      let booHead = if mbhf-join.len() > 1 {
        booHArr.join(mbhf-join.at(0), last: mbhf-join.at(1)) } else {
        booHArr.join(mbhf-join.at(0)) }
      let the_Key = if booSort != none { str(booSort + HUGE) } else { str(BIG + HUGE) }
      let the_Val = (__r.ENTR, __r.WHRE.page)
      // Populates idxDict
      if the_Key in idxDict {
        idxDict.at(the_Key).at(1).push(the_Val) } else {
        idxDict.insert(the_Key, (booHead, (the_Val,))) }
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

// Biblical Literature fill, for background
#let blFill = rgb("00000020") // Results in a transparent light gray

// "raw" Quoting of Biblical Literature
#let rQuot(body,
  tfmt: (font: "Linux Libertine", weight: "medium", lang: "en"),
  fill: true, quotes: true,
) = {
  if fill {
    if quotes { smartquote(double: true) }
    highlight(fill: blFill, text(..tfmt, body))
    if quotes { smartquote(double: true)} }
  else {
    if quotes { smartquote(double: true) }
    text(..tfmt, body)
    if quotes { smartquote(double: true)} }
}

// "line" Citation of Biblical Literature
#let lCite(abrv, lang, pssg, version, cited) = [
  --- #a2d(abrv, lang).at(0).full~#pssg (#version)~#cite(cited)]

// "inline" Quoting of Biblical Literature
#let iQuot(body, abrv, lang, pssg, version, cited,
  tfmt: (font: "Linux Libertine", weight: "medium", lang: "en"),
  fill: true, quotes: true,
) = {
  rQuot(body, tfmt: tfmt, fill: fill, quotes: quotes)
  lCite(abrv, lang, pssg, version, cited)
  blindex(abrv, lang, pssg)
}

// "block" Quoting of Biblical Literature
#let bQuot(body, abrv, lang, pssg, version, cited,
  tfmt: (font: "Linux Libertine", weight: "medium", lang: "en"),
  fill: true, quotes: false, width: 90%, inset: 4pt, fill-below: false,
) = {
  align(center,
    stack(dir: ttb,
      block(width: width,
        fill: if fill { blFill } else { none },
        inset: inset,
        align(left,
          par(leading: 0.65em, justify: true, linebreaks: "optimized",
            if quotes { [#smartquote(double: true)] } else { [] } +
            [#text(..tfmt, body)] +
            if quotes { [#smartquote(double: true)] } else { [] }
          )
        ),
      ),
      block(width: width,
        fill: if fill-below { blFill } else { none },
        inset: inset,
        align(right,
          lCite(abrv, lang, pssg, version, cited)
        )
      ),
      blindex(abrv, lang, pssg)
    )
  )
}



