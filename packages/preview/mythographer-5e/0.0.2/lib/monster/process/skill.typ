// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `save` data entries are as follows:
//
//   > `acrobatics`: string
//   > `animal`: string
//   > `arcana`: string
//   > `athletics`: string
//   > `deception`: string
//   > `history`: string
//   > `insight`: string
//   > `intimidation`: string
//   > `investigation`: string
//   > `medicine`: string
//   > `nature`: string
//   > `perception`: string
//   > `performance`: string
//   > `persuasion`: string
//   > `religion`: string
//   > `sleightofhand`: string
//   > `stealth`: string
//   > `survival`: string
//   > `special`: dict -> NOT SUPPORTED at the moment | HOMEBREW
//      > `description`
//      > ?

#import "../../external.typ": transl, get

#import "../process/enum.typ"
#import "../utils.typ"

#let process-skills(body) = {
  if not body.keys().contains("skill") { return }
  if body.skill == none { return }

  let processed = body
    .skill
    .pairs()
    .map(pair => {
      let name = pair.at(0).split("").join()
      let desc = pair.at(1)

      if name in enum.skill-names {
        [#utils.capitalize(get.text(transl("skill", t: name, mode: str))) #desc]
      } else {
        [#name #desc]
      }
    })

  return (proc: processed.join(", "), amount: body.skill.keys().len())
}
