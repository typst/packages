#let dir = "../../template/"
#let image(file, ..args) = std.image(dir + file, ..args)
#let config-file = dir + "paper.toml"
#let config = toml(config-file)
#let extra = toml(bytes(
  read(config-file)
    .split(regex("\\n\\n"))
    .filter(part => part.starts-with("# [[authors]]\n"))
    .map(x => x.split("\n").map(line => line.replace(regex("^#\\s*"), "")))
    .flatten()
    .join("\n"),
))
#(config.authors += extra.authors)
#import "../../ijimai.typ": *
#show: ijimai.with(
  config: config,
  bibliography: "bibliography.yaml",
  read: path => read-raw(dir + path),
)

= Introduction
Typst is a new markup-based typesetting system for the sciences. It is designed to be an alternative both to advanced tools like LaTeX and simpler tools like Word and Google Docs. Our goal with Typst is to build a typesetting tool that is highly capable and a pleasure to use @Madje2022 @Haug2022. An axes is shown in @axes.

#figure(
  image("axes.svg", width: 69%),
  caption: [Coordinate system used in the problem],
) <axes>


== Subsection title
#lorem(39)
Reference to equation: @eq.
$ G_(mu nu) + Lambda g_(mu nu) = kappa T_(mu nu) $ <eq>
#no-indent[where:]
- $G_(mu nu)$ is the Einstein tensor, and
- $T_(mu nu)$ is the stress–energy tensor.

Reference to equation: @ppt.

#figure(
  table(
    columns: (1fr, 9em, 4cm),
    inset: 3pt,
    align: horizon,
    table.header(..([], [Volume], [Parameters]).map(strong)),

    image("cylinder.svg", width: 0.8cm),
    $ pi h (D^2 - d^2) / 4 $,
    [
      $h$: height \
      $D$: outer radius \
      $d$: inner radius
    ],

    image("tetrahedron.svg", width: 0.8cm), $ sqrt(2) / 12 a^3 $, [$a$: edge length],
  ),
  caption: [Timing Results],
) <ppt>

= CRediT authorship contribution statement

= Data statement
State the availability of the data used in the research. If data is not available, provide the reason. Providing access to data increases transparency, encourages trust and facilitates reproducing results.

= Declaration of conflicts of interest
A conflict of interest (COI) refers to situations where any authors’ circumstance could influence the content and conclusions of their article. Disclosing COI is crucial to maintain transparency and trust in academic publishing, allowing to assess potential biases and the integrity of the research. If there are no conflicts of interest to declare, authors should state “No conflict of interest exists” or “We have no conflict of interest to declare”.

= Acknowledgment
In this section you can thank all those who have helped in undertaking the research work. We advise to express your gratitude in a concise way and to avoid strong emotive language.

Funding: Regarding funding sources, it is compulsory to disclose any funding sources for the research and/or preparation of the article. Indicate the funding agency(ies) and the code(s) of the project(s) under which the research leading to the published work was carried out. If no funding has been provided for the research, include the following sentence: “This research did not receive funding”.
