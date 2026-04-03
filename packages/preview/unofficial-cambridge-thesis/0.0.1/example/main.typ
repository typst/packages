#import "@preview/unofficial-cambridge-thesis:0.0.1": appendix, cam-dark-blue, cam-slate-4, cam-theisis, declaration, main-body, preamble

#show: cam-theisis.with(
  title: "University Of Cambridge Thesis Template",
  subtitle: "A Simple Template For Cambridge Theses",
  author: "Matthew Ord",
  crest: image("./assets/placeholder.svg", width: 100%),
  college-crest: none,
  department: "Department of Physics",
  college: "Your College",
  degree-title: "Doctor of Philosophy",
)

#preamble([

  #declaration()

  = Acknowledgements
  And I would like to acknowledge ...



  = Abstract
  #lorem(100)

  #lorem(100)

  #lorem(100)

  #lorem(100)

  #lorem(100)

  #outline(
    title: [Table of Contents],
    indent: auto,
    depth: 3,
  )


])






#show: main-body


= Introduction
#lorem(100)
$ E = m C^2 $

$ E = m C^2 $


#lorem(100) @harry

== Test
#lorem(100)

#lorem(100)

=== Test
#lorem(1000)

== Test
#lorem(100)

#lorem(100)



= Sectionz
#lorem(100)
$ E = m C^2 $



#lorem(100)

== Test
#lorem(100)

#lorem(100)

=== Test
#lorem(1000)

== Test
#lorem(100)

#lorem(100)


#show: appendix

= First Appendix

#lorem(100)

#lorem(100)


== Appendix Subsection

#lorem(100)

=== Appendix Sub-Subsection

#lorem(100)

= Second Appendix

#lorem(100)

#bibliography("bibliography.yml")
