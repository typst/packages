// Exemple sprig 0.2.0 — affiche bilingue « Calcul littéral » (fr / ar).
// Sélecteur : #let langue = "fr" ou "ar".

#import "@preview/sprig:0.2.0": *

// Choisir la langue : "fr" ou "ar"
#let langue = "fr"

#set page(
  width: 29.7cm,
  height: 21cm,
  margin: 0.6cm,
)

#set text(
  size: 10pt,
  font: (
    "Estedad", "Amiri", "Arial"
  ),
)

// Disposition calquée sur l'affiche « Calcul littéral » : hub rouge au centre,
// 4 pastilles en diagonale (dist: 5.5), feuilles épinglées par cap (at:) et
// distance (dist:) autour de leur pastille. En RTL, sprig miroite le tout.
// Ordre des branches = ordre de l'anneau (135°, 225°, 315°, 45° en LTR).

// -----------------------------------------------------------------------------
// Textes français
// -----------------------------------------------------------------------------

#let carte-fr = mindmap(
  [*Calcul littéral*],

  dir: ltr,
  hub-shape: "rounded",
  hub-fill: rgb("#ef3d22"),
  hub-text: white,
  hub-ink: rgb("#ef3d22"),

  leaf-width: 4.8,
  min-width: 2.2,
  dist: 4.6,
  spread: 360deg,
  start: 135deg,
  bend: 0.0,
  wave: 0.0,
  weight: 1.1pt,
  theme: "poster",

  palette: (
    rgb("#ca3d8f"),   // Vocabulaire (haut-gauche)
    rgb("#20aeb0"),   // Pourquoi ? (bas-gauche)
    rgb("#e48a2d"),   // Comment ? (bas-droite)
    rgb("#5caa55"),   // Propriétés (haut-droite)
  ),

  branch(
    title: [*Vocabulaire*],
    child-width: 4.6,
    children: (
      branch(title: [*Égalité vraie*], at: "north-west", dist: 6.7)[
        Solution de l'équation
      ],
      branch(title: [*Factoriser*], at: "west", dist: 5.4)[
        Somme → Produit \
        $7 times 4 + 7 times 5 = 7 times (4 + 5)$
      ],
      branch(title: [*Développer*], at: "south-west", dist: 6.2)[
        Produit → Somme \
        $9 times (8 + 4) = 9 times 8 + 9 times 4$
      ],
    ),
  ),

  branch(
    title: [*Pourquoi ?*],
    child-width: 4.2,
    children: (
      branch(title: [*Démontrer*], at: "west", dist: 7.7)[
        toujours vrai
      ],
      branch(title: [*Décrire*], at: "south-west", dist: 7.0)[
        une façon de calculer
      ],
      branch(title: [*Trouver*], at: "south", dist: 4.6)[
        des nombres inconnus
      ],
    ),
  ),

  branch(
    title: [*Comment ?*],
    child-width: 4.2,
    children: (
      branch(title: [*Réduire*], at: "east", dist: 8.1)[
        $3x times 2x = 6x^2$ \
        $3x + 2x = 5x$
      ],
      branch(title: [*Trouver*], at: "east", dist: 7.7, dy: -2.5)[
        un contre-exemple
      ],
      branch(title: [*Tâtonner*], at: "east", dist: 7.35, dy: -5.15)[
        Représenter (balancer, \
        schéma en barre)
      ],
      branch(at: "south", dist: 4.35, dx: 2.75)[
        $a + x = b$ \
        $x = b - a$
      ],
      branch(at: "south", dist: 5.0, dx: -1.85)[
        $a x = b$ \
        $x = b/a$
      ],
    ),
  ),

  branch(
    title: [*Propriétés*],
    child-width: 4.6,
    children: (
      branch(title: [*Distributivité*], at: "north", dist: 3.7)[
        $k (a + b) = k a + k b$ \
        $k (a - b) = k a - k b$
      ],
      branch(at: "north-east", dist: 7.6)[
        $a times b = b times a$ \
        $a + b = b + a$
      ],
      branch(at: "east", dist: 7.4)[
        × et ÷ prioritaires \
        sur + et −
      ],
    ),
  ),
)

// -----------------------------------------------------------------------------
// Textes arabes
// -----------------------------------------------------------------------------

#let carte-ar = mindmap(
  [*الحساب الحرفي*],

  dir: rtl,
  hub-shape: "rounded",
  hub-fill: rgb("#ef3d22"),
  hub-text: white,
  hub-ink: rgb("#ef3d22"),

  leaf-width: 4.8,
  min-width: 2.2,
  dist: 4.6,
  spread: 360deg,
  start: 45deg,
  bend: 0.0,
  wave: 0.0,
  weight: 1.1pt,
  theme: "poster",

  palette: (
    rgb("#ca3d8f"),
    rgb("#20aeb0"),
    rgb("#e48a2d"),
    rgb("#5caa55"),
  ),

  branch(
    title: [*المفردات*],
    child-width: 4.6,
    children: (
      branch(title: [*مساواة صحيحة*], at: "north-east", dist: 6.7)[
        حل المعادلة
      ],
      branch(title: [*التحليل إلى عوامل*], at: "east", dist: 5.4)[
        تحويل مجموع إلى جداء \
        $7 times 4 + 7 times 5 = 7 times (4 + 5)$
      ],
      branch(title: [*النشر*], at: "south-east", dist: 6.2)[
        تحويل جداء إلى مجموع \
        $9 times (8 + 4) = 9 times 8 + 9 times 4$
      ],
    ),
  ),

  branch(
    title: [*لماذا؟*],
    child-width: 4.2,
    children: (
      branch(title: [*البرهان*], at: "east", dist: 7.7)[
        النتيجة صحيحة دائما
      ],
      branch(title: [*الوصف*], at: "south-east", dist: 7.0)[
        وصف طريقة الحساب
      ],
      branch(title: [*إيجاد المجهولات*], at: "south", dist: 4.6)[
        إيجاد الأعداد المجهولة
      ],
    ),
  ),

  branch(
    title: [*كيف؟*],
    child-width: 4.2,
    children: (
      branch(title: [*التبسيط*], at: "west", dist: 8.1)[
        $3x times 2x = 6x^2$ \
        $3x + 2x = 5x$
      ],
      branch(title: [*إيجاد مثال مضاد*], at: "west", dist: 7.7, dy: -2.5)[
        إيجاد مثال يناقض القاعدة
      ],
      branch(title: [*التجريب*], at: "west", dist: 7.35, dy: -5.15)[
        تمثيل العملية \
        باستعمال ميزان أو شريط
      ],
      branch(at: "south", dist: 4.35, dx: -2.75)[
        $a + x = b$ \
        $x = b - a$
      ],
      branch(at: "south", dist: 5.0, dx: 1.85)[
        $a x = b$ \
        $x = b/a$
      ],
    ),
  ),

  branch(
    title: [*الخصائص*],
    child-width: 4.6,
    children: (
      branch(title: [*خاصية التوزيع*], at: "north", dist: 3.7)[
        $k (a + b) = k a + k b$ \
        $k (a - b) = k a - k b$
      ],
      branch(at: "north-west", dist: 7.6)[
        $a times b = b times a$ \
        $a + b = b + a$
      ],
      branch(at: "west", dist: 7.4)[
        الضرب والقسمة قبل \
        الجمع والطرح
      ],
    ),
  ),
)

// -----------------------------------------------------------------------------
// Rendu
// -----------------------------------------------------------------------------

#if langue == "ar" {
  carte-ar
} else {
  carte-fr
}
