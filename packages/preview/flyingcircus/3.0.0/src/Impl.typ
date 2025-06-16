#import "@preview/cetz:0.2.2"
#import "@preview/cuti:0.2.1": regex-fakeitalic
#import "@preview/tablex:0.0.8": gridx, cellx, hlinex, vlinex

/// Sets the tex to the Koch Fette FC font for people who don't want to remember that.
///
/// - body (content)
/// - ..args: Any valid argument to the text function
/// -> content
#let KochFont(body, ..args) = text(..args)[#text(font: "Koch Fette FC")[#body]]

#let defaultImg = read("images/Default.png", encoding: none)

/// Defines the FlyingCircus template
///
/// - Title (str): Title of the document. Goes in metadata and on title page.
/// - Author (str): Author(s) of the document. Goes in metadata and on title page.
/// - CoverImg (bytes): Image to make the first page of the document.
/// - Description (str): Text to go with the title on the title page.
/// - Dedication (str): Dedication to go down below the title on the title page.
/// - body (content)
/// -> content
#let FlyingCircus(Title: str, Author: str, CoverImg: none, Desciption: "Aircraft Catalogue", Dedication: "", body) = {
  //Set PDF Metadata
  set document(title: Title, author: Author)
  //Set Default Font document settings
  set text(font: "Balthazar", size: 14pt)
  show par: set block(spacing: 0.5em)
  set par(leading: 0.35em)
  set par(justify: true)
  set list(indent: 1em)
  set enum(indent: 1em)
  set page(numbering: "1")
   
  //Create fake italics because fonts don't have it.
  show emph: it => {
    regex-fakeitalic(it.body)
  }
   
  //Replace Synchronization Marker
  show regex("✣"): text(font: "Wingdings", [Ë])
   
  //Create default page format
  set page(
    paper: "a4",
    //Header is alternating directions and the centered "Flying Circus" with border
    header: context{
      align(center, cetz.canvas(length: 100%, {
        import cetz.draw:*
        set-style(stroke: (paint: black, thickness: 0.75mm))
        line((-.5, 0), (.5, 0))
        circle((-.5, 0), radius: 1.5mm, fill: black)
        circle((.5, 0), radius: 1.5mm, fill: black)
        if (calc.rem(counter(page).get().first(), 2) == 1) {
          for x in range(-490, 480, step: 13){
            line((x / 1000, -2mm), ((x + 20) / 1000, 2mm))
          }
        } else {
          for x in range(-470, 500, step: 13){
            line((x / 1000, -2mm), ((x - 20) / 1000, 2mm))
          }
        } 
        content((0, 1pt), KochFont(stroke: 5pt + white)[Flying Circus])
        content((0, 1pt), KochFont(stroke: 0.5pt + black)[Flying Circus])
      }))
    },
    //Footer is alternating directions with page number at outside and only partial bar
    footer: context{
      align(center, cetz.canvas(length: 100%, {
        import cetz.draw:*
        set-style(stroke: (paint: black, thickness: 0.75mm))
        if (calc.rem(counter(page).get().first(), 2) == 1) {
          content((-.5, 0), KochFont(size: 18pt)[#counter(page).get().first()])
           
          line((-.45, 0), (.5, 0))
          circle((-.45, 0), radius: 1.5mm, fill: black)
          circle((.5, 0), radius: 1.5mm, fill: black)
          for x in range(-440, 480, step: 13){
            line((x / 1000, -2mm), ((x + 20) / 1000, 2mm))
          }
        } else {
          content((.5, 0), KochFont(size: 18pt)[#counter(page).get().first()])
           
          line((-.5, 0), (.45, 0))
          circle((-.5, 0), radius: 1.5mm, fill: black)
          circle((.45, 0), radius: 1.5mm, fill: black)
          for x in range(-470, 450, step: 13){
            line((x / 1000, -2mm), ((x - 20) / 1000, 2mm))
          }
        }
      }))
    },
    //Margins, duh.
    margin: (top: 0.5in, bottom: 0.75in, left: 0.75in, right: 0.75in),
  )
   
   
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
    header: context{
      align(center, cetz.canvas(length: 100%, {
        import cetz.draw:*
        set-style(stroke: (paint: black, thickness: 0.75mm))
        line((-.45, 0), (.45, 0))
        circle((-.45, 0), radius: 1.5mm, fill: black)
        circle((.45, 0), radius: 1.5mm, fill: black)
        for x in range(-440, 430, step: 13){
          line((x / 1000, -2mm), ((x + 20) / 1000, 2mm))
        }
      }))
    },
    //Footer is smaller and even LtR
    footer: context{
      set align(center)
      cetz.canvas(length: 100%, {
        import cetz.draw:*
        set-style(stroke: (paint: black, thickness: 0.75mm))
        line((-.25, 0), (.25, 0))
        circle((-.25, 0), radius: 1.5mm, fill: black)
        circle((.25, 0), radius: 1.5mm, fill: black)
        for x in range(-240, 230, step: 13){
          line((x / 1000, -2mm), ((x + 20) / 1000, 2mm))
        }
      })
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
    #text(
      size: 75pt,
    )[
      #box(rotate(-90deg, reflow: true)[#scale(y: 300%, reflow: true)[$ sigma.alt $]]) #box(rotate(-90deg, reflow: true)[#scale(y: -300%, reflow: true)[$ sigma.alt $]]) 
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
        outline(depth: 10, indent: 1em, title: KochFont(size: 50pt, fill: white, stroke: black + 1pt)[Contents #h(1fr)]),
      ),
    )]
   
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
/// - Plane (str | dictionary): JSON string or dictionary representing the plane stats.
/// - Nickname (str): Nickname to go under the aircraft name.
/// - Img (bytes | none): Image to go at the top of the page. Set to none to remove.
/// - BoxText (dictionary): Pairs of values to go in the box over the image. Does nothing if no Img provided.
/// - BoxAnchor (str): Which anchor of the image to put the box in?  Sample values are "north", "south-west", "center".
/// - DescriptiveText (content)
/// -> content
#let FCPlane(Plane, Nickname: str, Img: defaultImg, BoxText: none, BoxAnchor: "north", DescriptiveText) = {
  pagebreak(weak: true)
  let plane = Plane
  //Read in json.decode file if it's a path
  if (type(Plane) == str) {
    plane = json.decode(Plane)
  }
  //Define image element
  let plane_image = if (Img != none) {
    context cetz.canvas(
      length: 100%,
      {
        import cetz.draw:*
        content((0.5, 1), anchor: "north", MaybeImage(Img, width: page.width * 0.95, fit: "stretch"), name: "image") 
        if (BoxText != none) {
          content("image." + BoxAnchor, anchor: BoxAnchor, padding: 5mm, align(center)[
            #let cells = (hlinex(),)
            #for (k, v) in BoxText {
              cells.push(text(size: 12pt, k))
              cells.push(text(size: 12pt, v))
              cells.push(hlinex())
            }
            #gridx(columns: 2, fill: white.transparentize(50%), stroke: luma(170), vlinex(x: 0), vlinex(x: 2), ..cells)
          ])
        }
      },
    )
  }
  //Define title element
  let plane_title = {
    set text(fill: luma(100))
    set block(spacing: 0em)
    let hN = plane.keys().contains("Price")
    let hU = plane.keys().contains("Used")
    text(size: 20pt)[#plane.Name];h(1fr); if (hN) { [#plane.Price;þ New] }; if (hN and hU) { [, ] }; if (hU) { [#plane.Used;þ Used] }
     
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
    columns: (100%),
    rows: (auto, 1fr),
    align: center + horizon,
    table.header(table.cell(stroke: none)[Vital Parts]),
    [#plane.at("Vital Parts") \ #plane.Crew],
  )
  //Define the secondary stats table element
  let miscTable = table(
    columns: (100%),
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
        #context stack(dir: ltr, spacing: 1%, box(width:59%, height:measure(statTable).height, statTable), box(width: 40%,
        height: measure(statTable).height, vitalTable))
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
/// - Vehicle (str | dictionary): JSON string or dictionary representing the Vehicle stats.
/// - Img (bytes): Image to go above the vehicle.
/// - DescriptiveText (content)
/// -> content
#let FCVehicleSimple(Vehicle, Img: none, DescriptiveText) = {
  //Read in the Vehicle JSON file
  let vehicle = Vehicle;
  if (type(Vehicle) == str) {
    vehicle = json.decode(Vehicle)
  }
  //Define title element
  let veh_title = par(leading: -1em)[
    #set text(fill: luma(100))
    #set block(spacing: 0em)
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
    for (idx, (k, v),) in row.pairs().enumerate() {
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
/// - Vehicle (str | dictionary): JSON string or dictionary representing the Vehicle stats.
/// - Img (bytes | none): Image to go at the top of the first page. Set to none to remove.
/// - TextVOffset (length): How far to push the text down the page. Want to do that inset text thing the book does? You can, the text can overlap with thte image.  Does nothing if no Img provided.
/// - BoxText (dictionary): Pairs of values to go in the box over the image. Does nothing if no Img provided.
/// - BoxAnchor (str): Which anchor of the image to put the box in?  Sample values are "north", "south-west", "center".
/// - FirstPageContent (content): Goes on the first page. If no image is provided, it is not present.
/// - AfterContent (content): Goes after the stat block. Always present.
/// -> content
#let FCVehicleFancy(Vehicle, Img: none, TextVOffset: 0pt, BoxText: none, BoxAnchor: "north", FirstPageContent, AfterContent) = {
  //Read in the Vehicle JSON file
  let vehicle;
  if (type(Vehicle) == str) {
    vehicle = json.decode(Vehicle)
  }
  //Define image element is done below because it needs context.
   
  //Define Firsttitle element
  let veh_title = par(leading: -1em)[
    #set text(fill: luma(100), size: 24pt)
    #set block(spacing: 0em)
    #link(vehicle.Link)[#vehicle.Name]
     
    #line(length: 100%, stroke: luma(100))
  ]
  //Define title element
  let veh_title2 = align(center)[#box(width: 70%)[#par(leading: -1em)[
        #set text(fill: luma(100))
        #set block(spacing: 0em)
        #link(vehicle.Link)[#text(size: 20pt)[#vehicle.Name]]; #h(1fr); #vehicle.Price;þ
         
        #line(length: 100%, stroke: luma(100))
         
        #vehicle.Nickname;#h(1fr)Upkeep #vehicle.Upkeep;þ
      ]]]
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
    for (idx, (k, v),) in row.pairs().enumerate() {
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
      background: align(
        top,
      )[
        #context cetz.canvas( length: 100%, { import cetz.draw:*
        content((0.5, 1), anchor: "north", MaybeImage(Img, width: page.width, fit: "stretch"), name: "image"); if (BoxText !=
        none) { content("image." + BoxAnchor, anchor: BoxAnchor, padding: 1in, align(center)[
        #let cells = ()
        #for (k, v) in BoxText {
          cells.push(text(size: 12pt, [#k: #v]))
        }
        #gridx(
          columns: 1,
          fill: white.transparentize(50%),
          stroke: black,
          vlinex(x: 0),
          vlinex(x: 1),
          hlinex(y: 0),
          ..cells,
          hlinex(),
        ), ]) } }, )
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
/// - Ship (str | dictionary): JSON string or dictionary representing the Ship stats.
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
  let statTable = gridx(
    columns: (30%, 30%, 30%),
    align: center + horizon,
    hlinex(end: 2, expand: (0pt, 1.9em)),
    [Speed],
    [Handling],
    cellx(rowspan: 6, inset: (top: -2em, right: -2em, bottom: -3em))[
      #let data = ()
      #for s in Ship.DamageStates {
        data.push((value: 1, label: s))
      }
      #cetz.canvas(length: 100%, {
        import cetz.draw: *
        import cetz.chart
        set-style(stroke: (paint: black))
        chart.piechart(
          data,
          radius: 0.5,
          value-key: "value",
          label-key: "label",
          outer-label: (content: none),
          inner-label: (content: "LABEL", radius: 130%),
          slice-style: ((fill: white, stroke: black),),
        )
        line((0, 0), (0, 0.5), stroke: (thickness: 3pt))
      })
    ],
    hlinex(end: 2, expand: (0pt, 0.8em)),
    [#Ship.Speed],
    [#Ship.Handling],
    hlinex(end: 2, expand: (0pt, 0.3em)),
    [Hardness],
    [Soak],
    hlinex(end: 2, expand: (0pt, 0em)),
    [#Ship.Hardness],
    [#Ship.Soak],
    hlinex(end: 2, expand: (0pt, 0.1em)),
    [Strengths],
    [Weaknesses],
    hlinex(end: 2, expand: (0pt, 0.4em)),
    [#Ship.Strengths],
    [#Ship.Weaknesses],
    hlinex(end: 2, expand: (0pt, 1.0em)),
    vlinex(x: 0),
    vlinex(x: 1),
  )
  // let statTable = grid(columns:(30%,30%,30%), align: center+horizon,
  // grid.hline(end:2, expand:15%+1em)
  // )
  let cells = ()
  for weap in Ship.Weapons {
    cells.push([#weap.Name])
    for dir in ("Fore", "Left", "Right", "Rear", "Up"){
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
  ]), grid.cell([#DescriptiveText]), grid.cell([
    #statTable
    #align(center)[#KochFont(size: 18pt)[Weapons]]
    #weaponTable
    #align(center)[#KochFont(size: 18pt)[Notes]]
     
    #notes
  ]))
}

/// Defines the FlyingCircus Weapon card. Image optional.
///
/// - Weapon (str | dictionary): JSON string or dictionary representing the Weapon stats.
/// - Img (bytes | none): Image to go above the card. Set to none to remove.
/// - DescriptiveText (content): Goes below the name and above the stats table.
/// -> content
#let FCWeapon(Weapon, Img: none, DescriptiveText)={
  let weapon = Weapon
  //Read in json.decode file if it's a path
  if (type(Weapon) == str) {
    weapon = json.decode(Weapon)
  }
  place(top + left, box(width: 0pt, height: 0pt, hide[== #weapon.Name]))
  MaybeImage(Img)
  {
    set text(fill: luma(100))
    set block(spacing: 0em)
    text(size: 20pt)[#weapon.Name]; h(1fr); weapon.Price
    line(length: 100%, stroke: luma(100))
  }
  DescriptiveText
  v(-1em)
   
  let cells = ()
  for (k, v) in Weapon.Cells {
    cells.push(table.cell(fill: black)[#text(fill: white)[#k]])
    cells.push([#v])
  }
  table(
    columns: (1fr,) * (2 * Weapon.Cells.len()),
    align: center + horizon,
    ..cells,
    table.cell(align: left, colspan: (2 * Weapon.Cells.len()))[#Weapon.Tags],
  )
}

#let HiddenHeading(body) = {
  show heading: it => []
  body
}