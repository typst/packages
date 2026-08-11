// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `immune` data entries are as follows:
// 
// Note: immune: conditionImmunityArray
// 
// conditionImmunityArray
//    > array
//       > dataCondition
//       > dict
//           > `special`: string - required
//       > dict
//           > `preNote`: string
//           > `immune`: conditionImmunityArray - required
//           > `note`: string


// `dataCondition`
//
// enum:string 
// "blinded", "charmed", "deafened", "exhaustion", "frightened", "grappled", "incapacitated", "invisible", "paralyzed", "petrified", "poisoned", "prone", "restrained", "stunned", "unconscious", "disease"

 
#import "../utils.typ"
#import "../process/enum.typ"

#let process-condition-immune(body) = {
  if not body.keys().contains("conditionImmune") { return }

  assert(type(body.conditionImmune) == array)

  let imm-str = ()
  let imm-dic = ()
  for immunity in body.conditionImmune {
    if type(immunity) == str {
      imm-str.push(utils.translate-t-word-if-possible("data-condition", immunity, enum.data-condition))
    } else if type(immunity) == dictionary {
      // preNote, conditionImmune, note, cond
      let curr-imm = ()
      let imm-keys = immunity.keys()
      if imm-keys.contains("preNote") { curr-imm.push(immunity.preNote) }
      curr-imm.push(
        immunity
          .conditionImmune
          .map(a => {
            utils.translate-t-word-if-possible("data-condition", a, enum.data-condition)
          })
          .join(", "),
      )
      if imm-keys.contains("note") { curr-imm.push(immunity.note) }
      if imm-keys.contains("cond") {}
      imm-dic.push(curr-imm.join(" "))
    } else {
      panic("this shouldn't exist")
    }
  }
  let processed = imm-str.join(", ")
  if imm-dic.len() > 0 {
    imm-dic.insert(0, processed)
    processed = imm-dic.flatten()
    return (proc: processed.join("; "), amount: processed.len())
  }

  return (proc: (processed), amount: 1)
}