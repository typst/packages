#import "/src/utils.typ": i18n
#import "/src/elements/logo.typ": logo
#import "/src/elements/colors.typ": colors

#let templates = (
  simple: (
    color: colors.black,
    title-color: colors.brilliantblue,
    logo-color: "blue",
    logo-text-color: colors.brilliantblue,
    signature: true,
    background: none,
  ),
  shape-1: (
    color: colors.white,
    logo-color: "white",
    title-color: colors.white,
    logo-text-color: colors.white,
    signature: true,
    background:[
      #context rect(
        fill: state("color-primary").get(),
        width: 100%,
        height: 100%,
      )
      #place(
        horizon + center,
        context logo(state("color-secondary").get(), style: "icon", width: 300%)
      )
    ]
  ),
  plain-1: (
    color: colors.white,
    logo-color: "white",
    title-color: colors.white,
    logo-text-color: colors.white,
    signature: true,
    background:[
      #context rect(
        fill: state("color-primary").get(),
        width: 100%,
        height: 100%,
      )
    ]
  )
)

#let titlepage(
  target: none,
  
  faculty: none,
  chair: none,
  title: none,
  thesis-type: none,
  authors: (
    (
      name: none,
      birthdate: none,
      birthplace: none
    ),
  ),
  supervisors: (),
  submissionplace: none,
  
  titlepage: none,
) = {
  let background
  let text-color
  let logo-color
  let signature
  let title-color
  let logo-text-color

  if type(titlepage) == str {
    background = templates.at(titlepage).background
    text-color = templates.at(titlepage).color
    title-color = templates.at(titlepage).title-color
    logo-color = templates.at(titlepage).logo-color
    logo-text-color = templates.at(titlepage).logo-text-color
    signature = templates.at(titlepage).signature
  }

  [ 
    #set page(
      footer: none,
    )

    #set page(
      background: background
    )

    #set text(fill: text-color)
    #logo(logo-color, style: "horizontal", crop: true, height: 17mm * (1 + 2/5))
   
    #[
      #set text(fill: logo-text-color)
      #text(weight: "semibold", faculty) \
      #chair
    ]

    #place(
      top + left,
      dy: 1/3 * 100%,
      [
        #[
          #set text(size: 24pt, weight: "semibold", font: "Noto Sans", fill: title-color)
          #set par(justify: false)
          #title
        ]
        
        #set text(size: 16pt, weight: "regular")
        #thesis-type
      ]
    )

    #if signature == true {
      place(
        bottom + right,
        [
          #align(right, [
            #set par(spacing: .5em)
            #line(length: 15em, stroke: (dash: "dotted", paint: text-color))
            #i18n("signature")
          ])
        ]
      )
    }

    #show grid.cell.where(x: 0): set text(weight: "medium")

    #place(
      dy: -(.5em + 1em),
      bottom + left,
      grid(
        columns: 2,
        gutter: 1.5em,
        align: top + left,
        ..for (index, author) in authors.enumerate() {
          (
            [#if index == 0{i18n("submitted-by")}],
            [
              #set par(leading: .75em);
              #author.name \
              #if author.birthdate != none {[#author.birthdate.display("[day].[month].[year]"), #author.birthplace]} \
              #if "course" in author and author.course != none {[#author.course]}
            ],
          )
        },
        ..for (index, supervisor) in supervisors.enumerate() {
          (
            [#if index == 0{i18n("supervised-by")}],
            [#supervisor],
          )
        },
        ..if (submissionplace != none){
          (
            i18n("submission"), [#context query(<vstl:submissionplace>).first().value, #context query(<vstl:submissiondate>).first().value.display("[day].[month].[year]")]
          )
        }
      )
    )
    
    #counter(figure.where(kind: image)).update(0)
  ]
}