#import "links.typ": *
#show: linktion
#set text()


#let file(
  url, 
  icon: "↗️", 
  ext: "", 
  name
) = {
  let title = {
    if (ext == "") {[#name]}
    else {[#name.#ext]}
  }
  
  block(
    link(url)[
      #box(
        inset: 1em, 
        stroke: gray + 0.5pt,
        width: 100%,
        radius: 4pt
      )[
        #icon #title
      ]
    ]
  )
}

#let media = file

#let video(
  url,
  icon: "↗️",
  ext: "",
  name
) = {
  media(url, icon: icon, ext: ext, name)
}

#let audio(
  url,
  icon: "↗️",
  ext: "",
  name
) = {
  media(url, icon: icon, ext: ext, name)
}

#let pdf(
  url,
  icon: "↗️",
  ext: "pdf",
  name
) = {
  file(url, icon: icon, ext: "pdf", name)
}

