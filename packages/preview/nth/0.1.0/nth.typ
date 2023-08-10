#let nth(ordinal-num) = {
  let ordinal-str = str(ordinal-num)
  if ordinal-str.contains(regex(".*1[0-9]"))
    show: ordinal-str + super("th")
  }
  else if ordinal-str.last() == "1" {
    show: ordinal-str + super("st")
  }
  else if ordinal-str.last() == "2" {
    show: ordinal-str + super("nd")
  }
  else if ordinal-str.last() == "3" {
    show: ordinal-str + super("rd")
  }
  else {
    show: ordinal-str + super("th")
  }
}
