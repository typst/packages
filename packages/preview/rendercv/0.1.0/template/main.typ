#import "@preview/rendercv:0.1.0": *

#show: rendercv.with(
  name: "John Doe",
)

= John Doe

#headline([Engineer])

#connections(
  [San Francisco, CA],
  [#link("mailto:john.doe@email.com", icon: false, if-underline: false, if-color: false)[john.doe\@email.com]],
  [#link("https://rendercv.com/", icon: false, if-underline: false, if-color: false)[rendercv.com]],
  [#link("https://github.com/rendercv", icon: false, if-underline: false, if-color: false)[github.com\/rendercv]],
)

== Education

#education-entry(
  [
    #strong[Princeton University], PhD in Computer Science -- Princeton, NJ

  ],
  [
    Sept 2018 – May 2023

  ],
  main-column-second-row: [
    - Thesis: Efficient Neural Architecture Search for Resource-Constrained Deployment

    - Advisor: Prof. Sanjeev Arora

    - NSF Graduate Research Fellowship, Siebel Scholar (Class of 2022)

  ],
)

== Experience

#regular-entry(
  [
    #strong[Co-Founder & CTO], Nexus AI -- San Francisco, CA

  ],
  [
    June 2023 – present

  ],
  main-column-second-row: [
    - Built foundation model infrastructure serving 2M+ monthly API requests with 99.97\% uptime

    - Raised \$18M Series A led by Sequoia Capital, with participation from a16z and Founders Fund

    - Scaled engineering team from 3 to 28 across ML research, platform, and applied AI divisions

    - Developed proprietary inference optimization reducing latency by 73\% compared to baseline

  ],
)

== Skills

*Programming:* Python, TypeScript, Rust, C++, SQL, NoSQL
