/* Resume in Typst
Author: Mariano Mollo
Project: https://github.com/visika/yuan-resume
Based on: https://github.com/Xyz-yuanhf/yuan-resume
*/

#import "@preview/yuan-resume:0.1.0": *

#set page(margin: (top: 1.2cm, bottom: 2.6cm, left: 1.8cm, right: 2.3cm))
#set text(font: "Sabon LT Std", 10pt)

#grid(
  columns: (3fr, 1fr),
  align: (left + bottom, right + bottom),
  smallcaps[
    #text(font: "Calluna", size: 30pt)[Name and Surname]
    #h(1em)
    #text(font: "Calluna", size: 14.5pt)[Ph.D.]
  ],
  [
    (+00) 111-2222-3333 \
    email\@example.com \
    https://www.example.com
  ],
)

#line(length: 100%, stroke: 0.4pt)

#section-block(
  [Education],
  [
    #edu-heading(
      department: [Department of Automation, Tsinghua University],
      location: [Beijing, China],
      role: [Ph.D. in Control Science and Engineering],
      time: [2022 - 2028 #text(9pt, style: "italic")[(expected)]],
    )
    - Advisor: Prof. Xiao Yuan
    - Research area: Operations Research and Machine Learning

    #edu-heading(
      department: [Department of Precision Instrument, Tsinghua University],
      location: [Beijing, China],
      role: [B.E. in Measurement and Control Technology and Instrument],
      time: [2018 - 2022],
    )
    - GPA: 0.00/4.00, Rank: 64/64.
  ],
)

#section-block(
  [Publications],
  [
    #set par(justify: true)
    #set enum(spacing: 12pt)
    + *Xiao Yuan*, Hua Li.
      The Future Urban Transportation Systems: Innovations and Challenges.
      _Journal of Operations Research and Optimization_, 2024.
    + Hua Li, *Xiao Yuan*, John Doe.
      Optimizing Logistics and Supply Chain Networks Using Machine Learning Techniques.
      _International Conference on Operations Research and Machine Learning_, 2023.
    + John Doe, *Xiao Yuan*, Hua Li.
      Artificial Intelligence in Healthcare: Transforming Diagnostics and Treatment.
      _International Conference on HealthTech Innovations_, 2023.
  ],
)

#section-block(
  [Projects],
  [
    #proj-heading(
      title: [Advanced Optimization Techniques for Smart Grid Management],
      institution: [National Natural Science Foundation of China (NSFC)],
      time: [2023.01 - 2024.01],
    )
    #proj-heading(
      title: [Optimizing Urban Traffic Flow Using AI-Based Predictive Models],
      institution: [Smart Transportation Innovations Grant],
      time: [2021.12 - 2022.12],
    )
  ],
)

#section-block(
  [Internships],
  [
    #intern-heading(
      company: [ABC Tech Ltd.],
      location: [Shanghai, China],
      time: [2024.01 - 2024.06],
    )
    - Develop engaging content for social media platforms.
    - Prepare reports and presentations summarizing research findings.

    #intern-heading(
      company: [XYZ Tech Inc.],
      location: [Shanghai, China],
      time: [2023.07 - 2023.12],
    )
    - Develop engaging content for social media platforms.
    - Prepare reports and presentations summarizing research findings.
  ],
)

#section-block(
  [Awards and Honors],
  [
    #set par(spacing: 8pt)
    #award(
      title: [*First Prize*, International Data Science Challenge],
      time: [2023.11],
    )
    #award(
      title: [*Best Innovation Award*, Tech Startup Pitch Competition],
      time: [2023.05],
    )
    #award(
      title: [*Excellence in Research Award*, Annual Research Symposium],
      time: [2022.12],
    )
    #award(
      title: [*Academic Scholarship*, Tsinghua University],
      time: [2022.09],
    )
  ],
)

#section-block(
  [Skills],
  [
    #set terms(separator: [: ])
    / Languages: Chinese, English, French
    / Programming: Python, C++, MATLAB
  ],
)

#section-block(
  [Academinc Services],
  [
    #set par(justify: true)
    / Reviewers for: _Journal of Operations Research and Optimization_
    / #hide[Reviewers for]: _International Conference on Optimization and Machine Learning_
    / #hide[Reviewers for]: ...
  ],
)
