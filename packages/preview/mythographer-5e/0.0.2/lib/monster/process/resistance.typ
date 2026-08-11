// Virtually IDENTICAL to `immunie` (`immunity.typ`)
//      the ONLY diff is damageImmunityArray <=> damageResistArray
// 
// 
// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `resist` data entries are as follows:
// 
// Note: resist: damageResistArray
// 
// damageResistArray
//    > array
//       > dataDamageType
//       > dict
//           > `special`: string - required
//       > dict
//           > `preNote`: string
//           > `resist`: damageResistArray - required
//           > `note`: string

#import "../utils.typ"
#import "../process/enum.typ"


// RESISTANCE
// - array:
//      - str (dataDamageType)
//      - dict <special> : str
//      - dict (preNote: str), (resist: damageResistArray), (note: str), (cond: const)
// - none
#let process-resistance(body) = {
  if not body.keys().contains("resist") { return }

  assert(type(body.resist) == array)

  let imm-str = ()
  let imm-dic = ()
  for immunity in body.resist {
    if type(immunity) == str {
      imm-str.push(utils.translate-t-word-if-possible("damage-type", immunity, enum.data-damage-type))
    } else if type(immunity) == dictionary {
      // preNote, resist, note, cond
      let curr-imm = ()
      let imm-keys = immunity.keys()
      if imm-keys.contains("preNote") { curr-imm.push(immunity.preNote) }
      curr-imm.push(
        immunity
          .resist
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
