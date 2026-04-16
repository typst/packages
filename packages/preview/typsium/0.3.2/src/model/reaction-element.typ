
#import "@preview/elembic:1.1.1" as e
#import "../utils.typ": get-arrow, is-default

#let reaction(
  children: (),
  plus-spacing: h(0.4em, weak: true),
  arrow-spacing: h(0.4em, weak: true),
  molecule-spacing: sym.space.nobreak,
  group-spacing-correction: h(-0.3em),
) = { }

#let draw-reaction(it) = {
  let last-type-id = ""
  for child in it.children {
    if child == [+] {
      it.plus-spacing
      math.plus
      it.plus-spacing
    } else {
      let type-id = e.data(child).eid
      if type-id == "e_@preview/typsium:0.3.2_---_reaction-arrow" {
        it.arrow-spacing
        child
        it.arrow-spacing
      } else if type-id == "e_@preview/typsium:0.3.2_---_molecule" {
        if last-type-id == "e_@preview/typsium:0.3.2_---_molecule" or last-type-id == "e_@preview/typsium:0.3.2_---_particle"{
          it.molecule-spacing
        }

        child
        let last = e.data(e.data(child).fields.children.last())
        let last-child-type-id = last.eid
        let charge = last.fields.at("charge", default: none)
        let count = last.fields.at("count", default: none)
        if (
          last-child-type-id == "e_@preview/typsium:0.3.2_---_group"
            and (not is-default(charge) or (not is-default(count) and count != 1))
        ) {
          it.group-spacing-correction
        }
      } else if type-id == "e_@preview/typsium:0.3.2_---_particle"{
        if last-type-id == "e_@preview/typsium:0.3.2_---_molecule" or last-type-id == "e_@preview/typsium:0.3.2_---_particle"{
          it.molecule-spacing
        }
        child
      }
      // else if type-id == "e_@preview/typsium:0.3.2_---_group"{
      //    child
      //    let charge = last.fields.at("charge", default: none)
      //    let count = last.fields.at("count", default: none)
      //    if not is-default(charge) or (not is-default(count) and count != 1){
      //      h(-0.3em)
      //    }
      //    }
      else {
        child
      }
    }
    last-type-id = e.data(child).eid
  }
}
}

#let reaction = e.element.declare(
  "reaction",
  prefix: "@preview/typsium:0.3.2",

  display: draw-reaction,

  fields: (
    e.field("children", e.types.array(content), required: true),
    e.field("plus-spacing", content, default: h(0.4em, weak: true)),
    e.field("arrow-spacing", content, default: h(0.4em, weak: true)),
    e.field("molecule-spacing", content, default: sym.space.nobreak),
    e.field("group-spacing-correction", content, default: h(-0.3em)),
  ),
)
