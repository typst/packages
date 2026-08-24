// Arabic Exam Kit — Guide débutant Typst
#import "../src/lib.typ": *

#set page(paper: "a4", margin: (x: 1.6cm, y: 1.45cm), numbering: "1 / 1")
#set text(font: "Amiri", lang: "fr", dir: ltr, size: 11.5pt, fill: rgb("#17212A"))
#set par(leading: .45em, justify: true)
#set heading(numbering: "1.")

#let code(source) = block(
  width: 100%,
  fill: rgb("#F4F7FA"),
  stroke: .5pt + rgb("#BFD0DE"),
  radius: 3pt,
  inset: .75em,
  raw(source, block: true, lang: "typst"),
)

#align(center)[
  #text(size: 25pt, weight: "bold", fill: wexam-palette.blue-dark)[Arabic Exam Kit]
  #v(.4em)
  #text(dir: rtl, size: 16pt)[دليل عملي للمبتدئ في Typst]
  #v(1em)
  #mf-paint-splat(model: 9, width: 4.7cm, height: 3.7cm)
]

#v(1.2em)

هذا الدليل يشرح، pas à pas, comment écrire un premier sujet de mathématiques
en arabe, choisir un modèle et activer le tracé rough. Tous les exemples sont
compilables avec Typst 0.15.1.

#v(1em)
#text(weight: "bold")[Objectif de ce guide]

- importer le package ;
- choisir une famille de composants ;
- créer une première question ;
- passer au mode rough ;
- utiliser les figures `ctz-euclide` ;
- éviter les erreurs courantes de direction RTL et de police.

#pagebreak()

#outline(title: [Table des matières])

#pagebreak()

= Installation et premier fichier

Placez le dossier du package dans le dossier local de Typst, puis importez-le :

```typst
#import "@local/arabic-exam-kit:0.1.0": *

#set page(paper: "a4", margin: 1cm)
#set text(font: "Amiri", lang: "ar", size: 12pt)
```

Pendant le développement, l’import relatif est plus simple :

```typst
#import "../src/lib.typ": *
```

== Une première question 2AM

```typst
#let wx = wexam-style(mode: "normal", dir: rtl)

#wexam-header(..wx)
#v(4mm)
#wexam-exercise-heading(title: [التمرين الأول], points: [3 ن], ..wx)
#wexam-question(number: 1, ..wx)[
  احسب $m = (+5) + (-7)$.
]
```

#wexam-header(
  school: [متوسطة : مثال],
  level: [🎓 المستوى : السنة ② متوسط],
  title: [مثال مبسط],
  year: [2024 – 2025],
  duration: [المدة : 02 سا],
)
#v(3mm)
#wexam-exercise-heading(title: [التمرين الأول], points: [3 ن])
#wexam-question(number: 1)[احسب $m = (+5) + (-7)$.]

#pagebreak()

= Styles, RTL et rough

Un dictionnaire de style évite de répéter les mêmes paramètres :

```typst
#let clean = wexam-style(mode: "normal", dir: rtl, seed: 42)
#let rough = wexam-style(mode: "rough", roughness: 1.15, dir: rtl, seed: 42)
```

Le paramètre `seed` rend le rough stable : le même document génère le même
tracé à chaque compilation. La direction `rtl` aligne le contenu arabe à droite
et place les composants selon le sens logique.

#grid(columns: (1fr, 1fr), column-gutter: 8mm,
  [
    #text(weight: "bold")[Normal]
    #v(2mm)
    #wexam-exercise-heading(title: [التمرين الأول], points: [3 ن])
  ],
  [
    #text(weight: "bold")[Rough]
    #v(2mm)
    #wexam-exercise-heading(title: [التمرين الأول], points: [3 ن], mode: "rough", roughness: 1.15)
  ],
)

== Réglages rough

| Valeur | Usage |
|---|---|
| `0.6` | très discret |
| `1.0` | manuscrit léger |
| `1.15` | réglage conseillé |
| `1.8` | volontairement expressif |

#pagebreak()

= Trois modèles de sujets

== Examen rouge à rubans

Utilisez-le pour une fiche dynamique avec cadres rouges :

