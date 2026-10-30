#import "../layout.typ": body-helper, generic-one-by-two, generic-two-by-two
#import "../utils.typ": link-helper, text-with-icon

// Builds a project's title line, including its optional role and tagline.
#let project-title-line(
  name: "",
  tagline: "",
  role: "",
) = {
  if role == "" [
    *#name*
    #if tagline != "" [
      *— #tagline*
    ]
  ] else [
    *#role*, #name
    #if tagline != "" [
      — #tagline
    ]
  ]
}

#let project(
  name: "",
  tagline: "",
  role: "",
  url: "",
  dates: "",
  relation: "",
  relation-type: "",
  columns: (1fr, 1fr),
  body,
) = {
  if url != "" {
    name = link(url)[#name]
  }

  if relation == "" {
    generic-one-by-two(
      cols: columns,
      project-title-line(
        name: name,
        tagline: tagline,
        role: role,
      ),
      [*#dates*],
    )
  } else {
    generic-two-by-two(
      cols: columns,
      top-left: [
        #project-title-line(
          name: name,
          tagline: tagline,
          role: role,
        )
      ],
      top-right: [
        *#dates*
      ],
      bottom-left: [
        #if relation-type == "" [
          #emph(relation)
        ] else [
          #emph(relation-type) - #emph(relation)
        ]
      ],
    )
  }
  body-helper(body)
}
