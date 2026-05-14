#import "i8n.typ": i8n-date-long

#show heading.where(level: 1): set block(spacing: 2em)
= Declaration

I hereby declare that I have written this thesis independently and without the help of others, have not used any sources other than the ones mentioned, and have marked the quotations from the sources as such. This work has not been submitted to any other examination board in the same or similar form. The printed version of this thesis is identical to the electronically transmitted text document.

Hagenberg, on #i8n-date-long(datetime.today(offset: auto))

#context grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  ..document.author.map(author => {
    v(2cm)
    author
  })
)
