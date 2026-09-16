#import "@preview/chicv-ripoff:1.1.4": *

#show: chicv.with(
  margin: (x: 1cm, top: 1.5cm, bottom: 2cm),
  par-padding: (left: 0pt, right: 0pt),
)

= Chi Zhang

#personal-info(
  email: "iskyzh@gmail.com",
  github: "https://github.com/skyzh",
  website: "https://skyzh.dev",
  linkedin: "https://www.linkedin.com/in/alex-chi-skyzh/",
  // x-twitter: "https://twitter.com/iskyzh",
  // (link: "https://typst.app/", text: "Typst", icon: "t", solid: true),
)

== Education

#cventry(
  tl: "Carnegie Mellon University",
  tr: dates(from: "2022/08", to: "2023/12"),
  bl: "Master of Science in Computer Science, GPA 4.10/4.33",
  br: "Pittsburgh, PA, USA"
)[
  - Teaching Assistant for 15-445/645 Database Systems (Fall 2022, Spring 2023, Fall 2023)
  - Courses: Distributed Systems, Compiler Design, Advanced Database Systems, Deep Learning Systems, etc.
]

// by default, #cventry will bold top-left text
#cventry(
  tl: "Shanghai Jiao Tong University",
  tr: dates(from: "2018/09", to: "2022/06"),
  bl: "Bachelor of Engineering in Computer Science and Technology",
  br: "Shangehai, China"
)[
  - GPA 93.80/100, Rank 1/149, National Scholarship 2019 (Top 0.2% national-wide)
  - A+ Courses: Operating Systems, Computer Architecture, Computer Networks, and 28 others
]

== Work Experience

// but you can override the default bold style by passing content blocks
#cventry(
  tl: [#link("https://neon.tech")[*Neon*]],
  tr: dates(from: "2024/02"),
  bl: [Systems Software Engineer],
  br: [Remote / Pittsburgh, PA, USA],
  // you can also override the default padding of content blocks
  padding: (bottom: -5pt)
)[]

#cventry(
  tl: [_... and also_],
  tr: dates(from: "2023/05", to: "2023/08"),
  bl: [Software Engineer Intern],
  br: [Remote / Pittsburgh, PA, USA],
)[
  - Neon is a fully-managed PostgreSQL service built on a key-value storage engine with point-to-time recovery support.
  - *Compaction Strategy Enhancement*. Conducted an in-depth analysis and evaluation of the storage engine to assess performance metrics and storage space efficiency. Implemented the RocksDB-style tiered compaction and improved page reconstruction strategy, which reduced space amplification by 2x and enhanced read-update performance by 20%.
 - *Improved User Adoption on the Edge*. Enhanced the overall reliability of the Neon serverless driver and the control plane proxy. Collaborated closely with the #link("https://github.com/prisma/prisma", [Prisma]) ORM team to integrate the serverless driver into Prisma and ensured compatibility with Vercel Edge Runtime by transitioning the Rust Prisma engine codebase to be WebAssembly-ready.
]

#cventry(
  tl: [#link("https://risingwave.com/", [*RisingWave Labs*])],
  tr: dates(from: "2021/08", to: "2022/07"),
  bl: [Database System R&D Intern],
  br: [Shanghai, China]
)[
  - *Top contributor of #githublink("https://github.com/risingwavelabs/risingwave", text: "RisingWave")*. RisingWave is a database system with PostgreSQL-compatible interface that incrementally maintains materialized views. Worked on features including streaming index joins, query optimization of stream plans, distributed streaming execution, cloud-native LSM state store, vectorized expression framework.
  - *Streaming Index Joins*:  Designed shared state and streaming index in RisingWave; implemented index lookup join executor; implemented delta join DAG optimizer transformations; implemented distributed delta join scheduler.
  - *Performance Improvement*:  Conducted intensive benchmarks and analyzed performance issues. Fixed bugs, proposed strategies, and led cross-team collaboration which improved the system throughput by 10x in a 3-month period.
  - *Developer Experience*.  Initiated the RiseDev development tool and the developer dashboard, which is deeply integrated into the development workflow across debugging, unit testing, integration testing, and benchmarking.
  - *Mentoring*. Mentored database kernel interns and helped their successful integration into the team. Maintained overview documents of the database kernel to facilitate knowledge transfer and help new hires learn about the system.
]

#cventry(
  tl: "ByteDance",
  tr: dates(from: "2021/06", to: "2021/08"),
  bl: "Storage System R&D Intern, TerarkDB Team",
  br: "Beijing, China"
)[
  - *Co-Optimized #githublink(text: "TerarkDB", "https://github.com/bytedance/terarkdb")* and *#githublink(text: "ZenFS", "https://github.com/westerndigitalcorporation/zenfs")*. TerarkDB is a fork of RocksDB and ZenFS is a filesystem on Zoned Namespaces (ZNS) SSDs. Implemented Zone-aware Garbage Collection in TerarkDB for ZNS and WAL-Aware Zone Allocator in ZenFS, which reduced 3-4x of space amplification and greatly improved tail latencies caused by zone allocation.
]

