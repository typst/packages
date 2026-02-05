#import "../lib.typ": (
  abstract, acknowledgements, cam-dark-blue, cam-slate-4, declaration, main-section, table-of-contents, title_page,
)

#title_page(
  title: "University Of Cambridge Thesis Template",
  subtitle: "A Simple Template For Cambridge Theses",
  author: "Matthew Ord",
  crest: image("./assets/placeholder.svg", width: 100%),
  college_crest: none,
  department: "Department of Physics",
  college: "Your College",
  degree_title: "Doctor of Philosophy",
)

#declaration()
#acknowledgements([
  And I would like to acknowledge ...
])
#abstract([
  #lorem(100)
])
#table-of-contents()




#show: main-section


= Your First Section
#lorem(100)
$ E = m C^2 $

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



= Your Second Section
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
