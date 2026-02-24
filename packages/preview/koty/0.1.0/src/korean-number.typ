#let _largeDigits = ("", "만", "억", "조", "경", "해", "자")
#let _smallDigits = ("", "십", "백", "천")

#let _processKilo(arr, fullKo: false) = {
  let _koNumbers = ("", "일", "이", "삼", "사", "오", "육", "칠", "팔", "구")
  let intValue = int(arr.rev().sum())
  if intValue == 0 {
    return none
  }
  if fullKo == true {
    let res = ()
    let strArr = str(intValue).clusters().rev().zip(_smallDigits)
    for (d, u) in strArr {
      if d != "0" { res.push(_koNumbers.at(int(d)) + u) }
    }
    return res.rev().join("")
  }
  return str(intValue)
}

#let _handleKoNumber(n, full-ko: false, join-str: " ") = {
  let sanitized = str(n).split(".").at(0)

  if n == 0 { if full-ko { return "영" } else { return "0" }}

  let strGroups = sanitized.clusters().rev().chunks(4).rev()
  let processed = ()
  for (idx, i) in strGroups.enumerate() {
    let groupStr = _processKilo(i, fullKo: full-ko)
    if groupStr == none {
      continue
    }
    let res = groupStr + _largeDigits.slice(0, count: strGroups.len()).rev().at(idx)
    processed.push(res)
  }
  return processed.join(join-str)
}
