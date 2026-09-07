#import "@preview/thwildau-telematics:0.1.1": (
  abbreviation, conf, define-abbreviation, define-unit, define-glossary, infocard, tables, th-color, todo, unit, glossary
)

// ---------- english ----------

= TH-Wildau telematics template (english)
This is the official Typst template of the telemtics course at the Technische Hochschule Wildau. It helps you create your own professional looking thesis with minimal styling effort and only limited understanding of typst needed. If you have made it far enough to get the PDF rendered that you are looking at right now, you may start writing your thesis right away. But this template does not come empty! In the chapters below you can find out what exactly this template offers you and how to use it.
Have fun!

== Configuring the template
While this template takes a lot of arguments for configuration, most of them are pretty self explanatory. The full config used for this document can be found in the `main.typ`. This chapter aims explain it bit by bit. To assemble all the parts into one final config used in a project, basic knowledge of what a #link("https://typst.app/docs/reference/foundations/dictionary/")[dictionary] in typst is, will be required.

To configure the thwildau-telematics template, it first must be imported.
#figure(
  caption: [Import the template],
)[
  ```typst
  #import "@preview/thwildau-telematics:0.1.1": (
    abbreviation, conf, define-abbreviation, define-unit, define-glossary, infocard, tables, th-color, todo, unit, glossary
  ) // TH-Wildau template

  // template configuration
    #show: conf.with(
      your configs...
    )
  ```]

Most of the options that can be defined in the config are related to specific pages, which are explained in #ref(<pages-en>). The only generic options are as follows:

#figure(
  caption: "Config options",
  table(
    columns: 3,
    table.header([Name], [Default Value], [Description]),
    [#`title`],
    [#`none`],
    [This field sets the title of your thesis. It is mandatory and should be a string. You can find it at some of the title page templates and in the header of most of the page.],

    [#`language`],
    [#`"de"`],
    [Sets the #link("https://typst.app/docs/reference/text/text#parameters-lang")[text language]. It also #link(<translation-en>)[translates] static text elements of this template.],

    [#`bibliography`],
    [#`none`],
    [The bibliography tells the template where to find sources used in the writing of your thesis. Read in the #link("https://typst.app/docs/reference/model/bibliography/")[Docs] to learn more about bibliographies in typst.],
  ),
)

The full config could look something like this:

#figure(caption: [Full template config example])[
  ```typst
  #show: conf.with(
    // title of this tehsis
    title: "TH-Wildau Telematics Typst Template",
    // type of title page
    titlepage: "internship",
    // your info
    student: (
      name: "Carl Heinrich Bellgardt",
      matrnr: "12345678",
      subject: "Praxisintegrierender Bachelor Studiengang Telematik",
      seminar-group: "T23",
      semester: "5",
    ),
    // your supervisor
    supervisor: (
      name: "Frau Dr. Lieschen Müller",
      mail: "mueller@beispielag.de",
    ),
    // infos related to your internship
    internship: (
      type: "3. Betriebspraktikum",
      partner: [Beispiel AG \ Straßenweg 1 \ 12345 Musterstadt \ #link("https://beispielag.de")],
      period: "16.06.2025 bis 25.07.2025",
    ),
    // your bibliography file
    bibliography: bibliography("bib.yaml", style: "institute-of-electrical-and-electronics-engineers"),
    // language of this document
    language: "de",
    // generate various predefined pages
    misc-pages: (
      // used for bibliographic description
      bibliographic-description: (
        de: (
          title-long: "TH-Wildau Telematics Typst Template für Thesis und Praktikumsbericht",
          metadata: " ",
          keywords: "Typst, Thesis, Template, TH-Wildau, Telematik",
          goal: [Erstellung eines neue Typst Projektes mit dem TH-Wildau Telematics Template.],
          abstract: [In dieser Arbeit wird erklärt, wie das darin verwendete TH-Wildau Telematics Typst-Template konfiguriert und angewendet werden kann.],
        ),
        en: (
          title-long: "TH-Wildau Typst template for thesis and intership.",
          metadata: " ",
          keywords: "Typst, Thesis, Template, TH-Wildau, Telematics",
          goal: [Creation of a new typst project with the TH-Wildau Telematics template.],
          abstract: [This thesis aims to explain the process of installing, configuring and applying the TH-Wildau Telematics typst template.],
        ),
      ),
      // add a reading guides page
      reading-guides: [Für diese Arbeit ist grundlegendes Wissen über die Sprache Typst von Vorteil.#linebreak() For this template it is advised to first understand the basic concepts of the typst language.],
      authorship-declaration: true,
      company-confirmation: true,
      glossary: (("Telematik", "Die Kombination aus Telekommunikation und Informatik"),),
      appendix: include "chapters/appendix.typ",
    ),
  )
  ```] <conf-example-en>


=== Error handling
Whenever the template needs a certain config parameter that was not specified by the user and has no default value, it will throw an error. Provided below is an example for the error block, that the typst compiler will show at the top of it's stack trace. In this example the key `student` in the config has a set stored in it, that itself is missing the key `matrnr`. It can also be noticed that the example value of `"12345678"` given, indicating that the value can be a string.

#figure(caption: [Config error example])[
  ```typst
  error: assertion failed:
  Missing variable in configuration: student.matrnr
  For example:    student.matrnr: "12345678"
  Please add the missing definition to your configuration of the thwildau-telematics template.
     ─ @preview/thwildau-telematics:0.1.1/utils/user_input.typ:7:2
  ```]

== Pages <pages-en>
Besides the styling, this template also generates a bunch of pages around your thesis, including the header page, various outlines and the bibliography. Some of them are enabled by default and can be opped-out, while others need to be enabled manually.

=== Title page
This template offers a title page, but since the TH-Wildau might require you to use theirs, it is more likely to only be used for minor projects that also require thesis-like formatting. If you do need to exchange the title page for one that you were provided, here is an example of how to do that.
#figure(caption: [Replace title page])[
  ```typst
    titlepage: (
      content: [
        #page(
          background: image("test.pdf", fit: "cover"),
        )[]
      ],
    )
  ```]
Notice that in the config, `titlepage` also takes the key `content`, which it then will render directly instead of the templates title page. Thus you can simply provide an empty page with your pdf title page as the filling background é voila you have the mandated title page. You can of course also insert any other typst `content`.

=== Bibliographic description
The bibliographic description aims to give a brief explaination and categorisation of your thesis. You can supply information in multiple languages, but as only german and english translations for the template are supplied with it, you may need to #link(<translation-en>, [add your own translations]).
#figure(caption: [Enable _bibliographic description_ page(s)])[
  ```typst
  misc-pages: (
    bibliographic-description: (
      de: (
        title-long: "TH-Wildau Typst Tempalte für Thesis und Praktikumsbericht",
        metadata: " ",
        keywords: "Typst, Thesis, Template, TH-Wildau",
        goal: [Erstellung eines neue Typst Projektes mit dem TH-Wildau Template.],
        abstract: [In dieser Arbeit wird erklärt, wie das darin verwendete Typst-Template konfiguriert und angewendet werden kann.],
      ),
      en: (
        title-long: "TH-Wildau Typst template for thesis and intership.",
        metadata: " ",
        keywords: "Typst, Thesis, Template, TH-Wildau",
        goal: [Creation of a new typst project with the TH-Wildau template.],
        abstract: [This thesis aims to explain the process of installing, configuring and applying the TH-Wildau typst template.],
      ),
    ),
  )
  ```]

=== Notes to the reader
With the _Notes to the reader_ page you can give your audience further context to help them understand your work.
#figure(caption: [Enable _notes to the reader_ page])[
  ```typst
  misc-pages: (
    reading-guides: [your content]
  )
  ```]

=== Company confirmation
If you write your thesis as part of your work at an extern company, you may need to add a confirmation page, in which the company verifies your affiliation and work with them.
#figure(caption: [Enable _company confirmation_ page])[
  ```typst
  misc-pages: (
    company-confirmation: true
  )
  ```]

=== Declaration of authenticity
To declare that your authorship of a thesis you can use this page. But depending on the current regulations you may instead be required to use an external form for that.
#figure(caption: [Enable _declaration of authorship_ page])[
  ```typst
  misc-pages: (
    authorship-declaration: true
  )
  ```]

