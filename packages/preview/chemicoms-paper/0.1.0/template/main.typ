#import "@preview/chemicoms-paper:0.1.0": template, elements;

#set page(paper: "us-letter", margin: (left: 10mm, right: 10mm, top: 12mm, bottom: 15mm))


#show: template.with(
  title: [A typesetting system to untangle the scientific writing process],
  abstract: (
    [The process of scientific writing is often tangled up with the intricacies of typesetting, leading to frustration and wasted time for researchers. In this paper, we introduce Typst, a new typesetting system designed specifically for scientific writing. Typst untangles the typesetting process, allowing researchers to compose papers faster. In a series of experiments we demonstrate that Typst offers several advantages, including faster document creation, simplified syntax, and increased ease-of-use.],
    (
      title: "Plain Language Abstract", 
      content: lorem(50)
    )
  ),
  venue: [_Ars Bibliologia_],
  header: (
    article-color: rgb("#364f66"),
    article-type: "Preprint",
    article-meta: [Not Peer-Reviewed],
  ),
  authors: (
    (
      name: "Martin Haug",
    ),
    (
      name: "Laurenz Mädje", 
      corresponding: true,
      orcid: ""
    ),
  ),
  dates: (
    (type: [Received Date], date: 2015),
    (type: [Revised Date], date: datetime.today()),
    (type: [Accepted Date], date: datetime.today())
  ),
  doi: "00.0000/XXXXXXXXXX",
  citation: [M. Haug and L. Mädje, _Ars Bibliologia_, 2024, *3*, 1---2]
)

#elements.float(align: bottom, [\*Corresponding author])

= Introduction
Scientific writing is a crucial part of the research process, allowing researchers to share their findings with the wider scientific community. However, the process of typesetting scientific documents can often be a frustrating and time-consuming affair, particularly when using outdated tools such as LaTeX. Despite being over 30 years old, it remains a popular choice for scientific writing due to its power and flexibility. However, it also comes with a steep learning curve, complex syntax, and long compile times, leading to frustration and despair for many researchers. @netwok2020

== Paper overview
In this paper we introduce Typst, a new typesetting system designed to streamline the scientific writing process and provide researchers with a fast, efficient, and easy-to-use alternative to existing systems. Our goal is to shake up the status quo and offer researchers a better way to approach scientific writing.

By leveraging advanced algorithms and a user-friendly interface, Typst offers several advantages over existing typesetting systems, including faster document creation, simplified syntax, and increased ease-of-use.

To demonstrate the potential of Typst, we conducted a series of experiments comparing it to other popular typesetting systems, including LaTeX. Our findings suggest that Typst offers several benefits for scientific writing, particularly for novice users who may struggle with the complexities of LaTeX. Additionally, we demonstrate that Typst offers advanced features for experienced users, allowing for greater customization and flexibility in document creation.

Overall, we believe that Typst represents a significant step forward in the field of scientific writing and typesetting, providing researchers with a valuable tool to streamline their workflow and focus on what really matters: their research. In the following sections, we will introduce Typst in more detail and provide evidence for its superiority over other typesetting systems in a variety of scenarios.

= Methods
#lorem(90)
$ a + b = gamma $
#lorem(200)

#set heading(numbering: none)
  
= Conflicts of Interest
The authors have no conflicts of interest to declare. All co-authors have seen and agree with the contents of the manuscript and there is no financial interest to report.

= Acknowledgements
#lorem(20)

= Notes and References
#set par(justify: true, first-line-indent: 0pt);
#lorem(20)
#bibliography(title:none, style:"ieee", "references.bib")