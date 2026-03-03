// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `hp` data entries are as follows:
//
// dict:
//    > `average`: int    - required
//    > `formula`: string - required
// dict:
//    > `special` string  - required

#import "../../external.typ": transl
#import "../../utils.typ"

#let render-hp(self, body) = {
  // Possible inputs
  // 1. dict
  //      average: int
  //      formula: str
  // 2. dict
  //      special: str
  // I'll only manage 1 as I don't think anyone would use 2.

  if not body.keys().contains("hp") { return }

  if body.hp.keys().contains("formula") and body.hp.formula != none {
    return [#text(fill: self.title.fill, weight: self.title.weight, transl("hit-points")): #utils.dnd-dice(body.hp.formula)]
  } else {

    return [#text(fill: self.fill.monster.title, weight: self.font.monster.title.weight, transl("hit-points")): #body.hp.special)]

  }
}
