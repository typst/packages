// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `size` data entries are as follows:
//
// for higher compatibility I'm taking the `ifBrew` branch (which is compatible with both `site` and `ua`)
//// SIZE - sizeEnum
// array:
//    string:enum  > "F", "D", "T", "S", "M", "L", "H", "G", "C", "V"
//
// - F: Fine
// - D: Diminutive
// - T: Tiny
// - S: Small
// - M: Medium
// - L: Large
// - H: Huge
// - G: Gargantuan
// - C: Colossal
// - V: Varies


//// TYPE
// dict:
//    > `type`
//        > creatureType
//        > string
//        > dict
//            > `properties`: array - required
//                > creatureType
//            > `properties`: dict
//                > `tag`: str - required
//                > `prefix`: str - required
//                > prefixHidden: bool
//    > `swarmSize`
//      > sizeEnum
//    > `sidekickType`    -> ignored at the moment
//    > sidekickTags      -> ignored
//    -> sidekickHidden`  -> ignored

// creatureType
// string:enum > "aberration", "beast", "celestial", "construct", "dragon", "elemental", "fey", "fiend", "giant", "humanoid", "monstrosity", "ooze", "plant", "undead"


#import "../../external.typ": transl
#import "../utils.typ": capitalize


#let render-size-type(self, body) = {
  if (not body.keys().contains("size")) { return }
  if (not body.keys().contains("type")) { return }

  let mtype = ""
  if type(body.type) == str {
    mtype = body.type
  } else if type(body.type) == dictionary {
    mtype = body.type.type
  }

  let out = none
  if body.size.len() > 1 {
    out = transl("creature-description", msize: body.size.last(), mtype: mtype)
    let body1 = body
    body1.pop()
    out = [#out #body1.map(size => get.text(transl("msize", msize: size)))]
  } else {
    out = transl("creature-description", msize: body.size.last(), mtype: mtype)
  }

  if (type(body.type) == dictionary and (body.type.tags != none or body.type.tags.len() > 0)) {
    // dict
    //    type: str
    //    tags: list
    //          (show in brackets)
    //    TODO: swarmSize --- NOT SUPPORTED YET
    //    TODO: sidekickType --- NOT SUPPORTED YET
    //    TODO: sidekickTags --- NOT SUPPORTED YET
    //    TODO: sidekickHidden --- NOT SUPPORTED YET
    return [#out (#body.type.tags.map(tags => (capitalize(tags))).join(", "))]
  } else {
    return out
  }
}
