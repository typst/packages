#import "styles.typ": *

#let render-contact-info(
  socials: ()
) = {
  let columns = ()
  for item in socials {
    columns.push(
      [
        #item.icon
        #link(item.link, item.text)
      ]
    )
  }

  return columns
}

#let create-header-info(
  full-name: [],
  job-title: [],
  socials: ()
) = {
  text(
    font: header-style.fonts,
    size: header-style.full-name.size, 
    weight: header-style.full-name.weight,
    full-name
  )
  linebreak()
  hline()
  linebreak()
  text(
    font: header-style.fonts, 
    size: header-style.job-title.size, 
    weight: header-style.job-title.weight,
    job-title
  )
  v(header-style.margins.between-info-and-socials)

  let count-of-socials = socials.len()
  if(count-of-socials > 1) {
    table(
      columns: count-of-socials,
      inset: 0pt,
      column-gutter: header-style.socials.column-gutter,
      align: center,
      stroke: none,
      ..render-contact-info(
        socials: socials
      )
    )
  }
}

#let create-header-avatar(
  profile-photo: ""
) = {
  if profile-photo != none {
    set image(
      height: header-style.profile-photo.image-height, 
      fit: "contain"
    )
    block(
      width: header-style.profile-photo.width, 
      height: header-style.profile-photo.height, 
      stroke: header-style.profile-photo.stroke, 
      radius: header-style.profile-photo.radius, 
      clip: true,
      profile-photo
    )
  }
}