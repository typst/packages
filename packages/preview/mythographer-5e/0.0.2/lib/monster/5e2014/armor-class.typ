// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `ac` data entries are as follows:
//
// int
// dict:
//    > `ac`: int - required
//    > `from` : array
//        > string
//    > `condition`: string
//    > `braces`: bool
// dict:
//    > `special`: string - required


#import "../../external.typ": transl

#let pre-render-ac(self, body) = {
  // Case 1
  if type(body) == dictionary and body.keys().contains("ac") {
    let ac = str(body.ac)

    if body.keys().contains("from") and body.from != none {
      if type(body.from) == array {
        ac = [#ac (#body.from.join(", "))]
      } else {
        ac = [#ac (#body.from)]
      }
    }

    if body.keys().contains("condition") and body.condition != none {
      ac = [#ac (#body.condition)]
    }

    return ac
  }

  // Case 2
  if type(body) == dictionary and body.keys().contains("special") {
    return body.special
  }

  // Case 3
  if type(body) == str {
    return [#body]
  }
}

#let render-ac(self, body) = {
  // Possible inputs are:
  // 0. array of below
  // 1. dict
  //      ac: int
  //      from: array(str)  -> not required
  //      condition: str -> not required
  // 2. dict
  //      special: string
  // 3. int
  if not body.keys().contains("ac") { return }

  let ac = none
  if type(body.ac) == array {
    ac = body.ac.map(ac => pre-render-ac(self, ac)).join(", ")
  } else {
    ac = pre-render-ac(self, body.ac)
  }

  return [
    === #transl("armor-class")
    #ac
  ]
}
