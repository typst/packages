#import "@preview/unibuc-fmi-thesis-template:0.1.0": *

#let rezumat = "Unu in romana "+lorem(30)
#let abstract = "One in engleza "+lorem(30)


#show: project.with(
 title: "Titlul Lucrarii",
 author: "Numele tau",
 coordinator: "Conf. Dr. Numele lui",
 rezumat: rezumat,
 abstract: abstract,
 date: "București, Iunie 2024",
)


// GHID REDACTARE: 
// https://drive.google.com/file/d/1UaCKdlgkSVW71c_h3OWPRFNdBICfU2r7/view

= Introducere
Conține:
- tipul lucrării şi subdomeniul specific în care se încadrează tema,
- prezentarea generală a temei,
- scopul şi motivația alegerii temei,
- contribuţia proprie în realizarea lucrării (pe scurt),
- structura lucrării, cu descrierea succintă a fiecărui capitol,
- câteva repere istorice relativ la temă şi rezultate cunoscute (starea actuală a
domeniului eventual).

#pagebreak()
== Subcapitol
=== Sub subcapitol
// Asa scrii un comentariu

Asa faci o lista:
#list( indent: 2em,
[Prima chestie;],
[A doua chestie.],
)

Sau asa:
- Prima chestie;
- A doua chestie.

#figure(image("images/logo-ub.png"), caption: [Asa se introduce o figura.])

#figure((table(columns:2, 
  [Coloana 1],[Coloana 2],
  [Randu 1], [Elementu 1],
  [Randu 2], [Elementu 2]
)),caption:[Asa se introduce un tabel.])

$ sum_(k=0)^n k
    &= 1 + ... + n \
    &= (n(n+1)) / 2 $

Referintele @book sunt puse @attention_is_all_you_need in ordinea in care @Spectre apar @site.



= Preliminarii
Conţine, după caz:
- noţiuni ştiinţifice sau tehnologice care stau la baza temei,
- stadiul actual al subdomeniului specific din care face parte tema,
- obiectivele lucrării prin raportare la context.


= Descrierea aplicației
sau "Contribuția propriu-zisă a candidatului"

- Structurată în funcție de tipul lucrării, fiind compusă dintr-un număr arbitrar de
capitole (vezi formatul lucrării în funcţie de tip).
- Capitolele:
  - Descriu în detaliu fundamentarea teoretică și dezvoltarea aplicativă (dacă e cazul)
  a temei abordate
  - Conţin puncte de vedere personale, interpretări ale teoriilor și conceptelor
  abordate în lucrare
  - Trec în revistă abordări existente ale problemei cu evidențierea avantajelor şi
  dezavantajelor
  - Descompun problema propusă de tema lucrării în subprobleme specifice şi
  prezentarea modului de rezolvare, analize critice ale fenomenelor şi proceselor
  studiate, comparații cu rezultate obţinute anterior (unde e cazul), proiectarea
  aplicaţiei, detalii de implementare, rezultate experimentale, exemple de test sau
  rezultate sub forma unor studii de caz, modul de utilizare a programului etc.

= Concluzii
- concluzii referitoare la modul de realizare a temei
- posibile dezvoltări ulterioare ale temei
- aprecierile personale privind relevanța rezultatelor obținute
- eventuale aplicații practice sau interferențe cu alte domenii

= Bibliografie
#bibliography("referinte.bib", title: none, full: false)

= Anexe

Sunt opționale și nu fac parte propriu-zisă din lucrare
 
Conţin informaţii utile pentru parcurgerea lucrării, dar care, prin specificul lor, nu se
încadrează în corpul propriu-zis al acesteia

Se numerotează distinct de capitolele lucrării: Anexa 1, Anexa 2, etc.



