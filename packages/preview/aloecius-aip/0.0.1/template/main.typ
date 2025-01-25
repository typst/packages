#import "@preview/aloecius-aip:0.0.1": *

#show: article.with(
  title: "Typst Template for Journal of Chemical Physics (Draft)",
  authors: (
    "Author 1": author-meta(
      "GU",
      email: "user1@domain.com",
    ),
    "Author 2": author-meta(
      "GU",
      cofirst: false
    ),
    "Author 3": author-meta(
      "UG"
    )
  ),
  affiliations: (
    "UG": "University of Global Sciences",
    "GU": "Institute for Chemistry, Global University of Sciences"
  ),
  abstract: [
  Here goes the abstract. This is the unofficial AIP like template for drafting papers of physics, computational chemistry etc. but mainly for Journal of Chemical Physics. Author of this template do not claim any link to AIP or other associates of AIP. It is a trial to mimic the the draft version of AIP LaTeX template present in overleaf.
  ],
  bib: bibliography("./reference.bib")
)

= Introduction
#indent
This work has been going on for years and it had impacted the field with so many different new things. I have been working for 34 years and this is what we are going to discuss. Every section needs to be started with this `#indent` variable because it is a dirty workaround to add an indent for the first paragraph.

From the next paragraph the indent is automatically added, just make a line gap by pressing `enter` and done. Or one can also use instead the `#parbreak()` function to achieve the same functionality.
#parbreak()
The same outcome, do whatever suits you but I feel the line break by a keyboard input is more natural. Cheers!
= Methods
#indent
This is a very fancy method that obeys the Einstein's Mass and Energy equivalence relations, the following equation is by default numbered as `(1)` 

$
E = m times c^2
$<eq1>

one can label the equation through `<eq1>` macro and refer in the body of the text as shown in @eq1 by invoking another macro `@eq1`. Line equation is also possible $E=m c^2$. For more go to the #link("https://typst.app/docs/reference/math/")[typst math docs].

Also one can write chemical formulae with the help of #link("https://typst.app/universe/package/whalogen")[whalogen] package with the `#ce()` function that would produce the result #ce("NO2^2+"). If one fancies some physics stuff it is also available through the #link("https://typst.app/universe/package/physica")[physica] package. 

$
A = mat(1,2,3,4;1,2,3,4;2,3,4,6;5,4,6,7)
$

or some fancy stuff like the following. For more please read the documentation of the above mentioned packages

$
H(f) = hmat(f;x,y,z; big:#true)
$


== Some Fancy Method explanation
//#linebreak()#indent
There is a fancy method that is taken from some fancy article which can be cited like `@liebLowerBound1979` @liebLowerBound1979 and it would automatically be reflected in the *References* section. Some diagrams can be drawn using the `cetz` package in `typst` like some fancy 

#align(center)[
  #v(0.4em)
  #cetz.canvas({
    import cetz.draw: *
    let up-height = 2.0
    let down-height = -2.0
    line((-4,0),(-3,0), stroke: (thickness: 1.75pt))
    content((-5,0), [*1s*])
    line((4,0),(3,0), stroke: (thickness: 1.75pt))
    content((5,0),[*1s*])
    line((-0.5,up-height),(0.5,up-height), stroke: (thickness: 1.75pt))
    content((1.5,up-height),$sigma^*$)
    line((-0.5,down-height),(0.5,down-height), stroke: (thickness: 1.75pt))
    content((1.5,down-height),$sigma$)
    line((-3,0),(-0.5,up-height), stroke: (dash: "dashed"))
    line((3,0),(0.5,up-height), stroke: (dash: "dashed"))
    line((3,0),(0.5,down-height), stroke: (dash: "dashed"))
    line((-3,0),(-0.5,down-height), stroke: (dash: "dashed"))
    line((-3.3,0.5),(-3.3,-0.5),mark:(start: ">", fill: black), stroke:(thickness: 0.5pt))
    line((3.7,0.5),(3.7,-0.5),mark:(start: ">", fill: black), stroke:(thickness: 0.5pt))
    let start-elec-up = up-height + 0.5
    let end-elec-up = up-height - 0.5
    let start-elec-down = down-height - 0.5
    let end-elec-down = down-height + 0.5
    line((0.2,start-elec-down),(0.2,end-elec-down),mark:(start: ">", fill: black), stroke:(thickness: 0.5pt))
    line((-0.2,start-elec-down),(-0.2,end-elec-down),mark:(end: ">", fill: black), stroke:(thickness: 0.5pt))
  })
  Figure 1: A Fancy Molecular Orbital Diagram
]

= Results
#indent
Some interesting results can be shown be shown through plots like the following
#figure(
  image("./plot.svg", width: 60%),
  caption:[Fancy Plot]
)

Some can represent the numbers in a table like the following

#align(center)[
    #table(
      columns: (auto, auto, auto),
      align: center + horizon,
      table.header(
        [column 1], [column 2], [column 3],
      ),
      [1],[2],[5],
      [2],[3],[6],
      [3],[4],[5]
    )
    Table 1 : A Thought Provoking Table
]

= Conclusions
#indent
There are still some things off and there should be more to do with this template, I am open to suggestions and feedback. And feel free to customize this template to do anything else.

= Acknowledgements
#indent
Author of the template is really thankful to the packages that has been used here which are listed below (ordering is irrelevant)

- `physica`
- `whalogen`
- `cetz`

Also the author thank the "journal starter article" template in typst template repository which got this started

https://typst.app/universe/package/starter-journal-article

