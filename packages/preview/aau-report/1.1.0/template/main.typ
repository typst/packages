#import "template.typ": *

// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  meta: (
    title: "Exploratory Analysis of Network Traffic Patterns in Heterogeneous Distributed Systems Utilizing Blockchain-Based Authentication Mechanisms",
    theme: "Decentralized Systems and Security",
    project_period: "Fall Semester 2023",
    project_group: "group 7",
    participants: (
      (name: "Kresten Laust", email: "participant1@student.aau.dk"),
      (name: "John Doe", email: "johndoe@example.com"),
      (name: "Jane Smith", email: "janesmith@example.com"),
      (name: "Alex Johnson", email: "alex.johnson@example.com"),
      (name: "Emily Brown", email: "emily.brown@example.com"),
      (name: "Michael Wang", email: "michael.wang@example.com"),
    ),
    supervisor: (
      (name: "Supervisor 1", email: "supervisor@studnet.aau.dk"),
    ),
    date: datetime.today().display()
  ),
  // Insert your abstract after the colon, wrapped in brackets.
  // Example: `abstract: [This is my abstract...]`
  abstract: [This study delves into the intricate dynamics of network traffic patterns within heterogeneous distributed systems, with a specialized focus on the transformative role of blockchain-based authentication mechanisms. In an era where distributed systems are becoming increasingly prevalent across various domains, understanding the nuanced interplay between authentication protocols and network performance metrics is imperative for ensuring robust security and optimal operational efficiency.

Through comprehensive exploratory analysis, this research endeavors to unravel the intricate relationships inherent in distributed systems architecture. By leveraging advanced analytical techniques, we aim to elucidate how different nodes within distributed networks interact, communicate, and authenticate transactions. Furthermore, our investigation seeks to uncover any discernible correlations between the adoption of blockchain-based authentication mechanisms and various aspects of network performance, including latency, throughput, and overall reliability.],
  department: "Computer Science",
)

// This is the primary file in the project.
// Commonly referred to as 'master' in LaTeX, and wokenly called 'main' in Typst.

#include "chapters/chapter1.typ"
#pagebreak(weak: true)

#include "chapters/chapter2.typ"
#pagebreak(weak: true)

#bibliography("sources/sources1.bib")
