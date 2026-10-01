#import "../lib.typ": presentation

#let slides = presentation(
  secondary-logo: "../assets/oxford-rse-square.svg",
)
#let hero = "../assets/presentation-hero-john-cairns.png"
#let credit = [OUImages/John Cairns]
#let rse-graphic = [#circle(radius: 1in, fill: rgb("#1D42A6"))]

#(slides.title_image)(
  [Research software#linebreak()at Oxford],
  hero,
  credit: credit,
)

#(slides.title)(
  [A University of Oxford template],
  subtitle: [YOUR NAME · AUGUST 2026],
  dark: true,
)

#(slides.title)(
  [Research software#linebreak()that supports Oxford's work],
  subtitle: [YOUR NAME · AUGUST 2026],
)

#(slides.section)([What we do])

#(slides.text_only)(
  [Software is part of modern research],
  lead: [Research software engineering makes code a reliable research instrument.],
  panel: true,
  body: [
    • Build robust tools for researchers and research groups.#linebreak()
    • Improve quality, reproducibility and long-term sustainability.#linebreak()
    • Share expertise across disciplines and institutions.
  ],
)

#(slides.two_column)(
  [Two complementary approaches],
  [Embedded collaboration],
  [Work directly with research teams to make software practical and sustainable.],
  [Community capability],
  [Share tools, standards and expertise across the University.],
)

#(slides.three_column)(
  [A clear delivery model],
  [Discover],
  [Understand research needs and define a practical technical approach.],
  [Develop],
  [Build, test and release software with researchers.],
  [Sustain],
  [Improve, maintain and share the resulting tools.],
)

#(slides.box_grid)(
  [A shared research-software service],
  (
    [Research teams],
    [Research Software Engineering],
    [University technology services],
    [External collaborators],
  ),
  highlighted: (2,),
  deactivated: (4,),
)

#(slides.box_grid)(
  [From idea to sustainable software],
  (
    [Discover research needs],
    [Design a practical approach],
    [Build and test],
    [Release, maintain and share],
  ),
  nrows: 4,
  ncols: 1,
  highlighted: (3,),
  deactivated: (4,),
)

#(slides.box_grid)(
  [A portfolio of support],
  (
    [Consultancy], [Embedded collaborations], [Training],
    [Community practice], [Research infrastructure], [Open-source tools],
  ),
  nrows: 2,
  ncols: 3,
  highlighted: (2, 5),
  deactivated: (6,),
)

#(slides.text_figure)(
  [A practical partnership],
  lead: [Embedded expertise alongside research teams.],
  body: [We help turn research ideas into maintainable software, then support teams as their needs grow.],
  picture: hero,
  credit: credit,
)

#(slides.two_column_figure)(
  [Support across the software lifecycle],
  [Plan and design],
  [Define needs, choose approaches and make good technical decisions.],
  [Build and sustain],
  [Develop, test, release and maintain research software.],
  picture: hero,
  credit: credit,
)

#(slides.image_caption)(
  hero,
  [This is a long line of text designed to try an break the template I have created. I can see that it wraps well but does it continue to wrap if I write many many lines? I will continue to write text until I get bored of typing. Which is starting to happen.],
  credit: credit,
)

#(slides.figure)(picture: hero, credit: credit)

#(slides.visual_caption)(
  [A command-line workflow],
  visual: [
    #block(width: 11.44in, fill: rgb("#211D1C"), inset: 0.3in)[
      #text(font: ("Menlo", "Courier New"), size: 15pt, fill: white)[
        #raw("$ typst compile examples/dummy-presentation.typ output/presentation.pdf --root .", block: true)
      ]
    ]
  ],
)

#(slides.text_figure)(
  [A connected service],
  lead: [One team, working with many research communities.],
  body: [The group connects researchers, software practice and the wider University technology ecosystem.],
  visual: rse-graphic,
)

#(slides.contact)(
  [University of Oxford],
  [Research Software Engineering Group],
  [rse.ox.ac.uk],
  social: [#text("@")UniofOxford University of Oxford#linebreak()#text("@")oxford_uni University of Oxford],
  dark: true,
)

#(slides.contact)(
  [University of Oxford],
  [Research Software Engineering Group],
  [rse.ox.ac.uk],
  social: [#text("@")UniofOxford University of Oxford#linebreak()#text("@")oxford_uni University of Oxford],
)
