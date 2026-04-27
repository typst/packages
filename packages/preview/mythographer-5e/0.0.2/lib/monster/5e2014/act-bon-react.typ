#import "../../external.typ": transl
#import "../process/actions.typ": process-action

#let make-action-header-w-line(key, body) = {
  let body-keys = body.keys()

  let header = none
  let note = none
  // key+"Note"; key+"Header"

  if body-keys.contains(key + "Header") and body.at(key + "Header") != none {
    header = body.at(key + "Header")
  }

  if body-keys.contains(key + "Note") and body.at(key + "Note") != none {
    note = body.at(key + "Note")
  }

  if header != none and note != none {
    return [== #transl(key)
      #header.join(" ")
      #note.join(" ")
    ]
  }
  if header != none {
    return [== #transl(key)
      #header.join(" ")
    ]
  }
  if note != none {
    return [== #transl(key)
      #note.join(" ")
    ]
  }
  return [== #transl(key)]
}

#let render-act-bon-react(self, key, body) = [
  #let processed = process-action(key, body)

  #if processed != none {
    make-action-header-w-line(key, body)
    processed
    v(-1em)
  }
]

#let make-legendary-header(body) = {
  let amount = none
  let lair = none

  let keys = body.keys()
  if keys.contains("legendaryHeader") and body.legendaryHeader != none {
    return [#body.legendaryHeader]
  }

  if keys.contains("LegendaryActions") and body.LegendaryActions != none {
    amount = body.LegendaryActions
  }

  if keys.contains("legendaryActionsLair") and body.legendaryActionsLair != none {
    lair = body.legendaryActionsLair
  }

  ////
  if amount == none { amount = 3 }

  if lair != none {
    return [#transl("legendary-header-lair", amount: amount, lairAmount: lair, shortName: body.shortName)#linebreak()]
  }else{
    return [#transl("legendary-header", amount: amount, shortName: body.shortName)#linebreak()]

  }
}

#let render-legendary-action(self, body) = [
  #let key = "legendary"
  #let processed = process-action(key, body)

  // legendaryActionsLair : int | none
  // LegendaryActions : int  | none


  #if processed != none {
    make-action-header-w-line(key, body)
    make-legendary-header(body)
    // if body.keys().contains("legendaryHeader") and body.legendaryHeader != none{
    //   [#body.legendaryHeader]
    // }
    processed
    v(-1em)
  }
]
