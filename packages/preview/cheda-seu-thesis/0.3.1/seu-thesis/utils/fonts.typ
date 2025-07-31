#let 字号 = (
  初号: 42pt,
  小初: 36pt,
  一号: 26pt,
  小一: 24pt,
  二号: 22pt,
  小二: 18pt,
  三号: 16pt,
  小三: 15pt,
  四号: 14pt,
  中四: 13pt,
  小四: 12pt,
  五号: 10.5pt,
  小五: 9pt,
  六号: 7.5pt,
  小六: 6.5pt,
  七号: 5.5pt,
  小七: 5pt,
)

#let 字体 = (
  仿宋: ("Times New Roman", "FangSong", "STFangSong"),
  宋体: ("Times New Roman", "SimSun"),
  黑体: ("Times New Roman", "SimHei"),
  //标题黑体: ("SimHei"),
  标题宋体: ("Times New Roman", "STZhongsong", "SimSun"),
  楷体: ("Times New Roman", "KaiTi"),
  代码: ("New Computer Modern Mono", "Times New Roman", "SimSun"),
)

#let ziti = 字体
#let zihao = 字号

#let chineseunderline(s, width: 300pt, bold: false) = {
  // 来自 pku-thesis
  let chars = s.clusters()
  let n = chars.len()
  context {
    let i = 0
    let now = ""
    let ret = ()

    while i < n {
      let c = chars.at(i)
      let nxt = now + c

      if measure(nxt).width > width or c == "\n" {
        if bold {
          ret.push(text(weight: "bold", now))
        } else {
          ret.push(now)
        }
        ret.push(v(-par.spacing))
        ret.push(line(start: (0em,  par.spacing/3), length: 100%, stroke: (thickness: 0.5pt)))
        if c == "\n" {
          now = ""
        } else {
          now = c
        }
      } else {
        now = nxt
      }

      i = i + 1
    }

    if now.len() > 0 {
      if bold {
        ret.push(strong(now))
      } else {
        ret.push(now)
      }
      ret.push(v(-par.spacing))
      ret.push(line(start: (0em, par.spacing/3),length: 100%, stroke: (thickness: 0.5pt)))
    }

    ret.join()
  }
}

#let justify-words(s, width: auto) = {
  assert(type(s) == str and s.clusters().len() >= 2)
  context {
    let measure-width = measure(s).width
    let expected-width = if width == auto {
      0pt
    } else if type(width) in (str, content) {
      measure(width).width.to-absolute()
    } else if type(width) == length {
      width.to-absolute()
    }
    let spacing = if measure-width > expected-width {
      0pt
    } else {
      (expected-width - measure-width) / (s.clusters().len() - 1)
    }
    text(tracking: spacing, s)
  }
}