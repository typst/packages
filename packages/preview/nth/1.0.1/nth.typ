#let nth(ordinal-num, sup: bool) = {
  // Conditinally define ordinal-num, and if it's an integer change it to a string
  let ordinal-str = if type(ordinal-num) == int {
    str(ordinal-num)
  } else {
    ordinal-num
  }
  // Main if-else tree for this function
  let ordinal-suffix = if ordinal-str.ends-with(regex("1[0-9]")) {
    "th"
  } else if ordinal-str.last() == "1" {
    "st"
  } else if ordinal-str.last() == "2" {
    "nd"
  } else if ordinal-str.last() == "3" {
    "rd"
  } else {
    "th"
  }
  // Check whether sup attribute is set, and if so return suffix superscripted
  if sup == true {
    return ordinal-str + super(ordinal-suffix)
  } else {
    return ordinal-str + ordinal-suffix
  }
}

// define nths function, which is just nth with sup attribute applied
#let nths(ordinal) = {
  nth(ordinal, sup: true)
}
