//============================================================================================//
//                                    Auxiliary Functions                                     //
//============================================================================================//

// Passage citation delimiter schemes
#let DELIM = (
  "pro": " .,–;",   // As in "Gn 1.1,2,5–7; 12.1; etc." (Protestant, en-dash)
  "cat": " ,.-;",   // As in "Gn 1,1.2.5-7; 12,1; etc." (Catholic, hyphen)
  "TOB": " .,-;",   // As in "Gn 1.1,2,5-7; 12.1; etc." (TOB: Œcuménique, hyphen)
)


//============================================================================================//
//                                Passage Formatting Functions                                //
//============================================================================================//

// Biblical Literature Index Entry
#let BLIE(st, to, DS: DELIM.pro) = {
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
  let ret = (:)
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
      ret.insert(KEY, (
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

// Biblical indexing
/*
#let blindex(abrv, lang, st, to, DS: DELIM.pro) = context [
  #metadata((
      ABRV: abrv,
      LANG: lang,
      BKID: a2i(abrv, lang),
      BNAM: a2n1(abrv, lang),
      BLST: a2n(abrv, lang),
      ENTR: BLIE(st, to, DS),
      WHRE: here().position(),
    ))<cnbi_index>
]
*/




