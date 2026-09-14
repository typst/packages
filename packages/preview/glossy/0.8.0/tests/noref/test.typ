#import "/lib.typ": *

// Our test glossary
#show: init-glossary.with((
    Normal: "this is a normal term",
    NoRef: "this term is noref'd",
    NoIndex: "this term is noindex'd",
    NoRefNoIndex: "this term is noref'd and noindex'd",
))

// Configure styling

#set page(margin: 1em)
#set page(width: 3.5in)
#set page(height: auto)
#set text(size: 10pt)

@Normal

@NoRef:noref

@NoIndex:noindex

@NoRefNoIndex:noref:noindex

#glossary()
