// ------ USAGE INSTRUCTIONS ---------------------------------------------

// This template has been checked to be compliant with general University presentation requirements. Nevertheless, responsibility for ensuring compliance with all applicable policies remains with the candidate.




// ------ TEMPLATE SETUP ------------------------------------------------
//#import "@preview/uom-thesis-casson:0.1.2": *
#import "uom-thesis-casson.typ": * // for local installation use


// Set up the project. Commented out fields are optional
#show: uom-thesis.with(
  title: "A data reduction algorithm incorporating a low power continuous wavelet transform for use in wearable electroencephalography systems",
  author: "Alexander J. Casson",
  faculty: "Science and Engineering",
  school: "School of Engineering",
  departmentordivision: "Department of Electrical and Electronic Engineering",
  // report: "taught-dissertation", 
      // Options: "thesis" for PhD thesis; "continuation-report" for PhD progress report; "taught-dissertation" for a BEng, MEng or taught MSc dissertation; "research-dissertation" for an MSc by Research. Defaults to "thesis" for PhD if left out
  // continuationyear: 1, 
      // 1, 2, 3 for 1st, 2nd, or 3rd year PhD progression report. Required when report is continuation-report. Not used for other report types
  //studentid: "123456", 
      // A taught dissertation shows the student ID instead of the name. For a group, give a list: ("12345678", "23456789")
  //degree: "Master of Philosophy", 
      // the full title of the degree. If left out, defaults to Doctor of Philosophy for a thesis or Master of Science by Research for an MSc by Research. It has to be given for a taught dissertation
  //covidstatement: [COVID-19 impact statement goes here], 
      // Uncomment if want in thesis. It goes before the title page, and comes out of the final version after the examination
  abstract: [Abstract goes here],
  keywords: ("Keyword 1", "Keyword 2", "Keyword 3"),
  publications: [Publications go here],
  //termsandabbreviations: [Enter terms and abbreviations as table or similar], 
      // Optional. Uncomment if want in thesis
  //layabstract: [Lay abstract goes here], 
      // Optional. Uncomment if want in thesis
  acknowledgements: [Acknowledgements go here],
      // Optional. Uncomment if want in thesis
  //theauthor: [If desired, a brief statement for External Examiners giving the candidate’s degree(s) and research experience, even if the latter consists only of the work done for this thesis.], 
      // Optional. Uncomment if want in thesis
  //declaration: [Say which part of the work has been submitted for another degree, including any jointly authored work], 
      // Uncomment if you want to override the default text
  //revisions: [List of thesis revisions goes here], 
      // For a resubmitted thesis only. It goes before the title page, and comes out of the final version after the re-examination
  //aideclaration: [AI declaration goes here], 
      // Optional. Uncomment if want in thesis
  //contentnotification: [Content notification goes here],
      // Optional. Uncomment if want in thesis
  year: "2026",
  font: "times", 
      // Suggest: "times" or "helvetica", but the template accepts a number more options (see uom-thesis-casson.typ for list). Just because the template supports and option, doesn't neceseaarily mean your computer has that font installed and avaiable for use
  fontsize: 12pt, 
      // Can be any reasonable value, though the policy recommends 12pt, and a taught dissertation needs at least 12pt
  //draft: true, 
      // While writing: puts DRAFT across each page, and allows #uom-todo[...] and #uom-missing-figure([...])
  //printmargins: true, 
      // Puts a larger margin on the left side so the text is still readable when the thesis is printed and bound on the left
)



// ------ MAIN BODY -----------------------------------------------------
= Introduction
#lorem(60) // add dummy text as a placeholder



