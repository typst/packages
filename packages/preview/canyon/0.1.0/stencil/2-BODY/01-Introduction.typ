#import "../SETUP/ELEMENTS.typ": exhibit, problem, answer
#import "@preview/glossarium:0.5.10": gls
#import "@preview/in-dexter:0.7.2": index

#heading(
  level: 1,
  supplement: [Chapter],
)[Introduction] <chp:intro>

== Lorem Ipsum <sec:lorem>

#lorem(21)#footnote[This type of "lorem" text means nothing and it's so overrated.]#index("Lorem") #lorem(14)

#math.equation(
  block: true,
)[$"lorem" i #sym.harpoon "ipsum"$#index("Lorem", "Ipsum Equation")] <eqn:clone>

According to @ipsum_book_1 @ipsum_book_2 @ipsum_journal, #gls("ipsum") @eqn:clone ...
#lorem(12)

#figure(
  caption: [An "x" in the center]
)[#box(inset: 7.5mm, stroke: 0.4pt)[x#index("Boxed", "x-figure")]] <fig:thex>

@fig:thex ...
#lorem(22)

== Labore et Dolore

#lorem(17)

#figure(
  table(
    columns: 4,
    [t#index("Data", "Tabular")], [1], [2], [3],
    [y], [0.3], [0.7], [0.5],
  ),
  caption: [Some results],
) <tab:results-clone>

@tab:results-clone ...
#lorem(34)

#exhibit(caption: [Hello world in English])[
  Hello World!#index("English", "Hello")
]

Now, the same code in `ANSI-C` is listed on @exh:hello-ansi-c below.

#exhibit(caption: [Hello world in `ANSI-C`])[
  ```c
  #include <stdio.h>

  int main(void) {
      printf("Hello, World!\n");
      return 0;
  }   
  ```
] <exh:hello-ansi-c>

== Problems

=== Basic Problems

#problem(id: "pro:first")[#lorem(17)]#index("Problem", "First")

#problem(id: "pro:first-var")[Solve @pro:first considering #lorem(12) #answer[#lorem(3)]]#index("Problem", "With answer")

#problem(id: "pro:another")[#lorem(21)]#index("Problem", "Another")

=== Text-Writing or Projects

#problem(id: "prj:first")[#lorem(35)]#index("Project", "First")
