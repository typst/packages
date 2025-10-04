#import "../../tools/miscellaneous.typ": content-to-string
#let plain(content) = {
  set text(10pt)

  show heading: it => {
    if content-to-string(it.body) == "" {
      return none
    }

    block(sticky: true, underline(it.body))
  }

  content
}


#let get-small-title(title) = context {
  return {
    line(length: 100%)
    text(
      size: 2em,
      font: "Noto Sans Georgian",
      align(
        center,
        if type(title) == array [
          *#title.at(0) - #title.at(1)*
        ] else [
          *#title*
        ],
      ),
    )


    line(length: 100%)
    v(15pt)
  }
}
