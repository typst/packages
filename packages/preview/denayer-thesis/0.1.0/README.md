## Template for master thesis at Campus De Nayer.
This is an unnoficial template for a thesis at campus De Nayer. For English and Dutch speaking students. 
## Usage
```typ
#import "@preview/denayer-thesis:0.1.0" : template


#template(
  auteurs: ("First name LAST NAME",),
  promotor:  "Promotor",
  co-promotor : "Co-promotor",
  evaluatoren : ("evaluator1","evaluator2"),
  begeleider : "accompanist",
  start-datum : "2025",
  einde-datum : "2026",
  title : "Title of master thesis",
  subtitle : "subtitle",
  cover : "cover_fiiw_denayer_eng.png",
  dutch-titlepage: false,
  dutch-title: "Titel van masterproef",
  dutch-subtitle: "ondertitel",
  contents: [
    // Put your content here
  ]
)
```
