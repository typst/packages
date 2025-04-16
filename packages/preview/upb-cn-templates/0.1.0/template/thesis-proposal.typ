#import "@preview/upb-cn-templates:0.1.0": upb-cn-report, code
#import "@preview/timeliney:0.2.0"

#show: upb-cn-report.with(
  title: "Thesis Proposal: Tentative Title of Your Thesis",
  author: "Your Name",
  matriculation-number: "Matriculation Number",
  left-header: "BSc/MSc Thesis",
  meta: (
    ([Research group], [Computer Networks (CN)]),
    ([Study program], [BSc/MSc Computer Science / Computer Engineering]),
    ([First reviewer], [Prof. Dr. Lin Wang]),
    ([Second reviewer], [Someone at the department with a PhD]),
    ([Daily supervisor(s)], [Usually our PhD researchers who talk to you on a daily/weekly basis]),
  ),
)

= Introduction <sec:introduction>

Provide the background for your thesis project and motivate your proposed work.
At the end of this section, provide a short summary of your expected contributions.
You can consider the following questions when writing:

- What problem are you going to work on?
- Why is it an important problem?
- Why does the problem have not been solved already?
- What new insights and ideas do you have?
- What is the overarching research question of your thesis work?
- What contributions do you expect to make? 

= Research Objectives <sec:objectives>

Provide more details about the overarching research question, set up a high-level goal, and divide the goal into multiple concrete objectives. 
Provide details for each of these objectives. Try to limit the number of objectives in the range of two to four.

= Related Work <sec:relatedwork>

Describe what has been done by others.
What are the important references?
Among these which ones are your direct competitors and which ones form the base of your own work?
Explain in detail.
For the direct competitors explain clearly what is still lacking from them to address your research question.

= Proposed Work <sec:proposedwork>

Describe the proposed work you will perform during your thesis.
To achieve each of the objectives listed in Section~@sec:objectives, what general approaches will you take?
What techniques will be used?
What innovative ideas will you explore?
How are you going to evaluate your proposed ideas?
It would be even better if you could already include some preliminary investigation results (e.g., a simplified case study, some measurement results) to support your arguments.
That would significantly increase the credibility of your proposal.

= Timeline <sec:timeline>

The following Gantt chart is required.
Change the titles with "Month" with your actual month information.
In the chart, we have already listed the most important entries for a typical systems-oriented thesis, but you can add or remove entries if necessary.
Adjust the duration of each entry according to your thesis project.
You may also provide a more detailed list of milestones to achieve along the project execution.

#figure(placement: none, numbering: none)[
  #timeliney.timeline(
    show-grid: true,
    grid-style: (
      stroke: (thickness: 0.5pt, paint: gray, dash: "dotted")
    ),
    {
      import timeliney: *
      headerline(..range(6).map(n => ([Month #(n+1)], 4)))
      
      task("Literature study", (0, 3))
      task("Design", (3, 10))
      task("Implementation", (7, 15))
      task("Evaluation", (11, 18))
      task("Writing & Presentation", (16, 20))
    }
  )
]

#figure(placement: none, numbering:  none)[
  #table(
    columns: 2,
    align: (right, left),
    table.cell(colspan: 2, align: left)[*Milestones*],
    table.hline(),
    [Date A], [Finish the literature study and generate a comparative table],
    [Date B], [Complete the sketch of the system design],
    [Date C], [Start implementation of the system],
    [Date D], [Complete the system setup and start evaluation],
    [...], [...],
  )
]

#bibliography("refs.bib")

#pagebreak()
#heading(numbering: none)[How to Use This Template for Writing]

(Please remove this section when submitting your proposal.)

== Subsection Heading

=== Subsubsection Heading (Avoid Using It If Possible)

Lorem Ipsum is simply dummy text of the printing and typesetting industry.
Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.
It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.
It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.

The above shows a normal paragraph for this document.
By default, the paragraph is not indented.
If you want to cite a reference, you can use the #code(lang: "typst", "@reference") syntax.
Here is an example: HIRE is a novel resource scheduler for in-network computing~@2021:asplos:hire.
The list of references is shown at the end of the document in the "References" section.
We use `biblatex`'s file format to manage references and the source of bib items is specified when printing the references with the command #code(lang: "typst", "#bibliography(\"...\")").
It is recommended that you collect the bib entries of papers from #link("https://dblp.org")[DBLP].

You can also create unnumbered and numbered lists as in the following examples.
Note that the list should not go deeper than two levels; otherwise, it becomes ugly.

- First item
- Second item
- Third item
- Last item 
  - First subitem
  - Second subitem

+ First entry
+ Second entry
+ Third entry
  + First subentry
  + Second subentry

If you have some text you want to put in monospace (e.g., cite something in verbatim), you can use backticks to do that (`like so`).
Alternatively, you can use
#code(lang: "typst", "#code(lang: \"...\", \"...\")").
The difference is that the latter is highlighted with a light gray background and we can also turn on syntax highlighting for many programming or scripting languages.
Here is an example to compare these two:
`exit 0` and #code(lang: "bash", "exit 0").
For this reason, the latter is always preferred when it comes to code. 

If you want to write a code block, you can use three backticks, where you can turn on the syntax highlighting if you want.
Here is an example for a shell script.

```bash
echo "Hello world!"
```

The following is an example for a C code snippet.

```c
int main(int argc, char** argv) {
  return 0;
}
```

#figure(caption: [This is the logo of UPB.], placement: top)[
  #image("figures/upb-logo.svg", width: 30%)
] <fig:upb-logo>

@fig:upb-logo depicts the logo of UPB.
By default, figures should always be put at the top of the page.
The same applies to tables.
@tab:info shows the group member information.
Avoid using vertical bars in a table unless it is really necessary.
All cells should be left-aligned except cells with numbers which should be right-aligned or dot-aligned.
The caption for the table should sit at the top of the table, while it is at the bottom for figures.

#figure(caption: [Course Grade])[
  #table(
    columns: 3,
    align: (left, right, right),
    [*Name*],
    [*Matriculation Number*],
    [*Grade*],
    table.hline(),
    [Max Mustermann], [112233], [1.3],
    [Paul Müller], [445566], [1.7],
  )
] <tab:info>
