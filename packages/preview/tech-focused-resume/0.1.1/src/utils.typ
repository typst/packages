// Cannot just use normal --- ligature becuase ligatures are disabled for good reasons
#let dates-helper(
  start-date: "",
  end-date: "",
) = {
  start-date + " " + sym.dash.em + " " + end-date
}

#let link-helper(
  link-type: "",
  prefix: "",
  value: "",
  show-prefix: true,
) = {
  box[
    #link(link-type + prefix + value)[
      #if show-prefix [#prefix]#value
    ]
  ]
}

#let text-with-icon(icon-name: "", content) = {
  let img = image("assets/icons/" + icon-name + ".svg")
  box[
    #box(img, height: 1.2em, baseline: 0.25em)
    #content
  ]
}
