#import "../settings/styles.typ": *
#import "utils.typ": *

#let renderSocials(
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

#let createHeaderInfo(
  fullName: [],
  jobTitle: [],
  socials: ()
) = {
  text(
    font: headerStyle.fonts,
    size: headerStyle.fullName.size, 
    weight: headerStyle.fullName.weight,
    fullName
  )
  linebreak()
  hLine()
  linebreak()
  text(
    font: headerStyle.fonts, 
    size: headerStyle.jobTitle.size, 
    weight: headerStyle.jobTitle.weight,
    jobTitle
  )
  v(headerStyle.margins.BetweenInfoAndSocials)

  let countOfSocials = socials.len()
  if(countOfSocials > 1) {
    table(
      columns: countOfSocials,
      inset: 0pt,
      column-gutter: headerStyle.socials.columnGutter,
      align: center,
      stroke: none,
      ..renderSocials(
        socials: socials
      )
    )
  }
}

#let createHeaderImage(
  profilePhoto: ""
) = {
  if profilePhoto.len() > 0 {
    block(
      width: headerStyle.profilePhoto.width, 
      height: headerStyle.profilePhoto.height, 
      stroke: headerStyle.profilePhoto.stroke, 
      radius: headerStyle.profilePhoto.radius, 
      clip: true,
      image(
        height: headerStyle.profilePhoto.imageHeight, 
        fit: "contain",
        profilePhoto
      )
    ) 
  }
}