=== Glossary
Glossary entries can be supplied directly by supplying an nested array with the term and a brief description like in the example below. If you however want to link to an entry from the text, the entry should be defined at some position it's linked, as shown in #ref(<define-glossary-en>).
#figure(caption: [Add _glossary_ entry])[
  ```typst
  misc-pages: (
    glossary: (
      ("Telematics", "The combination of telecommunication and informatics"),
    ),
  )
  ```]

=== Appendix
To attach text or figures to the document, that should not be part of the document directly or are only used partly (e.g. part of an image) in the document and you want to attach the full version, then the appendix is the place to put it.
#figure(caption: [Add _appendix_])[
  ```typst
  misc-pages: (
    appendix: #include "chapters/appendix.typ"
  )
  ```]
As you can see in this example, appendix works with any content. In order not to bloat the config, you can use an external typst document that can then be imported here, like in the example. Every entry should be marked by a top level heading and will then be numbered automatically.

== Figures
If you are already used to writing academic texts with software like Microsoft Word or LateX, you may know what different kind of figures are often times used. The next sections walk you through the figures included in this template. Because a big part of working with figures is always keeping track of how many of every kind you have to later list them in you registries, this template will take care of that. You will notice for example, that by adding a table, there will be a new page close to the end of your document listing and linking all your tables.

