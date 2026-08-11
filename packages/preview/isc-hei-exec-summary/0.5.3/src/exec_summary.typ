// Adapted from the BFH year book idea at https://www.bfh.ch/dam/jcr:e512ae31-a3ed-4b65-b589-870383d794b0/abschlussarbeiten-bsc-informatik.pdf

#import "@preview/isc-hei-exec-summary:0.5.3" : *

#let doc_language = "en" // Valid values are en, fr

// Must be < 425 characters long.
#let summary = "DataFlowX is a scalable data engineering platform for real-time analytics on large, heterogeneous datasets. DataFlowX automates data ingestion, transformation, and validation using distributed processing and intelligent scheduling. The system ensures data quality, accelerates insights, and supports seamless integration with modern business intelligence tools."

#let content = [

// This is where you put the content of your executive summary
== Objectives
The primary objective of DataFlowX is to provide organizations with a robust and scalable platform for real-time analytics on large, diverse datasets. By automating the processes of data ingestion, transformation, and validation, DataFlowX aims to streamline data workflows and ensure high quality. 

The platform leverages distributed processing and intelligent scheduling to optimize performance and resource utilization. Additionally, DataFlowX is designed to seamlessly integrate with modern business intelligence tools, enabling faster and more accurate insights. Ultimately, the project seeks to empower businesses to make data-driven decisions efficiently and confidently in dynamic environments.

// An example a figure using the `cetz` package to draw a
#import "@preview/cetz:0.4.0": canvas, draw
#import "@preview/cetz-plot:0.1.2": plot
#import draw: line, content, circle, rect

#let ex_fig = canvas(length: 2cm, {
  import draw: *
  let phi = (1 + calc.sqrt(5)) / 2

  ortho({
    hide({
      line(
        (-phi, -1, 0), (-phi, 1, 0), (phi, 1, 0), (phi, -1, 0), close: true, name: "xy",
      )
      line(
        (-1, 0, -phi), (1, 0, -phi), (1, 0, phi), (-1, 0, phi), close: true, name: "xz",
      )
      line(
        (0, -phi, -1), (0, -phi, 1), (0, phi, 1), (0, phi, -1), close: true, name: "yz",
      )
    })

    intersections("a", "yz", "xy")
    intersections("b", "xz", "yz")
    intersections("c", "xy", "xz")

    set-style(stroke: (thickness: 0.5pt, cap: "round", join: "round"))
    line((0, 0, 0), "c.1", (phi, 1, 0), (phi, -1, 0), "c.3")
    line("c.0", (-phi, 1, 0), "a.2")
    line((0, 0, 0), "b.1", (1, 0, phi), (-1, 0, phi), "b.3")
    line("b.0", (1, 0, -phi), "c.2")
    line((0, 0, 0), "a.1", (0, phi, 1), (0, phi, -1), "a.3")
    line("a.0", (0, -phi, 1), "b.2")

    anchor("A", (0, phi, 1))
    content("A", [$A$], anchor: "north", padding: .1)
    anchor("B", (-1, 0, phi))
    content("B", [$B$], anchor: "south", padding: .1)
    anchor("C", (1, 0, phi))
    content("C", [$C$], anchor: "south", padding: .1)
    line("A", "B", stroke: (dash: "dashed"))
    line("A", "C", stroke: (dash: "dashed"))
  })
})

#align(center, scale-to-width(50%, ex_fig)) 

== Explanation
The development of DataFlowX followed an agile methodology, emphasizing iterative progress and continuous feedback. The project began with requirements gathering and architectural design, focusing on scalability and integration capabilities. Core modules for data ingestion, transformation, and validation were implemented using distributed processing frameworks. Automated testing and code reviews ensured reliability and maintainability throughout development. 

Regular meetings with stakeholders guided feature prioritization and refinements. Integration with business intelligence tools was achieved via standardized APIs. Performance benchmarks and user acceptance testing validated the system’s effectiveness. Documentation and training materials were prepared to facilitate deployment and user onboarding, ensuring a smooth transition to production.

#colbreak() // As Typst does not support auto column balancing, this must be put to break the columns evenly. Move it to a location that makes the columns even.

== Conclusion / Benefits 
DataFlowX delivers significant benefits by enabling organizations to harness real-time analytics on large, heterogeneous datasets with ease. Its automated data ingestion, transformation, and validation processes reduce manual effort and minimize errors, ensuring high data quality. The platform’s distributed architecture and intelligent scheduling optimize resource usage and scalability, supporting growing business needs. By streamlining complex data workflows and providing robust performance, DataFlowX empowers businesses to respond quickly to changing environments, maintain a competitive edge, and make informed, data-driven decisions with confidence and efficiency.

#figure(code(numbering: none)[
```scala
  def lambda(val x : Any) : Int =
    x match :
      case f: Int => f
      case _ => 42 // The answer  
  ```
], caption: "A code snippet")

#align(center, block(text([Everything *must* fit on one page when rendered !]), fill : yellow, inset:4pt))

// Optionally, if you need a figure spanning multiple columns, you can use this.
#place(
 bottom,
 scope: "parent",
 float: true,
 figure(image("figs/made.svg", fit: "contain", height: 6cm, width: 100%), caption: "A figure spanning multiple columns"),
)

// This is the end !
]

// TODO: please modify the following to suit your needs.
#show: project.with(  
  title: "Life, the Universe and Everything", 
  language: doc_language, // Modify global if required, see above
  authors: "Stormy Peters", 
  student-picture: image("figs/random_image.png"), // [Optional], put none if not used
  permanent-email: "john.doe@example.com", // [Optional], put none if not used
  video-url: "https://isc.hevs.ch", // This is a link to the video of you project, if any

  summary: summary, // Not to be changed
  content: content, // Not to be changed

  thesis-supervisor: "Prof. Dr John von Neumann", 
  thesis-co-supervisor: "Lady Ada Lovelace", // Optional, use none if not needed
  thesis-expert: "Dr Grace Hopper", // Optional, use none if not needed
  academic-year: "2025-2026", // Optional, use none if not needed

  is-executive-summary: true, // This is an executive summary, not a full thesis  
  
  school: "Haute École d'Ingénierie de Sion", 
  programme: "Informatique et Systèmes de communication (ISC)",

  // Some keywords related to your thesis
  keywords: ("engineering", "data", "machine learning", "meteorology"),
  major : "Data engineering", // "Software engineering", "Networks and systems", "Embedded systems", "Computer security", "Data engineering""

  bind: right, // Bind the left side of the page
  footer: "Executive summary", // align(right, text(0.9em)[This is some content for the footer])
) 