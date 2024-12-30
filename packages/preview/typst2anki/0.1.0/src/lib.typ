#import "@preview/gentle-clues:1.1.0": *

#let card_container(
  title: "Anki", 
  icon: image("assets/anki.svg"),
  ..args
) = {
  clue(
    title: title,
    icon: icon,
    accent-color: rgb(4, 165, 229),
    ..args
  )
}

#let card(
  id: "",
  q: "",
  a: "",
  ..args
) = {
  let args = arguments(
    type: "basic",
    container: false,
    show_labels: false,
    ..args
  )
  
  if args.at("container") == false {
    if args.at("show_labels") == true {
      context [
        Q: #q \ 
        A: #a
      ]
    } else {
      context [
        #q \ 
        #a
      ]
    }
  } else {
    if args.at("show_labels") == true {
      card_container[
        Q: #q \ 
        A: #a
      ]
    } else {
      card_container[
        #q \ 
        #a
      ]
    }
  }
}
