#let conf = yaml("conf.yaml")
#import "@preview/free-cv:1.0.0": *

#freeCV[
    
    #makeContacts(conf.introduction)

    = Employment History
    #makeSection(conf.employment)

    = Education
    #makeSection(conf.education.degrees)

    = Passion Projects
    #makeSection(conf.projects)

    #pagebreak()    // Can add a page break if you don't want certain sections to be split across pages
    = Skills
    #makeSectionCompact(conf.skills, rowGutter: 16pt, paddingAbove: 0pt)

    = Miscellaneous
    == Self-contained Courses
    #makeSectionCompact(conf.education.selfContained, bodyIndent: 0pt, rowGutter: 8pt, paddingBelow: 0pt)
    == Certifications
    #makeSectionCompact(conf.education.certifications, bodyIndent: 0pt, rowGutter: 8pt, paddingBelow: 0pt)
    == Interests
    #makeSectionCompact(conf.interests, paddingAbove: -2pt, paddingBelow: 0pt)
    == References
    #makeSectionCompact(conf.references, paddingAbove: -2pt)
]
