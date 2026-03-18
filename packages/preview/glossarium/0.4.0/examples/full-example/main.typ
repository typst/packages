#import "../../glossarium.typ": make-glossary, print-glossary, gls, glspl
// Replace the local import with a import to the preview namespace. 
// If you don't know what that mean, please go read typst documentation on how to import packages at https://typst.app/docs/packages/.

#show: make-glossary

#set page(paper: "a5")

//I recommend setting a show rule for the links to that your reader understand that they can click on the references to go to the term in the glossary.
#show link: set text(fill: blue.darken(60%))

There are many Belgian universities, like @kuleuven and @ulb. When repeating their names, they won't show as a long version: @kuleuven, @ulb. But we can still force them to be long using the `gls` function: #gls("kuleuven", long: true). We can also force them to be short: #gls("kuleuven", long: false). Finally, we can make them plural using the `suffix` parameter: #gls("kuleuven", suffix: "s") or using the additional `supplement` onto the `ref`: @kuleuven[s]. We can also use the plural function function `#glspl(key: "kuleuven")` #glspl("kuleuven").



You can also override the text shown by setting the `display` argument: #gls("kuleuven", display: "whatever you want") 


#pagebreak()

Numbering is, of course, correct when referencing the glossary: @kuleuven, @ulb, @ughent, @vub, @ulb, @umons, @uliege, @unamur. They are also sorted based on where the page is in the document and not the textual representation.

#pagebreak()

At the moment, customization is not built-in to the function and instead follows a modified version of @ughent's template. But you can easily customize it by modifying `glossary.typ`. It is short enough and well documented enough to be easily understood. Additionally, you can load data externally and pass it as a parameter to the `glossary.with` function to load data from an external format.


#pagebreak()
= Glossary
#print-glossary(
  (
    (
      key: "kuleuven",
      short: "KU Leuven",
      long: "Katholieke Universiteit Leuven",
      desc: [Fugiat do fugiat est minim ullamco est eu duis minim nisi tempor adipisicing do _sunt_. #gls("vub")],
    ),
    (
      key: "uclouvain",
      short: "UCLouvain",
      long: "Université catholique de Louvain",
      desc: "Sunt pariatur deserunt irure dolore veniam voluptate cillum in. Officia nulla laborum nostrud mollit officia aliqua. Laborum tempor aute proident fugiat adipisicing qui laborum tempor ad officia. Nulla ipsum voluptate in proident laborum labore nulla culpa sunt deserunt sit ad aliqua culpa.",
    ),
    (
      key: "ughent",
      short: "UGent",
      long: "Universiteit Gent",
      desc: "Labore officia commodo dolor sunt eu sunt excepteur enim nisi ex ad officia magna. Nostrud elit ullamco quis amet id eu. Cupidatat elit cupidatat ad nulla laboris irure elit.",
    ),
    (
      key: "vub",
      short: "VUB",
      long: "Vrije Universiteit Brussel",
      desc: [Proident veniam non aliquip commodo sunt cupidatat. Enim est cupidatat occaecat elit et. Adipisicing irure id consequat ullamco non. Labore sunt tempor et mollit. #gls("kuleuven", long: true)],
    ),
    (
      key: "ulb",
      short: "ULB",
      long: "",
      desc: "Magna do officia sit reprehenderit anim esse. Eu Lorem ullamco incididunt minim quis sit sunt id mollit sit amet cupidatat. Labore incididunt enim culpa ex magna veniam proident non sint dolor. Incididunt proident esse culpa nostrud tempor cupidatat culpa consectetur excepteur ipsum deserunt duis exercitation. Non consectetur dolore culpa laboris in quis. Cupidatat aliquip exercitation id elit ipsum amet enim nostrud elit reprehenderit velit. Irure labore pariatur non dolore non officia laborum quis deserunt adipisicing cillum incididunt.",
    ),
    (
      key: "umons",
      short: "UMons",
      long: "Université de Mons",
      desc: "Aliquip incididunt elit aliquip eu fugiat sit consectetur officia veniam sunt labore consequat sint eu. Minim occaecat irure consequat sint non enim. Ea consectetur do occaecat aliqua exercitation exercitation consectetur Lorem pariatur officia nostrud. Consequat duis minim veniam laboris nulla anim esse fugiat. Ullamco aliquip irure adipisicing quis est laboris.",
    ),
    (
      key: "uliege",
      short: "ULiège",
      long: "Université de Liège",
      desc: "Tempor deserunt commodo reprehenderit eiusmod enim. Ut ullamco deserunt in elit commodo ipsum nisi voluptate proident culpa. Sunt do mollit velit et et amet consectetur tempor proident Lorem. Eu officia amet do ea occaecat velit fugiat qui tempor sunt aute. Magna Lorem veniam duis ea eiusmod labore non anim labore irure culpa Lorem dolor officia. Laboris reprehenderit eiusmod nostrud duis excepteur nisi officia.",
    ),
    (
      key: "unamur",
      short: "UNamur",
      long: "Université de Namur",
    ),
    (
      key: "notused",
      short: "Not used",
      desc: [This key is not cited anywhere, it won't be in the glossary unless the `show-all` argument is set to true],
    ),
  ),
  // show all term even if they are not referenced, default to true
  show-all: true,
  // disable the back ref at the end of the descriptions
  disable-back-references: true,
)
