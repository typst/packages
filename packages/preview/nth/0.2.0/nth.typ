#let nth(ordinal-num) = {
  let ordinal-str = str(ordinal-num)
  let ordinal-suffix = if ordinal-str.ends-with(regex("1[0-9]")) {
    "th"
  }
  else if ordinal-str.last() == "1" {
    "st"
  }
  else if ordinal-str.last() == "2" {
    "nd"
  }
  else if ordinal-str.last() == "3" {
    "rd"
  }
  else {
    "th"
  }
  ordinal-str + super(ordinal-suffix)
}
