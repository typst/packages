#import "@preview/cetz:0.4.0"
#import "@preview/cetz-plot:0.1.2"
#import "@preview/cuti:0.2.1": regex-fakebold

/// Sets the tex to the Koch Fette FC font for people who don't want to remember that.
///
/// - body (content)
/// - ..args: Any valid argument to the text function
/// -> content
#let KochFont(body, ..args) = text(..args)[#text(font: "Koch Fette FC")[#body]]

#let defaultImg = read("images/Default.png", encoding: none)

#let regex-fakeitalic(reg-exp: "\b.+?\b", ang: -18.4deg, s) = {
  show regex(reg-exp): it => {
    box(skew(ax: ang, reflow: false, it))
  }
  s
}

#let fakesc(s) = {
  show regex("[\p{Lu}]"): text.with(1.25em)
  text(0.8em, upper(s))
}

/// Defines the FlyingCircus template
///
/// - Title (str): Title of the document. Goes in metadata and on title page.
/// - Author (str): Author(s) of the document. Goes in metadata and on title page.
/// - CoverImg (bytes): Image to make the first page of the document.
/// - Description (str): Text to go with the title on the title page.
/// - Dedication (str): Dedication to go down below the title on the title page.
/// - body-only (bool): Whether to skip the cover, title, and contents pages.
/// - body (content)
/// -> content
#let FlyingCircus(
  Title: str,
  Author: str,
  CoverImg: none,
  Desciption: "Aircraft Catalogue",
  Dedication: "",
  body-only: false,
  body,
) = {
  //Set PDF Metadata
  set document(title: Title, author: Author)
  //Set Default Font document settings
  set text(font: "Balthazar", size: 14pt)
  // set par(spacing: 0.5em)
  set par(leading: 0.35em)
  set par(justify: true)
  set list(indent: 1em)
  set enum(indent: 1em)
  set page(numbering: "1")

  //Create fake italics because fonts don't have it.
  show emph: it => {
    regex-fakeitalic(it.body)
  }

  show strong: it => {
    regex-fakebold(it.body)
  }

  show smallcaps: it => {
    fakesc(it.body)
  }

  let is-missing() = {
    measure(text(font: "Wingdings", fallback: false, [Ë])).width == 0pt
  }
  show regex("✣"): {
    context if (is-missing()) {
      text(font: "Material Symbols Sharp", [#str.from-unicode(61800)])
    } else {
      text(font: "Wingdings", fallback: false, [Ë])
    }
  }
  //Create default page format
  set page(
    paper: "a4",
    //Header is alternating directions and the centered "Flying Circus" with border
    header: context {
      align(
        center,
        layout(ly => cetz.canvas(
          length: ly.width,
          {
            import cetz.draw: *
            set-style(stroke: (paint: black, thickness: 0.75mm))
            line((-.5, 0), (.5, 0))
            circle((-.5, 0), radius: 1.5mm, fill: black)
            circle((.5, 0), radius: 1.5mm, fill: black)
            set-style(stroke: (paint: black, thickness: 0.75mm))
            if (calc.rem(counter(page).get().first(), 2) == 1) {
              for x in range(-490, 480, step: 10) {
                line((x / 1000, -1.5mm), ((x + 15) / 1000, 1.5mm))
              }
            } else {
              for x in range(-470, 500, step: 10) {
                line((x / 1000, -1.5mm), ((x - 15) / 1000, 1.5mm))
              }
            }
            content((0, 0pt), KochFont(size: 18pt, stroke: 5pt + white)[Flying Circus])
            content((0, 0pt), KochFont(size: 18pt, stroke: 0.0pt + black)[Flying Circus])
          },
        )),
      )
    },
    //Footer is alternating directions with page number at outside and only partial bar
    footer: context {
      align(
        center,
        layout(ly => cetz.canvas(
          length: ly.width,
          {
            import cetz.draw: *
            set-style(stroke: (paint: black, thickness: 0.75mm))
            if (calc.rem(counter(page).get().first(), 2) == 1) {
              content((-.5, 0), KochFont(size: 18pt)[#counter(page).get().first()])

              line((-.45, 0), (.5, 0))
              circle((-.45, 0), radius: 1.5mm, fill: black)
              circle((.5, 0), radius: 1.5mm, fill: black)
              for x in range(-440, 480, step: 13) {
                line((x / 1000, -2mm), ((x + 20) / 1000, 2mm))
              }
            } else {
              content((.5, 0), KochFont(size: 18pt)[#counter(page).get().first()])

              line((-.5, 0), (.45, 0))
              circle((-.5, 0), radius: 1.5mm, fill: black)
              circle((.45, 0), radius: 1.5mm, fill: black)
              for x in range(-470, 450, step: 13) {
                line((x / 1000, -2mm), ((x - 20) / 1000, 2mm))
              }
            }
          },
        )),
      )
    },
    //Margins, duh.
    margin: (top: 0.5in, bottom: 0.75in, left: 0.75in, right: 0.75in),
  )


  if (not body-only) {
    //Place CoverImage, if it exists
    if (CoverImg != none) {
      page(paper: "a4", header: none, footer: none, margin: 0pt)[
        #set image(height: 100%, fit: "stretch")
        #CoverImg
      ]
    }
    //Create Title Page (and eventual TOC)
    let onepage(body) = page(
      //Header is evenly LtR, no text
      header: context {
        align(
          center,
          layout(ly => cetz.canvas(
            length: ly.width,
            {
              import cetz.draw: *
              set-style(stroke: (paint: black, thickness: 0.75mm))
              line((-.45, 0), (.45, 0))
              circle((-.45, 0), radius: 1.5mm, fill: black)
              circle((.45, 0), radius: 1.5mm, fill: black)
              for x in range(-440, 430, step: 13) {
                line((x / 1000, -2mm), ((x + 20) / 1000, 2mm))
              }
            },
          )),
        )
      },
      //Footer is smaller and even LtR
      footer: context {
        set align(center)
        layout(ly => cetz.canvas(
          length: ly.width,
          {
            import cetz.draw: *
            set-style(stroke: (paint: black, thickness: 0.75mm))
            line((-.25, 0), (.25, 0))
            circle((-.25, 0), radius: 1.5mm, fill: black)
            circle((.25, 0), radius: 1.5mm, fill: black)
            for x in range(-240, 230, step: 13) {
              line((x / 1000, -2mm), ((x + 20) / 1000, 2mm))
            }
          },
        ))
      },
      body,
    )

    onepage[
      #set align(center)
      //The Big FC
      #KochFont(size: 75pt)[
        Flying\
        #box(rotate(90deg)[#scale(x: -100%)[$ theta.alt $]]) Circus #box(rotate(-90deg)[$ theta.alt $])
      ]

      //Title and description
      #text(size: 24pt)[
        #Desciption \
        #Title
      ]

      //Fancy swirls
      #text(size: 75pt)[
        #box(rotate(-90deg, reflow: true)[#scale(y: 300%, reflow: true)[$ sigma.alt $]]) #box(
          rotate(-90deg, reflow: true)[#scale(y: -300%, reflow: true)[$ sigma.alt $]],
        )
      ]

      #v(1fr)
      //Dedication is optional
      #Dedication
      #v(2fr)
      //And the Author, of course
      #text(size: 24pt)[
        #Author
        #v(1em)
      ]
    ]
    //Style outline
    // show outline.title: it => {
    //   text
    // }
    show outline.entry.where(level: 1): it => {
      v(10pt, weak: true)
      text(size: 20pt, it)
    }

    onepage[#align(
        center,
        box(
          width: 80%,
          outline(
            depth: 10,
            indent: 1em,
            title: KochFont(size: 50pt, fill: white, stroke: black + 1pt)[Contents #h(1fr)],
          ),
        ),
      )]
  }

  set par(justify: true)
  set text(hyphenate: false)
  //Set up headings (gotta be styled after #outline)
  show heading: it => {
    KochFont[#align(left)[#it.body]]
  }
  show heading.where(level: 1): it => {
    KochFont(size: 24pt)[#align(left)[#it.body]]
    v(-1.3em)
    line(length: 100%, stroke: 1pt + luma(100))
  }
  show heading.where(level: 2): it => {
    KochFont(size: 24pt)[#align(left)[#it.body]]
  }
  show heading.where(level: 3): it => {
    KochFont(size: 18pt)[#align(left)[#it.body]]
  }

  //Reset Page counter to 1, and let's go!
  counter(page).update(1)

  body
}

#let MaybeImage(img, ..args) = if (img != none) {
  [
    #set image(..args)
    #img
  ]
}

/// Defines the FlyingCircus Plane page.  Always on a new page. Image optional.
///
/// - Plane (dictionary): dictionary representing the plane stats.
/// - Nickname (str): Nickname to go under the aircraft name.
/// - Img (bytes | none): Image to go at the top of the page. Set to none to remove.
/// - BoxText (dictionary): Pairs of values to go in the box over the image. Does nothing if no Img provided.
/// - BoxAnchor (str): Which anchor of the image to put the box in?  Sample values are "north", "south-west", "center".
/// - DescriptiveText (content)
/// -> content
#let FCPlane(plane, Nickname: str, Img: defaultImg, BoxText: none, BoxAnchor: "north", DescriptiveText) = {
  pagebreak(weak: true)
  //Define image element
  let plane_image = if (Img != none) {
    context layout(ly => cetz.canvas(
      length: ly.width,
      {
        import cetz.draw: *
        content((0.5, 1), anchor: "north", MaybeImage(Img, width: page.width * 0.95, fit: "stretch"), name: "image")
        if (BoxText != none) {
          content(
            "image." + BoxAnchor,
            anchor: BoxAnchor,
            padding: 5mm,
            align(center)[
              #let cells = ()
              #for (k, v) in BoxText {
                cells.push(text(size: 12pt, eval(k, mode: "markup")))
                cells.push(text(size: 12pt, eval(v, mode: "markup")))
              }
              #table(align: left, columns: 2, fill: white.transparentize(50%), stroke: black, ..cells)
            ],
          )
        } else { }
      },
    ))
  }
  //Define title element
  let plane_title = {
    set text(fill: luma(100))
    set block(spacing: 0.1em)
    let hN = plane.keys().contains("Price")
    let hU = plane.keys().contains("Used")
    text(size: 20pt)[#plane.Name]
    h(1fr)
    if (hN) { [#plane.Price;þ New] }
    if (hN and hU) { [, ] }
    if (hU) { [#plane.Used;þ Used] }

    line(length: 100%, stroke: luma(100))

    [_\"#Nickname\"_ #h(1fr); #plane.Upkeep;þ]
  }

  //Read through the stat rows and push them into cells
  let cells = ()
  for row in plane.Stats {
    for (k, v) in row {
      if (k == "Name") {
        cells.push(table.cell([#v], align: right, stroke: none))
      } else {
        cells.push(table.cell([#v]))
      }
    }
  }
  //Construct the stats table element
  let statTable = table(
    columns: 6,
    align: center,
    table.cell(stroke: none)[],
    table.cell(stroke: none)[Boost],
    table.cell(stroke: none)[Handling],
    table.cell(stroke: none)[Climb],
    table.cell(stroke: none)[Stall],
    table.cell(stroke: none)[Speed],
    ..cells,
  )
  //Define the vital parts table element
  let vitalTable = table(
    columns: 100%,
    rows: (auto, 1fr),
    align: center + horizon,
    table.header(table.cell(stroke: none)[Vital Parts]),
    [#plane.at("Vital Parts") \ #plane.Crew],
  )
  //Define the secondary stats table element
  let miscTable = table(
    columns: 100%,
    align: center + horizon,
    [#plane.Propulsion],
    [#plane.Aerodynamics],
    [#plane.Survivability],
    table.cell(align: left + horizon, [#plane.Armament]),
  )

  place(top + left, box(width: 0pt, height: 0pt, hide[= #plane.Name]))
  grid(
    columns: 1,
    rows: (auto, 1fr, auto),
    grid.cell(
      align: center,
      [
        #plane_image
        #plane_title
        #v(-1em)
        #context stack(
          dir: ltr,
          spacing: 1%,
          box(width: 59%, height: measure(statTable).height, statTable),
          box(width: 40%, height: measure(statTable).height, vitalTable),
        )
        #v(-1em)
        #miscTable
      ],
    ),
    grid.cell(columns(2)[#DescriptiveText], inset: (y: 0.5em)),
    grid.cell(align(center)[#text(size: 24pt)[#underline[#link(plane.Link)[Plane Builder Link]]]]),
  )
}

/// Defines the FlyingCircus Simple Vehicle.  Not always a full page. Image optional.
///
/// - Vehicle (dictionary): dictionary representing the Vehicle stats.
/// - Img (bytes): Image to go above the vehicle.
/// - DescriptiveText (content)
/// -> content
#let FCVehicleSimple(vehicle, Img: none, DescriptiveText) = {
  //Define title element
  let veh_title = [
    #set par(leading: -1em)
    #set text(fill: luma(100))
    #set block(spacing: 0.1em)
    #link(vehicle.Link)[#text(size: 20pt)[#vehicle.Name]]; #h(1fr); #vehicle.Price;þ, #vehicle.Upkeep;þ Upkeep

    #line(length: 100%, stroke: luma(100))
  ]
  //Define image element
  let veh_image = align(center)[
    #MaybeImage(Img, width: 110%, fit: "stretch")
  ]
  //Define the stat table element
  let veh_stats = align(center)[#table(
      align: center + horizon,
      columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      [Speed],
      [#vehicle.Speed],
      [Torque],
      [#vehicle.Torque],
      [Handling],
      [#vehicle.Handling],
      [Armour],
      [#vehicle.Armour],
      [Integrity],
      [#vehicle.Integrity],
      [Safety],
      [#vehicle.Safety],
      [Reliability],
      [#vehicle.Reliability],
      [Fuel Uses],
      [#vehicle.at("Fuel Uses")],
      [Stress],
      [#vehicle.Stress],
      table.cell(colspan: 3, [#vehicle.Size]),
      table.cell(colspan: 3, [#vehicle.Cargo]),
    )
  ]
  let cells = ()
  for row in vehicle.Crew {
    for (idx, (k, v)) in row.pairs().enumerate() {
      if (idx == 0) {
        if (v.contains("Loader")) {
          cells.push(table.cell(stroke: none)[])
          cells.push(table.cell([#v]))
        } else {
          cells.push(table.cell(colspan: 2)[#v])
        }
      } else {
        cells.push(table.cell([#v]))
      }
    }
  }
  let veh_crew = table(
    align: (left, left, center, center, center, left),
    columns: (1em, auto, auto, auto, auto, 1fr),
    table.cell(stroke: none, []),
    table.cell(stroke: none, []),
    [Type],
    [Vis.],
    [Escape],
    [Notes],
    ..cells,
  )

  place(top + left, box(width: 0pt, height: 0pt, hide[= #vehicle.Name]))
  if (Img != none) {
    veh_image
    v(-1em)
  }
  veh_title
  DescriptiveText
  veh_stats
  v(-1em)
  align(center)[#KochFont(size: 18pt)[Crew]]
  v(-1em)
  veh_crew
}

/// Defines the FlyingCircus Plane page.  Always on a new page. Image optional.
/// If the Img is provided, it will take up two facing pages, otherwise only one, but a full page, unlike the Simple.
///
/// - Vehicle (dictionary): dictionary representing the Vehicle stats.
/// - Img (bytes | none): Image to go at the top of the first page. Set to none to remove.
/// - TextVOffset (length): How far to push the text down the page. Want to do that inset text thing the book does? You can, the text can overlap with thte image.  Does nothing if no Img provided.
/// - BoxText (dictionary): Pairs of values to go in the box over the image. Does nothing if no Img provided.
/// - BoxAnchor (str): Which anchor of the image to put the box in?  Sample values are "north", "south-west", "center".
/// - FirstPageContent (content): Goes on the first page. If no image is provided, it is not present.
/// - AfterContent (content): Goes after the stat block. Always present.
/// -> content
#let FCVehicleFancy(
  vehicle,
  Img: none,
  TextVOffset: 0pt,
  BoxText: none,
  BoxAnchor: "north",
  FirstPageContent,
  AfterContent,
) = {
  //Define image element is done below because it needs context.
  //Define Firsttitle element
  let veh_title = [
    #set par(leading: -1em)
    #set text(fill: luma(100), size: 24pt)
    #set block(spacing: 0.1em)
    #link(vehicle.Link)[#vehicle.Name]

    #line(length: 100%, stroke: luma(100))
  ]
  //Define title element
  let veh_title2 = align(center)[#box(width: 70%)[
      #set par(leading: -1em)
      #set text(fill: luma(100))
      #set block(spacing: 0.1em)
      #link(vehicle.Link)[#text(size: 20pt)[#vehicle.Name]]; #h(1fr); #vehicle.Price;þ

      #line(length: 100%, stroke: luma(100))

      #vehicle.Nickname;#h(1fr)Upkeep #vehicle.Upkeep;þ
    ]]
  //Define the stat table element
  let veh_stats = align(center)[#box(width: 70%)[
      #table(
        align: center + horizon,
        columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        table.cell(colspan: 2, [Speed]),
        table.cell(colspan: 2, [Torque]),
        table.cell(colspan: 2, [Handling]),
        table.cell(colspan: 2, [#vehicle.Speed]),
        table.cell(colspan: 2, [#vehicle.Torque]),
        table.cell(colspan: 2, [#vehicle.Handling]),
        table.cell(colspan: 2, [Armour]),
        table.cell(colspan: 2, [Integrity]),
        table.cell(colspan: 2, [Safety]),
        table.cell(colspan: 2, [#vehicle.Armour]),
        table.cell(colspan: 2, [#vehicle.Integrity]),
        table.cell(colspan: 2, [#vehicle.Safety]),
        table.cell(colspan: 2, [Reliability]),
        table.cell(colspan: 2, [Fuel Uses]),
        table.cell(colspan: 2, [Stress]),
        table.cell(colspan: 2, [#vehicle.Reliability]),
        table.cell(colspan: 2, [#vehicle.at("Fuel Uses")]),
        table.cell(colspan: 2, [#vehicle.Stress]),
        table.cell(colspan: 3, [#vehicle.Size]),
        table.cell(colspan: 3, [#vehicle.Cargo]),
      )
    ]]
  let cells = ()
  for row in vehicle.Crew {
    for (idx, (k, v)) in row.pairs().enumerate() {
      if (idx == 0) {
        if (v.contains("Loader")) {
          cells.push(table.cell(stroke: none)[])
          cells.push(table.cell([#v]))
        } else {
          cells.push(table.cell(colspan: 2)[#v])
        }
      } else {
        cells.push(table.cell([#v]))
      }
    }
  }
  let veh_crew = table(
    align: (left, left, center, center, center, left),
    columns: (1em, auto, auto, auto, auto, 1fr),
    table.cell(stroke: none, []),
    table.cell(stroke: none, []),
    [Type],
    [Vis.],
    [Escape],
    [Notes],
    ..cells,
  )
  //If we have an image, then this is a two-page thing
  if (Img != none) {
    pagebreak(weak: true, to: "even")
    page(
      background: align(top)[
        #context layout(ly => cetz.canvas(
          length: ly.width,
          {
            import cetz.draw: *
            content((0.5, 1), anchor: "north", MaybeImage(Img, width: page.width, fit: "stretch"), name: "image")
            if (BoxText != none) {
              content(
                "image." + BoxAnchor,
                anchor: BoxAnchor,
                padding: 1in,
                align(center)[
                  #let cells = ()
                  #for (k, v) in BoxText {
                    cells.push(text(size: 12pt, [#eval(k, mode: "markup"): #eval(v, mode: "markup")]))
                  }
                  #table(
                    align: left,
                    columns: 1,
                    fill: white.transparentize(50%),
                    stroke: none,
                    inset: (y: 0.25em),
                    table.hline(),
                    table.vline(x: 0),
                    table.vline(x: 1),
                    ..cells,
                    table.hline(),
                  ),
                ],
              )
            }
          },
        ))
      ],
      margin: (top: 0pt),
      header: none,
    )[
      #place(top + left, box(width: 0pt, height: 0pt, hide[= #vehicle.Name]))
      #v(TextVOffset)
      #veh_title
      #FirstPageContent
    ]
  }
  //Second page goes back to normal
  pagebreak()
  if (Img == none) {
    place(top + left, box(width: 0pt, height: 0pt, hide[= #vehicle.Name]))
  }
  veh_title2
  veh_stats
  align(center)[#KochFont(size: 18pt)[Crew]]
  v(-1em)
  veh_crew
  AfterContent
}

/// Defines the FlyingCircus Ship page.  Always on a new page. Image optional.
///
/// - Ship (dictionary): dictionary representing the Ship stats.
/// - Img (bytes | none): Image to go at the top of the page. Set to none to remove.
/// - DescriptiveText (content): Goes below the name and above the stats table.
/// - notes (content): Goes in the notes section.
/// -> content
#let FCShip(Ship: dictionary, Img: bytes, DescriptiveText, notes) = {
  pagebreak(weak: true)
  //Define image element
  let ship_image = align(center)[
    #MaybeImage(Img, width: 80%, fit: "contain")
  ]
  //Define title element
  let ship_title = KochFont(size: 24pt)[#Ship.Name]

  //Construct the stats table element
  let statTable = table(
    columns: (30%, 30%, 30%),
    align: center + horizon,
    // hlinex(end: 2, expand: (0pt, 1.9em)),
    [Speed],
    [Handling],
    [],
    // hlinex(end: 2, expand: (0pt, 0.8em)),
    [#Ship.Speed],
    [#Ship.Handling],
    [],
    // hlinex(end: 2, expand: (0pt, 0.3em)),
    [Hardness],
    [Soak],
    [],
    // hlinex(end: 2, expand: (0pt, 0em)),
    [#Ship.Hardness],
    [#Ship.Soak],
    table.cell(inset: (top: -2em, right: -2em, bottom: -3em))[
      #let data = ()
      #for s in Ship.DamageStates {
        data.push((value: 1, label: s))
      }
      #place(horizon, dy: -0.7cm, float: false)[
        #layout(ly => cetz.canvas(
          length: ly.width,
          {
            import cetz.draw: *
            import cetz-plot: *
            set-style(stroke: (paint: black))
            circle((0, 0), radius: 0.5, fill: white, stroke: none)
            chart.piechart(
              data,
              radius: 0.5,
              value-key: "value",
              label-key: "label",
              outer-label: (content: none),
              inner-label: (content: "LABEL", radius: 130%),
              slice-style: ((fill: white, stroke: black),),
              legend: (label: none),
            )
            line((0, 0), (0, 0.5), stroke: (thickness: 3pt))
          },
        ))
      ]
    ],
    // hlinex(end: 2, expand: (0pt, 0.1em)),
    [Strengths],
    [Weaknesses],
    [],
    // hlinex(end: 2, expand: (0pt, 0.4em)),
    [#Ship.Strengths],
    [#Ship.Weaknesses],
    [],
    // hlinex(end: 2, expand: (0pt, 1.0em)),
    // vlinex(x: 0),
    // vlinex(x: 1),
    table.vline(x: 2, stroke: none),
  )

  let cells = ()
  for weap in Ship.Weapons {
    cells.push([#weap.Name])
    for dir in ("Fore", "Left", "Right", "Rear", "Up") {
      cells.push([#weap.at(dir, default: "-")])
    }
  }
  let weaponTable = table(
    columns: (3fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    table.cell(stroke: none)[],
    [Fore],
    [Left],
    [Right],
    [Rear],
    [Up],
    ..cells,
  )

  place(top + left, box(width: 0pt, height: 0pt, hide[= #Ship.Name]))
  grid(columns: 1, rows: (auto, 1fr, auto), grid.cell([
      #ship_image
      #ship_title
      #v(0.5em)
    ]), grid.cell([#DescriptiveText
      #v(1.5em)
    ]), grid.cell([
      #statTable
      #align(center)[#KochFont(size: 18pt)[Weapons]]
      #weaponTable
      #align(center)[#KochFont(size: 18pt)[Notes]]
      #notes
    ]))
}

/// Defines the FlyingCircus Weapon card. Image optional.
///
/// - Weapon (dictionary): dictionary representing the Weapon stats.
/// - Img (bytes | none): Image to go above the card. Set to none to remove.
/// - DescriptiveText (content): Goes below the name and above the stats table.
/// -> content
#let FCWeapon(weapon, Img: none, DescriptiveText) = {
  place(top + left, box(width: 0pt, height: 0pt, hide[== #weapon.Name]))
  MaybeImage(Img)
  {
    set text(fill: luma(100))
    set block(spacing: 0.1em)
    text(size: 20pt)[#weapon.Name]
    h(1fr)
    weapon.Price
    line(length: 100%, stroke: luma(100))
  }
  DescriptiveText
  v(-1em)

  let cells = ()
  for (k, v) in weapon.Cells {
    cells.push(table.cell(fill: black)[#text(fill: white)[#k]])
    cells.push([#v])
  }
  table(
    columns: (1fr,) * (2 * weapon.Cells.len()),
    align: center + horizon,
    ..cells,
    table.cell(align: left, colspan: (2 * weapon.Cells.len()))[#weapon.Tags],
  )
}

#let HiddenHeading(body) = {
  show heading: it => []
  body
}



#let ac(a, b) = {
  (a.at(0) + b.at(0), a.at(1) + b.at(1))
}



#let FCPSection(title, content) = {
  block(
    spacing: 0.4em,
    inset: 2pt,
    stroke: (bottom: 1pt),
  )[#KochFont(size: 14pt)[#title]#h(1fr)#text(size: 10pt)[#emph[#content]]]
}

#let FCPRule() = {
  context if (here().position().x.inches() < 5.5) {
    block(spacing: 0.4em)[
      #line(start: (-0.19in, 0pt), length: 100% + 0.35in)
    ]
  } else {
    block(spacing: 0.4em)[
      #line(start: (-0.16in, 0pt), length: 100% + 0.26in)
    ]
  }
}

#let FCPStatTable(name, tagline, stats) = {
  set par(spacing: 0.6em)
  block(stroke: (bottom: 0.5pt), inset: (bottom: 0.75pt))[#smallcaps[#name]]
  emph[#tagline]
  let cells = (table.hline(stroke: 2pt), table.vline(stroke: 2pt))
  let cells2 = ()
  for (k, v) in stats {
    cells.push(table.cell(fill: black)[#text(fill: white)[#smallcaps[#k]]])
    cells2.push([#v])
  }
  cells.push(table.vline(stroke: 2pt))
  cells2.push(table.hline(stroke: 2pt))
  table(columns: (1fr,) * (stats.len()), align: center + horizon, ..cells, ..cells2)
}

#let FCPlaybook(
  Name: str,
  Subhead: str,
  Character: content,
  Questions: content,
  Starting: content,
  Stats: content,
  StatNames: (),
  Triggers: content,
  Vents: content,
  Intimacy: content,
  Moves: content,
) = {
  let pb_counter = counter("playbook")
  pb_counter.update(0)
  set page(
    paper: "a4",
    flipped: true,
    //Header is nothing
    header: none,
    //For the Playbook the background contains the header and lines.
    background: context {
      layout(ly => cetz.canvas(
        length: ly.width,
        {
          import cetz.draw: *
          set-style(stroke: (paint: black, thickness: 0.75mm))
          line((0, 0), (1, 0.7071), stroke: white)
          let topl = (0.3in, 7.9in)
          let topm = ac(topl, (5.6in, 0mm))
          let topr = ac(topl, (11.1in, 0mm))
          circle(topl, radius: 1.5mm, fill: black)
          circle(topr, radius: 1.5mm, fill: black)
          line(topl, topr)
          line(ac(topl, (0mm, 1.5mm)), ac(topr, (0mm, 1.5mm)), stroke: 0.5mm)
          line(ac(topl, (0mm, -1.5mm)), ac(topr, (0mm, -1.5mm)), stroke: 0.5mm)
          line(topm, ac(topm, (0mm, -7.58in)))

          set-style(stroke: (paint: black, thickness: 0.25mm))
          line(ac(topl, (0.3mm, 0mm)), ac(topl, (0.3mm, -8in)))
          line(ac(topl, (-0.3mm, 0mm)), ac(topl, (-0.3mm, -8in)))
          line(ac(topr, (0.3mm, 0mm)), ac(topr, (0.3mm, -8in)))
          line(ac(topr, (-0.3mm, 0mm)), ac(topr, (-0.3mm, -8in)))

          if (pb_counter.get().at(0) == 0) {
            rect(ac(topl, (0.3mm, -1.5mm)), ac(topm, (0mm, -2cm)), fill: black)
          }

          content(topm, KochFont(size: 18pt, stroke: 8pt + white)[Flying Circus])
          content(topm, KochFont(size: 18pt, stroke: 0.0pt + black)[Flying Circus])
        },
      ))
    },
    //Footer is alternating directions with page number at outside and only partial bar
    footer: context {
      align(
        center,
        layout(ly => cetz.canvas(
          length: ly.width,
          {
            import cetz.draw: *
            set-style(stroke: (paint: black, thickness: 0.75mm), fill: black)
            circle((-.5, 0), radius: 1.5mm, fill: black)
            circle((.5, 0), radius: 1.5mm, fill: black)
            for x in range(-470, 500, step: 10) {
              line((x / 1000, -2mm), ((x - 20) / 1000, 2mm))
            }

            set-style(stroke: (paint: black, thickness: 0.25mm))
            line((-.5, 0.5mm), (.5, 0.5mm))
            line((-.5, -0.5mm), (.5, -0.5mm))
            content((0, 0), KochFont(size: 20pt, stroke: 10pt + white)[#Name])
            content((0, 0), KochFont(size: 20pt, stroke: 0.0pt + black)[#Name])
          },
        )),
      )
    },
    //Margins, duh.
    margin: (top: 0.5in, bottom: 0.75in, left: 0.5in, right: 0.4in),
  )

  set text(size: 11pt)
  set par(justify: false)
  set par(spacing: 0.8em)
  set list(indent: 0pt, marker: [•], spacing: 0.6em)

  let barwidth = 100% + 0.3in - 0.3mm
  columns(2, gutter: 0.3in)[
    #v(-.16in)
    #align(center)[
      #box(
        width: barwidth,
        inset: (left: 0.25in, right: 0.25in, top: 0.2cm, bottom: 0.2cm),
        // outset:(top:0.16in),
      )[
        #set align(left)
        #set text(fill: white)
        #KochFont(size: 28pt)[#Name]\
        #h(1fr)#KochFont(size: 18pt)[#Subhead]
      ]
    ]
    #place(top + left, box(width: 0pt, height: 0pt, hide[= #Name]))
    #Character
    #colbreak()
    #Questions
    #FCPRule()
    #Starting
    #FCPRule()
    #v(1fr)
    #align(center)[
      _Choose, and add +1 to a stat._
      #columns(2, gutter: 0.5in)[
        #Stats
      ]
    ]
  ]
  pb_counter.step()
  pagebreak()
  columns(2, gutter: 0.3in)[
    #box(width: 45%)[
      #FCPSection("")[]
      #KochFont(size: 14pt)[Name]
      #columns(2, gutter: 0.1in)[
        #FCPSection("")[]
        #KochFont(size: 14pt)[Age]
        #colbreak()
        #FCPSection("")[]
        #KochFont(size: 14pt)[Pronouns]
      ]
    ]#h(5%)#box(width: 50%)[
      #layout(ly => cetz.canvas(
        length: (ly.width / (StatNames.len() + 1)),
        {
          import cetz.draw: *
          set-style(stroke: (paint: black, thickness: 0.5mm), content: (padding: 0.1))
          line((0, -1cm), (0, 1cm), name: "L", stroke: (paint: white))
          for (idx, sn) in StatNames.enumerate() {
            circle((1.25 * idx + 0.5, 0.5), radius: 0.5, name: "S")
            content((name: "S", anchor: "south"), [#sn], anchor: "north")
          }
        },
      ))
    ]
    #FCPRule()
    #box(baseline: -4pt)[#KochFont(size: 16pt)[Stress ]] #box(width: 60%)[#cetz.canvas(
        length: 8cm,
        {
          import cetz.draw: *
          rect((0.4, -10pt), (1, 10pt), fill: black)
          circle((0.05, 0), radius: 7pt, fill: white)
          circle((0.15, 0), radius: 7pt, fill: white)
          circle((0.25, 0), radius: 7pt, fill: white)
          circle((0.35, 0), radius: 7pt, fill: white)
          circle((0.45, 0), radius: 7pt, fill: white)
          circle((0.55, 0), radius: 7pt, fill: white)
          circle((0.65, 0), radius: 7pt, fill: white)
          circle((0.75, 0), radius: 7pt, fill: white)
          circle((0.85, 0), radius: 7pt, fill: white)
          circle((0.95, 0), radius: 7pt, fill: white, stroke: (paint: white, dash: (0.5pt, 0.5pt), thickness: 0.03))
        },
      )] #box(baseline: -4pt)[#KochFont(size: 16pt)[XP ]] #box(width: 1fr)[#cetz.canvas(
        length: 3cm,
        {
          import cetz.draw: *
          rect((0, -10pt), (1, 10pt))
        },
      )]
    #columns(2)[
      #Triggers
      #colbreak()
      #Vents
    ]

    #FCPRule()
    #grid(
      columns: (auto, auto),
      gutter: 1em,
      grid.cell(inset: (bottom: 1em, right: 1em))[#FCPSection([Comrades#h(100fr)Trust?])[]
        #align(right)[#text(size: 30pt)[
            ○\
            ○\
            ○\
            ○
          ]]],
      grid.vline(),
      grid.cell(inset: (bottom: 1em, left: 1em))[#FCPSection("Familiar Vices")[]
      ],
    )

    #FCPRule()
    #Intimacy
    #colbreak()
    #Moves
  ]
}




#let FCShortNPC(plane, img: none, img_scale: 1.5, img_shift_dx: -10%, img_shift_dy: -10%, content) = {
  let plane_title = {
    set text(fill: luma(100))
    set block(spacing: 0.1em)
    let hN = plane.keys().contains("Price")
    let hU = plane.keys().contains("Used")
    let hUp = plane.keys().contains("Upkeep")
    text(size: 20pt)[#plane.Name]
    h(1fr)
    if (hN) { [#plane.Price;þ New] }
    if (hN and hU) { [, ] }
    if (hU) { [#plane.Used;þ Used] }

    line(length: 100%, stroke: luma(100))

    [_\"#plane.Nickname\"_ #h(1fr); #if (hUp) { [#plane.Upkeep;þ Upkeep] }]
  }

  plane_title
  grid(columns: (1fr, 3fr), grid.cell(
      align: right,
      place(
        auto,
        float: true,
        scope: "parent",
        dx: img_shift_dx,
        dy: img_shift_dy,
        layout(ly => cetz.canvas(
          length: ly.width,
          {
            import cetz.draw: *
            content((0, 0.0), (img_scale, 1), img)
          },
        )),
      ),
    ), [
      #emph(content)
      #table(
        align: center,
        columns: (2fr, 1fr, 1fr),
        [Speeds],
        [Handling],
        [Structure],
        [#plane.Speeds],
        [#plane.Handling],
        [#plane.Structure],
        table.cell(align: left, colspan: 3, plane.Notes),
      )
    ])
}


#let FCShortAirship(airship, img: none, img_scale: 1.5, img_shift_dx: -10%, img_shift_dy: -10%, content) = {
  let title = {
    set text(fill: luma(100))
    set block(spacing: 0.1em)
    let hN = airship.keys().contains("Price")
    let hU = airship.keys().contains("Used")
    let hUp = airship.keys().contains("Upkeep")
    text(size: 20pt)[#airship.Name]
    h(1fr)
    if (hN) { [#airship.Price;þ New] }
    if (hN and hU) { [, ] }
    if (hU) { [#airship.Used;þ Used] }

    line(length: 100%, stroke: luma(100))

    [_\"#airship.Nickname\"_ #h(1fr); #if (hUp) { [#airship.Upkeep;þ Upkeep] }]
  }

  title
  grid(columns: (1fr, 3fr), grid.cell(
      align: right,
      place(
        auto,
        float: true,
        scope: "parent",
        dx: img_shift_dx,
        dy: img_shift_dy,
        layout(ly => cetz.canvas(
          length: ly.width,
          {
            import cetz.draw: *
            content((0, 0.0), (img_scale, 1), img)
          },
        )),
      ),
    ), [
      #emph(content)
      #table(
        align: center,
        columns: (1fr, 1fr, 1fr, 1fr),
        [Max Speed],
        [Lift],
        [Handling],
        [Toughness],
        [#airship.Speed],
        [#airship.Lift],
        [#airship.Handling],
        [#airship.Toughness],
        table.cell(align: left, colspan: 4, airship.Notes),
      )
    ])
}
