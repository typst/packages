// Déclaration de l'état global pour la langue, permet une forme de traduction "semi-automatique" pour les textes écrit en "dur"
#let v-langue-global        = state("langue-document",         "fr")

// Déclaration de l'état global du glossaire, mis à jour par `junia-core()` et lu par la fonction `fbc-lexique`
#let v-glossaire-global     = state("glossaire-document",      ())

// State de citation du lexique, mis à jour par show ref quand une entrée est citée, permet la gestion de la section `fbc-lexique`
#let v-lexique-cite-global = state("lexique_cite_document", false)

// Déclaration de l'état global, active les notes de relecture et le filigrane BROUILLON
#let v-ebauche-global       = state("ebauche-document",        false)

// Déclaration de l'état global du filigrane de confidentialité, affiche le bandeau CONFIDENTIEL sur chaque page
#let v-filigrane-global     = state("filigrane-document",      false)

// Déclaration du fond de page global, permet l'affichage des filigranes
#let v-fond-de-page-global  = state("fond-de-page",            [])

// Déclaration de l'état global des couleurs de citation, (glossaire, bibliographie, annexe)
#let v-couleurs-cite-global = state("couleurs-cite-document",  (green, blue, purple))

// Déclaration de l'état global de la numérotation des équations dans le document
#let v-equations-global     = state("equations-document",      false)

// Compteur des notes inline — drafting ne les compte pas nativement
#let v-inline-note-counter = counter("inline-notes")

// Adresse de JUNIA, Grande École d'Ingénieurs
#let v-adresse-junia = [JUNIA \ 2 Rue Norbert Ségard \ 59014 Lille cedex]

// --- Gestion de la date du rapport de manière automatique ---
// Récupération de la date de compilation du document
#let v-date-du-jour = datetime.today()
// Création du dictionnaire permettant la traduction de l'anglais au français
#let v-mois-long = (
  January : "Janvier", February : "Février",  March :     "Mars",
  April :   "Avril",   May :      "Mai",      June :      "Juin",
  July :    "Juillet", August :   "Août",     September : "Septembre",
  October : "Octobre", November : "Novembre", December :  "Décembre"
)

// On affecte les mois français au mois anglais, à l'aide du dictionnaire
#let v-mois-court = v-mois-long.at(v-date-du-jour.display("[month repr:long]"))

// Récupération du mois en anglais
#let v-month-short = v-date-du-jour.display("[month repr:long]")

// Récupération de l'année
#let v-annee-court = v-date-du-jour.display("[year repr:full]")

// Dictionnaire de traduction automatique FR / EN
// Utilisé pour les titres de sections, les suppléments et les filigranes
#let v-liste-trad-auto = (
  
  // --- Titres de sections ---
  sommaire_ebauche: ("fr": [Liste des notes],             "en": [List of notes]     ),
  sommaire:         ("fr": [Table des matières],          "en": [Table of contents] ),
  sommaire_fig:     ("fr": [Table des figures],           "en": [List of figures]   ),
  sommaire_tab:     ("fr": [Liste des tableaux],          "en": [List of tables]    ),
  lexique:          ("fr": [Lexique],                     "en": [Glossary]          ),
  bibliographie:    ("fr": [Références Bibliographiques], "en": [Bibliography]      ),
  annexe:           ("fr": [Annexes],                     "en": [Appendices]        ),

  // --- Suppléments — forme longue (légende sous la figure) ---
  fig_long:         ("fr": [Figure],                      "en": [Figure]            ),
  tab_long:         ("fr": [Tableau],                     "en": [Table]             ),
  eq_long:          ("fr": [Équation],                    "en": [Equation]          ),
  annexe_fig:       ("fr": [Annexe],                      "en": [Appendix]          ),

  // --- Suppléments — forme courte (citation dans le texte) ---
  fig_court:        ("fr": [fig.],                        "en": [fig.]              ),
  tab_court:        ("fr": [tab.],                        "en": [tab.]              ),
  eq_court:         ("fr": [éq.],                         "en": [eq.]               ),
  chap_court:       ("fr": [chap.],                       "en": [chap.]             ),
  
  // --- Pagination ---
  page_app:         ("fr": [Page],                        "en": [Page]              ),
  delim_app:        ("fr": [sur],                         "en": [of]                ),

  // --- Filigranes ---
  brouillon:        ("fr": [BROUILLON],                   "en": [DRAFT]             ),
  secret:           ("fr": [CONFIDENTIEL],                "en": [CONFIDENTIAL]      ),

  // --- Variables dynamiques ---
  mois_date:        ("fr": v-mois-court,                  "en": v-month-short       ),
)