=== Table
There are two types of tables avaible to use. By default, the `tables.x-header` styling will be used. It has a header at the top and then iterates between two lighter colors to make reading the lines easier.
#figure(
  caption: "Programmer's work day",
  table(
    columns: 4,
    table.header([Time], [Duration], [Task], [Requirements]),

    [9:00 am], [30 minutes], [coffee break], [coffee, coffeemaker],
    [9:30 am], [30 minutes], [read mails], [computer],
    [10:00 am], [2 hours], [understand yesterday's code], [brain (must be awake)],
    [12:00 am], [30 minutes], [lunch break], [lunch or canteen and money],
    [12:30 am], [20 minutes], [walk through park], [park, shoes],
    [12:50 am], [10 minutes], [another Coffee break], [coffee, coffeemaker],
    [1:00 pm], [4 hours], [rewrite yesterday's code], [brain (keep awake with more coffee)],
    [5:00 pm], [30 minutes], [give up and go home], [-],
  ),
)

The second table style can be accessed with `tables.xy-header`. It has the same styling as the other, but also has a header on the start of the y-Axis, hence the name `xy-header`.

#figure(
  caption: "Battleships",
  tables.xy-header(
    table(
      columns: 6,
      table.header([ ], [A], [B], [C], [D], [E]),

      [1], [🌊], [🚢], [🌊], [💥], [🌊],
      [2], [🚢], [💥], [🌊], [🌊], [🌊],
      [3], [🌊], [🌊], [🌊], [🌊], [🌊],
      [4], [🌊], [🌊], [💥], [🚢], [🚢],
      [5], [🌊], [🚢], [🌊], [🌊], [💥],
    ),
  ),
)

=== Code
Typst already offers functionalities for ´inline´ code and block of code, called listings. You have in fact been reading them a lot in this document, for example in #ref(<conf-example-en>).

=== Info-Card
To give hints to the reader or to highlight important texts like definitions, the *Info-Card* is here to help. It is a simple element consisting of a title and a body text.

#infocard(
  "Example: Info-Card",
  "This is a Info-Card. It can be used for examples, definitions or just general information.",
)

The two colors can be easily exchanged.

#infocard(
  "Example: Info-Card",
  "This is a Info-Card. It can be used for examples, definitions or just general information.",
  color-dark: th-color.orange,
  color-light: th-color.paleorange,
)

=== Units
You can define a unit like #define-unit("v", $"ms"$, "Velocity", "Vector unit") and then easily link to it from anywhere in the text like #unit("v").

=== Glossary <define-glossary-en>
A glossary entry can be defined with #define-glossary("Telematics", "The combination of telecommunication and informatics") and later linked to with #glossary("Telematics").

=== Abbreviations
Abbreviations can be defined in a similar fashion to units. The abbreviation #define-abbreviation("M.A.", "Master of Arts") will link to the corresponding abbreviation's outline, which will be generated automatically. As with units, new links to #abbreviation("M.A.") can be created anywhere in the text. When making heavy use of this functionality, it is advised to automatically replace all occurrences in the text or at least to import the function with an alias, to not have to type out `#abbreviation("TH")` every single time.
=== Image
Even though it is not part of this template and just plain Typst, here is an image to complete the list of commonly used figures and to trigger the image's outline generation.

#figure(
  image("../img/figs.png", width: 8cm),
  caption: [Fig 1, Fig 2 @web-fig1-fig2],
)

=== ToDo
Sometime, when writing, you might leave a notification for yourself, e.g. rework this chapter. Or you may use something like _Placeholder_ for a word that did not come to mind right away. But there is always the risk of this little piece of unfinished text to make it into the final text unnoticed. To prevent this from happening, the todo element is here to help you. Just wrap #todo[anything you want] into a todo and optionally leave a #todo(info: "note")[note] that will then appear above it. Not only are todos marked with a red backdrop, but they will also appear in a todos outline that is generated after the main text.

=== Footnote
While not technically a figure, the footnote is an often used element, to add further information in the footer #footnote[Welcome to the footer.].

== Language support <translation-en>
The template has lots of static text elements, for example all headings that are not part of the thesis directly. To make this template work with multiple languages an unconventional solution was used: The template uses the `/utils/translations.json` file to look up the correct translation. This might seem as a bad solution to most programmers, because it uses the text directly as the dictionary key, but it also makes the code more readable, because it the can contain the text that will actually be display (in english) instead of some arbitrary variable name.
To add new languages though, there is no programming experience needed. Simply open `/utils/translations.json` in the template directory and add your language to every line needed. Then you can either use specific pages like the bibliographic description in that language or change it for your whole thesis directly. Just like for the config, the template will throw an error whenever a translation is missing. Thus you can also approach this, by only translating lines as needed, indicated by the errors.
For example, the line `"Signature": {"de": "Unterschrift"}` can be changed to `"Signature": {"de": "Unterschrift", "eo": "Subskribo"}` to add Esperanto translations.

== Contributions to the template
This template was created out of frustration with the boilerplate that is LaTeX and out of curiosity for the new replacement Typst. It initially was not meant as a full template, but rather developed for my (the author) own thesis, as a way to procrastinate the actual work. Because of that, the features were mainly added based on what I (the author again) needed myself. So if you feel that the template is missing a feature, or you even want to follow my lead and procrastinate-code a feature yourself, you are free to reach out to me or create a push-request to the git-repository directly. Feedback and contributions are always appreciated. This of course also applied for this tutorial. #linebreak()
*Thank you for using this template!*
#h(10pt) - #link("mailto:carl+thtemplate@bellgardt.dev", [_Carl Heinrich Bellgardt_])

