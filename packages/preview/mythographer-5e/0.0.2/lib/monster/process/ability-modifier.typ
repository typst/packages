// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `dex`, `con`, `int,` `wis`, `cha` data entries are as follows:
//
// dex/... : abilityScore

// Possible `abilityScore` data entries are as follows:
// int | none
// dict:
//    > special: string - required 

#let mod-value-plus(point) = {
  if point == none { return }

  if type(point) == dictionary {
    assert(point.keys().contains("special"))
    return point.special
  }

  let val = int((point / 2) - 5)

  if val > 0 {
    val = "+" + str(val)
  }

  let desc = str(point) + " (" + str(val) + ")"
  return desc
}

#let process-modifiers(body) = {
  return (
    mod-value-plus(body.str),
    mod-value-plus(body.dex),
    mod-value-plus(body.con),
    mod-value-plus(body.int),
    mod-value-plus(body.wis),
    mod-value-plus(body.cha),
  )
}
