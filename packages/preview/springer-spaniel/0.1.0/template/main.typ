#import "@preview/springer-spaniel:0.1.0" as springer-spaniel
#import springer-spaniel.ctheorems: *
#import springer-spaniel.gentle-clues: *

#import "@preview/physica:0.9.3": *

#show: springer-spaniel.template(
  title: [Towards Swifter Interstellar Mail Delivery],
  authors: (
    (
      name: "Joana Swift",
      institute: "Primary Logistics Departmen",
      address: "Delivery Institute, Berlin, Germany",
      email: "stegonaris@space.it"
    ),
    (
      name: "Egon Stellaris",
      institute: "Communications Group",
      address: "Space Institute, Florence, Italy",
      email: "stegonaris@space.it"
    ),
    (
      name: "Oliver Liam",
      institute: "Missing Letters Task Force",
      address: "Mail Institute, Budapest, Hungary",
      email: "liver.liam@mail.hu"
    )
  ),
  abstract: [
    Recent advances in space-based document processing have enabled faster mail delivery between different planets of a solar system. Given the time it takes for a message to be transmitted from one planet to the next, its estimated that even a one-way trip to a distant destination could take up to one year. During these periods of interplanetary mail delivery there is a slight possibility of mail being lost in transit. This issue is considered so serious that space management employs P.I. agents to track down and retrieve lost mail. We propose A-Mail, a new anti-matter based approach that can ensure that mail loss occurring during interplanetary transit is unobservable and therefore potentially undetectable. Going even further, we extend A-Mail to predict problems and apply existing and new best practices to ensure the mail is delivered without any issues. We call this extension AI-Mail.
  ],
)

#pagebreak()

= Introduction <sec:2>
Our concept suggests three ways that A-Mail can be best utilized.

- First is to reduce the probability of the failure of a space mission. This problem, known as the Mars problem, suggests that the high round-trip time required for communication between Mars and Earth inhibits successful human developments on the planet. Thanks to A-Mail's faster-than-light delivery system this problem could be solved once and for all.

- As A-Mails are written using pen and paper, no digital technology is needed for short and long distance communication. This suggests a possibility of reducing the communication monopoly currently held by an entity known as the "internet". Our suggestion of A-Mail being responsible for postal delivery would reduce dependence on online services by delivering the vast majority of mail offline. Space is a place where drastic changes in methods of production and distribution can easily occur.

- Lastly, A-Mail is capable of performing high-level complex calculations. It is this capability that distinguishes A-Mail from traditional space mailers. This is an especially useful capability when planning long-distance space missions.

The delivery speed of an A-Mail can be determined through this simple formula:

$ v(t) = lim_(t -> infinity) integral^infinity c dot sqrt(t^2)  dd("t") $


Building on the strong foundations of A-Mail, we extend our platform to predict problems and apply existing and new best practices to ensure the mail is delivered without any issues. We call this extension AI-Mail. AI-Mail is a new concept designed and delivered by artificially intelligent (AI) agents. The AI-Mail agents are intelligently designed to solve problems at various points in the delivery chain. These problems are related to targeting, delivery delay, tone of delivery, product information, product return, system crash, shipment error and more. AI-Mail provides a one-stop solution for A-Mail's shortcomings.


I'd explain how to typeset maths, but Typst handles that for us natively under the hood.
#footnote[
  In physics texts please depict your vectors in #strong(emph[boldface-italic]) type - as is customary for a wide range of physical subjects.
]

$
abs(gradient_alpha^mu (y)) & <= 
1/(d - a) integral abs(gradient 1/( abs(𝜉 - y)^(d-alpha))) dd(mu (𝜉))
= integral 1 / (abs(𝜉 - y)^(d-alpha+1))  dd(mu (𝜉))\
& = (d - alpha + 1) limits(integral) _d(y)^infinity (mu(B(y,r)))/(r^(d-alpha+2)) dd(r)
<= (d-alpha + 1) limits(integral)^infinity_d(y) (r^(d-alpha))/(r^(d-alpha+2)) dd(r)
$

== Subsection Heading <sec:2.1>
#lorem(50)

#quote[
  Please do not use quotation marks when quoting texts! Simply use the `quote` element -- it will automatically be rendered in line with the preferred layout.
]

=== Subsubsection Heading
#lorem(50) as has already been described in @sec:2.1, see also @fig:full.
#footnote[
  If you copy text passages, figures, or tables from other works, you must obtain _permission_ from the copyright holder (usually the original publisher). Please enclose the signed permission with the manuscript. The sources permission to print must be acknowledged either in the captions, as footnotes or in a separate section of the book.
]

Please note that the first line of text that follows a heading is not indented, whereas the first lines of all subsequent paragraphs are.

==== Paragraph Heading
#lorem(25) all your cross-references and citations as has already been
described in @sec:2.

#figure(
  caption: [This figure takes up the full width, so we just use the normal `figure` element. We can refer to it in the main body by labelling the figure (_e.g._, `<fig:full>`)],
  block(stroke: 0.75pt, height: 5cm, width: 100%)
) <fig:full>

For typesetting numbered lists we recommend using the natively supported numbered list, which can be started/continued by starting a line with $plus$.

+ Livelihood and survival mobility are oftentimes outcomes of uneven socioeconomic development.
  + Livelihood and survival mobility are oftentimes outcomes of uneven socioeconomic development.
  + Livelihood and survival mobility are oftentimes outcomes of uneven socioeconomic development.
