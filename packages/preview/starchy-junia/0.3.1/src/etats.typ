// =============================================================================
// ÉTATS ET CONSTANTES — états globaux, valeurs par défaut et traductions
// =============================================================================

// Déclaration de l'état global pour la langue, permet une forme de traduction "semi-automatique" pour les textes écrit en "dur"
#let v-langue-global        = state("langue-document",         "fr")

// Déclaration de l'état global du glossaire, mis à jour par `modele-junia()` et lu par la fonction `fbc-lexique`
#let v-glossaire-global     = state("glossaire-document",      ())

// Étiquette du repère invisible posé à chaque citation d'une entrée du lexique (`@cle`, `gls`, `glspl`).
// `fbc-lexique` n'affiche la section que si au moins un repère existe : contrairement aux citations
// elles-mêmes (forme longue à la première, courte ensuite) ou au décompte de glossarium, ce repère est
// identique d'une passe à l'autre, ce qui garantit la convergence de la compilation.
#let v-lexique-cite = <starchy-junia-lexique-cite>

// Déclaration de l'état global du mode ébauche, affiche le filigrane BROUILLON
#let v-ebauche-global       = state("ebauche-document",        false)

// Déclaration de l'état global du bandeau de confidentialité, affiche le bandeau CONFIDENTIEL sur chaque page
#let v-confidentiel-global  = state("confidentiel-document",   false)

// Déclaration de l'état global des mots-clés, affichés par `fbc-mots-cles`
#let v-mots-cles-global     = state("mots-cles-document",      ())

// Valeurs par défaut des paramètres regroupés de `modele-junia`, complétées par les clés fournies par l'utilisateur
#let v-couleurs-liens-defaut = (glossaire: green, bibliographie: blue, annexe: purple)
#let v-numerotation-defaut   = (profondeur: 3, equations: false, delimiteur: none, annexes: "A")
#let v-police-defaut         = (
  famille: "New Computer Modern Sans",
  taille:  12pt,
  titres:  (1.75em, 1.6em, 1.4em, 1.25em, 1.1em, 1em),  // Tailles des titres, niveaux 1 à 6
)

// Déclaration de l'état global des couleurs des liens (glossaire, bibliographie, annexe)
#let v-couleurs-liens-global = state("couleurs-liens-document", v-couleurs-liens-defaut)

// Déclaration de l'état global de la numérotation (profondeur des titres numérotés, équations)
#let v-numerotation-global  = state("numerotation-document",   v-numerotation-defaut)

// Zone courante du document ("pre-sommaire", "corps", "annexes"), mise à jour par les fonctions `fmp-*`
// Permet de numéroter une figure selon la zone où elle se trouve, y compris lorsqu'elle est citée depuis une autre zone
#let v-zone-global          = state("zone-document",           "pre-sommaire")

// Configuration par défaut des figures de code, complétée par le paramètre `code` de `modele-junia`
#let v-code-defaut = (
  mode:       "programme",  // "programme" : numérotation et liste propres — "figure" : traités comme des figures
  supplement: auto,         // Nom en légende, auto = traduction automatique
  court:      auto,         // Forme courte des citations @ref, auto = traduction automatique
  coloration: true,         // Mise en forme codly (numéros de lignes, icône du langage)
)

// Déclaration de l'état global de la configuration des figures de code
#let v-code-global          = state("code-document",           v-code-defaut)

// Adresse de JUNIA, Grande École d'Ingénieurs
#let v-adresse-junia = [JUNIA \ 2 Rue Norbert Ségard \ 59014 Lille cedex]

// --- Date de la page de garde ---
// Dictionnaire permettant la traduction des mois de l'anglais au français (voir `fa-mois-annee`)
#let v-mois-long = (
  January : "Janvier", February : "Février",  March :     "Mars",
  April :   "Avril",   May :      "Mai",      June :      "Juin",
  July :    "Juillet", August :   "Août",     September : "Septembre",
  October : "Octobre", November : "Novembre", December :  "Décembre"
)

// Dictionnaire de traduction automatique FR / EN
// Utilisé pour les titres de sections, les suppléments et les filigranes
#let v-liste-trad-auto = (
  
  // --- Titres de sections ---
  sommaire:         ("fr": [Table des matières],          "en": [Table of contents] ),
  sommaire_fig:     ("fr": [Table des figures],           "en": [List of figures]   ),
  sommaire_tab:     ("fr": [Liste des tableaux],          "en": [List of tables]    ),
  sommaire_prog:    ("fr": [Liste des programmes],        "en": [List of listings]  ),
  lexique:          ("fr": [Lexique],                     "en": [Glossary]          ),
  bibliographie:    ("fr": [Références Bibliographiques], "en": [Bibliography]      ),
  annexe:           ("fr": [Annexes],                     "en": [Appendices]        ),

  // --- Suppléments — forme longue (légende sous la figure) ---
  fig_long:         ("fr": [Figure],                      "en": [Figure]            ),
  tab_long:         ("fr": [Tableau],                     "en": [Table]             ),
  eq_long:          ("fr": [Équation],                    "en": [Equation]          ),
  prog_long:        ("fr": [Programme],                   "en": [Listing]           ),
  annexe_fig:       ("fr": [Annexe],                      "en": [Appendix]          ),

  // --- Suppléments — forme courte (citation dans le texte) ---
  fig_court:        ("fr": [fig.],                        "en": [fig.]              ),
  tab_court:        ("fr": [tab.],                        "en": [tab.]              ),
  eq_court:         ("fr": [éq.],                         "en": [eq.]               ),
  prog_court:       ("fr": [prog.],                       "en": [lst.]              ),
  chap_court:       ("fr": [chap.],                       "en": [chap.]             ),
  
  // --- Pagination ---
  page_app:         ("fr": [Page],                        "en": [Page]              ),
  delim_app:        ("fr": [sur],                         "en": [of]                ),

  // --- Mots-clés ---
  mots_cles:        ("fr": [Mots clés :],                 "en": [Keywords:]         ),

  // --- Filigranes ---
  brouillon:        ("fr": [BROUILLON],                   "en": [DRAFT]             ),
  secret:           ("fr": [CONFIDENTIEL],                "en": [CONFIDENTIAL]      ),
)
