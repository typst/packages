// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `senses` data entries are as follows:
// 
// array: string
// none

#import "../../external.typ": transl, get
#import "../process/enum.typ"
#import "../utils.typ"

// - array: dict <name>: string <ft + description>
// - array: str
// - null
#let process-senses(body) = {
  let passive = none
  let processed = ()
  if body.keys().contains("passive") {
    if body.passive == none { continue }
    passive = body.passive
  }

  if body.keys().contains("senses") {
    if body.senses == none { continue }
    if type(body.senses) == array {
      processed = body.senses.map(sense => {
        if type(sense) == str {
          utils.translate-t-word-if-possible("senses", sense, enum.senses)
        } else if type(sense) == dictionary {
          let current = sense.keys().at(0)
          [#utils.translate-t-word-if-possible("senses", sense, enum.senses) (#sense.at(current))]
        } else {
          panic("Senses have an unsupported data structure: ", type(body.senses))
        }
      })
    } else {
      panic("Senses have an unsupported data structure: ", type(body.senses))
    }
  }
  processed.insert(0, [#utils.capitalize(transl("senses", t: "passive", mode: str)) #passive])
  return (proc: processed.join(", "), amount: processed.len())
}
