// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `cr` data entries are as follows:
//
// string
// dict:
//    > `cr`: string - required
//    > `lair`: string
//    > `coven`: string
//    > `xp`: int
//    > `xpLair`: int

#import "../../external.typ": transl, get

#import "../process/enum.typ"
#import "../utils.typ"

#let challenge-to-xp(body) = {
  assert(enum.level-to-xp.keys().contains(body), message: "Invalid challenge rating: " + str(body))

  return [#enum.level-to-xp.at(body)]
}

#let xp-to-challenge(body) = {
  assert(enum.xp-to-level.keys().contains(body))
  return [#enum.xp-to-level.at(body)]
}




// CHALLENGE RATING
// required: cr
//
// array: str
// array: dict: (cr: str), (lair: str), (coven: str), (xp: str), (xpLair: str)
#let process-cr(body) = {
  if not body.keys().contains("cr") { return }
  if body.cr == none { return }

  let xp = none
  let prof = none

  if type(body.cr) == str {
    (proc: [#body.cr (#challenge-to-xp(body.cr) #transl("xp"))], amount: 1)
  
  } else if type(body.cr) == dictionary {
    let processed = ()

    if body.cr.keys().contains("xp") {
      xp = body.cr.xp
      processed.push([#body.cr (#challenge-to-xp(xp) #transl("xp"))])
    } else {
      processed.push([#body.cr.cr (#challenge-to-xp(body.cr.cr) #transl("xp"))])
    }


    if body.cr.keys().contains("lair") {
      xp = get.text([#body.cr.lair (#challenge-to-xp(body.cr.lair))])
      processed.push([#transl("in-laira", experience: xp)])
    }
    
    if body.cr.keys().contains("xpLair") {
      processed.push([#transl("in-lair", experience: body.cr.xpLair)])
    }

    if body.cr.keys().contains("coven") {
      panic("Covens not supported at the moment")
    }
    return (proc: processed.join(" "), amount: 1)

  }
}
