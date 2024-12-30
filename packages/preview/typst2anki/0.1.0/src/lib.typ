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
  Q: "",
  A: "",
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
        Q: #Q \ 
        A: #A
      ]
    } else {
      context [
        #Q \ 
        #A
      ]
    }
  } else {
    if args.at("show_labels") == true {
      card_container[
        Q: #Q \ 
        A: #A
      ]
    } else {
      card_container[
        #Q \ 
        #A
      ]
    }
  }
}