```typst
#let exam = exam-style(mode: "normal", dir: rtl)
#exam-header(..exam)
#exam-exercise-box(title: [التمرين الأول], points: [3 ن], ..exam)[
  اكتب العدد $562,405$ كتابة عشرية.
]
```

== Sujet noir et blanc `sexam`

Le modèle `sexam` est adapté aux sujets de lycée sobres, avec barèmes dans la
marge gauche :

```typst
#let sx = sexam-style(dir: rtl)
#sexam-exercise-heading(title: [التمرين الأول], points: [6 نقاط], ..sx)
#sexam-part(score: "2", ..sx)[
  اكتب الحل بالتفصيل.
]
```

Dans `sexam-part`, donnez #text(weight: "bold")[seulement le nombre] du score. Le package imprime
le `ن` à gauche du nombre dans la boîte sans ambiguïté BiDi.

== Modèle 2AM bleu

Le modèle `wexam` combine bande étoilée, pilules et cases cyan. C’est le modèle
le plus décoratif de la collection.

#pagebreak()

= Figures géométriques

Les figures intégrées utilisent `ctz-euclide`. Elles restent des objets
vectoriels : un PDF ou une impression restent parfaitement nets.

```typst
#let fig = wexam-style(mode: "rough", roughness: 1.15)
#wexam-angle-figure(width: 38%, ..fig)
#wexam-house-figure(width: 50%, ..fig)
#exam-circle-geometry(width: 42%, ..fig)
```

#grid(columns: (1fr, 1fr), column-gutter: 10mm,
  [#wexam-angle-figure(width: 100%)],
  [#wexam-house-figure(width: 100%)],
)

Le mode rough transmet `sketchy: true` à `ctz-euclide`. Les points, droites,
angles et marques de segments restent donc des constructions, même dans la
version dessinée à la main.

#pagebreak()

= Exercices, effets et décoration

== Cartes numérotées

```typst
#let cards = exercise-style(color_mode: "color", dir: rtl)
#exercise-3(title: [ضرب قوى لها نفس الأساس], ..cards)[
  احسب $2^3 times 2^5 = dots$.
]
```

== Café et éclaboussures

```typst
#mf-coffee-stain(size: 4cm, variant: "ring")
#mf-coffee-blot(width: 2cm, height: 3cm)
#mf-paint-splat(model: 5, width: 5cm, height: 4cm)
```

#align(center)[
  #mf-coffee-stain(size: 3.7cm, variant: "ring")
  #h(1cm)
  #mf-paint-splat(model: 5, width: 4.6cm, height: 3.6cm)
]

== Cases de réponse et papier quadrillé

`mf-grid-box`, `mf-perforated-box`, `mf-choice` et `mf-spiral-box` sont utiles
pour les contrôles avec zones de réponse. Les recettes suivantes montrent
exactement le code nécessaire, suivi du rendu correspondant.

#pagebreak()

= Recettes de boîtes : code et rendu

== Carte avec titre

```typst
#mf-card[
  #mf-title(dir: rtl)[بطاقة رياضيات]
  #v(.7em)
  محتوى عربي داخل بطاقة قابلة لإعادة الاستعمال.
]
```

#mf-card[
  #mf-title(dir: rtl)[بطاقة رياضيات]
  #v(.7em)
  محتوى عربي داخل بطاقة قابلة لإعادة الاستعمال.
]

`mf-card[...]` est RTL par défaut : le texte arabe est naturellement aligné à
 droite. Pour une carte latine, utiliser `#mf-card(dir: ltr)[English text]`.

#v(7mm)

== Papier quadrillé

```typst
#mf-grid-box(grid-columns: 20, dir: rtl)[
  اكتب خطوات الحل هنا.
]
```

#mf-grid-box(grid-columns: 20, dir: rtl)[
  اكتب خطوات الحل هنا.
]

#pagebreak()

== Papier perforé et choix multiple

```typst
#mf-perforated-box(perforation-count: 8, dir: rtl)[
  سؤال على ورقة مثقبة.
]

#mf-choice("أ", dir: rtl)[
  الإجابة الأولى.
]
```

#mf-perforated-box(perforation-count: 8, dir: rtl)[
  سؤال على ورقة مثقبة.
]
#v(5mm)
#mf-choice("أ", dir: rtl)[
  الإجابة الأولى.
]

#v(8mm)

== Page à spirale

