#let get-wuu-conter(loc, tones, data: none) = {
  if data == none {
    data = cbor("./wuu-pron-6.cbor")
  }
  let conter = data.at(loc).at(str(tones), default: none)
  if (conter == none) {
    return none
  }
  let conter = str(conter).split("9")
  if loc == "cs" and tones.len() == 3 and conter.len() == 2 {
    conter = (conter.first(), 0, conter.last())
  }
  return conter
}
