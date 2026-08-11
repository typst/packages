#import "@preview/isc-hei-tb-assignment:0.7.1" : *

#let language = "fr"
#let tb-student = "Barbara Liskov" // Student's name
#let tb-id = "ISC-ID-26-1" // TB identifier, given by the secretariat (format: ISC-ID-XX-Y, where XX last two digits of the academic year, and Y is a sequential number)
#let tb-supervisor = "Prof. Dr L. Lettry" // Responsible supervisor
#let tb-co-supervisor = none // Co-superviseur·e (none = tiret)
#let tb-study-program = "ISC"
#let tb-academic-year = "2025-26"

// Expert·e, with address and email address (use \ for new lines)
#let tb-expert = [
  Dr John Carmack \
  Rue de la Paix 24 \
  CH - 1211 Genève \
  john.carmack\@example.com
]

// Mandator and location of where the work will be done (either hes(), industry("Acme Corp"), school("EPFL"))
#let tb-mandator = hes()
#let tb-location = school("MOVE, Tokyo University")
#let tb-confidential = false
#let tb-title = [A hardware-software co-design approach for embedded systems]

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
#let doc-version = "1.21"
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

// Let's get started with the document!
#show: project.with(
  doc-type: "tb-assignment",
  language: language,
  title: "Donnée du travail de bachelor", // Bachelor thesis description in english
  authors: tb-student,
  date: doc-date, 
  revision: version,
  logo: none,
  fancy-line: false,
)

#tb-assignment-page(
  student: tb-student,
  id: tb-id,
  supervisor: tb-supervisor,
  co-supervisor: tb-co-supervisor,
  expert: tb-expert, 
  study-program: tb-study-program,
  academic-year: tb-academic-year,
  mandator: tb-mandator,
  site: tb-location,
  confidential: tb-confidential,
  title: tb-title,
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
