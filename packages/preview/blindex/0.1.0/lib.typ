//============================================================================================//
//                                    Auxiliary Functions                                     //
//============================================================================================//

// Passage citation delimiter schemes
#let DELIM = (
  "pro":      " .,-;",   // As in "Gn 1.1,2,5–7; 12.1; etc." (Protestant, hyphen)
  "cat":      " ,.-;",   // As in "Gn 1,1.2.5-7; 12,1; etc." (Catholic, hyphen)
  "TOB":      " .,-;",   // As in "Gn 1.1,2,5-7; 12.1; etc." (TOB: Œcuménique, hyphen)
  "pro-en":   " .,-;",   // As in "Gn 1.1,2,5–7; 12.1; etc." (Protestant, en-dash)
  "cat-en":   " ,.-;",   // As in "Gn 1,1.2.5-7; 12,1; etc." (Catholic, en-dash)
  "TOB-en":   " .,-;",   // As in "Gn 1.1,2,5-7; 12.1; etc." (TOB: Œcuménique, en-dash)
)


//============================================================================================//
//                                Passage Formatting Functions                                //
//============================================================================================//

// Biblical Literature Index Entry
#let BLIE(st, to, DS: DELIM.pro-en) = {
  let DLC = DS.clusters() // Safe indexing with multi-byte codepoints
  let ret = ()
  ret.push(st.map(str).join(DLC.at(1)))
  if st.at(0) == to.at(0) {
    if to.at(1)-st.at(1) == 0 {} else {
      if to.at(1)-st.at(1) == 1 {
        ret.push(DLC.at(2))
      } else {
        ret.push(DLC.at(3))
      }
      ret.push(str(to.at(1)))
    }
  } else {
    ret.push(DLC.at(3))
    ret.push(to.map(str).join(DLC.at(1)))
  }
  return ret.join("")
}


//============================================================================================//
//                                    Book Info Retrieving                                    //
//============================================================================================//

// abrv to dict -> dict
#let a2d(abrv, lang) = {
  import "./lang/" + lang + ".typ": aDict
  import "./books.typ": iBoo, bSort
  let ret = ()
  for (KEY, VAL) in aDict {
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
#let blindex(abrv, lang, st, to, DS: DELIM.pro-en) = context [
  #metadata((
      ABRV: abrv,
      LANG: lang,
      DATA: a2d(abrv, lang),
      ENTR: BLIE(st, to, DS: DS),
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
    let __r = __e.value // __v is the record placed by blindex(...)
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


