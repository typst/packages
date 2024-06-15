//============================================================================================//
//                                    Auxiliary Functions                                     //
//============================================================================================//

// Passage citation delimiters
#let DELIM = (
  "pro": " .,–;",   // As in "Gn 1.1,2,5–7; 12.1; etc." (Protestant, en-dash)
  "cat": " ,.-;",   // As in "Gn 1,1.2.5-7; 12,1; etc." (Catholic, hyphen)
  "TOB": " .,-;",   // As in "Gn 1.1,2,5-7; 12.1; etc." (TOB: Œcuménique, hyphen)
)
// Strings with multi-byte code-points can be safely indexed with the `clusters()` function.


//============================================================================================//
//                                Passage Formatting Functions                                //
//============================================================================================//

// Biblical Literature Index Entry
#let BLIE(st, to, DS: DELIM.pro) = {
  let DLC = DS.clusters()
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

// abbrv to id
#let a2i(abbrv, lang) = {
}

