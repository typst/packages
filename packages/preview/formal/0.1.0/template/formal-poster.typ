#import "@preview/formal:0.1.0": formal-poster
#import "@preview/physica:0.9.5": *

#show: formal-poster.with(
  lang: "en",
  title: [
    On the Electrodynamics of Moving Bodies \
    and the General Theory of Relativity
  ],
  authors: [Albert Einstein],
  department: [Institute for Advanced Study, Princeton University],
  footer: [
    Work performed in collaboration with colleagues at Princeton University and
    the Kaiser Wilhelm Institute for Physics, Berlin.
  ],
  right-column: { include "formal-poster-diagrams.typ" },
  conference: "International Congress of Physics 1955",
  dates: "July 15-20, 1955, Princeton, New Jersey",
  contacts: [email: `einstein@ias.edu`],
)

= Introduction

== Historical Context
The nature of space, time, and gravity has puzzled physicists since Newton's era. Classical mechanics and electromagnetism appeared fundamentally incompatible, with Maxwell's equations suggesting light propagation at a fixed speed while Newtonian mechanics allowed arbitrary relative velocities, requiring a revolutionary revision of our understanding of the physical universe.

== Special Relativity
Special relativity, developed in 1905, established that space and time are unified into a four-dimensional spacetime continuum, with the speed of light $c$ as a universal constant defining the causal structure of the universe. This revolutionized our understanding of simultaneity, length contraction, and time dilation, fundamentally altering concepts of absolute space and time.

#align(center, [$ E = m dot c^2 $])

== General Relativity
General relativity extends these concepts to incorporate gravity as the curvature of spacetime itself, rather than a force acting through space. This geometric interpretation provides a unified description of gravitational phenomena, explaining both planetary motion and the behavior of light in gravitational fields.

- Experimental verification of relativistic predictions was crucial for the scientific acceptance of the theory
- The famous 1919 solar eclipse expedition led by Arthur Eddington confirmed gravitational light bending
- This provided the first direct observational evidence for general relativity

= Mathematical Framework

- The spacetime interval in special relativity remains invariant under Lorentz transformations, preserving the fundamental causal structure of spacetime across all inertial reference frames:
  $ s^2 = c^2 dot t^2 - x^2 - y^2 - z^2 $

- Lorentz transformations mathematically connect inertial reference frames moving with relative velocity $v$, ensuring the universal constancy of light speed and preserving the form of physical laws:
  $
    t' & = gamma dot (t - v dot x / c^2), quad
         x' & = gamma dot (x - v dot t), quad
              y' & = y, quad
                   z' & = z
  $
  where $gamma = 1 / sqrt(1 - v^2 / c^2)$ is the Lorentz factor, approaching infinity as $v$ approaches $c$.

- General relativity is formulated using the sophisticated mathematics of Riemannian geometry, with the Einstein field equations providing a direct relationship between spacetime curvature and energy-momentum content:

  $ G_(mu nu) + Lambda g_(mu nu) = (8 dot pi dot G) / c^4 T_(mu nu) $

  where $G_(mu nu)$ is the Einstein tensor, $Lambda$ is the cosmological constant, and $T_(mu nu)$ is the stress-energy tensor.

- The metric tensor $g_(mu nu)$ completely describes the local geometry of spacetime, determining proper time intervals, spatial distances, and the geodesic paths followed by freely falling particles and light rays.

- In the weak field limit, general relativity reduces to Newtonian gravity with small relativistic corrections that successfully explain previously mysterious phenomena such as Mercury's perihelion precession of 43 arcseconds per century.

- The photoelectric effect demonstrates the quantum nature of electromagnetic radiation, with individual photon energies determined by Planck's fundamental relation:
  $ E = h dot nu $
  where $h = 6.626 times 10^(-34)$ J⋅s is Planck's constant and $nu$ is the frequency of the electromagnetic radiation.

= Results and Implications

- Derived the profound equivalence of mass and energy, fundamentally transforming our understanding of matter and energy conservation in all physical processes, with applications ranging from nuclear physics to stellar evolution.

- Successfully predicted gravitational time dilation, gravitational redshift, and gravitational lensing effects---all subsequently confirmed through precise astronomical observations and laboratory experiments using atomic clocks.

#{
  import "@preview/rustycure:0.1.0": qr-code

  set align(center)

  v(1fr)
  grid(
    // Non-equal columns for better visual balance
    columns: (1.3fr, 1fr),
    align: (right + horizon, left + horizon),
    column-gutter: 1em,
    qr-code(width: 4cm, "https://www.ias.edu"), [Institute for \ Advanced Study \ Princeton, NJ],
  )
  v(1fr)
}
