#import "context.typ": component-wrapper
#import "../utils/people.typ": presentation-people, affiliation-link

#let render-affiliation(self: none, id, scope: auto) = {
  let info = if scope == auto { self.info } else { self.info + (affiliation-scope: scope) }
  let people = presentation-people(info)
  let institution = people.institutions.find(it => it.id == id)
  assert(institution != none, message: "Unknown institution ID: " + str(id))
  super(affiliation-link(id, institution.marker, scope: institution.scope))
}

/// Linked superscript using the title metadata's institution IDs and numbering.
#let ambrosia-affiliation(id, scope: auto) = component-wrapper(render-affiliation, id, scope: scope)
