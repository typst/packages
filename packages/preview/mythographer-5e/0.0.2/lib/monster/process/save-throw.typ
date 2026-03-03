// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `save` data entries are as follows:
// 
// dict:
//    > `str`: string
//    > `dex`: string
//    > `con`: string
//    > `int`: string
//    > `wis`: string
//    > `cha`: string
//    > `special` -> NOT SUPPORTED at the moment | HOMEBREW (i need to see a homebrew file)

#import "../../external.typ": transl, get
#import "../process/enum.typ"
#import "../utils.typ"

// SAVE THROWS
// save: dict
//    - str
//    - dex
//    - con
//    - int
//    - wis
//    - cha
// Badly managed
//    - $$ifbrew -> special -> description, $$ref
#let process-save(body) = {
  if not body.keys().contains("save") { return }
  if body.save == none { return }
  if not type(body.save) == dictionary { panic("`save` (throws) type is not supported: ", type(body.save)) }


  let processed = body
    .save
    .pairs()
    .map(pair => {
      let key = pair.at(0)
      let value = pair.at(1)

      if key in enum.ability-modifier-names {
        [#utils.capitalize(get.text(transl(key, t: "short", mode: str))) #value]
      } else {
        [#value.special.description]
      }
    })

  return (proc: processed.join(", "), amount: body.save.keys().len())
}