#import "@preview/tudelft-thesis-novanext:0.1.0": *
#import "@preview/drafting:0.2.2": *

/*
  set document(
    author: "auto",
    title: [Placeholer Title],
    date: datetime.today(),
  )
  subtitle.update([Optional Subtitle])
  #show: thesis
  // #show: thesis-classic
  #show: front-matter
*/

#show title: it => align(center, [
  #e.get(get => {text(
    font: get(dropcap).font,
    size: 24pt,
    it
  )})
  #if subtitle.get() != none {
    subtitle-font(subtitle.get())
  }
])

#title()
#pagebreak(to: "odd")
#title()

#v(3fr)
#align(center, [
  #subtitle-font[Dissertation]
  
  for the purpose of obtaining the degree of doctor\ at TU Delft\
  by the authority of the Rector Magnificus,
  prof.~dr.~ir.~T.H.J.J.~van der Hagen,\
  chair of the Board for Doctorates\
  to be defended publicly on\
  Sunday 31, February 2202 at 24:00 o'clock
  #v(1fr)
  #margin-note(dy:-2cm)[Check that everything here is correct RIGHT BEFORE SENDING YOUR THESIS TO THE PUBLISHER]
  by\

  #linebreak()
  #author-font[
    #context(document.author).join(", ", last:" & ")
    #linebreak()
  ]
  #v(1fr)
  [highest academic title, name university, country] \
  born in [town/city, country of birth]
  #v(2fr)
])

#pagebreak()

// The following line is dictated by the promotieregelement.
This dissertation has been approved by the promotors.

Composition of the doctoral committee:
// List the committee members, starting with the Rector Magnificus and the promotor(s) and ending with the reserve members.
#let grid = grid.with(
  columns: (33%, auto),
  align: (left, left),
  row-gutter: 0.7em,
)
#grid(
  [Rector Magnificus], [chairperson],
  [Prof. dr. A. Kleiner], [TU Delft _promotor_],
  [Dr. A.A. Aaronson], [TU Delft, _copromotor_],
)

_Independent members:_

#grid(
  [Prof. dr. A. Jansen], [TU Delft],
  // Special case, only for very long names
  grid.cell(colspan: 2)[Prof. dr. ir. A.B.C.D. van de Lange-Achternaam],
  [], [TU Delft],
  [Prof. dr. N. Nescio], [Politecnico di Milano, Italy],
  [Prof. dr. ir. J. Doe], [TU Delft, reserve member]
)

_Other members:_

#grid(
  [Prof. dr. ir. J. de Wit], [TU Delft],
  [Dr. ir. Q. de Zwart], [TU Delft],
)

#v(1fr)

// Include the following disclaimer for committee members who have contributed to this dissertation. Its formulation is again dictated by the promotieregelement.
Prof. dr. ir. J. de Wit of TU Delft has contributed greatly to the preparation of this dissertation.
// Here you can include the logos of any institute that contributed financially to this dissertation.

#v(2fr)
#align(center)[#image(width: 7cm, "tudelft.svg")]
#v(2fr)

/*
  \begin{center}
    \includegraphics[height=0.5in]{_logos/tudelft}
    \hspace{2em}
    \includegraphics[height=0.5in]{_logos/casimir} \\
    \includegraphics[height=0.5in]{_logos/fom}
    \hspace{2em}
    \includegraphics[height=0.5in]{_logos/nwo}
  \end{center}
*/

#grid(
  columns: (20%, auto),
  [_Keywords:_], [...],
  [_Printed by:_], [Johannes Gutenberg],
  [_Cover by:_], [Beautiful cover art that captures the entire content of this thesis in a single illustration.]
)
#v(2fr)
Copyright #sym.copyright #datetime.today().display("[year]") by //\@initials~\@lastname
A. Einstein

// Uncomment the following lines if this dissertation is part of the Casimir PhD Series, or a similar research school.
// Casimir PhD Series, Delft-Leiden 2015-01

ISBN 000-00-0000-000-0

An electronic copy of this dissertation is available at\
https://repository.tudelft.nl/.
