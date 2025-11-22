#import "@preview/upb-cn-templates:0.2.0": upb-cn-thesis, code

#show: upb-cn-thesis.with(
  title: "A Cool Networked System That Will Change the World",
  author: "Max Mustermann",
  degree: "Master of Sciences",
  submission-date: datetime.today().display("[month repr:long] [day], [year]"),
  second-reviewer: "Someone with a PhD",
  supervisors: ("Supervisor 1",),
  acknowledgement: [
    // Please replace the following text with your own
    Here you can express your appreciation to anyone who has helped you during your thesis work, probably starting from your reviewers and supervisors.
    You can also write about special moments that are worth mentioning in your journey.

    You are also free to skip this part if there is nothing worthwhile to mention (which I hope is unlikely).
    Negative comments are also possible, although not encouraged since you will probably regret it later.
    Who knows what will happen in the future?
  ],
  abstract: [
    This thesis presents the cool idea of ...
  ],
)

// Your thesis chapters start from here
= Introduction <chap:introduction>

= Background and Related Work <chap:background>

= System Design <chap:design>

= Evaluation <chap:evaluation>

= Discussion <chap:discussion>

= Conclusion <chap:conclusion>

= Template Usage // Remove this chapter in your thesis

== Section Heading

=== Subsection Heading

==== Subsubsection Heading (Avoid Using It If Possible)

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


#bibliography("refs.bib")
