// // 15/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `action` | `bonus` | `reaction` | ? `legendary` data entries are as follows:
//
// array:
//    > dict
//        > name: str | required
//        > entries: array | required
//            > ?
//    > none

#import "regex.typ"


// NOTE: action, actionNote, bonus, bonusNote, reaction, reactionNote -> they may need to be rendered as well!

#let action-title() = {

}

#let process-action(key, body) = {
  if not body.keys().contains(key) {return}
  if body.at(key) == none {return}

  let body = body.at(key)

  assert(type(body) == array, message: "Actions are created as arrays!")
  let processed = body.map(act => {
    [ === #act.name
      #act.entries.join(" ")
    ]
  })

  return processed.join([#linebreak()#v(0pt)])
}