#cventry(
  tl: "PingCAP",
  tr: dates(from: "2020/08", to: "2021/01"),
  bl: "Storage System R&D Intern, TiKV Storage Team",
  br: "Shanghai, China"
)[
  - Built LSM-based storage engine *#githublink("https://github.com/tikv/agatedb", text: "AgateDB")* from ground-up. Inspired by WiscKey and BadgerDB, AgateDB separates large values from the LSM tree into a separate value log, so as to reduce write amplification and improve throughput.
]

== Open-Source Contributions

#cventry(
  tl: [
    *BusTub* #githublink("https://github.com/cmu-db/bustub", text: "cmu-db/bustub") _as Teaching Assistant for Database Systems_
  ],
  tr: dates(from: "2022/08", to: "2023/12")
)[
  - Lead the development of the BusTub educational database system and course projects in CMU Database Systems course.
 - Added query processing layer to the system with PostgreSQL syntax support. Restructured the query execution project.
 - Added multi-version concurrency control to the system based on HyPer/Umbra undo log version chain implementation.
 - Redesigned course projects to help students better understand the concepts and align with industrial database systems.
 - Developed leaderboard tests to challenge advanced students and enable further study in optimizing database systems.
]

#cventry(
  tl: [
    *RisingLight Maintainer* #githublink("https://github.com/risinglightdb", text: "risinglightdb")
  ],
  tr: dates(from: "2022/01")
)[
  -  Lead the development of RisingLight, an OLAP database system in Rust for educational purpose. RisingLight supports simple TPC-H queries, and has a merge-tree based columnar storage.
]

#cventry(
  tl: [
    *TiKV Community* #githublink("https://github.com/tikv", text: "tikv")
  ],
  tr: dates(from: "2020/05")
)[
  - Maintains TiKV Coprocessor, the push-down execution framework of TiDB. Mentored community members to contribute features (e.g. new data types, plugin system) in the *LFX Mentorship*. #iconlink("https://github.com/tikv/tikv/issues/9066")  #iconlink("https://github.com/tikv/tikv/issues/9747")
]

#cventry(
  tl: [
    *Personal Projects* #githublink(text: "skyzh", "https://github.com/skyzh")
  ],
  tr: [6.6k followers on GitHub]
)[
  - *#githublink(text: "mini-lsm", "https://github.com/skyzh/mini-lsm")* (#fa-icon("star", solid: true) 2k) Build a simple LSM-Tree storage system in Rust in a week
  - *#githublink(text: "type-exercise-in-rust", "https://github.com/skyzh/mini-lsm")* (#fa-icon("star", solid: true) 1k) Learn Rust generics by implementing a vectorized expression evaluation framework
]

== Research Experience

#cventry(
  tl: [*Adaptive Query Optimization Framework* #githublink("https://github.com/cmu-db/optd", text: "cmu-db/optd")],
  tr: dates(from: "2023/09", to: "2023/12"),
  bl: [CMU Database Group, advised by Professor Andy Pavlo],
  br: [Pittsburgh, PA, USA]
)[
  - *Developed optd*, an optimizer framework based on the Columbia Cascades paper targeting real-time OLAP queries.
  - *Adaptive Optimization*. optd collects statistics during execution and uses runtime data to guide later plan searches.
  - *Partial Exploration*. optd explores plans by reusing and incrementally expanding the plan space from the last search.
]

#cventry(
 tl: [*PostgreSQL Extension Manager* #githublink("https://github.com/cmu-db/pgextmgrext", text: "cmu-db/pgextmgrext")],
 tr: dates(from: [2023/02], to: [2023/05]),
 bl: [CMU Database Group, advised by Professor Andy Pavlo],
 br:[Pittsburgh, PA, USA]
)[
 - *Implemented pgextmgrext*, a PostgreSQL extension that manages other PostgreSQL extensions and provides new APIs to PostgreSQL extension developers that enables them to write new extensions with fewer lines of code.
 - *Integration with PostgreSQL Ecosystem*. Integrated pg_hint_plan with the extension manager. Implemented output rewriter in the extension manager, and based on that, a demo extension pg_poop that rewrites all text to poop emojis.
]

== Skills

- *Programming Languages*: Rust (6 years), C++, Python, Node.js and Golang
- *Tech Skills*: Stream-Processing Systems, Database Systems (Optimizer and Query Execution), Key-Value Storage Systems, SSD-optimized File System

#align(right, text(fill: gray)[Last Updated on #today()])
