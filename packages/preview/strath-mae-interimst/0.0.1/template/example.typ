#import "@local/strath-mae-interimst:0.1.0": *

/* 

Welcome to typst! It should be fairly simple to contribute to this document here in the web app, as all the formatting has been done for you. 

A tutorial can be found at https://typst.app/docs/tutorial/writing-in-typst/, or a cheat sheet is available in the cheatsheet folder:  click the closed eye next to cheatsheet.typ to show it in the main preview. To return to main.typ, click the closed eye next to it in the filetree.

To add text, just type anywhere! The preview will auto-scroll to where you are editing, and clicking text in the preview will bring you to the relevant place in the editor.

To cite a source, add it to bib.yml - this is in the Hayagriva YAML format (if you have experience with bibtex you can use that instead. Read this (https://github.com/typst/hayagriva/blob/main/docs/file-format.md) to learn more about the Hayagriva format. When you @cite a source, it is automatically added to the #bibliography in order of appearance in the document.

*/

#show: body => report(
  class: [ME420: Individual Project (Aerospace)],
  title: [Title of Interim Report],
  author: [Joe Bloggs],
  number: [202512345],
  supervisor: "",
  date: [#datetime.today().display("[day]/[month]/[year]")],
  abstract: [#lorem(100)],
  body
)

= Introduction

== Sub-section

=== Sub-sub-section

= Literature Review

= Methodology

#figure(
  table(
    columns: 3,
    [],[Step],[Comment],
    [1],[Add a `caption` argument to `#figure`],[The `show` rule sets the caption position],
    [2],[Add the caption text in square brackets],[Add a `<tag>` after the figure to reference it later]
    
  ), caption: [How to insert a caption]
) <tableexample>

= Results
#figure(
image("MSWord.png"),
caption: [The Caption pop out window from the References Tab in Microsoft Word @source]
) <screenshot>

= Discussion

= Conclusion

#pagebreak()
#show bibliography: set heading(numbering: "1.1.")
#bibliography("bib.yml", title: [References], )
