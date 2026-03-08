#import "@preview/cv-soft-and-hard:0.1.0": styling, section, entry, subsection, rust, cpp, python, typst-logo, hugo, typescript

#set document(author: "Jonas Pleyer", title: "CV Jonas Pleyer")
#show: styling

#align(center)[
  = Jonas Pleyer - Curriculum Vitae\
  Stefan-Meier Str. 30, 79104 Freiburg\
  #link("https://jonas.pleyer.org", "jonas.pleyer.org") |
  #link("https://www.github.com/jonaspleyer", "github.com/jonaspleyer") |
  #link("mailto:jonas.dev@pleyer.org", "jonas.dev@pleyer.org") |
  #link("tel:+491785430064", "+49 178 5430064")
]

#section("Profile")
Software engineer and computational scientist with expertise in Rust and Python.
I build high-quality software for scientific computing and contribute actively to the Rust
open-source ecosystem.
I enjoy working in teams that emphasize functionality and reliability and use excellent tooling.

//Experience
#section("Experience")
#entry(
  [
    *Doctoral Candidate* (_University of Freiburg_)
    - Study of cellular systems via computational models
    - Developed and maintained agent-based simulation framework `cellular_raza`
    - Contributed to Open Source projects
    - Published peer-reviewed software and scientific papers and reviewed papers
  ],
  [_since 08/2021_]
)

#entry(
  [
    *Research Asistant - Tutor* (_University of Freiburg_)
    - Weekly tutorials in Physics, Mathematics and Systems Biology, exams, lectures
    // - Weekly Tutorials: Elementary Geometry, Analysis I - III, Introduction to\
    //   Systems Biology, Experimental Physics I, Theoretical Physics III, Higher Math II
    // - Prepared and graded mandatory work sheets and exams, lecture substitute
  ],
  [_since 04/2020_]
)

#entry(
  [
    *Supervisor iGEM* (_CIBBS, Freiburg_)
    - Mentored students in scientific modeling, website and science communication
  ],
  [_05/2023 - 09/2024_],
)

#entry(
  [
    *Research Assistant* (_Fraunhofer Institute ISE, Freiburg_)
    - Uncertainty estimation for heat pumps, eco-label validation and assignment
  ],
  [_02/2020 - 04/2021_],
)

#entry(
  [
    *Internship* (_SAP, Walldorf_)
    - Natural Language Processing, Data Analysis
  ],
  [_08/2017 - 10/2017_],
)

#section("Education")
#entry(
  [
    *University of Freiburg*\
    Doctoral Candidate (Computational Systems Biology)\
    // #text([Thesis: "_Agent-based Models in Cellular Systems_" (Christian Fleck)], size: 9pt)\
    MSc. Physics (Theoretical Physics & Mathematics),\
    #text([Thesis: "_Zero Values of the TOV Equation_" (Prof. Nadine Große)], size: 9pt)
  ],
  [\
    _since 08/2021\ \
    04/2020-07/2021_
  ],
)
#entry(
  [
    *Heidelberg University*\
    MSc. Physics\
    Bsc. Physics\
    #text([Thesis: "_About Topological Tunneling Configurations, the Anharmonic Oscillator\
    and the Functional Renormalization Group_" (Prof. Jan Pawlowski)], size: 9pt)
  ],
  [\
    _04/2018-04/2020\
    09/2013-03/2018_
  ],
)
#entry(
  [*Ottheinrich-Gymnasium, Wiesloch* (High School)],
  [_09/2005-06/2013_]
)

#section("Skills", note: "In descending order of skill level")
#table(
  align: left,
  columns: (auto, 1fr),
  stroke: none,
  row-gutter: 0pt,
  column-gutter: 5pt,
  inset: (left: 0pt, top: 2pt),
  text("Programming Languages", weight: 600),
  [Rust, Python, C++, C, Javascript, Bash],
  text("Development Tools", weight: 600),
  [Git, GitHub Actions, Linux, Make, CMake, GitLab CI/CD],
  text("Documentation & Publishing", weight: 600),
  [Hugo, Typst, LaTeX, Sphinx, HTML, CSS],
)

#pagebreak()

