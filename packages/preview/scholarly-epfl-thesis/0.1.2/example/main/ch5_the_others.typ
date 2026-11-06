= The others (_not the movie_)

== Useful stuff for citation

This is to cite stuff in-line `#cite(<bla-bla>)` #sym.arrow @REF:3 @REF:1.

Now for brief foot citations you can put citations in a footnote: `#footnote[#cite(<bla-bla>)]` #sym.arrow look
down!#footnote[#cite(<REF:1>)]

See https://typst.app/docs/reference/model/cite/ for more citation styles.// For fully-detailed citation we do it like dis `footfullcite{bla-bla}` #sym.arrow look
// down\footfullcite{REF:1} and another one for fun\footfullcite{REF:3}.

// To cite the author only we do dis `citeauthor{bla-bla}` #sym.arrow \citeauthor{REF:1};
// the only year god only knows why we could use it but here we go `citeyear{bla-bla}` #sym.arrow \citeyear{REF:1}.

This is just a normal footnote.#footnote[I'm just a normal footnote minding my own business]

== Useful stuff chemical formulae

- The first style:
CHEM FORMULA HERE
- The second style:
CHEM FORMULA HERE
- The third style:
CHEM FORMULA HERE
// \begin{itemize}
//     \item The first style:\newline~\newline
// \ce{Na2SO4 ->[H2O] Na+ + SO4^2-}
// \ce{(2Na+,SO4^2- ) + (Ba^2+, 2Cl- ) -> BaSO4 v + 2NaCl}
// ~\newline~\newline
// \item The second style:\newline~\newline
// \begin{chemmath}
//   Na_{2}SO_{4}
//   \reactrarrow{0pt}{1.5cm}{\ChemForm{H_2O}}{}
//   Na^{+} + SO_{4}^{2-}
// \end{chemmath}
// \begin{chemmath}
//   (2 Na^{+},SO_{4}^{2-}) + (Ba^{2+},2 Cl^{-})
//   \reactrarrow{0pt}{1cm}{}{}
//   BaSO_{4} + 2 NaCl
// \end{chemmath}
// ~\newline~\newline
// \item The third style:\newline~\newline
// \schemestart
// \chemfig{Na_2SO_4}
// \arrow{->[\footnotesize\chemfig{H_2O}]}
// \chemfig{Na^+}\+\chemfig{SO_2^{-}}
// \schemestop
// \schemestart
// (2\chemfig{Na^+}, \chemfig{SO_4^{2-}})
// \+
// (\chemfig{Ba^{2+}}, 2\chemfig{Cl^{-}})
// \arrow(.mid east--.mid west)
// \chemname[1pt]{\chemfig{BaSO_4}}{\chemfig{-[,0.75]-[5,.3,,,-stealth]}}\+2\chemfig{NaCl}
// \schemestop

// \end{itemize}

#lorem(100)

#pagebreak()

just an empty page...