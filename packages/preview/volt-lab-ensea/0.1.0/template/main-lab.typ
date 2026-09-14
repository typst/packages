#import "@preview/volt-lab-ensea:0.1.0": *

// ============================
// VARIABLES TO MODIFY
// ============================

#show: report.with(
  // Title of the lab report
  title: [#lorem(10)],

  // Name(s) of the student(s) contributing to the report
  authors: (
    "Jean DUPONT",
    "Marie DUBOIS",
  ),

  // Information about the student(s)
  student-info: [*Élève ingénieur en X#super[ème] année* #linebreak()
    Promotion 20XX #linebreak()
    Année 20XX/20XX],

  // Description of the lab objectives
  lab-description: [
    - #lorem(15) #linebreak()
    - #lorem(15) #linebreak()
    - #lorem(15)
  ],
)

// ============================
// START HERE
// DELETE THE LINES BELOW THIS COMMENT
// ============================

= Titre de niveau 1
#lorem(70)

== Titre de niveau 2
#lorem(50)

#figure(image("media/logo-ENSEA.png", width: 25%), caption: [Logo de l'ENSEA])

=== Titre de niveau 3
#lorem(35)

```java
// HelloWorld.java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```

// Insert a page break
#pagebreak()

= Conclusion
#lorem(350)
