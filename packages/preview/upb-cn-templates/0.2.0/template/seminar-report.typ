#import "@preview/upb-cn-templates:0.2.0": upb-cn-report, code

#show: upb-cn-report.with(
  title: "Seminar: XXX (SS24)", // XXX is the name of the seminar
  author: "Your Name",
  matriculation-number: "Matriculation Number",
  meta: (
    ([Research group], [Computer Networks (CN)]),
    ([Study program], [BSc/MSc Computer Science / Computer Engineering]),
    ([Supervisor], [Prof. Dr. Lin Wang]),
    ([Paper title], [Title of the selected paper]),
  ),
)

// Please remove the following part in your report
The following structure should be followed in general.
You may deviate from this structure slightly if you have a good reason to do so.
Skipping any parts contained in the structure without proper justification will result in penalties.
If you are unsure about your choice, please contact your supervisor.

#heading(numbering: none)[Abstract]

//  Please remove the following part in your report
An abstract is a compressed summary of the paper.
It should make clear at least the following points:

+ What is the context of the problem and why the problem is important?
+ What are the new insights/observations that motivate the paper?
+ What are the major contributions of the paper?

You should explain each of the above points with just 1--2 sentences.

= Introduction <sec:introduction>

// Please remove the following part in your report
The introduction section serves as an unzipped summary of the paper.
It is similar to the abstract but with more details.
An example storyline for the introduction could look like the following:

+ Background, general context of the problem
+ Problem description and its importance
+ Existing works and why they fall short
+ New insights/observations that motivate a new design
+ Key features of the new design
+ Summary of contributions

This storyline just serves as a typical example.
You can also find your own way to organize this section.


= Background <sec:background>

// Please remove the following part in your report
This section introduces the necessary background for others to understand the context and problem.
You can have multiple subsections, each focusing on one major concept.
For example, if the paper is about an in-network key-value cache, you may need to explain first what is a _key-value store and the associated caching problem_, and then what is _in-network computing_.
After reading these two background descriptions, readers would have a good idea about the context of in-network key-value caching.


= Problem Statement and Taxonomy <sec:problem>

// Please remove the following part in your report
This section is tailored for a literature study report.
Since you have read multiple papers, hopefully on closely related topics.
Now you should think about what is a good overarching problem to write about, covering all the papers you want to include.
But of course, these papers may have different focuses, even though they all fit the overarching problem.

You must identify the overarching problem and make a clear statement about it so it is crystal clear to the reader.
Then, categorize the papers and create a (simple) taxonomy to guide the readers further.
For example, if you want to include papers about the hardware architecture of programmable switches in a report, you could create a taxonomy based on the hardware type:
FPGA-based, ASIC-based, and NPU-based.
You can even divide each of these directions into sub-directions.
For example, for ASIC-based architecture, there are pipeline-based and multi-core-based.


= Summary of Surveyed Papers <sec:papers>

// Please remove the following part in your report
This section provides summaries of the papers according to the taxonomy you have just presented.
You are free to choose how to organize this section, but it should somehow reflect the taxonomy.
Note that you should not copy anything directly from the paper.
You must identify the key elements (like the ones listed in the storyline of the introduction) of each of the papers and summarize the paper in your own words.
You might want to go a bit deeper here regarding the core technical ideas, but you can be very brief on aspects that are not essentially related to the core ideas.


= Qualitative Analysis and Comparison <sec:analysis>

// Please remove the following part in your report
This section is to perform a qualitative analysis of the papers you have presented.
Try to synthesize some metrics on which you can compare the solutions presented in this paper.
These metrics could include system requirements (e.g., scalability, reliability, extensibility, programmability), and performance metrics (e.g., latency, throughput).
Please carefully select metrics to include according to the context of the studied problem.
A table would be helpful for such a qualitative analysis and comparison, where each column includes a metric while each row corresponds to a solution.


= Comments on the Papers <sec:comments>

// Please remove the following part in your report
Here you can make some general comments about the research field, the studied problem, as well as the papers included in this report. You could comment on the importance of the problem, the significance of the presented solutions, and maybe also your opinion about the development of the research field in general. After all, no paper is perfect and no one can predict the future. 

= Conclusions <sec:conclusions>

// Please remove the following part in your report
Finally, draw some conclusions as to whether the presented papers have already solved the stated problem. Try first to draw conclusions about the current landscape and then outline some future directions that could be interesting to explore.


#bibliography("refs.bib")

#pagebreak()
#heading(numbering: none)[How to Use This Template for Writing]

(Please remove this section when submitting your seminar report.)

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