#section("Selected Projects", note: "In descending order of project size")
#entry(
  [
    *#link("https://cellular-raza.com", `cellular_raza`)* -
    _Agent-based Simulation Framework_ #rust #python #hugo\
    - Written with generics and custom templates for performance and flexibility
    - Dedicated documentation, examples & guides
      (#link("https://cellular-raza.com", "cellular-raza.com"))
    - Peer-reviewed and published @Pleyer2025
  ],
  [_08/2022_]
)

#entry(
  [
    *#link("https://github.com/jonaspleyer/cr_mech_coli", `cr_mech_coli`)* -
    _Modeling of Rod-shaped Bacteria_ #rust #python\
    - Uses
      #link("https://cellular-raza.com", "cellular_raza")
      #link("https://docs.rs/ndarray/latest/ndarray/", "ndarray")
      #link("https://docs.rs/nalgebra/latest/nalgebra/", "nalgebra") in Rust backend,
      #link("https://numpy.org/", "numpy"),
      #link("https://scipy.org/", "scipy"),
      #link("https://matplotlib.org/", "matplotlib"),
      #link("https://docs.pyvista.org/index.html", "pyvista") for analysis and visualization and
      #link("https://pyo3.rs", "pyo3") with #link("https://github.com/PyO3/maturin", "maturin")
      to generate Python bindings
  ],
  [_10/2024_],
)

#entry(
  [
    *#link("https://github.com/jonaspleyer/peace-of-posters", `peace-of-posters`)* -
    _Create Scientific Posters in Typst_ #typst-logo #hugo\
    - 81 stars, 9 contributors at
      #link(
        "https://github.com/jonaspleyer/peace-of-posters",
        "github.com/jonaspleyer/peace-of-posters"
      )
  ],
  [_10/2023_],
)

#entry(
  [
    *#link("https://github.com/jonaspleyer/approx-derive", `approx-derive`)* -
    _Derive macros for the approx crate_ #rust
    - $approx 1000$ weekly downloads at
      #link("https://crates.io/crates/approx-derive", "crates.io/crates/approx-derive")
  ],
  [
    _05/2024_
  ],
)

#entry(
  [
    *#link("https://github.com/jonaspleyer/crate2bib", `crate2bib`)* -
    _BibTeX Generator for Rust crates_ #rust #python\
    - Rust library, CLI tool, webapp
      (#link("https://jonaspleyer.github.io/crate2bib/", "jonaspleyer.github.io/crate2bib/"))
      & Python package
    - Uses `async` methods to query #link("https://crates.io", "crates.io") and
      #link("https://github.com/", "github.com"), #link("https://webassembly.org/", "Wasm") with
      #link("https://dioxuslabs.com", "dioxus") to create the webapp and
      #link("https://pyo3.rs", "pyo3") with #link("https://github.com/PyO3/maturin", "maturin") to
      create Python bindings.
  ],
  [_02/2025_]
)

#entry(
  [
    *#link("https://github.com/jonaspleyer/vtk-rs", `vtk-rs`)* -
    _Rust Bindings for VTK_ #rust #cpp\
    - Goal: Rust bindings for Visualization Toolkit (VTK) `C++` library (in early development)
    - Uses #link("https://cmake.org", `cmake`), #link("https://cxx.rs", `cxxbridge`) and
      #link("https://github.com/dgobbi/WrapVTK", `WrapVTK`) for automatic generation of bindings
  ],
  [_05/2025_],
)

#section("Publications", note: "In chronological order")
#[
  #set text(size: 10pt)
  #bibliography("citations.bib", title: none, style: "chicago-author-date.csl", full: true)
]

#pagebreak()

#section("Further Commitment")
#entry(
  [
    *Badminton*\
    Trainer license level B+C\
    FT Freiburg 1844 honorary Trainer of Children and Adults\
    TSG Wiesloch honorary Trainer of Children and Adults
  ],
  [
    \
    _2018/2019_\
    _since 01/2020_\
    _2016 - 2019_
  ],
)

#entry(
  [
    *KjG Wiesloch*\
    - Honorary member for two week camp in hometown
    - Approx. 90 Kids from age 6 to 17 and 30 volunteers
    - Camp director from 2020 to 2021.
  ],
  [
    _10/2011 - 01/2024_\
    // _11/2020 - 11/2021_
  ],
)

#entry(
  [
    *FIRST LEGO League (FLL)*\
    7th in Germany\
    3rd in Germany, 8th in Europe
  ],
  [
    _2008 - 2011_\
    _2011_\
    _2010_
  ],
)
