#import "@preview/latexy-book:0.0.1": book, frontmatter, mainmatter, appendix, backmatter, definition, theorem, assumption, proposition, lemma, corollary, exercise, example, notice, code, citep, citet, subfigure, mode-wheel
/* 
If you are sure you want to import all the macros and not conflict with other packages, uncomment the line below.

#import "@preview/latexy-book:0.0.1": *
*/
#show: book.with(
  title: "Book Title",
  subtitle: "Book Subtitle",
  author: "Author Name",
  date: datetime.today().display("[month repr:long] [day], [year]"),
  titlepage: true,
)




// ---------------------------------------------------------
//                     Frontmatter
// ---------------------------------------------------------
#frontmatter()

= Foreword
#lorem(50)

= Preface
#lorem(50)

== Section 1
#lorem(50)

== Section 2
#lorem(50)

== Section 3 
#lorem(50)

= Acknowledgments
#lorem(50)

// contents
#outline()



// ---------------------------------------------------------
//                     Mainmatter
// ---------------------------------------------------------
#mainmatter()

= Part I <sec:partI>
#lorem(50)

== Chapter 1 <sec:chapter1>
#lorem(50)

=== Section 1.1
#lorem(50)

==== Subsection 1.1.1
#lorem(50)

===== Subsubsection 1.1.1.1
#lorem(50)


#pagebreak()
=== Math

Equations without numbering:
#math.equation( 
  block:true,
  numbering: none,
  $ dif S = (delta q) / T $,
)

Equations with numbering:
$ pi, alpha, beta, ..., cal(A), AA $<eq:math-1-1>

$ x^2_3 , frac(x^2, 2), sum_(k=0)^n k, product_(k=0)^n k, lim_x (x^2/x), integral_0^infinity x^2 dif x $<eq:math-1-2>

$
f'(x, y) = cases(
  x + 2y &= 3,
  3x - y &= 5
)
$

$ 
vec(1, 2 ), vec(1, 2, delim: "["),
mat(1; 2 ), mat(1; 2, delim: "["),
$


#definition(caption:"Definition 1.1")[#lorem(50)]

#definition[#lorem(50)] <def:definition-1-2>

#theorem(caption:"Theorem 1.1")[#lorem(50)]

#assumption(caption:"Assumption 1.1")[#lorem(50)]

#proposition(caption:"Proposition 1.1")[#lorem(50)]

#lemma(caption:"Lemma 1.1")[#lorem(50)]

#corollary(caption:"Corollary 1.1")[#lorem(50)]

#exercise(caption:"Exercise 1.1")[#lorem(50)]

#example(caption:"Example 1.1")[#lorem(50)]

#notice(caption:"Notice 1.1")[#lorem(50)]

#lorem(50)





#pagebreak()
=== Code


```
def python():
  return 5 + 5
```


```python
def python():
  return 5 + 5
```


#code[
```python
def hello():
    print("world")
```
]


#code(lineno: false, show-language: false)[
```py
def hello():
    print("world")
```
]


#code(caption: "Code Example")[
```python
# test
def hello():
    print("world")
for each in range(0,5):
    print(each)
def hello():
    print("world")
for each in range(0,5):
    print(each)
def hello():
    print("world")
for each in range(0,5):
    print(each + each + each + each + each + each + each + each + each + each + each + each )
def hello():
    print("world")
```
]


#code[
```stata
regress y x
```
]


#lorem(50)




#pagebreak()
=== List 


#enum[
  Item 1
    + Subitem 1
      + Subitem 1
      + Subitem 2
        + Subitem 1
          + Subitem 1
          + Subitem 2
            + Subitem 1
            + Subitem 2
        + Subitem 2
    + Subitem 2
  ][
  Item 2
    + Subitem 1
    + Subitem 2
  ][
    Item 3
    + Subitem 1
    + Subitem 2
]


#list[
  Item 1
  - Subitem 1
    - Subitem 1
    - Subitem 2
      - Subitem 1
      - Subitem 2
  - Subitem 2
][
  Item 2
  - Subitem 1
  - Subitem 2
][
  Item 3
  - Subitem 1
  - Subitem 2
]




#pagebreak()
=== Table

#lorem(50)

#figure(
  caption: "Table 1.1 Table without Notes",

  table(
    columns: 3,
    align: center,
    stroke: none,
    
    table.hline(),
    [123456789], [123456789], [123456789],
    [X], [X], [X],
    table.hline(),
  ),
) <tab:table-1-1>

