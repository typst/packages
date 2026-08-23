#import "@local/ntnu-report-ethical-hacking:1.0.0"

// Task Report — Typst version
// Converted from Sample-Task-Report.docx

// -- Set your name and email here --
#let name = "<Name>"
#let email = "<Email>"


#set document(title: "Task Report", author: name)
#set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm))
#set text(font: "Liberation Sans", size: 14pt, lang: "en")
#set heading(numbering: "1.1")
#set par(justify: true)

// ---------- Title page ----------
#align(center)[
  #v(1cm)
  #text(size: 22pt, weight: "bold")[Task Report]

  #text(size: 14pt)[IIK-3100]

  #v(1cm)
  #align(horizon)[#image("media/ntnu_logo.png", width: 14cm)]
  #v(1cm)

  #align(bottom)[
  *Prepared On:*
  
  #datetime.today().display("[day padding:zero]-[month repr:short]-[year]")
  #v(1cm)
  *Prepared By:*
  
  #name\ #email
  ]

]

#pagebreak()

// ---------- Table of contents ----------

#set page(numbering: "i")
#counter(page).update(1)

#outline(title: "Contents", indent: auto)

#pagebreak()

// ---------- Content ----------

#set page(numbering: "1")
#counter(page).update(1)

= Introduction

= Tasks Summary

// Setting up table color parameters
#let completed = table.cell(
  fill: green.lighten(20%),
)[*Completed*]

#let partially_completed = table.cell(
  fill: orange.lighten(30%),
)[*Partially Completed*]


#let not_completed = table.cell(
  fill: red.lighten(10%),
)[*Not Completed*]


The following table highlights the tasks completed.

#align(center)[
  #table(
    columns: 4,
    align: center + horizon,
    stroke: 0.5pt,
    [*Total Challenges*], completed, partially_completed, not_completed,
    
    // -- Set the number of task --
    [*9*], [4], [3], [2],
  )
]

#v(0.5em)

#table(
  columns: (5.1%, 64%, 31%),
  align: (center + horizon, left, center + horizon),
  stroke: 0.5pt,
  fill: (x, y) =>
    if y == 0 { gray.lighten(50%) },
  
  [*S. No.*], [*Challenge*], [*Status*],
  
  // -- Describe your challenge here and completion. --
  [1.], [
    An IP address is given to identify and exploit potential vulnerabilities.

    The IP address is 10.10.8.2
  ], completed,
  [2.], [.................], partially_completed,
  [3.], [.................], completed,
  [3.], [.................], not_completed,
)

= Home Tasks

== Task Name/IP

*Description*

Vulnerable CMS was found to be running on the target server, the tester used a known vulnerability in the CMS and uploaded a shell to retrieve the content of secret.txt.

*Vulnerability Discovery*

The tester first performed an nmap scan which identified a web application running on the remote server as seen in the figure below:

\<Figure\>

Upon visiting the website vulnerable version of ICE HRM was discovered which is found to be vulnerable to remote file upload vulnerability as seen in the figure below:

\<Figure\>

*Vulnerability Exploitation*

The tester used the known exploit and uploaded a shell using the following link:

\<Figure/Link\>

In the request response uploaded file address is returned as seen in the figure below:

\<Figure\>

Upon visiting the link the shell was accessed as seen in the figure below:

\<Figure\>

From the uploaded shell the tester retrieved the content of secret.txt as seen in the figure below:

\<Figure\>

*Vulnerability Remediation (If asked in the challenge description)*

Following steps will mitigate this vulnerability:

+ Update to latest version of ICE HRM CMS.
+ Remove unnecessary files from the server.
+ Implement write protection on in website root directory.
