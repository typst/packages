#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#show: codly-init

= Introduction

In this exemplary document I will show you how to use the HS Emden/Leer template for academic writing.
This template is designed to help you create a well-structured and formatted thesis or work of any kind. It includes various features such as the automated generation of a table of contents, list of figures, and list of tables, as well as support for citations and references.
In the following sections, I will demonstrate the key features of the template and how to use them effectively.

== Basics

Typst is a markdown based typesetting system that allows you to write documents in a simple and intuitive way. For the really basic formatting, I recommend you to check out the Typst documentation #link("https://typst.app/docs/"). It covers everything from the very basic features and syntax to really advanced features. I highly recommend playing around with it a bit to get a feel for how it works.

== Features for Academic Writing

The HS Emden/Leer template for academic writing includes a variety of features to help you create a professional and polished document. Some of the key features will be demonstrated in the following sections.

=== Automated Table of Contents
The template automatically generates a table of contents based on the headings in your document. This makes it easy to navigate through your work and find specific sections.

This section is a level 3 heading, which will be included in the table of contents as such. The table of contents supports headings up to level 3, which means you can create a well-structured document with multiple levels of headings.

=== List of Figures and Tables
The template also generates a list of figures and tables, making it easy to reference them in your text.
You can include figures by using the `#figure` command. 

#figure(
  image("../logo.svg", width: 50%),
  caption: [Logo of the HS Emden/Leer],
) <LogoHSEmdenLeer>

As you can see, the figure is automatically numbered and included in the list of figures. You can also include tables using the `#table` command.

#align(center)[
  #table(
    columns: 3,
    table.header(
      [Substance],
      [Subcritical °C],
      [Supercritical °C],
    ),
    [Hydrochloric Acid],
    [12.0], [92.1],
    [Sodium Myreth Sulfate],
    [16.6], [104],
    [Potassium Hydroxide],
    table.cell(colspan: 2)[24.7],
  )
]


But as you can see, the table is not automatically numbered and added to the list of tables. Therefore, you should wrap tables in a `#figure` command to make them automatically numbered, give them a caption and include them in the list of tables.

When you have a table that would span over multiple pages the template ensures that the heading row will be repeated on every page, so you don't have to worry about that.
#figure(
  kind: table,
  caption: [Metrics in Table layout],
  table(
    columns: 4,
    inset: .5em,
    table.header([Method],[Accuracy],[Latency],[Energy]),
    [Baseline], [92.3%], [120ms], [450mW],
    [Our approach], [93.1%], [78ms], [270mW],
    [#lorem(75)], [#lorem(75)], [#lorem(75)], [#lorem(75)],
  )
) <table-metrics>

And if you look now, you can see that the table is automatically numbered and included in the list of tables respectively, the list of tables is automatically generated and updated when you add or remove tables from your document.

=== Citations and References
The template supports citations and references, allowing you to easily include sources and create a bibliography.

If you want to reference a source or something from within your document that you previously tagged by using brackets `<...>` you can either use the `@`-tag. For example if you were to reference the logo of the HS Emden/Leer, you could use `@LogoHSEmdenLeer` to reference it. This will create a link to the figure in your document like this: @LogoHSEmdenLeer.

If you want the full control of what is displayed in the text, you can use the `#cite` command to create citations in your text, and the template will automatically format them according to the selected citation style.
Especially for works you want to reference, I recommend creating a `.bib` file with all your references and then using the `#cite` command to cite them in your text. 
For example the command `#cite(<example2022>, form: "prose")` will be displayed like this: "#cite(<example2022>, form: "prose")"

In some disciplines it might also be common to list the references that are occuring on the same page in a footnote.
I personally found a way that works for me, but I am not sure if this is the best way to do it. Nevertheless, I will show you how I did it: using this snippet `@example2023 #footnote[#cite(<example2023>,form: "prose")]` will look like this in the text: @example2023 #footnote[#cite(<example2023>,form: "prose")] and the reference will be automatically listed in the footnote. 

If you need any further information on what is possible with references and citations, I recommend checking out the Typst documentation on #link("https://typst.app/docs/reference/model/ref/") and #link("https://typst.app/docs/reference/model/cite/").

=== Abbreviations and Glossary
In order to use abbreviations and a glossary, I recommend using the `@preview/glossarium` package.

Then you can create a file called `abbreviations.typ` or however you want and add all your abbreviations in there.
#pagebreak()
```typst
#import "@preview/glossarium:0.5.6": *
#pagebreak(weak: true)
#heading("Abbreviations", numbering: none)
#show: make-glossary
#register-glossary(abbreviations-entry-list)
#print-glossary(abbreviations-entry-list, disable-back-references: true)
```<Code1>
Abbreviations can be used by using the `@`-tag. The first occurence of the abbreviation will be displayed in full with the abbreviation in brackets behind and all following occurrences will be displayed as the only the abbreviation (unless you want to have it displayed in a different way).

Here is an example of how to use the `@`-tag: 

@Cpu

The next occurence of this abbreviation will be displayed as @cpu.
\

You can also create a glossary in the same way. Just create a file called `glossary.typ` or however you want and add all your glossary entries in there.

Then you can use the registered entries like this: `@Algorithm`

The result will look like this:

@Algorithm
