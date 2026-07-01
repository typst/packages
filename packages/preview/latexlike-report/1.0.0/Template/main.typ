#import "@preview/latexlike-report:1.0.0": *

#show: latexlike-report.with(
 
 // ======== Cover ============
 //Use content [] or none, except in author.
  author: "Jorge X Beta", // must be a string ("")
  title: [Report Title],
  subtitle: [Report Subtitle],
  
  participants: [Some other author], // In case of several authors (the name in author parameter will go first) Use content [] or none.
  
  affiliation: [Your institution],
  year: [2025],
  class: [Your class],
  other: none,

  date: [#datetime.today().display()], // You could use #datetime.today().display() for the date.

  logo : image("Images/InSTEC.svg"),

  //==========Theme ===============
  theme-color: rgb("#0f2787"),
  lang: "en", 
   participants-supplement: "Authors:", //Change it if you change the language
 
            
  //=========Font =================
  title-font: "New Computer Modern",
  font: "New Computer Modern",
  font-size : 13pt,
  font-weight: 400,

  //============ Math =============

  math-font: "New Computer Modern Math",
  math-weight: 400,
  math-ref-supplement: auto, //Use none for no supplement, auto for language based or any other function or string you like
  math-numbering: "(1.1)", // The numbering style you like
  
  // ---- Equate package ---
  // For more information, you can refer to equate documentation
  
  math-number-mode: "label", //Can be "label" or "line" 
  math-sub-numbering: true,  // true or false

  //===========Page style===============
  pagebreak-section: true, //For pagebreak after adding a new level one heading (=)
  show-outline:true, //true or false 
  page-paper:"a4",

  //-----chic header package----
  // customize the left/center/right header and left/center/right footer
  // you can add images, text, the number of the current page, etc, or put none if you don't want some part of the header or footer.
  //some usefull function: chic-page-number(), chic-heading-name()
  
  h-l : [#smallcaps[Something you want to add]],
  h-r :[#image("Images/InSTEC_LOGO.svg",width: 14%)],
  h-c : none,

  f-l : [],
  f-r : [],
  f-c : chic-page-number(),
  //=======================================
  //For more customitation you can check the documentation. !! Enjoy :D !!
)

  
///////////////////////////Document starts/////////////////////////////
= First section

 #lorem(50)

 $ alpha = 5 x x /7  oo > integral_oo^oo  dif x   = -> => >= integral_a^x  oo sum_a_i angle.l alpha|x|a_i angle.r  dif x  $ <eq1>


 #smallcaps[Some unsense math in ]  @eq1



= Unnumbered section <nonumber>

== Unnumbered section in level two <nonumber>

=== Simple list <nonumber>


+ #lorem(4)
  - #lorem(2)
+ #lorem I'm tired





= Related Work
#lorem(200)

#figure(
  table(columns: 2)[A][B][C][D],
  caption: [Tables caption go up, but you can change it \ at the start of the document],
)
#figure(
  caption: "Down for figures",
  image("Images/InSTEC.svg",width: 30%)
)<ascas>





#figure(
table(columns: 6, align: center,
  table.cell(colspan: 2 )[Resistencia $X 1$], table.cell(colspan: 2 )[Resistencia $ X 2$], table.cell(colspan: 2,  )[Resistencia $X 3$], 
  [Valor de $ R 2$], [Valor de Resistencia], [Valor de $R 2$], [Valor de Resistencia], [Valor de $R 2$], [Valor de Resistencia], 
  [10], [512], [2010], [101495], [55000], [2777228], 
  [10], [511], [2010], [101495], [55010], [2777733], 
  [10], [511], [2010], [101500], [55003], [2777379], 
  [10], [511], [2010], [101500], [55020], [2778238], 
  [10], [511], [2010], [101500], [55000], [2777228], 
  [10], [511], [2010], [101495], [55000], [2777228], 
  [10], [512], [2010], [101500], [55005], [2777480], 
  [10], [511], [2010], [101500], [54973], [2775864], 
  [10], [511], [2010], [101500], [55007], [2777581], 
  [10], [511], [2010], [101495], [55004], [2777430], 
), caption: [Table cells are not justify])
