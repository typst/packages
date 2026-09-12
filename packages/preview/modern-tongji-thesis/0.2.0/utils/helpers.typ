#set pagebreak(weak: true)

// New page — odd page if twoside
#let newpage(twoside: false) = if twoside { pagebreak(to: "odd") } else { pagebreak() }

// Chinese numeral — 1-30, "十" after 10
#let chinese-numeral(n) = {
  let digits = ("零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十")
  if n <= 10 {
    digits.at(n)
  } else if n < 20 {
    "十" + digits.at(n - 10)
  } else if n < 30 {
    digits.at(calc.quo(n, 10)) + "十" + if calc.rem(n, 10) != 0 { digits.at(calc.rem(n, 10)) }
  } else {
    str(n)
  }
}

// Circled number — matching LaTeX's HaranoAjiMincho strategy
#let circled-number(n) = {
  set text(font: ("Apple SD Gothic Neo", "HaranoAjiMincho"), fallback: true)
  if n >= 1 and n <= 20 {
    "①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳".clusters().at(n - 1)
  } else if n >= 21 and n <= 35 {
    "㉑㉒㉓㉔㉕㉖㉗㉘㉙㉚㉛㉜㉝㉞㉟".clusters().at(n - 21)
  } else if n >= 36 and n <= 50 {
    "㊱㊲㊳㊴㊵㊶㊷㊸㊹㊺㊻㊼㊽㊾㊿".clusters().at(n - 36)
  } else {
    let w = str(n).len()
    let s = if w <= 2 { 0.65 } else if w == 3 { 0.50 } else { 0.40 }
    box(
      width: 0.93em, height: 0.93em,
      stroke: 0.5pt,
      radius: 50%,
      inset: 0.2pt,
      baseline: 0.1em,
      align(center + horizon, scale(x: s * 100%, y: s * 100%, text(size: 1em, str(n)))),
    )
  }
}

// Cross-reference convenience commands
#let chapref(label) = [第@label章]
#let secref(label) = [第@label节]
#let figref(label) = [图@label]
#let tabref(label) = [表@label]
#let eqref(label) = [式@label]
#let algoref(label) = [算法@label]