```typst
#mf-spiral-box(coil-count: 8, dir: rtl)[
  دفتر حل مزود بحلقات.
]
```

#mf-spiral-box(coil-count: 8, dir: rtl)[
  دفتر حل مزود بحلقات.
]

#pagebreak()

== Exercice numéroté

```typst
#let cards = exercise-style(color_mode: "color", dir: rtl)
#exercise-3(title: [ضرب قوى لها نفس الأساس], ..cards)[
  احسب $2^3 times 2^5 = dots$.
]
```

#let recipe-cards = exercise-style(color_mode: "color", dir: rtl)
#exercise-3(title: [ضرب قوى لها نفس الأساس], ..recipe-cards)[
  احسب $2^3 times 2^5 = dots$.
]

Pour changer le numéro depuis le style commun :

```typst
#let labelled = exercise-style(number: "أ", color_mode: "color", dir: rtl)
#exercise-3(title: [اختبار], ..labelled)[احسب $2^3 times 2^5$.]
```

Pour changer un seul numéro sans affecter les autres cartes :

```typst
#exercise-3(number: "✓", title: [اختبار], color_mode: "color", dir: rtl)[
  احسب $2^3 times 2^5$.
]
```

#v(8mm)

== Cadre de limailles

```typst
#mf-magnetic-filings-box(dir: rtl)[
  المجال المغناطيسي.
]
```

#mf-magnetic-filings-box(dir: rtl)[
  المجال المغناطيسي.
]

#pagebreak()

== Café et éclaboussure

```typst
#mf-coffee-stain(size: 3.5cm, variant: "ring")
#mf-paint-splat(model: 5, width: 4.5cm, height: 3.5cm)
```

#align(center)[
  #mf-coffee-stain(size: 3.5cm, variant: "ring")
  #h(1cm)
  #mf-paint-splat(model: 5, width: 4.5cm, height: 3.5cm)
]

Les mêmes composants acceptent `mode: "rough"`, `roughness:` et `seed:`.

#pagebreak()

= Fiche pédagogique complète

La fonction `worksheet(...)` n'est pas une boîte isolée : elle compose une
fiche pédagogique complète responsive. Elle conserve son propre système de
géométrie virtuelle puis se redimensionne uniformément dans l'espace de la
page. C'est donc le bon choix pour une fiche de cours entière, pas seulement
pour une question d'examen.

```typst
#import "@local/arabic-exam-kit:0.1.0": *

#set page(paper: "a4", margin: 0pt)
#set text(font: "Amiri", lang: "ar")

#worksheet(mode: "normal")
```

Pour obtenir la version manuscrite :

```typst
#worksheet(
  mode: "rough",
  roughness: 1.25,
  outer-x: 3.8%,
  outer-y: 3.8%,
)
```

`outer-x` et `outer-y` sont des marges relatives à la page. Utilisez-les au
lieu de modifier les coordonnées internes. L'exemple complet
`examples/05-pedagogical-sheet.typ` est prêt à compiler et son PDF est fourni
avec le package.

== Aperçu de la fiche complète

La page suivante est produite directement par `worksheet(...)` : elle fait
partie du package et non d'une image collée dans la documentation.

#pagebreak()
#worksheet(mode: "normal")

#pagebreak()

= Dépannage et bonnes pratiques

== Police arabe absente

Si Typst affiche un avertissement sur Amiri, compilez ainsi :

```typst
typst compile --font-path assets/fonts examples/01-minimal-wexam.typ
```

== Les composants dépassent

- réduisez `width:` à `90%` ;
- diminuez la taille de texte globale ;
- ajoutez `#pagebreak()` avant une grande figure ;
- conservez des valeurs relatives (`%`, `em`) dans les composants réutilisables.

== Décimales arabes

Les exemples algériens du package utilisent la virgule :

```typ
$562,405$     // correct dans le style des sujets
$2,5 "m"$
```

== Checklist avant impression

1. compiler la version normale ;
2. compiler la version rough ;
3. vérifier les débordements de page ;
4. vérifier les notes `ن` et les séparateurs décimaux ;
5. imprimer une page de test en noir et blanc si nécessaire.

#align(center)[#text(size: 15pt, weight: "bold", fill: wexam-palette.blue-dark)[Bonne création avec Typst !]]