#lorem(50)

#figure(
  caption: "Table 1.2 Table with Notes",
  
  block[
    // table notes
    #align(left)[
      #set par(leading: 0.5em)
      #set text(size: 10pt)
      #lorem(50)
    ]
    // table
    #table(
      columns: 3,
      align: (left + top, center + horizon, right + bottom),
      stroke: none,
      
      table.hline(),
      table.cell(rowspan: 2, align: center, [Multirows]),
      table.cell(colspan: 2, align: center, [Multicolumns]),
      table.hline(start: 1),
      
      [X], [X],
      table.hline(),
      
      [X], [X], [X],
      [#lorem(20)], [#lorem(20)], [#lorem(20)],
      table.hline(),
    )
  ]
) <tab:table-1-2>



=== Figure

#lorem(50)

#figure(
  caption: "Figure 1.1 Figure with Notes",
)[
  // figure
  #mode-wheel(scale-notes: (0,2,4,7,9),)
  // figure notes
  #align(left)[
    #set par(leading: 0.5em)
    #set text(size: 10pt)
    #lorem(50)
  ]
] <fig:figure-1-1>

#lorem(50)

#figure(
  caption: "Figure 1.2 Figure without Notes",
)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 0cm,
    subfigure(
      mode-wheel(scale-notes: (0,2,4,7,9),),
      caption: "Subfigure (a)",
    ),
    subfigure(
      mode-wheel(scale-notes: (0,2,4,7,9),),
      caption: "Subfigure (b)",
    ),
  )
] <fig:figure-1-2>

#lorem(50)



#pagebreak()
=== Reference

Section @sec:figure, Chapter @sec:chapter1, Part @sec:partI. 

Eq. @eq:math-1-1, Eq. @eq:math-1-2. 

Definition @def:definition-1-2, Definition @def:definition-2-2.

Table @tab:table-1-1, Table @tab:table-1-2, Table @tab:table-2-1, Table @tab:table-2-2, Table @tab:table-B-1, Table @tab:table-B-2.

Figure @fig:figure-1-1, Figure @fig:figure-1-2, Figure @fig:figure-2-1, Figure @fig:figure-2-2, Figure @fig:figure-B-1, Figure @fig:figure-B-2.



=== Citation 

Original commands:

// \citet{} in LaTeX
#cite(<lamontFinancialConstraintsStock2001>, form: "prose").

// \citep{} in LaTeX
@lamontFinancialConstraintsStock2001 @famaCrossSectionExpectedStock1992.


Commands defined in `latexy-book`:

// \citep{} in LaTeX
#citep(<famaCrossSectionExpectedStock1992>,<lamontFinancialConstraintsStock2001>,<chungEffectsAntitrustLaws2024>,)

// \citet{} in LaTeX
#citet(<famaCrossSectionExpectedStock1992>,<lamontFinancialConstraintsStock2001>,<chungEffectsAntitrustLaws2024>,)





== Chapter 2 Check Numbering

=== Section 2.1 Math

#definition(caption:"Definition 2.1")[#lorem(50)] 

#definition(caption:"Definition 2.2")[#lorem(50)] <def:definition-2-2>

#definition[#lorem(50)]


=== Section 2.2 Table <sec:table>

#figure(
  caption: "Table 2.1",

  table(
    columns: 3,
    align: center,
    stroke: none,
    
    table.hline(),
    [123456789], [123456789], [123456789],
    [X], [X], [X],
    table.hline(),
  ),
)<tab:table-2-1>


#figure(
  caption: "Table 2.2",
  
  block[
    // table notes
    #align(left)[
      #set par(leading: 0.5em)
      #set text(size: 10pt)
      #lorem(50)
    ]
    // table
    #table(
      columns: 3,
      align: (left + top, center + horizon, right + bottom),
      stroke: none,
      
      table.hline(),
      table.cell(rowspan: 2, align: center, [Multirows]),
      table.cell(colspan: 2, align: center, [Multicolumns]),
      table.hline(start: 1),
      
      [X], [X],
      table.hline(),
      
      [X], [X], [X],
      [#lorem(20)], [#lorem(20)], [#lorem(20)],
      table.hline(),
    ),
  ],
)<tab:table-2-2>


=== Section 2.3 Figure <sec:figure>

