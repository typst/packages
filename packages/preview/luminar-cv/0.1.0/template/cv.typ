#import "@preview/luminar-cv:0.1.0": *

#show: cv.with(
  name: [John Doe],
  positions: (
    [MSc Aerospace Engineering],
    [Research Assistant],
    [AIAA Student Member],
  ),
  contact: (
    phone: "+41 79 123 45 67",
    email: "john.doe@unihelios.ch",
    website: "johndoe.dev",
    linkedin: "johndoe",
    github: "johndoe",
    location: "Bern, CH",
  ),
  bio: [Aerospace Engineering graduate student at University of Helios, passionate about computational fluid dynamics and sustainable aviation.],
  page-numbering: true,
  skill-highlight-color: rgb("#135b8f"),
  link-color: rgb("#135b8f"),
)

#section(title: [Education])[
  #entry(
    title: [University of Helios — MSc Aerospace Engineering],
    subtitle: [Focus: Computational Fluid Dynamics · GPA 5.8 / 6.0],
    date: [2023 -- present],
  )[]

  #entry(
    title: [Polytechnic Institute of Varda — BSc Mechanical Engineering],
    subtitle: [Focus: Thermodynamics and Fluid Mechanics · GPA 1.2 (German grading system)],
    date: [2019 -- 2023],
  )[
    Thesis: _Numerical Simulation of Turbulent Flow over a NACA 0012 Airfoil_
  ]

  #entry(
    title: [Gymnasium Solaris — Abitur],
    date: [2019],
  )[
    Final grade: 1.0 · Valedictorian · Awarded distinction in Mathematics and Physics
  ]
]

#section(title: [Experience])[
  #entry(
    title: [University of Helios — Research Assistant],
    subtitle: [Institute of Fluid Dynamics],
    date: [2024 -- present],
  )[
    Supporting research on high-speed compressible flows in rotating detonation engines. Developing CFD simulation pipelines in Python and OpenFOAM. Assisting with experimental test campaigns and data analysis.
  ]

  #entry(
    title: [Aerovaunt AG — Engineering Intern],
    subtitle: [Aerodynamics Department, Bern],
    date: [Summer 2022],
  )[
    Contributed to aerodynamic shape optimisation workflows using simulation tools and MATLAB. Automated post-processing of simulation results, reducing analysis time by 40%.
  ]

  #entry(
    title: [Polytechnic Institute of Varda — Teaching Assistant],
    subtitle: [Thermodynamics I and II],
    date: [2021 -- 2023],
  )[
    Guided undergraduate students through course material and weekly exercise sessions for two consecutive semesters.
  ]
]

#section(title: [Projects])[
  #entry(
    title: [Autonomous UAV for Search and Rescue],
    subtitle: [Student project — Python, ROS2, Fusion 360],
    date: [2023],
  )[
    Designed and built a fixed-wing UAV capable of autonomous waypoint navigation. Implemented a custom flight controller in Python using sensor fusion and PID control. Achieved 45-minute endurance in field tests. #body-link("https://github.com/johndoe/sar-uav")[github.com/johndoe/sar-uav]
  ]

  #entry(
    title: [CFD Surrogate Model for Airfoil Optimisation],
    subtitle: [Research project — PyTorch, OpenFOAM],
    date: [2024],
  )[
    Trained a neural network surrogate model to predict lift and drag coefficients from airfoil geometry parameters, achieving 98% accuracy at 1000$times$ speedup over full CFD simulations.
  ]
]

#section(title: [Awards & Scholarships])[
  #entry(
    title: [Helix Foundation Scholarship],
    subtitle: [Awarded to the top 1% of engineering students nationwide],
    date: [2023 -- present],
  )[]

  #entry(
    title: [Varda Student Paper Competition — 1st place],
    subtitle: [Polytechnic Institute of Varda Annual Research Awards],
    date: [2023],
  )[]

  #entry(
    title: [Solaris Physics Prize],
    subtitle: [Awarded by Gymnasium Solaris for outstanding performance in Physics],
    date: [2019],
  )[]
]

#pagebreak()

#section(title: [Publications])[
  #publication(
    title: [Surrogate Modeling for Transonic Airfoil Optimisation Using Deep Neural Networks],
    authors: [J. Doe, M. Mustermann, A. Smith],
    journal: [Journal of Computational Aerodynamics],
    year: [2024],
    doi: "10.0000/example",
    note: [peer-reviewed],
  )

  #publication(
    title: [Numerical Investigation of Turbulent Boundary Layer Separation on Swept Wings],
    authors: [J. Doe, M. Mustermann],
    journal: [International Journal of Fluid Engineering],
    year: [2023],
    note: [under review],
  )
]

#section(title: [Skills])[
  #skill([Python], highlight: true)
  #skill([C++], highlight: true)
  #skill([OpenFOAM], highlight: true)
  #skill([Ansys Fluent], highlight: true)
  #skill([PyTorch])
  #skill([MATLAB])
  #skill([ROS2])
  #skill([Fusion 360])
  #skill([Siemens NX])
  #skill([LaTeX])
  #skill([Typst])
  #skill([Git])
]

#section(title: [Languages])[
  #languages((
    (name: [English], level: [native]),
    (name: [German], level: [C2]),
    (name: [Spanish], level: [B2]),
    (name: [French], level: [A2]),
  ))
]

#align(right)[
  #text(size: 9pt, fill: luma(100))[
    _Bern, #datetime.today().display("[month repr:long] [year]")_
  ]
]