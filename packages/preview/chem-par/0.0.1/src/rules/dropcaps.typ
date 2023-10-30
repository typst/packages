#import "../stateful.typ": *
#import "../constants.typ"

#let fischer-dropcaps(body) = {
    show: it => {
        for k in constants.fischer-dropcaps {
            it = {
                show k + "-": (it) => {
                    show: text.with(size: 0.65em)
                    show "-": "–"
                    it
                }
                it
            }
        }
        it
    }
    body
}