#figure(
  caption: "Figure 2.1",
)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 0cm,
    subfigure(
      mode-wheel(scale-notes: (0,2,4,7,9),),
      caption: "Subfigure (a)",
    ),
    subfigure(
      mode-wheel(scale-notes: (0,2,4,7,9),),
      caption: "Subfigure (b)",
    ),
  )
  
  #align(left)[
    #set par(leading: 0.5em)
    #set text(size: 10pt)
    #lorem(50)
  ]
] <fig:figure-2-1>


#figure(
  caption: "Figure 2.2",
)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 0cm,
    subfigure(
      mode-wheel(scale-notes: (0,2,4,7,9),),
      caption: "Subfigure (a)",
    ),
    subfigure(
      mode-wheel(scale-notes: (0,2,4,7,9),),
      caption: "Subfigure (b)",
    ),
  )
]<fig:figure-2-2>


= Part II Long Part Name Long Part Name Long Part Name Long Part Name Long Part Name

== Chapter 3 Long Chapter Name Long Chapter Name Long Chapter Name Long Chapter Name Long Chapter Name Long Chapter Name Long Chapter Name Long Chapter Name
#lorem(50)

=== Section 3.1 Long Section Name Long Section Name Long Section Name Long Section Name Long Section Name Long Section Name Long Section Name Long Section Name
#lorem(50)

==== Subsection 3.1.1
#lorem(50)
==== Subsection 3.1.2
#lorem(50)
==== Subsection 3.1.3
#lorem(50)
==== Subsection 3.1.4
#lorem(50)
==== Subsection 3.1.5
#lorem(50)
==== Subsection 3.1.6
#lorem(50)
==== Subsection 3.1.7
#lorem(50)
==== Subsection 3.1.8
#lorem(50)
==== Subsection 3.1.9
#lorem(50)
==== Subsection 3.1.10
#lorem(50)
==== Subsection 3.1.11
#lorem(50)

=== Section 3.2
#lorem(50)

== Chapter 4
#lorem(50)

== Chapter 5
#lorem(50)

== Chapter 6
#lorem(50)

== Chapter 7
#lorem(50)

== Chapter 8
#lorem(50)

== Chapter 9
#lorem(50)

== Chapter 10
#lorem(50)





// ---------------------------------------------------------
//                     Appendix
// ---------------------------------------------------------

#appendix()

= Appendix A

== Appendix A.1
#lorem(50)

== Appendix A.2
#lorem(50)

= Appendix B

== Appendix B.1
#lorem(50)

== Appendix B.2

#figure(
  caption: "Table B.1",

  table(
    columns: 3,
    align: center,
    stroke: none,
    
    table.hline(),
    [123456789], [123456789], [123456789],
    [X], [X], [X],
    table.hline(),
  ),
)<tab:table-B-1>


#figure(
  caption: "Table B.2",
  
  block[
    // table notes
    #align(left)[
      #set par(leading: 0.5em)
      #set text(size: 10pt)
      #lorem(50)
    ]
    // table
    #table(
      columns: 3,
      align: (left + top, center + horizon, right + bottom),
      stroke: none,
      
      table.hline(),
      table.cell(rowspan: 2, align: center, [Multirows]),
      table.cell(colspan: 2, align: center, [Multicolumns]),
      table.hline(start: 1),
      
      [X], [X],
      table.hline(),
      
      [X], [X], [X],
      [#lorem(20)], [#lorem(20)], [#lorem(20)],
      table.hline(),
    )
  ],
)<tab:table-B-2>


#figure(
  caption: "Figure B.1",
)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 0cm,
    subfigure(
      mode-wheel(scale-notes: (0,2,4,7,9),),
      caption: "Subfigure (a)",
    ),
    subfigure(
      mode-wheel(scale-notes: (0,2,4,7,9),),
      caption: "Subfigure (b)",
    ),
  )
  
  #align(left)[
    #set par(leading: 0.5em)
    #set text(size: 10pt)
    #lorem(50)
  ]
] <fig:figure-B-1>


#figure(
  caption: "Figure B.2",
)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 0cm,
    subfigure(
      mode-wheel(scale-notes: (0,2,4,7,9),),
      caption: "Subfigure (a)",
    ),
    subfigure(
      mode-wheel(scale-notes: (0,2,4,7,9),),
      caption: "Subfigure (b)",
    ),
  )
]<fig:figure-B-2>


// ---------------------------------------------------------
//                     Backmatter
// ---------------------------------------------------------
#backmatter()

= Afterword
#lorem(50)

== Afterword 1
#lorem(50)

== Afterword 2
#lorem(50)

== Afterword 3
#lorem(50)


#bibliography("ref.bib")
