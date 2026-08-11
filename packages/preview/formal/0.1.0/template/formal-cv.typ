#import "@preview/formal:0.1.0": cv-item, formal-cv, keyword-grid, label, small, summary

#show: formal-cv.with(
  name: [Albert Einstein],
  prefix: [Dr.],
  title: [Theoretical Physicist. Nobel Laureate],
  location: [Princeton, New Jersey, USA],
  contacts: (
    label(
      "noreply@einstein.com",
      dest: "mailto:noreply@einstein.com",
      icon-name: "envelope",
    ),
    label("+1-999-XXX-YYYY", dest: "tel:+1-999-XXX-YYYY", icon-name: "phone"),
  ),
  links: (
    label("Web", dest: "https://einstein.com", icon-name: "globe"),
    link("https://en.wikipedia.org/wiki/Albert_Einstein", "wikipedia.org"),
    link("https://www.nobelprize.org/prizes/physics/1921/einstein", "nobelprize.org"),
  ),
)

#summary[
  Theoretical physicist with revolutionary contributions to modern physics spanning over 5 decades. Developed the theory of relativity, explained the photoelectric effect, and made fundamental contributions to quantum mechanics and statistical mechanics. Nobel Prize laureate and Fellow of the Royal Society. Dedicated advocate for civil rights, pacifism, and scientific internationalism.
]

== Expertise

#keyword-grid(
  n-rows: 5,
  column-gutter: 0.5em,
  Physics: (
    [Relativity],
    [Quantum Mechanics],
    [Statistical Mechanics],
    [Cosmology],
    [Field Theory],
  ),
  Math: (
    [Tensors],
    [Differential Geometry],
    [Complex Analysis],
    [Probability Theory],
    [Group Theory],
  ),
  Music: (
    [Violin],
    [Piano],
    [Chamber Music],
    [Classical Music],
  ),
  Other: (
    [Scientific Method],
    [Determinism],
    [Causality],
    [Pacifism],
    [Civil Rights],
  ),
)

= Experience

- #cv-item(
    title: [Professor],
    organization: [Institute for Advanced Study],
    organization-comment: [School of Mathematics],
    dates: [Oct '33 -- Apr '55],
    location: [Princeton, NJ],
  )
  - Developed unified field theory attempting to unify electromagnetic and gravitational forces, laying groundwork for modern theories of everything.
  - Continued work on quantum mechanics foundations, famously challenging quantum theory with the EPR paradox and "God does not play dice" philosophy.
  - Collaborated with colleagues on cosmological models and contributed to understanding of gravitational phenomena.

- #cv-item(
    title: [Professor of Theoretical Physics],
    organization: [Princeton University],
    dates: [Oct '33 -- Oct '33],
    location: [Princeton, NJ],
  )
  - Brief appointment before joining Institute for Advanced Study.

- #cv-item(
    title: [Professor],
    organization: [Kaiser Wilhelm Institute],
    organization-comment: [Director of Physics],
    dates: [Apr '14 -- Dec '32],
    location: [Berlin, Germany],
  )
  - Formulated general theory of relativity (1915), revolutionizing understanding of gravity, space, and time.
  - Derived field equations describing curvature of spacetime, predicting phenomena later confirmed: gravitational lensing, Mercury's perihelion precession, gravitational redshift.
  - Received Nobel Prize in Physics (1921) for explanation of photoelectric effect and contributions to theoretical physics.
  - Made contributions to quantum theory including photon concept, wave-particle duality, and Bose-Einstein statistics.
  - Developed cosmological models with cosmological constant, laying foundation for modern Big Bang theory.

- #cv-item(
    title: [Professor of Theoretical Physics],
    organization: [ETH Zurich],
    dates: [Oct '12 -- Apr '14],
    location: [Zurich, Switzerland],
  )
  - Continued development of general relativity theory while teaching advanced physics courses.
  - Conducted research on specific heats of solids and developed Einstein model for lattice vibrations.
  - Established international reputation leading to invitation to join Prussian Academy of Sciences in Berlin.

- #cv-item(
    title: [Associate Professor],
    organization: [University of Prague],
    dates: [Apr '11 -- Oct '12],
    location: [Prague, Austria-Hungary],
  )
  - Further developed special relativity applications and began formulating general relativity principles.
  - Conducted research on statistical mechanics and thermodynamics of radiation.

- #cv-item(
    title: [Assistant Professor],
    organization: [University of Zurich],
    dates: [May '09 -- Apr '11],
    location: [Zurich, Switzerland],
  )
  - First academic appointment while continuing work at Swiss Patent Office.
  - Published papers on quantum theory of radiation and specific heats.

= Education

- #cv-item(
    title: [Physics],
    title-comment: [PhD],
    organization: [University of Zurich],
    dates: [Jan '06],
  )
  #small[_Dissertation_: A New Determination of Molecular Dimensions]

- #cv-item(
    title: [Mathematics and Physics],
    title-comment: [Diploma],
    organization: [Swiss Federal Polytechnic],
    organization-comment: [ETH Zurich],
    dates: [Jul '00],
  )
  #small[_Thesis_: Consequences of Capillarity Phenomena]
