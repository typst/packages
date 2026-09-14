// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `dex`, `con`, `int,` `wis`, `cha` data entries are as follows:
//
// dex/... : abilityScore

// Possible `abilityScore` data entries are as follows:
// int | none
// dict:
//    > special: string - required

#import "../../external.typ": transl

#import "../process/enum.typ": ability-modifier-names
#import "../process/ability-modifier.typ": process-modifiers

#let render-abilities(self, body) = {
  set text(fill: self.title.fill)
  if (
    not body.keys().contains("str")
      or not body.keys().contains("dex")
      or not body.keys().contains("con")
      or not body.keys().contains("int")
      or not body.keys().contains("wis")
      or not body.keys().contains("cha")
  ) { return }

  [
    #v(-4pt)
    #table(
      fill: none,
      align: center,
      columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      row-gutter: -0.7em,
      ..ability-modifier-names.map(name => text(fill: self.title.fill, weight: "bold", upper(transl(
        name,
        t: "short",
      )))),
      ..process-modifiers(body).map(value => text(value)),
    )
    #v(-4pt)
  ]
}
