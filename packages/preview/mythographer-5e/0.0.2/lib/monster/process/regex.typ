// Many thanks to Boondoc: https://codeberg.org/boondoc/5e-spellbooks/src/commit/d58945c95405a05c12341e71897b5e55edd6733f/includes/render.typst#L41

#import "../../external.typ": transl, get
#import "../../utils.typ"

#let regex-5e = (
  dc: regex("\{@dc\s+(\d+)\}"),
  hit: regex("\{@hit\s+(\d+)\}"),
  h: regex("\{@h\}"),
  atk: regex("\{@atk [^}]+}"), // mw: melee weapon, rw: ranged weapon, ms: melee spell, rs: ranged spell
  dice: regex("(?:\d+\s*\()?\{@dice\s+([^}]+)\}\)?"),
  dice-body: regex("\d+d\d+\s*(?:\+\s*\d+)?"),
  dmg: regex("(?:\d+\s*\()?\{@damage\s+([^}]+)\}\)?"),
  spell: regex("\{@spell [^}]+}"), // {@spell <name>}
  item: regex("\{@item [^|}]+(?:|[^}]+)?}"), // {@item <name>} or {@item <name>|<reference>} )
  condition: regex("\{@condition [^}]+}"), //{@condition <name>}
)



#let process-5etool-tags(body) = {
  show regex-5e.dc: body => {
    let (text,) = body.text.match(regex-5e.dc).captures
    [#transl("dc") #text.find(regex("\d+"))]
  }

  show regex-5e.hit: body => {
    [#body.text.find(regex("\d+"))]
  }

  show regex-5e.h: body => {
    [#transl("hit"): ]
  }

  show regex-5e.atk: body => {
    [#transl(body.text.trim("{@atk ").trim("}"))]
  }

  show regex-5e.dice: body => {
    utils.dnd-dice(body.text.find(regex-5e.dice-body))
  }

  show regex-5e.dmg: body => {
    utils.dnd-dice(body.text.find(regex-5e.dice-body))
  }

  show regex-5e.spell: body => {
    [#body.text.trim("{@spell ").trim("}")]
  }

  show regex-5e.item: body => {
    [#body.text.trim("{@item ").trim("}").split("|").at(0)]
  }

  show regex-5e.condition: body => {
    [#body.text.trim("{@condition ").trim("}")]
  }

  body
}
