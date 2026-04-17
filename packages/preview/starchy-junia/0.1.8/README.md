# starchy-junia

---

## Français

Modèle de rapport selon la charte de l'écrit V2 (2024) de JUNIA Grande École d'Ingénieur.

> **Remarque :** Ce modèle ne respecte pas la charte à 100 % — quelques adaptations ont été apportées pour l'utilisabilité.

### Utilisation

```typ
#import "@preview/starchy-junia:0.1.8": *

#show: modele_junia.with(
  generate-cover: true,
  titre_rapport: [Mon Rapport],
  type_rapport: [Rapport de stage],
  auteurs: ("NOM Prénom",),
  formation: [Ingénieur en Apprentissage],
  promotion: [HEI],
  niveau_classe: [48],
  lang_doc: "fr",
)
```

Via `typst init`, la structure complète du modèle est copiée dans votre projet.

### Paramètres

#### Page de garde (`generate-cover: true`)

| Paramètre | Type | Défaut | Description |
|-----------|------|--------|-------------|
| `generate-cover` | `bool` | `true` | Génère la page de garde depuis les paramètres |
| `cover-pdf-path` | `str` ou `none` | `none` | Chemin vers un PDF externe utilisé comme page de garde |
| `type_rapport` | `content` | `[]` | Type de rapport ou de mémoire |
| `titre_rapport` | `content` | `[]` | Titre du rapport (aussi utilisé dans les métadonnées PDF) |
| `confidentialite` | `content` | `[]` | Mention de confidentialité |
| `type_diplome` | `content` | `[]` | Diplôme visé |
| `professeur` | `content` | `[]` | Enseignant référent |
| `encadrant` | `content` | `[]` | Encadrant en organisme d'accueil |
| `auteurs` | `array` | `()` | Liste des auteurs (aussi utilisée dans les métadonnées PDF) |
| `formation` | `content` | `[]` | Intitulé de la formation |
| `promotion` | `content` | `[]` | Promotion / classe |
| `niveau_classe` | `content` | `[]` | Numéro de classe ou de cohorte |
| `mois_annee` | `auto` ou `str` | `auto` | Date affichée en page de garde — `auto` utilise le mois et l'année courants |

#### Comportement du document

| Paramètre | Type | Défaut | Description |
|-----------|------|--------|-------------|
| `ebauche` | `bool` | `false` | Mode brouillon — affiche les notes de marge et le filigrane « BROUILLON » |
| `filigrane` | `bool` | `false` | Filigrane « CONFIDENTIEL » sur toutes les pages |
| `math_num` | `bool` | `false` | Numérotation des équations mathématiques |
| `lang_doc` | `str` | `"fr"` | Langue du document (`"fr"` ou `"en"`) — traduit automatiquement les titres des sections |

### Structure du modèle

```
Modele/
├── main.typ                            ← Point d'entrée (configurer les paramètres ici)
├── Configuration/
│   ├── setup.typ                       ← Moteur du modèle (mise en page, styles, fonctions)
│   └── universe.typ                    ← Imports des paquets tiers
├── Fiches/
│   ├── B_Resume.typ                    ← Résumé
│   ├── C_Remerciements.typ             ← Remerciements
│   ├── D_Preambule.typ                 ← Préambule / Nomenclature
│   ├── G_Introduction.typ              ← Introduction
│   ├── H_Cadre_de_etude.typ            ← Cadre de l'étude
│   ├── I_Contexte_Etat_art.typ         ← Contexte & état de l'art
│   ├── J_Methodologie_Moyens.typ       ← Méthodologie & moyens
│   ├── K_Presentation_Analyses.typ     ← Résultats & analyses
│   ├── L_Discussions_Perspectives.typ  ← Discussion & perspectives
│   ├── M_Conclusion.typ                ← Conclusion
│   └── P_Annexes.typ                   ← Annexes
├── Ressources/
│   ├── E_Lexique.typ                   ← Entrées du glossaire
│   ├── N_Bibliographie.bib             ← Bibliographie BibTeX
│   └── N_Bibliographie.yml             ← Bibliographie Hayagriva
├── Systeme/
│   ├── Y_Helpers.typ                   ← Fonctions utilitaires (notes de marge, affichage PDF)
│   └── Z_Figures.typ                   ← Figures personnalisées
└── Images/
    └── Garde/
        └── JUNIA_LOGO.png              ← Logo JUNIA pour la page de garde
```

