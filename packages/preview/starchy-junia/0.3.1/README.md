# starchy-junia

> Report template following JUNIA engineering school's writing charter, built with [Typst](https://typst.app). Ready-made folder structure, generated or external cover page, bilingual FR/EN, auto-numbered figures, tables, code listings and equations. Documentation below is in French, the template's primary audience; an optional guide for AI assistants is available on Codeberg ([AGENTS.md](https://codeberg.org/MathYeiv/starchy-junia/src/tag/v0.3.1/docs/AGENTS.md)).

Modèle de rapport conforme à la charte de l'écrit de JUNIA, réalisé avec [Typst](https://typst.app).

> **Nouveau sur Typst ?** Typst est un logiciel de mise en page à base de texte — comme LaTeX, mais plus simple. Vous rédigez du texte, le modèle s'occupe de la mise en forme. Pas besoin de connaître Typst pour utiliser ce modèle : il suffit de remplir `squelette.typ` et d'écrire dans les fichiers du dossier `fiches/`.

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

Écrire le contenu dans les fichiers correspondants du dossier `fiches/` :

| Fichier | Section |
|---|---|
| `pre-sommaire/01-resume.typ` | Résumé |
| `pre-sommaire/02-remerciements.typ` | Remerciements |
| `pre-sommaire/03-preambule.typ` | Préambule / Avant-propos |
| `corps/01-introduction.typ` | Introduction |
| `corps/02-cadre-etude.typ` | Cadre de l'étude |
| `corps/03-contexte-etat-art.typ` | Contexte et état de l'art |
| `corps/04-methodologie-moyens.typ` | Méthodologie et moyens |
| `corps/05-presentation-analyses.typ` | Présentation et analyses |
| `corps/06-discussions-perspectives.typ` | Discussions et perspectives |
| `corps/07-conclusion.typ` | Conclusion |
| `annexes/01-annexes.typ` | Annexes |

### 4. Compiler

> **Police** : le modèle utilise *New Computer Modern Sans*, disponible d'office dans la Web App Typst. En local, l'installer sur le système (paquet `fonts-newcomputermodern` ou équivalent, ou [téléchargement](https://ctan.org/pkg/newcomputermodern)) ou la désigner avec `typst compile --font-path <dossier>`. Sans elle, Typst utilise une police de remplacement ; une autre police peut aussi être choisie avec `police: (famille: "...")`.

**Via Typst Web App** : la compilation est automatique.

**Via CLI** :
```sh
typst compile squelette.typ
```

#### Export PDF/A (archivage)

Si un dépôt ou une bibliothèque exige un PDF/A, Typst le produit directement, en CLI ou dans les options d'export de la Web App :

```sh
typst compile --pdf-standard a-2b squelette.typ
```

- **PDF/A-2b** est la norme d'archivage habituelle des mémoires ; le squelette du modèle la respecte.
- **PDF insérés** : `fm-afficher-pdf(image("x.pdf"), ...)` et `page-de-garde: image("garde.pdf")` sont refusés dans ce mode (« embedding PDFs is currently not supported in this export mode »). Convertir le PDF en SVG (ou en PNG) et insérer l'image obtenue.
- **PDF/A-2a et PDF/UA-1** (accessibilité) exigent en plus un texte alternatif sur chaque image et chaque équation : `image("schema.png", alt: "Schéma du réseau")`, `math.equation(block: true, alt: "a égale b", $a = b$)`. Sans lui : « missing alt text ». Deux limites viennent des paquets utilisés par le modèle, et non du document :
  - les **blocs de code** : les icônes de langage de codly n'ont pas de texte alternatif ; désactiver la mise en forme avec `code: (coloration: false)` ;
  - le **lexique** : les entrées affichées par glossarium n'en ont pas non plus ; un document dont le lexique est affiché ne peut pas, pour l'instant, être exporté dans ces deux normes.
- PDF/A-1b, plus ancien, est déconseillé : il refuse les PDF insérés récents.

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
  image("../../images/mon-image.png", width: 80%),
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
)<mon-programme>
````

> Un bloc de code placé dans une figure devient un **programme** : « Programme 1.1 », légende au-dessus, cité avec `@mon-programme` (« prog. 1.1 ») et listé dans la *Liste des programmes*. Un programme long se poursuit sur plusieurs pages.
> Pour le traiter plutôt comme une figure ordinaire (même numérotation, table des figures) : `code: (mode: "figure")` dans `squelette.typ`.

---

## Fonctionnalités du modèle

### Lexique (glossaire)

Définir les entrées dans `ressources/lexique.typ` :

```typst
#let v-liste-glossaire = (
  (
    key: "api",
    short: "API",
    long: "Application Programming Interface",
    description: "Interface permettant à des logiciels de communiquer entre eux.",
    group: "Sigles",
  ),
)
```

Citer dans le texte avec `@api`. Le lexique s'affiche automatiquement dans le pré-sommaire dès qu'une entrée est citée.

Les citations suivent la syntaxe du paquet [glossarium](https://typst.app/universe/package/glossarium) :

| Écriture | Résultat |
|---|---|
| `@api` (première citation) | Application Programming Interface (API) |
| `@api` (citations suivantes) | API |
| `@api:long` / `@api:short` | Application Programming Interface / API |
| `@Api` | majuscule initiale, utile en début de phrase |
| `@api:pl` | pluriel |

> **Pluriel** : par défaut, glossarium ajoute un « s » à la forme courte (« APIs »). Un sigle français étant invariable, renseigner `plural: "API"` dans l'entrée (et `longplural` pour la forme longue si besoin).

> **Groupes conseillés** : `"Acronymes"` (se prononcent comme un mot, ex. OTAN), `"Sigles"` (ne se prononcent pas comme un mot, ex. SNCF, API), `"Définitions"`.

### Bibliographie

Deux formats sont supportés : `.yml` (Hayagriva) et `.bib` (BibTeX). Les fichiers sont dans `ressources/` : `bibliographie.yml` (format propre à Typst) et `bibliographie.bib` (format exporté par Zotero et la plupart des outils).

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

> Le style par défaut est IEEE. Pour changer, modifier l'appel `#bibliography(...)` dans `squelette.typ` :
> ```typst
> #bibliography(
>   ("ressources/bibliographie.yml", "ressources/bibliographie.bib"),
>   style: "apa",
> )
> ```
> Le titre de la section est traduit automatiquement par `fbc-bibliographie` ; pour le personnaliser : `#show: fbc-bibliographie.with(titre: [Sources])`.

### Annexes

Rédiger dans `fiches/annexes/01-annexes.typ`. Chaque titre de niveau `=` crée une annexe lettrée (A, B, C…), ou numérotée selon `numerotation: (annexes: "1")`, `"Annexe A"` ou `"Annexe 1"`. Un sommaire des annexes est généré automatiquement, et les annexes apparaissent sous « Annexes » dans les signets du PDF. Une annexe se cite avec `@etiquette` → « Annexe A ».

```typst
= Annexe technique

Contenu de l'annexe A.

= Données expérimentales

Contenu de l'annexe B.
```

Pour insérer un PDF externe dans les annexes et afficher plusieurs pages :

```typst
#fm-afficher-pdf(
  image("../../ressources/mon-document.pdf"),
  legende: [Mon document externe],
  premiere-page: 1,
  derniere-page: 3,
  etiquette: "mon-doc",
)
```

> Le PDF est passé sous la forme `image("chemin.pdf")` : le chemin est ainsi résolu depuis le fichier appelant — la fonction vit dans le paquet et ne peut pas résoudre elle-même un chemin relatif au projet.

### Page de garde

La page de garde est générée à partir des paramètres de `squelette.typ`. Elle peut être personnalisée ou remplacée :

```typst
#show: modele-junia.with(
  // ...
  logo-droite:    image("images/logo-entreprise.png"),   // logo à droite, en plus de celui de JUNIA
  adresse-droite: [Entreprise \ Adresse],
  // page-de-garde: image("images/garde.pdf"),          // page de garde externe, à la place de la page générée
  // page-de-garde: none,                               // aucune page de garde
)
```

> Les images et PDF sont toujours passés sous la forme `image("chemin")` : le chemin est lu depuis le fichier où il est écrit.

### Paquets et fonctions personnalisées

Le fichier `ressources/commun.typ` est importé dans chaque fiche. Il contient :
- l'import du modèle `starchy-junia` — **seul endroit où figure sa version** ;
- les paquets de rédaction déjà disponibles : `cetz` (dessin), `fletcher` (diagrammes), `zap` (circuits), `timeliney` (Gantt), `lilaq` (courbes, `lq`), `echarm` (graphiques) ;
- vos propres fonctions et figures, à ajouter en fin de fichier pour les utiliser dans toutes les fiches.

Pour ajouter un paquet, ajouter son `#import "@preview/..."` dans `commun.typ` (catalogue : [typst.app/universe](https://typst.app/universe)).

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
| `date` | auto / datetime / content / none | `auto` | Date de la page de garde (`auto` = mois et année de compilation ; `datetime(year: 2025, month: 6, day: 30)` = mois et année traduits, et date des métadonnées PDF ; `[Juin 2025]` = texte libre ; `none` = pas de date). Un texte entre guillemets est refusé |
| `mots-cles` | array | `()` | Mots-clés dans la langue du document, ex : `("IoT", "LoRa")` : métadonnées PDF, et affichage sous le résumé avec `#fbc-mots-cles()` |
| `confidentialite` | content | `[]` | Mention rouge sur la page de garde |
| `langue` | str | `"fr"` | Langue : `"fr"` ou `"en"` |
| `ebauche` | bool | `false` | Filigrane BROUILLON sur chaque page |
| `bandeau-confidentiel` | bool | `false` | Bandeau CONFIDENTIEL sur chaque page |
| `numerotation` | dictionnaire | `(profondeur: 3, equations: false, delimiteur: none, annexes: "A")` | Niveau de titre maximum numéroté ; numérotation des équations par chapitre ; texte après le numéro des titres, repris dans les sommaires et l'en-tête (ex : `")"` → « 1.1) ») ; numérotation des annexes : `"A"`, `"1"`, `"Annexe A"` ou `"Annexe 1"` |
| `code` | dictionnaire | `(mode: "programme", supplement: auto, court: auto, coloration: true)` | Blocs de code en figure : `"programme"` (liste des programmes) ou `"figure"` (table des figures) |
| `police` | dictionnaire | `(famille: "New Computer Modern Sans", taille: 12pt, titres: (1.75em, …))` | Police et taille du texte, tailles des titres |
| `couleurs-liens` | dictionnaire | `(glossaire: green, bibliographie: blue, annexe: purple)` | Couleurs des liens dans le texte |
| `page-de-garde` | auto / content / none | `auto` | `auto` = page générée, `image("garde.pdf")` = page externe à la place, `none` = aucune |
| `logo-gauche` / `logo-centre` / `logo-droite` | auto / content / none | logo JUNIA / `none` | Logos de la page de garde, ex : `image("images/logo.png")` |
| `adresse-gauche` / `adresse-centre` / `adresse-droite` | auto / content / none | adresse JUNIA / `none` | Adresses sous les logos |

---

## Architecture des dossiers

```text
squelette.typ                  ← point d'entrée : configuration et ordre des fiches
│
├── fiches/                    ← contenu du document (à rédiger ici)
│   ├── pre-sommaire/          ← résumé, remerciements, préambule
│   ├── corps/                 ← chapitres numérotés
│   └── annexes/
│
├── images/                    ← images du projet
│
└── ressources/
    ├── commun.typ             ← modèle, paquets et fonctions personnalisées, importé dans chaque fiche
    ├── lexique.typ            ← entrées du lexique
    ├── bibliographie.yml      ← bibliographie au format Hayagriva (propre à Typst)
    └── bibliographie.bib      ← bibliographie au format BibTeX (Zotero…)
```

Chaque fiche commence par une seule ligne, `#import "../../ressources/commun.typ": *`, qui lui donne accès au modèle, aux paquets et aux fonctions personnalisées. La version du paquet `starchy-junia` n'est écrite qu'à un endroit, dans `commun.typ`.

Le moteur du modèle (fonctions, modèles, mise en page) vit dans le paquet `starchy-junia` lui-même — importé dans `ressources/commun.typ` via `#import "@preview/starchy-junia:0.3.1": *`, il n'apparaît pas dans les fichiers du projet.

---

## Documentation

- **Référence complète** des paramètres et fonctions : [starchy-junia-0.3.1.pdf](https://codeberg.org/MathYeiv/starchy-junia/src/tag/v0.3.1/starchy-junia-0.3.1.pdf).
- **Guide pour les assistants IA** (facultatif) : [AGENTS.md](https://codeberg.org/MathYeiv/starchy-junia/src/tag/v0.3.1/docs/AGENTS.md) décrit le fonctionnement du modèle (arborescence, paramètres, tâches courantes, erreurs fréquentes) pour un assistant IA. Il n'est pas inclus dans les projets : à joindre à la conversation, ou à copier à la racine de son projet, si on le souhaite.
- **Tests** (pour les contributeurs) : `tests/` contient une suite de tests fonctionnels à lancer sur plusieurs versions de Typst avant chaque publication — voir [tests/README.md](https://codeberg.org/MathYeiv/starchy-junia/src/tag/v0.3.1/tests/README.md).
- **Mise à jour depuis la version 0.2.x** : voir la note de migration du [CHANGELOG](https://codeberg.org/MathYeiv/starchy-junia/src/tag/v0.3.1/CHANGELOG.md).

---

## Licence

[MIT-0](./LICENSE) (MIT No Attribution) — MathYeiv : le modèle et les documents créés à partir de lui peuvent être utilisés, modifiés et diffusés sans obligation de mention ni de copie de la licence.

Dépôt : [codeberg.org/MathYeiv/starchy-junia](https://codeberg.org/MathYeiv/starchy-junia)
