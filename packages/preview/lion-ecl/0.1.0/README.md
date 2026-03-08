# ECL-template-typst
A Typst template for Ecole Centrale de Lyon scientific report

## Quick start : 

```typ
#import "@preview/lion-ecl:0.1.0": *
#show: project.with(
  titre: "Rapport",
  subtitle :"Sous titre",
  auteurs: ("Le Lion"),
  mentors : ("Ecully","Bob"),
)

// Content of the report
```

