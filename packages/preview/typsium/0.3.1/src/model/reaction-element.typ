
#import "@preview/elembic:1.1.1" as e
#import "../utils.typ": get-arrow, is-default

#let reaction(
  children: (),
) = { }

#let draw-reaction(it) = {
  for child in it.children {
    if child == [+] {
      h(0.4em, weak: true)
      math.plus
      h(0.4em, weak: true)
    } else {
      let type-id = e.data(child).eid
      if type-id == "e_typsium_---_arrow" {
        h(0.4em, weak: true)
        child
        h(0.4em, weak: true)
      } else if type-id == "e_typsium_---_molecule" {
        child
        let last = e.data(e.data(child).fields.children.last())
        let last-child-type-id = last.eid
        let charge = last.fields.at("charge", default: none)
        let count = last.fields.at("count", default: none)
        if (
          last-child-type-id == "e_typsium_---_group"
            and (not is-default(charge) or (not is-default(count) and count != 1))
        ) {
          h(-0.4em)
        }
      } 
      // else if type-id == "e_typsium_---_group"{
       //   child
       //   let charge = last.fields.at("charge", default: none)
       //   let count = last.fields.at("count", default: none)
       //   if not is-default(charge) or (not is-default(count) and count != 1){
       //     h(-0.3em)
       //   }
       //   }
      else {
        child
      }
    }
  }
}
}

#let reaction = e.element.declare(
  "reaction",
  prefix: "@preview/typsium:0.3.0",

  display: draw-reaction,

  fields: (
    e.field("children", e.types.array(content), required: true),
  ),
)
