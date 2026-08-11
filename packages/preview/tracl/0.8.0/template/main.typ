
// This is a minimal starting document for tracl, a Typst style for ACL.
// See https://typst.app/universe/package/tracl for details.


#import "@preview/tracl:0.8.0": *
#import "@preview/pergamon:0.7.0": *



#show: doc => acl(doc,
  anonymous: false,
  title: [A Blank ACL Paper],
  authors: make-authors(
    (
      name: "Your Name",
      affiliation: [Your Affiliation\ #email("your@email.edu")]
    ),
  ),
)


#abstract[
  #lorem(50)
]


= Introduction

#lorem(80)

#lorem(80)

#lorem(80)


// Uncomment this to include your bibliography:
// #add-bib-resource(read("custom.bib"))
// #print-acl-bibliography()
