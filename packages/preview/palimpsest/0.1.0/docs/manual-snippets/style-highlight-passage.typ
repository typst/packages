#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)

*highlight-passage: false (default)*
#passage[Only the #add[actually changed words] are tinted --- the rest of the sentence stays plain black text.]

#v(0.8em)
#set-revisions(highlight-passage: true)
*highlight-passage: true*
#passage[The whole passage's background is lightly tinted, not just #add[the changed words] --- useful when a reviewer asked for a full rewrite.]
