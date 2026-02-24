#import "../../tools/miscellaneous.typ": content-to-string
#let numbered(content) = {
  set text(10pt)

  set heading(numbering: "I)1)a)i)")

  show heading: it => {
    if content-to-string(it) == "audhzifoduiygzbcjlxmwmwpadpozieuhgb" {
      return none
    }
    set par(spacing: 15pt)
    if it.numbering != none {
      let n = it.level - 1
      set text(size: 15pt - 1pt * n)

      block(
        sticky: true,
        h(1cm * n)
          + underline([
            #counter(heading).display(it.numbering).split(")").at(-2))
            #it.body

          ]),
      )
    }
  }

  content
}
