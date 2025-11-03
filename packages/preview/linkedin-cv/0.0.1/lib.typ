#import "src/colors.typ": colors
#import "src/typography.typ"
#import "src/utils.typ": *
#import "src/components.typ"
#import "src/layout.typ": layout
#import "src/frame.typ"

#let linkedin-cv(
  firstname: "First",
  lastname: "Last",
  email: none,
  mobile: none,
  github: none,
  linkedin: none,
  position: none,

  body,
) = {
  show: doc => layout(firstname, lastname, doc)

  components.header(
    firstname,
    lastname,
    email: email,
    mobile: mobile,
    github: github,
    linkedin: linkedin,
    position: position,
  )

  body
}
