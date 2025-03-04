#import "../utils/states.typ": digital-signature-option-state
#import "../config/constants.typ": e-digital-signature-mode

#let use-digital-signature(content) = {
  let digital-signature-option = digital-signature-option-state.get()
  let digital-signature-mode = digital-signature-option.at("mode")

  show: it => {
    if digital-signature-mode == e-digital-signature-mode.scanned-copy {
      set page(
        footer: none,
        header: none,
        background: digital-signature-option.at("scanned-copy"),
      )
    } else if digital-signature-mode == e-digital-signature-mode.default {
      for offset in digital-signature-option.at("author-signature-offsets") {
        place(
          dx: offset.dx,
          dy: offset.dy,
        )[
          #digital-signature-option.at("author-signature")
        ]
      }

      for offset in digital-signature-option.at("supervisor-signature-offsets") {
        place(
          dx: offset.dx,
          dy: offset.dy,
        )[
          #digital-signature-option.at("supervisor-signature")
        ]
      }

      for offset-array in digital-signature-option.at("date-offsets").zip(digital-signature-option.at("date-array")) {
        let number-offset-array = offset-array.at(1).zip(offset-array.at(0))

        for number-offset in number-offset-array {
          place(
            dx: number-offset.at(1).dx,
            dy: number-offset.at(1).dy,
          )[
            #number-offset.at(0)
          ]
        }
      }
      if not digital-signature-option.show-declaration-of-originality-page-number {
        set page(footer: none)
      }
      it
    } else {
      if not digital-signature-option.show-declaration-of-originality-page-number {
        set page(footer: none)
      }
      it
    }
  }

  content
}
