// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `immune` data entries are as follows:
// 
// Note: immune: damageImmunityArray
// 
// damageImmunityArray
//    > array
//       > dataDamageType
//       > dict
//           > `special`: string - required
//       > dict
//           > `preNote`: string
//           > `immune`: damageImmunityArray - required
//           > `note`: string


// `dataDamageType`
//
// enum:string 
// "acid", "bludgeoning", "cold", "fire", "force", "lightning", "necrotic", "piercing", "poison", "psychic", "radiant", "slashing", "thunder"

#import "../utils.typ"
#import "../process/enum.typ"

// IMMUNE - same as vulnerability
// - array:
//      - str (dataCondition)
//      - dict <special> : str
//      - dict: (preNote: str), (vulnerable: damageImmunityArray), (note: str), (cond: const)
// - none
#let process-immunity(body) = {
  if not body.keys().contains("immune") { return }

  assert(type(body.immune) == array)

  let imm-str = ()
  let imm-dic = ()
  for immunity in body.immune {
    if type(immunity) == str {
      imm-str.push(utils.translate-t-word-if-possible("damage-type", immunity, enum.data-damage-type))
    } else if type(immunity) == dictionary {
      // preNote, immune, note, cond
      let curr-imm = ()
      let imm-keys = immunity.keys()
      if imm-keys.contains("preNote") { curr-imm.push(immunity.preNote) }
      curr-imm.push(
        immunity
          .immune
          .map(a => {
            utils.translate-t-word-if-possible("damage-type", a, enum.data-damage-type)
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
