// # Header. Cabeçalho.

#import "../packages.typ": icons
#import "../state.typ": kept_colors


#let include_contact_information(
  colors: (:),
  icon: none,
  info: "gabrielgoncalves",
  url: none,
) = {
  set text(
    fill: colors.dark,
    weight: "medium",
  )
  let icon_box = text(
    fill: colors.primary,
    icons.icon(
      icon,
      width: 1em,
      y: -2pt,
    ),
  )
  let info_box = if url != none {
    link(url, {
      set text(colors.dark)
      info
    })
  } else {
    info
  }
  [#icon_box#sym.space.nobreak#info_box]
}


#let header(
  first_name: "Gabriel",
  last_name: "Gonçalves",
  picture: none,
  contact_information: (
    (
      icon: "tabler:cake",
      info: "30 anos",
    ),
  ),
) = context {
  let colors = kept_colors.get()

  grid(
    columns: (1fr, auto),
    align: (start, end),
    column-gutter: 1em,

    [
      #text(
        size: 1.75em,
        fill: colors.primary,
      )[
        #text(
          weight: "medium",
        )[
          #first_name
        ]
        #text(
          weight: "black",
        )[
          #last_name
        ]
      ]
      #parbreak()

      #{
        let contacts = contact_information.map(
          contact => include_contact_information(
            colors: colors,
            icon: if contact.keys().contains("icon") { contact.icon } else { none },
            info: contact.info,
            url: if contact.keys().contains("url") { contact.url } else { none },
          ),
        )
        let contacts_remaining = contacts.len()
        set par(
          leading: 0.75em,
        )
        box(
          inset: (y: 0.25em),
        )[
          #for contact in contacts {
            [
              #contact
              #if contacts_remaining > 1 {
                [|]
              }
              #(contacts_remaining -= 1)
            ]
          }
        ]
      }
    ],

    if picture != none {
      box(clip: true, radius: 100%, width: 5em, height: 5em)[
        #set image(
          width: 100%,
          height: 100%,
        )
        #picture
      ]
    },
  )

  line(
    length: 100%,
    stroke: colors.primary,
  )
}
