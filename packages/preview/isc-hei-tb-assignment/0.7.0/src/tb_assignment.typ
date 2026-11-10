// ════════════════════════════════════════════════════════════════════════════
// PARAMÈTRES — seule section à modifier
// Langue : "fr" | "en" | "de"  — change toutes les étiquettes du formulaire
// ════════════════════════════════════════════════════════════════════════════

#let language = "fr"
#let doc-version  = "1.1"
#let doc-date = datetime.today()  // ou datetime(year: 2026, month: 3, day: 8)

// ─── Identité ─────────────────────────────────────────────────────────────
#let tb-student        = "Barbara Liskov"       // Nom de l'étudiant·e
#let tb-id             = "ISC-ID-26-1"          // Identifiant du TB
#let tb-supervisor     = "Prof. Dr L. Lettry"   // Professeur·e responsable
#let tb-co-supervisor  = none                   // Co-superviseur·e (none = tiret)
#let tb-filiere        = "ISC"
#let tb-academic-year  = "2025-26"

// Expert·e (contenu libre, utiliser \ pour les sauts de ligne)
#let tb-expert = [
  Dr John Carmack \
  Rue de la Paix 24 \
  CH - 1211 Genève \
  john.carmack\@example.com
]

// ─── Mandant et lieu ──────────────────────────────────────────────────────
// Valeurs possibles : "hes" | "industrie" | "etablissement"
//   ou avec un nom : (industrie: "Nom") | (etablissement: "Nom")
#let tb-mandant = "hes"
#let tb-lieu    = (etablissement: "MOVE, Tokyo University")

// ─── Confidentialité ──────────────────────────────────────────────────────
#let tb-confidential = false

// ─── Contenu (Typst libre) ────────────────────────────────────────────────
#let tb-title = [A hardware-software co-design approach for embedded systems]

#let tb-description = [
  In this work, we propose a novel approach for designing embedded systems that integrates hardware and software components. The approach is based on a co-design methodology that allows for the simultaneous development of hardware and software components, leading to improved performance and reduced development time.

  We evaluate our approach through a *case study* on the design of an embedded system for a smart home application, demonstrating its effectiveness in terms of performance, energy efficiency, and ease of development.
]

#let tb-objectifs = [
  + Analyser l'état de l'art dans la thématique
  + Proposer une approche de co-design pour les systèmes embarqués.
    - En coordination avec les travaux de recherche
    - Dans le contexte de la filière ISC
  + Évaluer l'approche à travers une étude de cas sur un système de maison intelligente.
  + Comparer les résultats avec des approches traditionnelles de développement de systèmes embarqués
]

// ─── Délais (datetime ou texte libre pour la défense) ─────────────────────
#let date-attribution  = datetime(year: 2026, month: 3, day: 3)
#let date-debut        = datetime(year: 2026, month: 5, day: 11)
#let date-remise       = datetime(year: 2026, month: 7, day: 24)
#let date-remise-time  = "12:00"
#let date-defense      = [Semaines du 17 et 25 août 2026]
#let date-expo-hei     = datetime(year: 2026, month: 8, day: 28)
#let date-expo-monthey = datetime(year: 2026, month: 8, day: 31)

// ─── Addendum ─────────────────────────────────────────────────────────────
// Type de projet : "exploratoire" | "implementation"
#let tb-project-type = "exploratoire"

// Dépendances aux données (1–5) — explication obligatoire si ≥ 3
#let tb-data-dep         = 1
#let tb-data-explanation = none

// Dépendances matérielles (1–3)
//   explication obligatoire si ≥ 2
//   coût et procédure d'acquisition obligatoires si = 3
#let tb-material-dep         = 3
#let tb-material-explanation = "Un oscilloscope et une carte FPGA"
#let tb-material-cost        = "CHF 250.-"              // ex. "CHF 500.–" (obligatoire si dep = 3)
#let tb-material-procedure   = "Achat chez Digitec, en stock normalement. Si pas disponible, utilisation d'un autre fournisseur."              // procédure d'acquisition (obligatoire si dep = 3)

// Informations complémentaires (none = section vide)
#let tb-extra-info = none

// ════════════════════════════════════════════════════════════════════════════

#import "@preview/isc-hei-tb-assignment:0.7.0" : *

#show: project.with(
  doc-type: "tb-assignment",
  language: language,
  title: "Donnée du travail de bachelor",
  authors: tb-student,
  date: doc-date,
  revision: version,  
  logo: none,
  fancy-line: false,
)

#tb-assignment-page(
  student:       tb-student,
  id:            tb-id,
  supervisor:    tb-supervisor,
  co-supervisor: tb-co-supervisor,
  expert:        tb-expert,
  filiere:       tb-filiere,
  academic-year: tb-academic-year,
  mandant:       tb-mandant,
  lieu:          tb-lieu,
  confidential:  tb-confidential,
  title:         tb-title,
  description:   tb-description,
  objectifs:     tb-objectifs,
  date-attribution:  date-attribution,
  date-debut:        date-debut,
  date-remise:       date-remise,
  date-remise-time:  date-remise-time,
  date-defense:      date-defense,
  date-expo-hei:     date-expo-hei,
  date-expo-monthey: date-expo-monthey,
  project-type:         tb-project-type,
  data-dep:             tb-data-dep,
  data-explanation:     tb-data-explanation,
  material-dep:         tb-material-dep,
  material-explanation: tb-material-explanation,
  material-cost:        tb-material-cost,
  material-procedure:   tb-material-procedure,
  extra-info:           tb-extra-info,
  doc-version:          doc-version,
  language:             language,
)
