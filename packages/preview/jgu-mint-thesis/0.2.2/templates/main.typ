#import "@local/jgu-mint-thesis:0.2.2": *

#show: frontmatter.with(
  title: "Precision Measurements at MESA",
  abstract: [
    The Mainz Energy-recovering Superconducting Accelerator (MESA) is a novel
    electron accelerator currently under commissioning at Johannes Gutenberg
    University Mainz. Operating as an energy recovery linac (ERL), MESA delivers
    a continuous-wave electron beam of exceptional intensity and low emittance
    to three dedicated experiments: P2, MAGIX, and DarkMESA. This thesis
    presents measurements conducted at MESA and discusses their implications
    for precision tests of the Standard Model and searches for physics beyond it.
  ],
  author: "Jane Doe",
  examiners: ("Dear Advisor",),
  department: "Department of Physics",
  thesis-type: "dissertation",
  doctor-of: "Natural Sciences",
  major: "Physics",
  creative-commons: true,
  dedication: none,
  acknowledgements: none,
  list-of-figures: false,
  list-of-tables: false,
  abbreviations: none,
  statutory-declaration: none,
  language: "en",
)

= The MESA Accelerator

The Mainz Energy-recovering Superconducting Accelerator (MESA) is a compact
recirculating electron linac designed for high-intensity, low-emittance beams
@mesa-web @mesa-erl. It operates in two distinct modes tailored to the
requirements of its experimental program.

#figure(
  table(
    columns: 3,
    table.header([Parameter], [EB Mode], [ER Mode]),
    [Beam energy], [155 MeV], [105 MeV],
    [Beam current], [150 μA], [1–10 mA],
    [Operating temp.], [2 K], [2 K],
    [Energy gain / pass], [≤ 25 MeV], [≤ 25 MeV],
  ),
  caption: [Key beam parameters for external beam (EB) and energy recovery (ER) operation modes],
) <tab:beam-params>

== Superconducting RF Cavities

The accelerating structures consist of two cryomodules, each housing two
superconducting niobium cavities cooled to $T = 2$ K by liquid helium. At this
temperature niobium becomes superconducting, enabling high accelerating
gradients with minimal resistive losses. Each module spans approximately 4 m
in length. The quality factor of a superconducting cavity is

$
  Q_0 = omega_0 W / P_c,
$

where $omega_0$ is the resonant frequency, $W$ the stored energy, and $P_c$
the power dissipated in the cavity walls.

== Energy Recovery

In ER mode, spent electrons are decelerated back through the linac in opposite
phase, returning their kinetic energy to the RF field. The net power consumption
of the accelerator is thereby dramatically reduced. The energy recovery efficiency
is characterised by

$
  eta_"ER" = 1 - P_"dissipated" / P_"beam",
$

which approaches unity for high-current, low-loss operation. MESA is designed
to be the first facility to demonstrate multi-turn energy recovery in a
superconducting environment.

= Experimental Program

Three experiments exploit the MESA beam, each targeting complementary physics
goals @mesa-physics.

== P2

The P2 experiment measures the weak mixing angle $theta_W$ via parity-violating
electron scattering off protons at low momentum transfer. The target relative
precision of

$
  Delta sin^2 theta_W \/ sin^2 theta_W = 0.1%
$

surpasses existing low-energy determinations by more than one order of magnitude,
providing sensitivity to $Z'$ bosons and other BSM contributions.

== MAGIX

MAGIX is a multi-purpose magnetic spectrometer operated in ER mode, designed
for high-precision nuclear and hadron physics measurements at low momentum
transfer @magix-web. Its physics program includes:

#figure(
  table(
    columns: 2,
    table.header([Measurement], [Observable]),
    [Proton charge radius], [$r_p$],
    [Nuclear form factors], [$F(q^2)$],
    [Dark photon search], [$epsilon$, $m_(A')$],
  ),
  caption: [Selected measurements of the MAGIX physics program],
)

== DarkMESA

DarkMESA is a beam dump experiment situated downstream of P2. It searches for
light dark matter (LDM) particles produced in electromagnetic interactions of the
primary beam with a tungsten dump. The kinetic mixing parameter $epsilon$ and
dark matter mass $m_chi$ constitute the primary parameter space under investigation.

= Results

#lorem(40)

#figure(
  rect(width: 100%, height: 8em, fill: accent-color.lighten(80%)),
  caption: [Exclusion contours in the $(m_(A'), epsilon)$ plane derived from the MAGIX dataset],
)

#lorem(20)

#bibliography("refs.yml", style: "harvard-cite-them-right")

#show: appendix.with()

= Technical Parameters

The following table lists the full set of MESA accelerator parameters relevant to the experiments described in this thesis.

#figure(
  table(
    columns: 3,
    table.header([Component], [Specification], [Value]),
    [Injector energy], [kinetic], [5 MeV],
    [Cavity frequency], [SRF], [1.3 GHz],
    [Repetition structure], [CW], [—],
    [Normalised emittance], [rms], [≤ 1 mm·mrad],
    [Bunch charge], [EB/ER], [1 pC / 6.7 pC],
  ),
  caption: [MESA accelerator technical parameters],
)

= Statistical Analysis

The signal yield $S$ extracted from a counting experiment is related to the
observed event count $N$ and estimated background $B$ via

$
  S = N - B, quad sigma_S = sqrt(N + sigma_B^2).
$

Profile likelihood ratio tests are used throughout this analysis. The test
statistic

$
  q_mu = -2 ln lambda(mu), quad lambda(mu) = cal(L)(mu, hat(hat(theta))) / cal(L)(hat(mu), hat(theta))
$

is evaluated against the asymptotic $chi^2$ distribution to derive confidence
intervals on the parameter of interest $mu$.
