# starchy-junia

Modèle de rapport conforme à la charte de l'écrit de JUNIA, réalisé avec [Typst](https://typst.app).

> **Nouveau sur Typst ?** Typst est un logiciel de mise en page à base de texte — comme LaTeX, mais plus simple. Vous rédigez du texte, le modèle s'occupe de la mise en forme. Pas besoin de connaître Typst pour utiliser ce modèle : il suffit de remplir `squelette.typ` et d'écrire dans les fichiers `02-fiches/`.

---

## Démarrage rapide

### 1. Récupérer le modèle

**Via Typst Web App** : cliquer sur *Start from template* et chercher `starchy-junia`.

**Via CLI** :
```sh
typst init @preview/starchy-junia
```

**Manuellement** : télécharger le ZIP depuis [Codeberg](https://codeberg.org/MathYeiv/starchy-junia) et décompresser.

### 2. Configurer le document

Ouvrir `squelette.typ` et remplir la section `CONFIGURATION` :

```typst
#show: modele-junia.with(

  type-rapport:  [Rapport de stage],
  titre-rapport: [Mon rapport],
  type-diplome:  [Ingénieur généraliste JUNIA-HEI],
  professeur:    [Enseignant référent : DUPONT Alice],
  encadrant:     [Encadrant : MARTIN Bob],
  auteurs:       ("NOM Prénom",),
  formation:     [Ingénieur en Apprentissage],
  promotion:     [BTP/ESE HEI],
  niveau-classe: [48],
)
```

> **Plusieurs auteurs ?** Ajouter une ligne par auteur :
> ```typst
> auteurs: (
>   "DUPONT Alice",
>   "MARTIN Bob",
> ),
> ```

### 3. Rédiger

Écrire le contenu dans les fichiers correspondants du dossier `02-fiches/` :

| Fichier | Section |
|---|---|
| `021-pre-sommaire/B-resume.typ` | Résumé |
| `021-pre-sommaire/C-remerciements.typ` | Remerciements |
| `021-pre-sommaire/D-preambule.typ` | Préambule / Avant-propos |
| `022-post-sommaire/G-introduction.typ` | Introduction |
| `022-post-sommaire/H-cadre-de-etude.typ` | Cadre de l'étude |
| `022-post-sommaire/I-contexte-etat-art.typ` | Contexte et état de l'art |
| `022-post-sommaire/J-methodologie-moyens.typ` | Méthodologie et moyens |
| `022-post-sommaire/K-presentation-analyses.typ` | Présentation et analyses |
| `022-post-sommaire/L-discussions-perspectives.typ` | Discussions et perspectives |
| `022-post-sommaire/M-conclusion.typ` | Conclusion |
| `023-annexes/P-annexes.typ` | Annexes |

### 4. Compiler

**Via Typst Web App** : la compilation est automatique.

**Via CLI** :
```sh
typst compile squelette.typ
```

---

## Syntaxe Typst — l'essentiel

> Cette section est destinée aux personnes qui n'ont jamais utilisé Typst. Si vous connaissez déjà Markdown, vous avez les bases.

### Titres

```typst
= Titre de chapitre        // Niveau 1 — apparaît dans la table des matières
== Sous-section            // Niveau 2
=== Sous-sous-section      // Niveau 3
```

### Texte

```typst
Texte normal.

*Texte en gras.*

_Texte en italique._

Saut de ligne simple : continuer sur la ligne suivante. \
Le `\` force le saut. Un paragraphe se crée avec une ligne vide.
```

### Figures et images

```typst
#figure(
  image("../../03-images/mon-image.png", width: 80%),
  caption: [Légende de l'image],
)<mon-label>
```

> Le `<mon-label>` permet de citer la figure dans le texte avec `@mon-label`.
> Le chemin `../../` remonte de deux niveaux depuis le fichier `.typ` courant jusqu'à la racine du projet.

### Tableaux

```typst
#figure(
  table(
    columns: (1fr, 1fr, 1fr),   // 3 colonnes de largeur égale
    table.header([*Colonne 1*], [*Colonne 2*], [*Colonne 3*]),
    [Ligne 1, Col 1], [Ligne 1, Col 2], [Ligne 1, Col 3],
    [Ligne 2, Col 1], [Ligne 2, Col 2], [Ligne 2, Col 3],
  ),
  caption: [Mon tableau],
)<mon-tableau>
```

### Équations mathématiques

```typst
// Équation dans le texte (inline) :
La formule $E = m c^2$ est connue de tous.

// Équation centrée sur sa propre ligne (block) :
$
  integral_0^infinity e^(-x^2) dif x = sqrt(pi) / 2
$
```

### Notes de bas de page

```typst
Ce texte a une note de bas de page.#footnote[Contenu de la note.]
```

### Blocs de code

````typst
#figure(
  ```python
  def hello():
      print("Bonjour JUNIA")
  ```,
  caption: [Exemple de code Python],
)
````

---

## Fonctionnalités du modèle

### Lexique (glossaire)

Définir les entrées dans `04-ressources/040-lexique/E-lexique.typ` :

```typst
#let v-liste-glossaire = (
  (
    key: "api",
    short: "API",
    artshort: "une ",
    long: "Application Programming Interface",
    description: "Interface permettant à des logiciels de communiquer entre eux.",
    group: ("Acronymes"),
  ),
)
```

Citer dans le texte avec `@api`. Le lexique s'affiche automatiquement dans le pré-sommaire si des entrées sont présentes.

