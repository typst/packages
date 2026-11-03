#import "@preview/lagom-eit-lth:0.1.0": popular-science-summary
#import "metadata.typ": *

#import "@preview/droplet:0.3.1": dropcap
#import "@preview/wordometer:0.1.6": word-count, total-words

#show: popular-science-summary.with(
  summary-title:[The title should contain a maximum of 100 characters. #lorem(7)],
  original-title: title,
  authors: authors,
  supervisors: supervisors,
  examiner: examiner,
  lead-paragraph: [The lead paragraph (abstract) should contain a maximum of 200 characters/35 words given the maximum is reached on the title. #lorem(35 - 12)],
  thesis-link: "https://www.student.lth.se/english/masters-students/degree-project/popular-science-readership/",
  presentation-date: end-date,
  lang: "en"
)

#word-count(total => [

#dropcap(
    height: 3,
    gap: 4pt,
    hanging-indent: 1em,
    overhang: 14pt,
    font: "EB Garamond")[
      To generate these dropped capitals, one could use a package like #link("https://typst.app/universe/package/droplet")[droplet]. In the link above one can find information on what should be included in, and how to write a popular science summary.
    ]

#lorem(95) 

= Word limits.
In total, the summary should have a maximum of 3000 characters. In this text, there are #underline(str(total.characters)) which is almost perfect. As seen, it fits neatly.

#lorem(140)

= #lorem(2)
#lorem(145)

= Another heading!
Headings are not necessary, but are visually appealing and helps readability. All headings are set to level 3 and are in-line with text.

#lorem(80)

])