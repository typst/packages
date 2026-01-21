= Introduction <chap:intro>

== Topic and scope of this thesis <sec:topic-and-scope>
This is not an actual thesis. It is a boilerplate document meant to showcase
the put-thesis Typst template for writing scientific dissertations for Poznań
University of Technology. The stylistic choices are largely inspired
by~@template2022 and~@Drozdowski2006.

This document is written for Polish and International students alike.
Information pertaining to all is written in English. Tips and guidelines
specific to the Polish language are also sprinkled throughout, with lengthier
topics covered in @chap:polish-tips.

== The rules of introductions
The introduction chapter should include the following information:

- a brief explanation of why the topic was chosen;

- the goal of the work (see below);

- scope of work -- how the work will be done, to what extent, in how much time;

- potential hypotheses, which the authors will aim to test or prove;

- a brief summary of sources and inspirations, especially literature;

- the structure of the work (see below), i.e. a terse characteristics of the
  contents of each chapter;

- potential remarks regarding the implementation, e.g. difficulties which were
  encountered along the way, comments on the equipment that was used,
  partnerships with third-party companies.

#v(1em)
/ Introduction #underline[must] conclude with the following two paragraphs\::
  #v(1mm)
  1. #quote(block: true)[
    The goal of this thesis is to research / analyze / design / ...
  ]
  2. #quote(block: true)[
    The structure of the thesis is as follows. @chap:literature contains a
    review of literature on~... . @chap:own-work is dedicated to~... (a few
    sentences). @chap:conclusions concludes the work.
  ]
  #v(2mm)
/ or, in Polish\::
  #v(1mm)
  #set text(lang: "pl")
  1. #quote(block: true)[
    Celem pracy jest opracowanie / wykonanie analizy / zaprojektowanie / ...
  ]
  2. #quote(block: true)[
    Struktura pracy jest następująca. W @chap:literature[Rozdziale] przedstawiono
    przegląd literatury na temat ... . @chap:own-work[Rozdział] jest poświęcony ...
    (kilka zdań). @chap:conclusions[Rozdział] stanowi podsumowanie pracy.
  ]
  #set text(lang: "en")

#v(1em)
#block(breakable: false)[
  In case of Bachelor theses done in groups, or Master theses done in pairs,
  after the aforementioned two paragraphs, there #underline[must] be a paragraph
  detailing how work was divided among the group members. For example:
  #v(-1em)
  #quote(block: true)[
    Throughout the process of making this thesis, Jane Doe was responsible for
    creating the design for ... and .... She identified the issues present in
    ... and proposed ..., etc.

    Joe Briggs contributed ..., etc.
  ]
  Or, in Polish:
  #v(-1em)
  #set text(lang: "pl")
  #quote(block: true)[
    Jan Kowalski w ramach niniejszej pracy wykonał projekt tego i tego,
    opracował ... .

    Grzegorz Brzęczyszczykiewicz wykonał ..., itd.
  ]
  #set text(lang: "en")
]