> **Groupes disponibles** : `"Acronymes"` (se prononcent comme un mot, ex. OTAN), `"Sigles"` (ne se prononcent pas comme un mot, ex. SNCF), `"Définitions"`.

### Bibliographie

Deux formats sont supportés : `.yml` (Hayagriva) et `.bib` (BibTeX). Les fichiers sont dans `04-ressources/041-bibliographies/`.

**Format `.yml`** (recommandé) :
```yaml
dupont2023:
    type: Article
    title: Mon article de recherche
    author: ["Dupont, Alice", "Martin, Bob"]
    date: 2023-05-15
    parent:
        type: Periodical
        title: Journal of Engineering
        volume: 12
```

**Format `.bib`** :
```bibtex
@article{dupont2023,
  author  = {Alice Dupont and Bob Martin},
  title   = {Mon article de recherche},
  journal = {Journal of Engineering},
  year    = {2023},
  volume  = {12},
}
```

Citer dans le texte avec `@dupont2023`. La bibliographie s'affiche automatiquement si des citations sont présentes.

> Le style par défaut est IEEE. Pour changer :
> ```typst
> #show: fbc-bibliographie.with(style-biblio: "apa")
> ```

### Annexes

Rédiger dans `02-fiches/023-annexes/P-annexes.typ`. Chaque titre de niveau `=` crée une annexe lettrée (A, B, C…). Un sommaire des annexes est généré automatiquement.

```typst
= Annexe technique

Contenu de l'annexe A.

= Données expérimentales

Contenu de l'annexe B.
```

Pour insérer un PDF externe dans les annexes et afficher plusieurs pages :

```typst
#fm-afficher-pdf(
  chemin: "../../04-ressources/mon-document.pdf",
  legende: [Mon document externe],
  premiere-page: 1,
  derniere-page: 3,
  tag: "mon-doc",
)
```

### Fonctions de personnalisation

Ces fonctions sont à appeler directement dans les fichiers `02-fiches/` :

```typst
#footnote[Texte de la note de bas de page]
```

En mode ébauche (`ebauche: true` dans `squelette.typ`) :

```typst
#fr-note-de-marge[Commentaire dans la marge]

#fr-note-de-texte[Note encadrée dans le flux du texte]
```

---

## Options du modèle

Toutes les options s'ajoutent dans le bloc `modele-junia.with(...)` de `squelette.typ`.

| Option | Type | Défaut | Description |
|---|---|---|---|
| `titre-rapport` | content | — | **Obligatoire** |
| `auteurs` | array | — | **Obligatoire** |
| `type-rapport` | content | `[]` | Type de document |
| `type-diplome` | content | `[]` | Diplôme visé |
| `professeur` | content | `[]` | Enseignant référent |
| `encadrant` | content | `[]` | Encadrant entreprise |
| `formation` | content | `[]` | Filière |
| `promotion` | content | `[]` | Promotion |
| `niveau-classe` | content | `[]` | Niveau / classe |
| `mois-annee` | content | `auto` | Date de la page de garde (`auto` = date actuelle) |
| `confidentialite` | content | `[]` | Mention rouge sur la page de garde |
| `lang-doc` | str | `"fr"` | Langue : `"fr"` ou `"en"` |
| `ebauche` | bool | `false` | Filigrane BROUILLON + notes de relecture visibles |
| `filigrane` | bool | `false` | Bandeau CONFIDENTIEL sur chaque page |
| `num-equations` | bool | `false` | Numéroter les équations par chapitre |
| `generate-cover` | bool | `true` | Générer la page de garde automatiquement |
| `cover-pdf-path` | str | `none` | Chemin vers une page de garde PDF externe |
| `img-gau` / `img-cen` / `img-dro` | str | logo JUNIA / `""` | Logos gauche, centre, droite de la page de garde |
| `adr-gau` / `adr-cen` / `adr-dro` | content | adresse JUNIA / `[]` | Adresses sous les logos |

---

## Architecture des dossiers

```
squelette.typ                  ← point d'entrée, à modifier
│
├── 00-configuration/          ← moteur du modèle (ne pas modifier)
├── 01-utilisateurs/           ← fonctions et figures personnalisées
│   ├── 010-auxiliaires.typ
│   └── 011-figures.typ
│
├── 02-fiches/                 ← contenu du document (à rédiger ici)
│   ├── 021-pre-sommaire/
│   ├── 022-post-sommaire/
│   └── 023-annexes/
│
├── 03-images/                 ← images du projet
│   └── 030-page-de-garde/
│
└── 04-ressources/             ← lexique et bibliographie
    ├── 040-lexique/
    │   └── E-lexique.typ
    └── 041-bibliographies/
        ├── N-bibliographie.yml
        └── N-bibliographie.bib
```

---

## Autres modèles disponibles

Ce paquet inclut deux modèles autonomes qui n'utilisent pas cette architecture de dossiers :

- **`junia-light`** — document court rédigé dans un seul fichier `.typ`, sans page de garde institutionnelle.
- **`junia-expert`** — fonctionnalités complètes, architecture libre, transitions de zones manuelles.

Voir la documentation détaillée dans [starchy-junia-0.2.0.pdf](https://codeberg.org/MathYeiv/starchy-junia/raw/tag/v0.2.0/starchy-junia-0.2.0.pdf).

---

## Licence

MIT — MathYeiv

Dépôt : [codeberg.org/MathYeiv/starchy-junia](https://codeberg.org/MathYeiv/starchy-junia)
