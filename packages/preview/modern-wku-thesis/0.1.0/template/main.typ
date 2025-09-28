// WKU Thesis Template
#import "@preview/modern-wku-thesis:0.1.0": graduate-thesis

#show: graduate-thesis.with(
  title: [Your Thesis Title Goes Here],
  author: "Your Name",
  degree: [MS of Computer Information Systems],
  department: [Department of Computer Science and Technology],
  university: [Wenzhou-Kean University],
  supervisor: [Your Supervisor],
  month: [December],
  year: [2025],
  degree-year: [2025],
  program-type: [Master of Science],
  abstract: [
    Classical Traceability Management Systems (TMS) help track links between software parts like requirements, designs, Code, and test cases. They help keep projects organized and meet quality goals. But they have issues. Pulling out data takes too long. Searching is hard. The results are greasy and not easy to understand. These problems slow teams down and make fast decisions, especially for agile teams.

    This study proposes an improved Traceability Management System (TMS) for software engineering processes. The system retrieves data in real-time and presents it through dynamically updating charts. It is designed to operate with greater speed and simplicity, thereby enhancing team coordination and progress monitoring.
    
    Utilizing regular expressions, the system efficiently extracts critical information from intricate software datasets. This extracted data is subsequently transformed into comprehensible visual representations.
  ],
  keywords: [Traceability; Automatic; Regular Expression; Visualization; TMS.],
  acknowledgments: [
    I would like to express my sincere gratitude to my supervisor, Dr. Your Supervisor, for his invaluable guidance, patience, and support throughout this research. His expertise and insights have been instrumental in shaping this work.
    
    I am also grateful to the faculty and staff of the Department of Computer Science and Technology at Wenzhou-Kean University for providing an excellent academic environment and resources that made this research possible.
    
    Special thanks to my family and friends for their unwavering support and encouragement during this journey. Their belief in me has been a constant source of motivation.
    
    Finally, I acknowledge all the researchers and authors whose work has contributed to the foundation of this study. Their contributions to the field of software engineering and traceability management have been invaluable.
  ],
  bibliography: bibliography("refs.bib"),
  acronyms: (
    "TMS": "Traceability Management System",
    "RE": "Regular Expression",
    "CSV": "Comma-Separated Values",
    "JSON": "JavaScript Object Notation",
    "XML": "eXtensible Markup Language",
    "HTML": "HyperText Markup Language",
    "CSS": "Cascading Style Sheets",
    "JS": "JavaScript",
    "SQL": "Structured Query Language",
    "DB": "Database",
    "UI": "User Interface",
    "UX": "User Experience",
    "API": "Application Programming Interface",
    "HTTP": "Hypertext Transfer Protocol",
    "HTTPS": "Hypertext Transfer Protocol Secure",
    "TCP": "Transmission Control Protocol",
    "IP": "Internet Protocol",
    "DNS": "Domain Name System",
    "SMTP": "Simple Mail Transfer Protocol",
    "POP3": "Post Office Protocol version 3",
    "IMAP": "Internet Message Access Protocol",
  ),
)
// THE CONTENT GOES HERE
= Introduction

#lorem(20)

using References @brown2022algorithms, @anderson2023blockchain, try add figure and use it @fig:1

#figure(
  image("pic.png"),
  caption: [Example Figure],
)<fig:1>

#lorem(100)

#lorem(150)
== Second heading
=== Third heading
==== Fourth heading
= Background
#lorem(2000)
