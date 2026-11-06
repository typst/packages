#import "@preview/valkyrie:0.2.0" as z;
#import "./elements.typ" as elements;

#let abstracts = z.dictionary(
  (
    title: z.string(default: "Abstract"),
    content: z.content(),
  ),
  pre-transform: z.coerce.dictionary(it => (content: it)),
)

#let template-schema = z.dictionary(
  aliases: (
    "author": "authors",
    "running-title": "short-title",
    "running-head": "short-title",
    "affiliation": "affiliations",
    "abstract": "abstracts",
    "date": "dates",
  ),
  (  
    header: z.dictionary(
      (
        article-type: z.content(default: "Article"),
        article-color: z.color(default: rgb(167,195,212)),
        article-meta: z.content(default: [])
      ),
    ),
    fonts: z.dictionary(
      (
        header: z.string(default: "Century Gothic"),
        body: z.string(default: "CMU Sans Serif")
      ),
    ),
    title: z.content(optional: true),
    subtitle: z.content(optional: true),
    short-title: z.string(optional: true),
    authors: z.array(z.schemas.author, pre-transform: z.coerce.array),
    abstracts: z.array(abstracts, pre-transform: z.coerce.array),
    citation: z.content(optional: true),
    open-access: z.boolean(optional: true),
    venue: z.content(optional: true),
    doi: z.string(optional: true),
    keywords: z.array(z.string()),
    dates: z.array(
      z.dictionary(
        (
          type: z.content(optional: true),
          date: z.date(pre-transform: z.coerce.date),
        ),
        pre-transform: z.coerce.dictionary(it => (date: it)),
      ),
      pre-transform: z.coerce.array,
    ),
  ),
)


#let template(body, ..args) = {

  let args = z.parse(args.named(), (template-schema));

  // setup
  set text(font: args.fonts.header, lang: "en", size:9pt)
  set page(footer: elements.footer(args))

  show heading: set block(above: 1.4em, below: 0.8em)
  show heading: set text(size: 12pt)
  set heading(numbering: "1.1")
  set par(leading: 0.618em, justify: true)

  v(1.2em)
  elements.header-journal(args)
  elements.header-block(args)
  elements.precis(args)
  v(0.8em)

  // Main body.
  set text( font: args.fonts.body, lang: "en", size:9pt )
  set par( first-line-indent: 0.45cm );
  show par: set block(above: 0pt, below: 0.618em,)
  show: columns.with(2, gutter: 1.618em)

  show figure.caption: c => {
    set par(justify: true, first-line-indent: 0cm);
    align(left, par(justify: true, first-line-indent: 0cm)[*#c.supplement #c.counter.display(c.numbering)#c.separator*#c.body])
  }

  set math.equation(numbering: "(Eq. 1)")
  show math.equation: set block(spacing: 1em, above: 1.618em, below: 1em)
  body;
}
