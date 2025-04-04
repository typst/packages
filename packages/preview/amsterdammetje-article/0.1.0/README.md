# Amsterdammetje Article

(Unofficial) Typst rewrite of [LaTeX article template](https://www.overleaf.com/latex/templates/uva-informatica-template-artikel/dsjkstcpphny)
used in the BSc Computer Science of the University of Amsterdam.

## Usage

```typst
#import "@preview/amsterdammetje-article:0.1.0": article, heading-author, abstract

#set text(lang: "en") // or "nl"

#show: article(
  title: "Title of the document",
  authors: ("Author 1", "Author 2"),
  ids: ("UvAnetID student 1", "UvAnetID student 2"),
  tutor: "Name of the tutor",
  mentor: none,
  lecturer: none,
  group: "Name of the group",
  course: "Name of the course",
  course-id: none,
  assignment-name: "Name of the assignment",
  assignment-type: "Assignment type",
  link-outline: true
)

#abstract[This article proposes groundbreaking...]

= Heading with author name in margin
#heading-author[Edsger Dijkstra]
```

The `link-outline` parameter specifies whether links should be surrounded with a cyan box,
similar to what hyperref does by default in LaTeX.
The difference is that hyperref boxes are part of the link itself
and split up at newlines,
whereas boxes around links in this template are as big as the total bounding box of the link.

For the other parameters, see the original template.
