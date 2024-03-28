#let socialslist = state("socialslist", ())

#let social(
  name, icon: none,
) = {
  let social = if icon == none {
    name
  } else {
    box(image("../" + icon, height: 1.5em), baseline: 20%)
    h(1em)
    name
  }

  socialslist.update(current => current + (social,))
}

#let socials(header: "Social Media", color: white, size: 11pt) = {
  locate(
    loc => {
      let socialslist = socialslist.final(loc)
      if socialslist.len() > 0 {
        heading(level: 1, text(color, header))
        set text(color, size: size)
        block(
          align(left)[#socialslist.join("\n")]
        )
      }
    }
  )
}
