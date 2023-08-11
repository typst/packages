#let contactslist = state("contactslist", ())

#let contact(
  name, icon: none,
) = {
  let contact = if icon == none {
    name
  } else {
    box(image("../" + icon, height: 1.5em), baseline: 20%)
    h(1em)
    name
  }

  contactslist.update(current => current + (contact,))
}

#let contacts() = {
  locate(
    loc => {
      let contactslist = contactslist.final(loc)
      if contactslist.len() > 0 {
        v(1em)
        set text(size: 10pt)
        v(1em)
        grid(
          columns: 2,
          contactslist.join(h(0.5em)),
        )
      }
    }
  )
}
