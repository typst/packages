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

// abbrv to id -> array
#let a2i(abbrv, lang) = {
  import "./lang/" + lang + ".typ": aDict
  let ret = ()
  for KV in aDict.pairs() {
    if abbrv == KV.at(1).at("abbr") {
      ret.push(int(KV.at(0)))
    }
  }
  return ret
}

// abbrv to name -> array
#let a2n(abbrv, lang) = {
  import "./lang/" + lang + ".typ": aDict
  let ret = ()
  for KV in aDict.pairs() {
    if abbrv == KV.at(1).at("abbr") {
      ret.push(KV.at(1).at("full"))
    }
  }
  return ret.join(" / ")
}

// abbrv to name -> string
#let a2n1(abbrv, lang) = {
  import "./lang/" + lang + ".typ": aDict
  for KV in aDict.pairs() {
    if abbrv == KV.at(1).at("abbr") {
      return KV.at(1).at("full")
    }
  }
  return none
}


