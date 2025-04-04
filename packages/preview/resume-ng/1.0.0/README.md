# Resume-ng (Typst Version)

A typst resume designed for optimal information density and aesthetic appeal.

A LaTeX version


# QuickStart

`main.typ` will be a good start. 

A minimal exmaple would be:

```typst
#show: project.with(
  title: "Resume-ng",
  author: (name: "FengKaiyu"),
  contacts: 
    (
      "+86 188-888-8888",
       link("https://github.com", "github.com/fky2015"),  
      // More items...
    )
)

#resume-section("Educations")
#resume-education(
  university: "BIT",
  degree: "Your degree",
  school: "Your Major and school",
  start: "2021-09",
  end: "2024-06"
)[
*GPA: 3.62/4.0*. My main research interest 
is in #strong("Byzantine Consensus Algorithm"), 
and I have some research and engineering experience in the field of distributed systems.
]

#resume-section[Work Experience]
#resume-work(
  company: "A company",
  duty: "Your duty",
  start: "2020.10",
  end: "2021.03",
)[
  - *Independently responsible for the design, development, testing and deployment of XXX business backend.* Implemented station letter template rendering service through FaaS, Kafka and other platforms. Provided SDK code to upstream, added or upgraded various offline and online logic.
  - *Participate in XXX's requirement analysis, system technical solution design; complete requirement development, grey scale testing, go-live and monitoring.*
]

#resume-section[Projects]

#resume-project(
  title: "Project name",
  duty: "Your duty",
  start: "2021.11",
  end: "2022.07",
)[
  - Implemented a memory pool manager based on an extensible hash table and LRU-K, and developed a concurrent B+ tree supporting optimistic locking for read and write operations.
  - Utilized the volcano model to implement executors for queries, updates, joins, and aggregations, and performed query rewriting and pushing down optimizations.
  - Implemented concurrency control using 2PL (two-phase locking), supporting deadlock handling, multiple isolation levels, table locks, and row locks.
]
```
