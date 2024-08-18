#import "../stateful.typ": *
#import "../constants.typ"


#let deuterated(body) = {
    show regex("(\w-d\d+)"): (it) => {
        if-state-enabled( it , {
            //show "-": "–"
            show regex("\d"): sub
            it
            
        })
    }
    body
}