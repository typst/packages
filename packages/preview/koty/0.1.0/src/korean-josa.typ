#let _checkLastIsHangul(s) = {
  let sLast = s.last()
  let outbound = (sLast.to-unicode() < "가".to-unicode()) or (sLast.to-unicode() > "힣".to-unicode())
  if outbound { return false } else { true }
}

#let _hasJongseong(s) = {
  if _checkLastIsHangul(s) != true { return none }

  let uni = s.last().to-unicode()
  let jongseongIdx = calc.rem((uni - 44032), 28)

  if jongseongIdx != 0 { return true } else { return false }
}

#let _josaList = (
    ("을", "를"),
    ("은", "는"),
    ("이", "가"),
    ("과", "와"),
    ("이나", "나"),
    ("으로", "로"),
    ("아", "야"),
    ("이랑", "랑"),
    ("이며", "며"),
    ("이다", "다"),
    // '가' will only get resolved with 이 or 가 following the order of this list.
    // If you want to explicitly use 이가/가 check, use '이가' as param.
    ("이가", "가")
)

#let _findJosa(josa) = {
  let filtered = _josaList.find((josaGroup) => {
    if josaGroup.find((j) => j == josa) != none { return true } else { return false }
  })

  assert.ne(filtered.len(), 0, message: "Invalid josa type.")

  return filtered
}

#let _handleJosa(s, josa, concat: true) = {
  let filtered = _findJosa(josa)

  if type(s) == array {
    assert.eq(type(s.at(1)), bool)
    if concat == true {
      if s.at(1) == true { return s.at(0) + filtered.at(0) } else { return s.at(0) + filtered.at(1) }
    } else {
      if s.at(1) == true { return filtered.at(0) } else { return filtered.at(1) }
    }
  }

  if _checkLastIsHangul(s) != true {
    return if concat == true { s + josa } else { josa }
  }
  
  let resJosa = if _hasJongseong(s) { filtered.at(0) } else { filtered.at(1) }

  if concat == true {
    return s + resJosa
  } else {
    return resJosa
  }
}
