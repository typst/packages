#import "@preview/glossarium:0.4.1": make-glossary, print-glossary

#show: make-glossary

/*
Add your glossary terms below!

  - They will always be shown alphabetically

  - If you don't specify a plural/longplural form, #gspl() will just add an s in case you call it

For any doubts, check the page of the imported package:
https://github.com/typst-community/glossarium
*/
#print-glossary(

  // Terms you add in this file need to be referenced to show up, unless you uncomment this line:
  // show-all: true,
  
  (
    (
      key: "potato",
      short: "potato",
      plural: "potatoes",
      desc: "A tuber that you can eat."
    ),
    

    // You can add categories with "group:"

    // ACRONYMS GROUP
    (
      key: "ist",
      short: "IST",
      long: "Instituto Superior Técnico",
      group: "Acronyms"
    ),

    (
      key: "dm",
      short: "DM",
      long: "Diagonal Matrix",
      longplural: "diagonal matrices",
      group: "Acronyms"
    ),

    // SYMBOLS GROUP
    (
      key: "mu_0", 
      short: $mu_0$,
      desc: "Standard magnetic permeability.",
      group: "Symbols"
    ),
  )
)