= Literature review

  == Introduction
  #lorem(60) // add dummy text as a placeholder

  
  == Example display items
  This is an example of providing a cross-reference to @sec:really_good_work. Similarly, this is an example cross-reference to a sub-section, @sec:content.

  This is an example of adding references @ref:jCAS09 @ref:jCAS09a @ref:jCAS10. If you want the author name, or similar, you can use: #cite(<ref:jCAS09>, form: "author") in #cite(<ref:jCAS09>, form: "year") introduced a really good idea. (This is for when you primarily use numbered citations, but occasionally need an author’s name. If using author names as the reference everywhere, change style=ieee in the biblatex setup above to whatever reference style you want, and then just use the cite command.)

  For adding #emph[emphasis] use the emph command or underscores such as _emphasis_.

  An example table is given in @table:example_tabular. Note that the headings are inside a table.header environment to tell screen readers which cells are headers and which cells have the table content. Also, at the moment the template only adds the top horizontal line to the table. The others are added by hand in the table definition below. Ideally the template should detect the end of the header, and the end of the table, and add these horizontal lines automatically, but this doesn't work yet. 
  #figure(
  table(
    columns: 5,
    table.hline(stroke: 1.5pt),
    table.header(
      table.cell(align: horizon, rowspan: 2, [Participant]),
      table.cell(colspan: 2,[Number (%)]),
      table.cell(colspan: 2,[Duration (%)]),
      [Prime dresses], [Non-prime dresses], [Prime dresses], [Non-prime dresses],
    ),
    table.hline(stroke: 1.5pt), // note added by hand, whereas top is done in template
    [1], [33.33], [33.91], [20.83], [18.42],
    [2], [13.04], [17.50], [04.93], [07.62],
    [3], [22.73], [20.10], [13.00], [08.20],
    [4], [31.34], [21.88], [10.57], [11.09],
    [5], [08.47], [19.32], [03.04], [09.73],
    table.hline(),
    [Mean], [16.4], [16.5], [07.8], [07.5],
    [Standard deviation], [09.7], [06.6], [05.4], [03.3],
    table.hline(stroke: 1.5pt), // note added by hand, whereas top is done in template
  ),
  caption: uom-flex-caption(
    [Example table. Short caption for list of tables],
    [Example table. Full caption goes here. Generally in the list of tables a shorter caption which all fits on one line is used to help keep it tidy.],
    ),
  )<table:example_tabular>

  // For an accessible PDF (PDF/UA-1), give each equation alt text as below.
  This is an example equation in text #math.equation(alt: "2 sine omega t", $2 sin omega t$). @equ:example_equation is an example of a displayed equation.

  #math.equation(block: true, alt: "a squared plus b squared equals c squared", $ a^2 + b^2 = c^2 $) <equ:example_equation>

  Note that numbers are displayed differently in the text depending on how they are entered. Compare for example 123456 vs. #math.equation(alt: "123456", $123456$). Entering numbers directly, such as 1955, should be used for _text mode_ numbers. That is, those representing text (dates, page numbers, and similar). Numbers representing maths, or variables or similar, should be entered inside \$ \$ so they are typeset in the same way as they appear in an equation. (This requires a bit of discipline, but helps ensure consistent use of number styles throughout.)

  This is an example of a quote in text #quote(attribution: cite(<ref:jCAS10>))[The electroencephalogram (EEG) is a classic non-invasive method for measuring a person’s brainwaves]. Below is an example of a displayed quote. 

  #quote(block: true, attribution: cite(<ref:jCAS10>))[
    Electrodes are placed on the scalp to detect the microvolt-sized signals that result from synchronized neuronal activity within the brain.
  ]

  // While writing, #uom-todo[...] marks something still to do, and #uom-missing-figure([Caption]) stands in for a figure that hasn't been made yet. Both need draft: true above.

  @fig:uom_logo is an example figure. @fig:uom_logo_in_subfig is an example of a figure made of sub-figures, using the subpar package, and a reference to one part of it looks like @fig:subfig_b.

  #figure(
    image("image.svg", width: 30%, alt: "Put short description for screen readers here"), caption: uom-flex-caption(
      [Example figure. Short caption for list of figures],
      [Example figure. Full caption goes here. Generally in the list of figures a shorter caption which all fits on one line is used to help keep it tidy.],
      
    ),
  ) <fig:uom_logo>

  #uom-subfigures(
    figure(
      image("image.svg", width: 100%, alt: "Put short description for screen readers here"), caption: []
    ), <fig:subfig_a>,
    figure(
      image("image.svg", width: 100%, alt: "Put short description for screen readers here"), caption: []
    ), <fig:subfig_b>,
    figure(
      image("image.svg", width: 100%, alt: "Put short description for screen readers here"), caption: []
    ), <fig:subfig_c>,
    columns: (1fr, 1fr, 1fr),
    caption: uom-flex-caption(
      [Three logos],
      [Three copies of the University logo. (a) Copy one. (b) Copy two. (c) Copy three.],
    ),    label: <fig:uom_logo_in_subfig>,
  )




  An example code listing is given below. Code in the body of the text can be included as `for` or `while` or `main`. This is just using the built in Typst functionality which is fairly limited. Could look at #link("https://typst.app/universe/package/codly/") or similar to give more functionality such as line numbers, ability to link to a piece of code, and similar.

  ```python
  # /// script
  # requires-python = ">=3.14"
  # dependencies = [
  #   "numpy>=2.4.6",
  # ]
  # ///

  import numpy as np

  def main():
      print("Hello")
      a = np.array([0, 1, 2])
      print(a)
    
  if __name__ == "__main__"
      main()
  ``` <code:example>


  == Summary
  #lorem(60)


  
= Really good work <sec:really_good_work>

== Introduction
#lorem(60)


== Content <sec:content>
#lorem(60)


=== Introduction
#lorem(60)


=== Detail
#lorem(60)


=== More detail
#lorem(60)


=== Summary
#lorem(60)


== Summary
#lorem(60)



= Conclusions
#lorem(60)



// ------ REFERENCES ----------------------------------------------------
#bibliography("references.yml", style: "ieee", title: "References")



// ------ APPENDICIES ---------------------------------------------------
#show: uom-appendix
= First Appendix <first-appendix>
== Section in Appendix <section-in-appendix>
#figure(
  image("image.svg", width: 30%, alt: "Put short description for screen readers here"), caption: [
    Example figure in Appendix.
  ],
) <fig:uom_logo2>



= Second Appendix <second-appendix>
== Section in Appendix <section-in-appendix-1>
