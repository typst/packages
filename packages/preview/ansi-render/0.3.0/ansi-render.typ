// add your theme here!
#let terminal-themes = (
  // vscode terminal theme
  vscode: (
    black: rgb(0, 0, 0),
    red: rgb(205, 49, 49),
    green: rgb(13, 188, 121),
    yellow: rgb(229, 229, 16),
    blue: rgb(36, 114, 200),
    magenta: rgb(188, 63, 188),
    cyan: rgb(17, 168, 205),
    white: rgb(229, 229, 229),
    gray: rgb(102, 102, 102),
    bright-red: rgb(214, 76, 76),
    bright-green: rgb(35, 209, 139),
    bright-yellow: rgb(245, 245, 67),
    bright-blue: rgb(59, 142, 234),
    bright-magenta: rgb(214, 112, 214),
    bright-cyan: rgb(41, 184, 219),
    bright-white: rgb(229, 229, 229),
    default-text: rgb(229, 229, 229), // white
    default-bg: rgb(0, 0, 0), // black
  ),

  // putty terminal theme
  putty: (
    black: rgb(0, 0, 0),
    red: rgb(187, 0, 0),
    green: rgb(0, 187, 0),
    yellow: rgb(187, 187, 0),
    blue: rgb(0, 0, 187),
    magenta: rgb(187, 0, 187),
    cyan: rgb(0, 187, 187),
    white: rgb(187, 187, 187),
    gray: rgb(85, 85, 85),
    bright-red: rgb(255, 0, 0),
    bright-green: rgb(0, 255, 0),
    bright-yellow: rgb(255, 255, 0),
    bright-blue: rgb(0, 0, 255),
    bright-magenta: rgb(255, 0, 255),
    bright-cyan: rgb(0, 255, 255),
    bright-white: rgb(255, 255, 255),
    default-text: rgb(187, 187, 187), // white
    default-bg: rgb(0, 0, 0), // black
  ),

  // themes from Windows Terminal
  campbell: (
    black: rgb("#0C0C0C"),
    red: rgb("#C50F1F"),
    green: rgb("#13A10E"),
    yellow: rgb("#C19C00"),
    blue: rgb("#0037DA"),
    magenta: rgb("#881798"),
    cyan: rgb("#3A96DD"),
    white: rgb("#CCCCCC"),
    gray: rgb("#767676"),
    bright-red: rgb("#E74856"),
    bright-green: rgb("#16C60C"),
    bright-yellow: rgb("#F9F1A5"),
    bright-blue: rgb("#3B78FF"),
    bright-magenta: rgb("#B4009E"),
    bright-cyan: rgb("#61D6D6"),
    bright-white: rgb("#F2F2F2"),
    default-text: rgb("#CCCCCC"),
    default-bg: rgb("#0C0C0C"),
  ),

  campbell-powershell: (
    black: rgb("#0C0C0C"),
    red: rgb("#C50F1F"),
    green: rgb("#13A10E"),
    yellow: rgb("#C19C00"),
    blue: rgb("#0037DA"),
    magenta: rgb("#881798"),
    cyan: rgb("#3A96DD"),
    white: rgb("#CCCCCC"),
    gray: rgb("#767676"),
    bright-red: rgb("#E74856"),
    bright-green: rgb("#16C60C"),
    bright-yellow: rgb("#F9F1A5"),
    bright-blue: rgb("#3B78FF"),
    bright-magenta: rgb("#B4009E"),
    bright-cyan: rgb("#61D6D6"),
    bright-white: rgb("#F2F2F2"),
    default-text: rgb("#CCCCCC"),
    default-bg: rgb("#012456"),
  ),

  vintage: (
    black: rgb("#000000"),
    red: rgb("#800000"),
    green: rgb("#008000"),
    yellow: rgb("#808000"),
    blue: rgb("#000080"),
    magenta: rgb("#800080"),
    cyan: rgb("#008080"),
    white: rgb("#C0C0C0"),
    gray: rgb("#808080"),
    bright-red: rgb("#FF0000"),
    bright-green: rgb("#00FF00"),
    bright-yellow: rgb("#FFFF00"),
    bright-blue: rgb("#0000FF"),
    bright-magenta: rgb("#FF00FF"),
    bright-cyan: rgb("#00FFFF"),
    bright-white: rgb("#FFFFFF"),
    default-text: rgb("#C0C0C0"),
    default-bg: rgb("#000000"),
  ),

  one-half-dark: (
    black: rgb("#282C34"),
    red: rgb("#E06C75"),
    green: rgb("#98C379"),
    yellow: rgb("#E5C07B"),
    blue: rgb("#61AFEF"),
    magenta: rgb("#C678DD"),
    cyan: rgb("#56B6C2"),
    white: rgb("#DCDFE4"),
    gray: rgb("#5A6374"),
    bright-red: rgb("#E06C75"),
    bright-green: rgb("#98C379"),
    bright-yellow: rgb("#E5C07B"),
    bright-blue: rgb("#61AFEF"),
    bright-magenta: rgb("#C678DD"),
    bright-cyan: rgb("#56B6C2"),
    bright-white: rgb("#DCDFE4"),
    default-text: rgb("#DCDFE4"),
    default-bg: rgb("#282C34"),
  ),

  one-half-light: (
    black: rgb("#383A42"),
    red: rgb("#E45649"),
    green: rgb("#50A14F"),
    yellow: rgb("#C18301"),
    blue: rgb("#0184BC"),
    magenta: rgb("#A626A4"),
    cyan: rgb("#0997B3"),
    white: rgb("#FAFAFA"),
    gray: rgb("#4F525D"),
    bright-red: rgb("#DF6C75"),
    bright-green: rgb("#98C379"),
    bright-yellow: rgb("#E4C07A"),
    bright-blue: rgb("#61AFEF"),
    bright-magenta: rgb("#C577DD"),
    bright-cyan: rgb("#56B5C1"),
    bright-white: rgb("#FFFFFF"),
    default-text: rgb("#383A42"),
    default-bg: rgb("#FAFAFA"),
  ),

  solarized-dark: (
    black: rgb("#002B36"),
    red: rgb("#DC322F"),
    green: rgb("#859900"),
    yellow: rgb("#B58900"),
    blue: rgb("#268BD2"),
    magenta: rgb("#D33682"),
    cyan: rgb("#2AA198"),
    white: rgb("#EEE8D5"),
    gray: rgb("#073642"),
    bright-red: rgb("#CB4B16"),
    bright-green: rgb("#586E75"),
    bright-yellow: rgb("#657B83"),
    bright-blue: rgb("#839496"),
    bright-magenta: rgb("#6C71C4"),
    bright-cyan: rgb("#93A1A1"),
    bright-white: rgb("#FDF6E3"),
    default-text: rgb("#839496"),
    default-bg: rgb("#002B36"),
  ),

  solarized-light: (
    black: rgb("#002B36"),
    red: rgb("#DC322F"),
    green: rgb("#859900"),
    yellow: rgb("#B58900"),
    blue: rgb("#268BD2"),
    magenta: rgb("#D33682"),
    cyan: rgb("#2AA198"),
    white: rgb("#EEE8D5"),
    gray: rgb("#073642"),
    bright-red: rgb("#CB4B16"),
    bright-green: rgb("#586E75"),
    bright-yellow: rgb("#657B83"),
    bright-blue: rgb("#839496"),
    bright-magenta: rgb("#6C71C4"),
    bright-cyan: rgb("#93A1A1"),
    bright-white: rgb("#FDF6E3"),
    default-text: rgb("#657B83"),
    default-bg: rgb("#FDF6E3"),
  ),

  tango-dark: (
    black: rgb("#000000"),
    red: rgb("#CC0000"),
    green: rgb("#4E9A06"),
    yellow: rgb("#C4A000"),
    blue: rgb("#3465A4"),
    magenta: rgb("#75507B"),
    cyan: rgb("#06989A"),
    white: rgb("#D3D7CF"),
    gray: rgb("#555753"),
    bright-red: rgb("#EF2929"),
    bright-green: rgb("#8AE234"),
    bright-yellow: rgb("#FCE94F"),
    bright-blue: rgb("#729FCF"),
    bright-magenta: rgb("#AD7FA8"),
    bright-cyan: rgb("#34E2E2"),
    bright-white: rgb("#EEEEEC"),
    default-text: rgb("#D3D7CF"),
    default-bg: rgb("#000000"),
  ),

  tango-light: (
    black: rgb("#000000"),
    red: rgb("#CC0000"),
    green: rgb("#4E9A06"),
    yellow: rgb("#C4A000"),
    blue: rgb("#3465A4"),
    magenta: rgb("#75507B"),
    cyan: rgb("#06989A"),
    white: rgb("#D3D7CF"),
    gray: rgb("#555753"),
    bright-red: rgb("#EF2929"),
    bright-green: rgb("#8AE234"),
    bright-yellow: rgb("#FCE94F"),
    bright-blue: rgb("#729FCF"),
    bright-magenta: rgb("#AD7FA8"),
    bright-cyan: rgb("#34E2E2"),
    bright-white: rgb("#EEEEEC"),
    default-text: rgb("#555753"),
    default-bg: rgb("#FFFFFF"),
  ),
)