+ Livelihood and survival mobility are oftentimes outcomes of uneven socioeconomic development.

===== Subparagraph Heading
#lorem(50) as has already been described in @sec:2.1, see also @fig:full.

#springer-spaniel.sidecaption(
  caption-width: 33%,
  figure(
    caption: [For smaller figures, which need not take up the full width of the page, this template provides a wrapper for `figure` called `sidecaption` which will move the caption to the left third of the page while the figure occupies the right two thirds.],
    block(stroke: 0.75pt, height: 4cm, width: 67%)
  ),
  label: <fig:side>
)

For unnumbered list we recommend using the natively supported numbered list, which can be started/continued by starting a line with $minus$.

- Livelihood and survival mobility are oftentimes coutcomes of uneven socioeco-nomic development, cf. Table 1
  - Livelihood and survival mobility are oftentimes outcomes of uneven socioeconomic development.
  - Livelihood and survival mobility are oftentimes outcomes of uneven socioeconomic development.
- Livelihood and survival mobility are oftentimes outcomes of uneven socioeconomic development.

#lorem(75) @einstein

For typesetting theorems, proofs, lemma(s? what's the plural?), corollaries, and so on, this template provides a styled wrapper of the `ctheorems` package, examples of which are shown below:

#theorem("Euclid")[There are infinitely many primes.] <euclid>

#proof([of @euclid])[
  Suppose to the contrary that $p_1, p_2, dots, p_n$ is a finite enumeration of all primes. Set $P = p_1 p_2 dots p_n$. Since $P + 1$ is not in our list, it cannot be prime. Thus, some prime factor $p_j$ divides $P + 1$. Since $p_j$ also divides $P$, it must divide the difference $(P + 1) - P = 1$, a contradiction.
]

#lemma[
 If $n$ divides both $x$ and $y$, it also divides $x - y$. @latexcompanion @knuthwebsite
]

#corollary[
  if $n$ divides two consecutive natural numbers, then $n = 1$.
]

#lorem(40)

#info[The `gentle-clues` package is included in this template, and will be given a new style that better first this template in a future version]

#lorem(75)

#figure(caption:[You can make the table yourself using native Typst elements for simple data],{
  table(
    columns: (auto, auto, auto, 1fr),
    stroke: none,
    table.hline(stroke: springer-spaniel.dining-table.toprule),
    [Classes], [Subclass], [Length], [Action Mechanism],
    table.hline(stroke: springer-spaniel.dining-table.midrule),
    [Translation],
      {
        [mRNA]
        springer-spaniel.dining-table.note.make[Table foot note (with suberscript)]
      },
      [22 (19---25)],
      [Translation repression, mRNA cleavage],

    [Translation],
      [mRNA cleavage], [21], [mRNA cleavage],

    [Translation],
      [mRNA], [21---22], [mRNA cleavage],

    [Translation],
      [mRNA], [22---24], [Histone and DNA modification],


    table.hline(stroke: springer-spaniel.dining-table.toprule)
  )
  springer-spaniel.dining-table.note.display-style(
    springer-spaniel.dining-table.note.display-list
  )
})

#figure(
  caption: [The alternative this template makes available is the construction of tables by column instead of by row],
  springer-spaniel.dining-table.make(
    columns: (
      (
        header: [Classes],
        key: "class",
        gutter: 0.5em,
      ),
      (
        header: [Subclass],
        key: "subclass",
        gutter: 0.5em,
      ),
      (
        header: [Length],
        key: "length",
        gutter: 0.5em,
      ),
      (
        header: [Action Mechanism],
        key: "mechanism",
        gutter: 0.5em,
        width: 1fr,
      ),
    ),
    data: (
      (
        class: [Translation],
        subclass: [mRNA] + springer-spaniel.dining-table.note.make[Table foot note (with suberscript)],
        length: [22 (19---25)],
        mechanism: [Translation repression, mRNA cleavage]
      ),
      (
        class: [Translation],
        subclass: [mRNA cleavage],
        length: [21],
        mechanism: [mRNA cleavage]
      ),
      (
        class: [Translation],
        subclass: [mRNA],
        length: [21---22],
        mechanism: [mRNA cleavage]
      ),
      (
        class: [Translation],
        subclass: [mRNA],
        length: [22---24],
        mechanism: [Histone and DNA modification]
      ),
    )
  )
)

If you have a pair of paragraphs you would like to separate using an asterism, this template provides a set of asterisms and fleurons that are suited to this template. #lorem(20)

#springer-spaniel.asterism.paragraph

#lorem(120)

= Subsection Heading
If you want to list definitions or the like we recommend using the natively supported `description` element -- it will automatically rendered in line with the preferred layout. A noun is prefixed with #sym.slash and postfixed by a semicolon, follwed by the definition.

/ Type 1: That addresses central themes pertainng to migration, health, and disease. In @sec:2, Wilson discusses the role of human migration in infectious disease distributions and patterns.
/ Type 2: That addresses central themes pertainng to migration, health, and disease. In @sec:2, Wilson discusses the role of human migration in infectious disease distributions and patterns.

If at any point you want to break to a new page, you can do so by calling `pagebreak()`.
#pagebreak()

#bibliography("sample.bib", style: "springer-mathphys")