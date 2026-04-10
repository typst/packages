#import "colors.typ": colors
#import "typography.typ"
#import "utils.typ": *
#import "components.typ"
#import "layout.typ": layout

#let linked-cv(
  firstname: "First",
  lastname: "Last",
  socials: (
    email: none,
    mobile: none,
    github: none,
    linkedin: none,
  ),
  position: none,

  body,
) = {
  show: doc => layout(firstname, lastname, doc)

  components.header(
    firstname,
    lastname,
    socials: socials,
    position: position,
  )

  body
}
