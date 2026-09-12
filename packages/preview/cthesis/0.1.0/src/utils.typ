#let small = text.with(0.90em)
#let large = text.with(1.2em)
#let x-large = text.with(1.2*1.2em)
#let xx-large = text.with(1.2*1.2*1.2*1.2em)

#let tr(sv, en) = context { 
  if text.lang == "sv" { sv } 
  else { en }
}

#let ty(ba, ma) = context { 
  let type = lower(query(<thesis-type>).first().value)
  if ("b", "ba", "bachelor", "bachelors").contains(type) { ba } 
  else if ("m", "ma", "master", "masters").contains(type) { ma }
  else { panic("Invalid thesis type") }
}

#let CHALMERS = tr("Chalmers Tekniska Högskola", "Chalmers University of Technology")
#let GOTHENBURG_UNIVERSITY = tr("Göteborgs Universitet", "University of Gothenburg")
#let GOTHENBURG_CITY = tr("Göteborg", "Gothenburg, Sweden")
#let THESIS_TYPE = tr(
  ty("Kandidat", "Magister") + "arbete",
  ty("Bachelor's", "Master's") + " thesis"
)
#let department_of(name) = [#tr("Institutionen för", "Department of") #name]

#let LOGO_HORIZONTAL = context {
  let gu = query(<gu-collaboration>).first().value;
  if gu { 
    let w = 100% 
    tr(
      std.image("logos/old/sv_cth_gu_horizontal.png", width: w), // TODO: replace with vector
      std.image("logos/old/en_cth_gu_horizontal.svg", width: w)
    ) 
  } else {
    let h = 18mm
    tr(
      std.image("logos/old/sv_cth_horizontal.svg", height: h), 
      std.image("logos/old/en_cth_horizontal.svg", height: h)
    )
  }
}

#let LOGO_VERTICAL = context {
  let gu = query(<gu-collaboration>).first().value;
  if gu { 
    let w = 35% 
    tr(
      std.image("logos/old/sv_cth_gu_vertical.png", width: w), // TODO: replace with vector
      std.image("logos/old/en_cth_gu_vertical.svg", width: w)
    ) 
  } else {
    let w = 25% 
    tr(
      std.image("logos/old/sv_cth.svg", width: w),
      std.image("logos/old/en_cth.svg", width: w)
    )
  }
}

#let pagebreak-recto() = {
  set page(numbering: none)
  pagebreak(to: "odd", weak: true)
}

#let heading-style(prefix, style, in-outline) = (..nums) => {
  context {
    let n = nums.pos()
    if n.len() == 1 and not in-outline.get() {
      text(0.8em, weight: "bold")[
        #smallcaps(prefix + numbering(style, ..n))
        #linebreak()
      ]
    } else {
      numbering(style, ..n)
    }
  }
}