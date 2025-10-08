# KULeuven template for master thesis at Campus De Nayer.
For english and dutch speaking students. 
## Usage
```typ
#import "../template/template.typ" : template


#template(
  auteurs: ("First name LAST NAME",),
  promotor:  "Promotor",
  Co-promotor : "Co-promotor",
  evaluatoren : ("evaluator1","evaluator2"),
  begeleider : "accompanist",
  startDatum : "2025",
  eindeDatum : "2026",
  title : "Title of master thesis",
  subtitle : "subtitle",
  cover : "cover_fiiw_denayer_eng.png",
  dutchTitlePage: false,
  dutchTitle: "Titel van masterproef",
  dutchSubtitle: "ondertitel",
  contents: [
    // Put your content here
  ]
)
```