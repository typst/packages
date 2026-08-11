#import "utils.typ": *

#let render-socials(
  socials: (),
) = {
  let columns = ()
  for item in socials {
    columns.push(
      [
        #item.icon
        #link(item.link, item.text)
      ],
    )
  }

  return columns
}

#let create-header-info(
  styles: (),
  full-name: [],
  job-title: [],
  socials: (),
) = {
  text(
    font: styles.header-style.fonts,
    size: styles.header-style.full-name.size,
    weight: styles.header-style.full-name.weight,
    full-name,
  )
  linebreak()
  h-line()
  linebreak()
  text(
    font: styles.header-style.fonts,
    size: styles.header-style.job-title.size,
    weight: styles.header-style.job-title.weight,
    job-title,
  )
  v(styles.header-style.margins.between-info-and-socials)

  let count-of-socials = socials.len()
  if (count-of-socials > 1) {
    table(
      columns: count-of-socials,
      inset: 0pt,
      column-gutter: styles.header-style.socials.column-gutter,
      align: center,
      stroke: none,
      ..render-socials(
        socials: socials,
      )
    )
  }
}

#let create-header-image(
  styles: (),
  profile-photo: "",
) = {
  if profile-photo != none {
    set image(
      height: styles.header-style.profile-photo.image-height,
      fit: "contain",
    )
    block(
      width: styles.header-style.profile-photo.width,
      height: styles.header-style.profile-photo.height,
      stroke: styles.header-style.profile-photo.stroke,
      radius: styles.header-style.profile-photo.radius,
      clip: true,
      profile-photo,
    )
  }
}