### Fonctions utilitaires

#### `note-de-marge(contenu)` — note dans la marge
Visible uniquement en mode brouillon (`ebauche: true`).

```typ
#note-de-marge[À revoir]
```

#### `note-de-texte(contenu)` — note inline
Commentaire encadré dans le texte, visible uniquement en mode brouillon.

```typ
#note-de-texte[Cette section est incomplète.]
```

#### `f_afficher_pdf(chemin, legende, premiere_page, derniere_page, largeur, tag)` — affichage multi-pages d'un PDF
Affiche une ou plusieurs pages d'un PDF sous forme de figures.

```typ
#f_afficher_pdf(
  chemin: "../Images/schema.pdf",
  legende: [Architecture du système],
  premiere_page: 0,
  derniere_page: 2,
  tag: "fig-schema",
)
```

### Paquets inclus

| Paquet | Version | Utilité |
|--------|---------|---------|
| [glossarium](https://typst.app/universe/package/glossarium) | 0.5.10 | Gestion du lexique / glossaire |
| [hydra](https://typst.app/universe/package/hydra) | 0.6.2 | Titre courant dans l'en-tête de page |
| [drafting](https://typst.app/universe/package/drafting) | 0.2.2 | Notes de marge pour le mode brouillon |
| [codly](https://typst.app/universe/package/codly) | 1.3.0 | Blocs de code stylisés |
| [codly-languages](https://typst.app/universe/package/codly-languages) | 0.1.1 | Icônes de langages pour codly |
| [cetz](https://typst.app/universe/package/cetz) | 0.4.2 | Dessin bas niveau (inspiré TikZ) |
| [fletcher](https://typst.app/universe/package/fletcher) | 0.5.8 | Diagrammes (nœuds & arêtes) |
| [zap](https://typst.app/universe/package/zap) | 0.5.0 | Schémas électriques |
| [meander](https://typst.app/universe/package/meander) | 0.4.1 | Placement fin des figures |
| [timeliney](https://typst.app/universe/package/timeliney) | 0.4.0 | Diagrammes de Gantt |
| [lilaq](https://typst.app/universe/package/lilaq) | 0.6.0 | Visualisation de données |
| [echarm](https://typst.app/universe/package/echarm) | 0.3.1 | Figures de type Echart |

---

## English

Report template based on the JUNIA Grande École d'Ingénieur writing charter V2 (2024).

> **Note:** This template does not comply 100% with the charter — some adaptations have been made for usability.

### Usage

```typ
#import "@preview/starchy-junia:0.1.8": *

#show: modele_junia.with(
  generate-cover: true,
  titre_rapport: [My Report],
  type_rapport: [Internship Report],
  auteurs: ("LAST First",),
  formation: [Engineering Apprenticeship],
  promotion: [HEI],
  niveau_classe: [48],
  lang_doc: "en",
)
```

Via `typst init`, the full template structure is copied into your project.

### Parameters

#### Cover page (`generate-cover: true`)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `generate-cover` | `bool` | `true` | Generate the cover page from parameters |
| `cover-pdf-path` | `str` or `none` | `none` | Path to an external PDF cover (used when `generate-cover: false`) |
| `type_rapport` | `content` | `[]` | Report / thesis type |
| `titre_rapport` | `content` | `[]` | Report title (also used for PDF metadata) |
| `confidentialite` | `content` | `[]` | Confidentiality notice |
| `type_diplome` | `content` | `[]` | Target degree |
| `professeur` | `content` | `[]` | Academic supervisor |
| `encadrant` | `content` | `[]` | Company supervisor |
| `auteurs` | `array` | `()` | List of authors (also used for PDF metadata) |
| `formation` | `content` | `[]` | Training programme name |
| `promotion` | `content` | `[]` | Cohort / class name |
| `niveau_classe` | `content` | `[]` | Class or cohort number |
| `mois_annee` | `auto` or `str` | `auto` | Date shown on cover — `auto` uses current month/year |

#### Document behaviour

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ebauche` | `bool` | `false` | Draft mode — shows margin notes and a "BROUILLON/DRAFT" watermark |
| `filigrane` | `bool` | `false` | "CONFIDENTIEL/CONFIDENTIAL" watermark on every page |
| `math_num` | `bool` | `false` | Number mathematical equations |
| `lang_doc` | `str` | `"fr"` | Document language (`"fr"` or `"en"`) — auto-translates section titles |

### Template structure

```
Modele/
├── main.typ                      ← Entry point (configure parameters here)
├── Configuration/
│   ├── setup.typ                 ← Template engine (page layout, styles, functions)
│   └── universe.typ              ← Third-party package imports
├── Fiches/
│   ├── B_Resume.typ              ← Abstract
│   ├── C_Remerciements.typ       ← Acknowledgements
│   ├── D_Preambule.typ           ← Preamble / Nomenclature
│   ├── G_Introduction.typ        ← Introduction
│   ├── H_Cadre_de_etude.typ      ← Study framework
│   ├── I_Contexte_Etat_art.typ   ← Context & state of the art
│   ├── J_Methodologie_Moyens.typ ← Methodology & means
│   ├── K_Presentation_Analyses.typ ← Results & analyses
│   ├── L_Discussions_Perspectives.typ ← Discussion & perspectives
│   ├── M_Conclusion.typ          ← Conclusion
│   └── P_Annexes.typ             ← Appendices
├── Ressources/
│   ├── E_Lexique.typ             ← Glossary entries
│   ├── N_Bibliographie.bib       ← BibTeX bibliography
│   └── N_Bibliographie.yml       ← Hayagriva bibliography
├── Systeme/
│   ├── Y_Helpers.typ             ← Helper functions (margin notes, PDF display)
│   └── Z_Figures.typ             ← Custom figures
└── Images/
    └── Garde/
        └── JUNIA_LOGO.png        ← JUNIA logo for the cover page
```

### Helper functions

#### `note-de-marge(contenu)` — margin note
Visible only in draft mode (`ebauche: true`).

```typ
#note-de-marge[To be revised]
```

#### `note-de-texte(contenu)` — inline note
Highlighted inline comment, visible only in draft mode.

```typ
#note-de-texte[This section is incomplete.]
```

#### `f_afficher_pdf(chemin, legende, premiere_page, derniere_page, largeur, tag)` — multi-page PDF display
Displays one or more pages of a PDF as figures.

```typ
#f_afficher_pdf(
  chemin: "../Images/schema.pdf",
  legende: [System architecture],
  premiere_page: 0,
  derniere_page: 2,
  tag: "fig-schema",
)
```

### Included packages

| Package | Version | Purpose |
|---------|---------|---------|
| [glossarium](https://typst.app/universe/package/glossarium) | 0.5.10 | Glossary / lexicon |
| [hydra](https://typst.app/universe/package/hydra) | 0.6.2 | Running header with current chapter title |
| [drafting](https://typst.app/universe/package/drafting) | 0.2.2 | Margin notes for draft mode |
| [codly](https://typst.app/universe/package/codly) | 1.3.0 | Styled code blocks |
| [codly-languages](https://typst.app/universe/package/codly-languages) | 0.1.1 | Language icons for codly |
| [cetz](https://typst.app/universe/package/cetz) | 0.4.2 | Low-level drawing (TikZ-like) |
| [fletcher](https://typst.app/universe/package/fletcher) | 0.5.8 | Diagrams (nodes & edges) |
| [zap](https://typst.app/universe/package/zap) | 0.5.0 | Electrical circuit diagrams |
| [meander](https://typst.app/universe/package/meander) | 0.4.1 | Fine-grained figure placement |
| [timeliney](https://typst.app/universe/package/timeliney) | 0.4.0 | Gantt charts |
| [lilaq](https://typst.app/universe/package/lilaq) | 0.6.0 | Data visualisation |
| [echarm](https://typst.app/universe/package/echarm) | 0.3.1 | Echart figures |


---

## Changelog / Journal des modifications

See [CHANGELOG.md](./CHANGELOG.md).

## Licence

[MIT](./LICENSE) — MathYeiv, 2026.
