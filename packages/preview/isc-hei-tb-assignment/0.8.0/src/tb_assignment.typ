//        ___ ____   ____      _   _ _____ ___
//       |_ _/ ___| / ___|    | | | | ____|_ _|     Informatique et
//        | |\___ \| |   ___  | |_| |  _|  | |       systèmes de communication
//        | | ___) | |__|___| |  _  | |___ | |       HEI Sion · HES-SO Valais / mui 24-26
//       |___|____/ \____|    |_| |_|_____|___|
//
//   52 65 61 64 69 6e 67 20 68 65 78 20 66 6f 72 20 66 75 6e 3f 20 49 53 43 20 66 6f 72 65 76 65 72
// 

#import "@preview/isc-hei-tb-assignment:0.8.0" : *

#let language = "fr" // Document language (fr/en/de), choose to your liking
#let tb-student = "Barbara Liskov" // Student's name
#let tb-id = "ISC-ID-26-1" // TB identifier, please ask the secretariat for the proper number (format: ISC-ID-XX-Y, where XX last two digits of the academic year, and Y is a sequential number)
#let tb-supervisor = "Prof. Dr L. Lettry" // Responsible supervisor (HES-SO side)
#let tb-co-supervisor = none // Co-superviseur·e (none = tiret) — local projects only
#let tb-study-program = "ISC" // Do not change
#let tb-academic-year = "2025-26" // Update accordingly

// Bachelor thesis carried out abroad (e.g. through the MOVE exchange programme).
// When true: tb-supervisor is shown as the "HES-SO supervisor", the expert field is
// dropped, and the co-supervisor is replaced by the two host fields below.
#let tb-abroad = true
#let tb-host-supervisor = none // (abroad only) Supervisor at the host institution
#let tb-host-mentor = none     // (abroad only, optional) First-line mentor at the host institution

// Expert·e, with address and email address (use \ for new lines) — local projects only
#let tb-expert = [
  Dr John Carmack \
  Rue de la Paix 24 \
  CH - 1211 Genève \
  #link("mailto:john.carmack@example.com")
]

// Mandator and location of where the work will be done (either hes(), industry("Acme Corp"), school("EPFL"))
#let tb-mandator = hes()
#let tb-location = school("EPFL")
#let tb-confidential = false
#let tb-title = [Software co-design for embedded systems] // Must be concise and descriptive, use subtitle if you need more space
#let tb-subtitle = [An exploration of the intersection between science and engineering]  // Optional, use none if not needed

#let tb-description = [
  In this work, we propose a novel approach for designing embedded systems that integrates hardware and software components. The approach is based on a co-design methodology that allows for the simultaneous development of hardware and software components, leading to improved performance and reduced development time.

  We evaluate our approach through a *case study* on the design of an embedded system for a smart home application, demonstrating its effectiveness in terms of performance, energy efficiency, and ease of development.
]

#let tb-objectives = [
  + Analyser l'état de l'art dans la thématique
  + Proposer une approche de co-design pour les systèmes embarqués:
    - En coordination avec les travaux de recherche
    - Dans le contexte de la filière ISC
  + Évaluer l'approche à travers une étude de cas sur un système de maison intelligente.
  + Comparer les résultats avec des approches traditionnelles de développement de systèmes embarqués
]

// Document information
#let doc-version = "1.30"
#let doc-date = datetime.today() // or datetime(year: 2026, month: 3, day: 8)

#let date-attribution = datetime(year: 2026, month: 3, day: 3)
#let date-start = datetime(year: 2026, month: 5, day: 11)
#let date-submission = datetime(year: 2026, month: 7, day: 24)
#let date-defense = [Semaines du 17 et 25 août 2026]
#let date-exhibition-hei = datetime(year: 2026, month: 8, day: 28)
#let date-exhibition-monthey = datetime(year: 2026, month: 8, day: 31)

/**********************************
 * Information for the second page (which won't be included in the public document)
 **********************************/

// Project type: project-types.exploratory | project-types.implementation
#let tb-project-type = project-types.exploratory

// Data dependency (1–5) — must be explained if ≥ 3
#let tb-data-dep = 1
#let tb-data-explanation = none

// Hardware dependencies (1–3)
//   explanation required if ≥ 2
//   cost and acquisition procedure required if = 3
#let tb-material-dep = 3
#let tb-material-explanation = "Un oscilloscope et une carte FPGA"
#let tb-material-cost = "CHF 250.-" // ex. "CHF 500.–" (required if dep = 3)
#let tb-material-procedure = "Achat online chez XXX, en stock normalement. Si pas disponible, utilisation d'un autre fournisseur (ces composants sont bien sourcés et nous n'anticipons pas de problèmes de livraison). 
 
En cas d'indisponibilité, nous utiliserons un ancien modèle que nous avons déjà." // HW acquisition procedure (required if dep = 3)

// Extra information (none = empty section)
#let tb-extra-info = []

/****
 * DO NOT EDIT BELOW THIS LINE
 * (unless you know what you are doing)
 ****/
#show: project.with(
  doc-type: "tb-assignment",
  language: language,
  authors: tb-student,
  date: doc-date,
)

#tb-assignment-page(
  student: tb-student,
  id: tb-id,
  supervisor: tb-supervisor,
  co-supervisor: tb-co-supervisor,
  expert: tb-expert,
  abroad: tb-abroad,
  host-supervisor: tb-host-supervisor,
  host-mentor: tb-host-mentor,
  study-program: tb-study-program,
  academic-year: tb-academic-year,
  mandator: tb-mandator,
  site: tb-location,
  confidential: tb-confidential,
  title: tb-title,
  subtitle: tb-subtitle,
  description: tb-description,
  objectives-content: tb-objectives,
  date-attribution: date-attribution,
  date-start: date-start,
  date-submission: date-submission,
  date-defense: date-defense,
  date-exhibition-hei: date-exhibition-hei,
  date-exhibition-monthey: date-exhibition-monthey,
  project-type: tb-project-type,
  data-dep: tb-data-dep,
  data-explanation: tb-data-explanation,
  material-dep: tb-material-dep,
  material-explanation: tb-material-explanation,
  material-cost: tb-material-cost,
  material-procedure: tb-material-procedure,
  extra-info: tb-extra-info,
  doc-version: doc-version,
  language: language,
)
