# Arabic Exam Kit

**Arabic Exam Kit** est un package Typst pour construire des contrôles, examens,
feuilles d’exercices et supports de mathématiques en arabe — en version nette
ou dessinée à la main (*rough*).

Il rassemble plusieurs familles cohérentes :

- cartes pédagogiques et composants « mathématiques faciles » ;
- boîtes d’exercices numérotées ;
- modèle d’examen rouge à rubans superposés ;
- modèle sobre noir et blanc inspiré de CTAN `sexam` ;
- modèle 2AM bleu étoilé ;
- fiche pédagogique complète et responsive `worksheet(...)` ;
- figures géométriques `ctz-euclide` ;
- taches de café, éclaboussures et décorations vectorielles.

> Le package est pensé pour les débutants : chaque famille a un style commun,
> des dimensions relatives, un exemple complet et une version rough.

---

## Sommaire

1. [Installation](#installation)
2. [Premier document](#premier-document)
3. [Les deux modes : normal et rough](#les-deux-modes--normal-et-rough)
4. [Choisir une famille](#choisir-une-famille)
5. [Examen rouge](#examen-rouge-à-rubans)
6. [Modèle sexam noir et blanc](#modèle-sexam-noir-et-blanc)
7. [Modèle 2AM bleu étoilé](#modèle-2am-bleu-étoilé)
8. [Figures géométriques](#figures-géométriques)
9. [Boîtes d'exercices et effets](#boîtes-deffercices-et-effets)
10. [FAQ de dépannage](#faq-de-dépannage)

La documentation détaillée et imprimable est disponible dans :

- [`docs/guide.typ`](docs/guide.typ) / `guide.pdf` — guide débutant français enrichi ;
- [`docs/guide-ar.typ`](docs/guide-ar.typ) / `guide-ar.pdf` — الدليل العربي للمبتدئ ;
- [`docs/gallery.typ`](docs/gallery.typ) / `gallery.pdf` — galerie visuelle de toutes les familles.

---

## Installation

### Option A — tester depuis ce dossier

Dans un fichier placé dans `examples/` ou à côté de ce package :

```typ
#import "../src/lib.typ": *
```

C’est la méthode la plus simple pendant l’apprentissage : aucun réglage Typst
n’est nécessaire.

### Option B — installation locale comme un vrai package

Copiez ce dossier dans le répertoire local de Typst :

```sh
mkdir -p ~/.local/share/typst/packages/local/arabic-exam-kit
cp -R arabic-exam-kit \
  ~/.local/share/typst/packages/local/arabic-exam-kit/0.1.0
```

Puis, dans n’importe quel document Typst :

```typ
#import "@local/arabic-exam-kit:0.1.0": *
```

Sous Windows, le dossier local est généralement situé dans
`%APPDATA%/typst/packages/local/`. Si votre système utilise `XDG_DATA_HOME`,
remplacez `~/.local/share` par `$XDG_DATA_HOME`.

### Police arabe

Le package fournit **Amiri** dans `assets/fonts/`. Pour obtenir le rendu arabe
des exemples, compilez avec :

```sh
typst compile --font-path assets/fonts examples/01-minimal-wexam.typ
```

Dans le document, activez la police :

```typ
#set text(font: "Amiri", lang: "ar")
```

---

## Premier document

Copiez ce fichier minimal :

```typ
#import "@local/arabic-exam-kit:0.1.0": *

#set page(paper: "a4", margin: 1cm)
#set text(font: "Amiri", lang: "ar", size: 12pt)

#let wx = wexam-style(dir: rtl)

#wexam-header(..wx)
#v(4mm)
#wexam-exercise-heading(title: [التمرين الأول], points: [3 ن], ..wx)
#wexam-question(number: 1, ..wx)[
  احسب $m = (+5) + (-7)$.
]
```

Les arguments entre parenthèses règlent le composant ; le contenu entre
crochets est le texte de l’exercice.

> `mf-card[...]` est désormais RTL par défaut : un texte arabe nu est donc
> aligné à droite. Pour une carte latine, écrire explicitement `dir: ltr`.

### Lire une fonction Typst

```typ
#wexam-question(number: 1, ..wx)[
  احسب $m = (+5) + (-7)$.
]
```

- `wexam-question` est le nom du composant ;
- `number: 1` affiche la petite boîte numérotée ;
- `..wx` applique un style commun ;
- `[...]` est le contenu affiché dans la question.

---

## Fiche pédagogique responsive complète

La fonction `worksheet(...)` inclut la fiche pédagogique complète : bande
d'identité, zone de contexte, barres de compétences, tableau de déroulement et
encadré de notes pédagogiques. Contrairement à une image, tout le contenu est
vectoriel et le design se redimensionne pour A4, A5, Letter ou un format
personnalisé.

```typ
#import "@local/arabic-exam-kit:0.1.0": *

#set page(paper: "a4", margin: 0pt)
#set text(font: "Amiri", lang: "ar")

#worksheet(mode: "normal")
// ou : #worksheet(mode: "rough", roughness: 1.25)
```

Les marges internes de la fiche se règlent sans toucher aux coordonnées :

```typ
#worksheet(
  mode: "rough",
  roughness: 1.15,
  outer-x: 4%,
  outer-y: 3.5%,
)
```

L'exemple complet est `examples/05-pedagogical-sheet.typ`.

---

## Les deux modes : normal et rough

Chaque famille accepte un dictionnaire de style :

```typ
#let clean = wexam-style(mode: "normal", dir: rtl, seed: 10)
#let hand  = wexam-style(mode: "rough", roughness: 1.15, dir: rtl, seed: 10)
```

| Paramètre | Rôle |
|---|---|
| `mode: "normal"` | règles nettes, rendu d’impression classique |
| `mode: "rough"` | contours légèrement manuscrits |
| `roughness: 0.7` | effet très discret |
| `roughness: 1.15` | réglage conseillé |
| `roughness: 1.8` | effet nettement dessiné à la main |
| `seed` | stabilise le dessin rough d’une compilation à l’autre |
| `dir: rtl` | arabe / contenu aligné à droite |
| `dir: ltr` | français, anglais ou contenu latin |

Le texte reste lisible : seul le tracé vectoriel devient irrégulier.

---

## Choisir une famille

| Besoin | Composants à utiliser |
|---|---|
| Contrôle rouge à rubans | `exam-header`, `exam-exercise-box`, `exam-circle-geometry` |
| Sujet sobre type lycée | `sexam-header`, `sexam-exercise-heading`, `sexam-part` |
| Sujet 2AM bleu étoilé | `wexam-header`, `wexam-question`, `wexam-house-figure` |
| Fiche pédagogique structurée | `worksheet(mode: "normal" | "rough")` |
| Cartes pédagogiques | `mf-card`, `mf-grid-box`, `mf-choice`, `mf-ribbon-flat` |
| Exercices colorés numérotés | `exercise-1` à `exercise-10` |
| Effets décoratifs | `mf-coffee-stain`, `mf-coffee-blot`, `mf-paint-splat` |

---

## Examen rouge à rubans

```typ
#let exam = exam-style(mode: "normal", dir: rtl)

#exam-page-frame(height: 95%, ..exam)[
  #exam-header(..exam)
  #v(.8mm)
  #exam-meta-line()
  #v(4mm)

  #exam-exercise-box(title: [التمرين الأول], points: [3 ن], ..exam)[
    اكتب العدد $2025 / 100$ كتابة عشرية.
  ]
]
```

### Points importants

- `exam-page-frame(height: 95%)` donne un cadre couvrant presque toute la
  page ; laissez le footer à l’extérieur si vous désirez reproduire les sujets
  algériens classiques.
- `exam-header` accepte `school`, `year`, `title`, `level-label` et
  `level-value`.
- `exam-meta-line` place la durée à gauche et l’avertissement au centre.
- `arrow-gap: 3mm` règle la séparation colorée des flèches.

Pour une figure :

```typ
#exam-circle-geometry(width: 42%, ..exam)
```

Cette figure utilise `ctz-euclide` pour les points, segments, cercle, angle
droit et doubles marques d’égalité.

---

## Modèle sexam noir et blanc

```typ
#let sx = sexam-style(mode: "normal", dir: rtl)

#sexam-page(
  height: 100%,
  footer: sexam-footer(
    footer-left: [اقلب الورقة],
    footer-center: [صفحة 1 من 2],
    footer-right: [ركز جيدًا],
    ..sx,
  ),
  ..sx,
)[
  #sexam-header(..sx)
  #v(1cm)
  #sexam-exercise-heading(title: [التمرين الأول], points: [6 نقاط], ..sx)
  #sexam-part(score: "2", ..sx)[
    اكتب الحل بالتفصيل.
  ]
]
```

Les petites cases de barème sont automatiquement composées avec `ن` à gauche
du nombre. Donnez seulement le nombre :

```typ
#sexam-part(score: "2")[نص السؤال]
```

---

## Modèle 2AM bleu étoilé

```typ
#let wx = wexam-style(mode: "normal", dir: rtl)

#wexam-header(
  school: [متوسطة : عيسات إيدير],
  level: [🎓 المستوى : السنة ② متوسط],
  title: [اختبار الفصل الثاني في الرياضيات],
  year: [2023 – 2024],
  duration: [المدة : 02 سا],
  ..wx,
)
#v(5mm)
#wexam-exercise-heading(title: [التمرين الأول], points: [3 ن], ..wx)
#wexam-question(number: 1, ..wx)[
  احسب العبارة $m = (+5) + (-7)$.
]
```

### Numéros de question

```typ
#wexam-question(number: 3)[
  اشرح خطوات الإنشاء.
]
```

Pour masquer le numéro, omettez l’argument :

```typ
#wexam-question[
  سؤال أو ملاحظة دون رقم.
]
```

---

## Figures géométriques

Le package télécharge automatiquement `@preview/ctz-euclide:0.2.0` au premier
build qui utilise une figure.

```typ
#wexam-angle-figure(width: 35%, mode: "rough", roughness: 1.15)
#wexam-house-figure(width: 48%)
#exam-circle-geometry(width: 42%)
```

Les figures restent des constructions vectorielles modifiables : elles ne sont
pas des images PDF ou PNG.

---

## Boîtes d’exercices et effets

### Exercices numérotés

```typ
#let cards = exercise-style(mode: "normal", color_mode: "color", dir: rtl)

#exercise-3(title: [ضرب قوى لها نفس الأساس], ..cards)[
  احسب: $2^3 times 2^5 = dots$
]
```

### Taches de café

```typ
#mf-coffee-stain(
  size: 4.5cm,
  variant: "ring",
  rotation: -12deg,
)

#mf-coffee-blot(width: 2cm, height: 3cm)
```

### Éclaboussures sélectionnables

```typ
#mf-paint-splat(
  model: 5,      // de 1 à 9
  width: 5cm,
  height: 4cm,
  fill: rgb("#008DAA"),
)
```

---

## FAQ de dépannage

### « unknown font family: Amiri »

Ajoutez le chemin vers les polices :

```sh
typst compile --font-path assets/fonts mon-fichier.typ
```

### Les nombres `ن2` s’inversent

Avec `sexam-part`, donnez le score comme une chaîne numérique :

```typ
#sexam-part(score: "2")[...]
```

Le package place le `ن` et le nombre dans deux boîtes distinctes pour éviter
les ambiguïtés BiDi.

### Une figure ne compile pas

Vérifiez la connexion lors du premier build : `ctz-euclide` et CeTZ doivent
être téléchargés une seule fois. Ensuite, relancez simplement la compilation.

### Le contenu sort d’une page

1. réduisez `size:` ou la taille globale du texte ;
2. utilisez `width: 90%` pour une figure ;
3. ajoutez `#pagebreak()` avant le grand exercice ;
4. évitez les longueurs de page fixes dans un composant réutilisable.

---

## Exemples prêts à compiler

| Fichier | Contenu |
|---|---|
| `examples/01-minimal-wexam.typ` | premier sujet bleu très simple |
| `examples/02-red-exam.typ` | cadre rouge et rubans d’exercices |
| `examples/03-sexam.typ` | sujet noir et blanc avec scores `ن` |
| `examples/04-effects.typ` | café, éclaboussures et cadres décoratifs |
| `examples/05-pedagogical-sheet.typ` | fiche pédagogique responsive complète |
| `docs/guide.typ` | manuel PDF illustré pour débuter |

Consultez aussi les fichiers `demo-*.typ` du projet parent pour des sujets
complets de plusieurs pages. 

FERGOUS Abdelhak.