// ansi rendering function
#let ansi-render(body, font: "Cascadia Code", size: 10pt, radius: 3pt,theme: terminal-themes.solarized-light) = {
  // dict with text style
  let match-text = (
    "1": (weight: "bold"),
    "3": (style: "italic"),
    "23": (style: "normal"),
    "30": (fill: theme.black),
    "31": (fill: theme.red),
    "32": (fill: theme.green),
    "33": (fill: theme.yellow),
    "34": (fill: theme.blue),
    "35": (fill: theme.magenta),
    "36": (fill: theme.cyan),
    "37": (fill: theme.white),
    "39": (fill: theme.default-text),
    "90": (fill: theme.gray),
    "91": (fill: theme.bright-red),
    "92": (fill: theme.bright-green),
    "93": (fill: theme.bright-yellow),
    "94": (fill: theme.bright-blue),
    "95": (fill: theme.bright-magenta),
    "96": (fill: theme.bright-cyan),
    "97": (fill: theme.bright-white),
    "default": (weight: "regular", style: "normal", fill: theme.default-text)
  )
  // dict with background style
  let match-bg = (
    "40": (fill: theme.black),
    "41": (fill: theme.red),
    "42": (fill: theme.green),
    "43": (fill: theme.yellow),
    "44": (fill: theme.blue),
    "45": (fill: theme.magenta),
    "46": (fill: theme.cyan),
    "47": (fill: theme.white),
    "49": (fill: theme.default-bg),
    "100": (fill: theme.gray),
    "101": (fill: theme.bright-red),
    "102": (fill: theme.bright-green),
    "103": (fill: theme.bright-yellow),
    "104": (fill: theme.bright-blue),
    "105": (fill: theme.bright-magenta),
    "106": (fill: theme.bright-cyan),
    "107": (fill: theme.bright-white),
    "default": (fill: theme.default-bg)
  )

  let match-options(opt) = {
    // parse 38;5 48;5
    let parse-8bit-color(num) = {
      num = int(num)
      let colors = (0, 95, 135, 175, 215, 255)
      if num <= 7 { match-text.at(str(num+30)) }
      else if num <= 15 { match-bg.at(str(num+32)) }
      else if num <= 231 {
        num -= 16
        let (r, g, b) = (colors.at(int(num/36)), colors.at(calc.rem(int(num/6),6)), colors.at(calc.rem(num,6)))
        (fill: rgb(r, g, b))
      } else {
        num -= 232
        let (r, g, b) = (8+10*num, 8+10*num, 8+10*num)
        (fill: rgb(r, g, b))
      }
    }

    let (opt-text, opt-bg) = ((:), (:))
    let (ul, ol, reverse, last) = (none, none, none, none)
    let count = 0
    let color = (0, 0, 0)

    // match options
    for i in opt {
      if last == "382" or last =="482" {
        color.at(count) = int(i)
        count += 1
        if count == 3 {
          if last == "382" { opt-text += (fill: rgb(..color)) }
          else { opt-bg += (fill: rgb(..color)) }
          count = 0
          last = none
        }
        continue
      }
      else if last == "385" {
        opt-text += parse-8bit-color(i)
        last = none
        continue
      }
      else if last == "485" {
        opt-bg += parse-8bit-color(i)
        last = none
        continue
      }
      else if i == "0" {
        opt-text += match-text.default
        opt-bg += match-bg.default
        ul = false
        ol = false
        reverse = false
      }
      else if i in match-bg.keys() { opt-bg += match-bg.at(i) }
      else if i in match-text.keys() { opt-text += match-text.at(i) }
      else if i == "4" { ul = true }
      else if i == "24" { ul = false }
      else if i == "53" { ol = true }
      else if i == "55" { ol = false }
      else if i == "7" { reverse = true }
      else if i == "27" { reverse = false }
      else if i == "38" or i == "48" {
        last = i
        continue
      }
      else if i == "2" or i == "5" {
        if last == "38" or last == "48" {
          last += i
          count = 0
          continue
        }
      }
      last = none
    }
    (text: opt-text, bg: opt-bg, ul: ul, ol: ol, reverse: reverse)
  }

  let parse-option(body) = {
    let arr = ()
    let cur = 0
    for map in body.matches(regex("\x1b\[([0-9;]*)m([^\x1b]*)")) {
      // loop through all matches
      let str = map.captures.at(1)
      // split the string by newline and preserve newline
      let split = str.split("\n")
      for (k, v) in split.enumerate() {
        if k != split.len()-1 {
          v = v + "\n"
        }
        let temp = (v, ())
        for option in map.captures.at(0).split(";") {
          temp.at(1).push(option)
        }
        arr.push(temp)
      }
      cur += 1
    }
    arr
  }

  set text(..(match-text.default), font: font, size: size, top-edge: "ascender", bottom-edge: "descender")
  set par(leading: 0em)

  let option = (
    text: match-text.default,
    bg: match-bg.default,
    ul: false,
    ol: false,
    reverse: false
  )
  show: c => rect(..(match-bg.default), radius: radius, c)
  // work around for rendering first line without escape sequence
  body = "\u{1b}[0m" + body
  for (str, opt) in parse-option(body) {
    let m = match-options(opt)
    option.text += m.text
    option.bg += m.bg
    if m.reverse != none { option.reverse = m.reverse }
    if option.reverse {
      (option.text.fill, option.bg.fill) = (option.bg.fill, option.text.fill)
    }
    if m.ul != none { option.ul = m.ul }
    if m.ol != none { option.ol = m.ol }

    // hack for under/overline trailing whitespace
    str = str.replace(regex("([ \t]+)$"), m => m.captures.at(0) + "\u{200b}")
    {
      show: c => box(..option.bg, c)
      show: c => text(..option.text, c)
      show: c => if option.ul {
        underline(c)
      } else {
        c
      }
      show: c => if option.ol {
        overline(c)
      } else {
        c
      }
      [#str]
    }
    // fill trailing newlines
    let s = str.find(regex("\n+$"))
    if s != none {
      for i in s {
        linebreak()
      }
    }
  }
}
