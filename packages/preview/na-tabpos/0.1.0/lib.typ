// ======================================================================
// na-tabpos : جداول الإشارة والتغيّرات والوضع النسبي
// أنواع الأسطر في label : "s" إشارة (ومنها سطر الفرق f(x)-g(x)) ، "v" تغيّرات ، "p" الوضع النسبي بالأقواس
//
// الشيفرة أدناه مبنية على حزمة vartable 0.2.5 (المؤلف : Le_Foucheur ، الرخصة : MIT)
// https://github.com/Le-foucheur/Typst-VarTable
// الإضافات : نوع السطر "p" (راجع _pos-zero و pos-rows) ، الخيار diff-height ،
// وكلمات "فوق/تحت/يقطع/في النقطة" التي تتبع لغة المستند تلقائيًا.
// ======================================================================
#import "@preview/cetz:0.5.3"

#let _prochain-signe(tab_signe, j) = {
  // Cherche le prochain élément non vide "()" dans ce sous tableau
  let indice = j + 1
  while indice < tab_signe.len() and type(tab_signe.at(indice)) == array and tab_signe.at(indice).len() == 0 {
    indice += 1
  }
  indice
}

#let _prochain-ele(ligne, j) = {
  // Cherche le prochain élément non vide "()" dans ce sous tableau
  let indice = j + 1
  while indice < ligne.len() and ligne.at(indice).len() == 0 {
    indice += 1
  }
  indice
}

#let _prochainne-baliseh(ligne, j) = {
  // Renvoie l’indice de la balise de fin "H" du hachurage
  let indice = j + 1
  while indice < ligne.len() and ligne.at(indice).len() == 0 {
    indice += 1
  }
  indice
}

#let _yatilhach(ligne, j) = {
  // Renvoie vrais s’il y a une zone haché jute avant, non sinon
  let indice = j - 1
  while indice >= 0 and type(ligne.at(indice)) == array and ligne.at(indice).len() == 0 {
    indice -= 1
  }
  if "h" == ligne.at(indice) or "|h" == ligne.at(indice) or "h|" == ligne.at(indice) or "|h|" == ligne.at(indice) {
    true
  } else {
    false
  }
}

#let _coord-fleche(i, j, indef, proch_indef, ligne, coordX, coordY) = {
  // Caclule les points de départ et d’arrivé des flèches

  // On cherche des flèches qui pointe toujours vers le centre du prochain élément et qui parte du centre de l’élément courant
  // De plus on ne veut pas que les flèches soit présente dans une zone réctangulaire autours des éléments, qui dépent de la taille de l’élément

  let indice_proch_ele = _prochain-ele(ligne, j)

  let h = measure(ligne.at(j).last()).height.mm() / 10.65
  let l = measure(ligne.at(j).last()).width.mm() / 10.65

  let n = (
    measure(
      ligne
        .at(indice_proch_ele)
        .at(if proch_indef {
          if (
            ligne.at(indice_proch_ele).at(1) == "||"
              or ligne.at(indice_proch_ele).at(1) == "h"
              or ligne.at(indice_proch_ele).at(1) == "|h"
              or ligne.at(indice_proch_ele).at(1) == "H"
              or ligne.at(indice_proch_ele).at(1) == "H|"
          ) { 2 } else { 3 }
        } else { 1 }),
    )
      .height
      .mm()
      / 10.65
  )
  let d = (
    measure(
      ligne
        .at(indice_proch_ele)
        .at(if proch_indef {
          if (
            ligne.at(indice_proch_ele).at(1) == "||"
              or ligne.at(indice_proch_ele).at(1) == "h"
              or ligne.at(indice_proch_ele).at(1) == "|h"
              or ligne.at(indice_proch_ele).at(1) == "H"
              or ligne.at(indice_proch_ele).at(1) == "H|"
          ) { 2 } else { 3 }
        } else { 1 }),
    )
      .width
      .mm()
      / 10.65
  )

  h += 0.25
  l += 0.25
  d += 0.25
  n += 0.25

  let (x, y) = (
    //les coordonées de l'element
    coordX.at(j).at(0) + if indef and j != 0 { l / 2 + 0.17 } else if indef and j == 0 { 0.3 } else { 0 },
    coordY.at(i).at(0)
      + if ligne
        .at(j)
        .at(if indef {
          if (
            ligne.at(j).at(1) == "||"
              or ligne.at(j).at(1) == "h"
              or ligne.at(j).at(1) == "|h"
              or ligne.at(j).at(1) == "H"
              or ligne.at(j).at(1) == "H|"
          ) { 0 } else { 1 }
        } else { 0 })
        == top {
        (
          coordY.at(i).at(1) / 2
            - 0.3
            - measure(
              ligne
                .at(j)
                .at(if ligne.at(j).len() > 2 {
                  if (
                    ligne.at(j).at(1) == "||"
                      or ligne.at(j).at(1) == "h"
                      or ligne.at(j).at(1) == "|h"
                      or ligne.at(j).at(1) == "H"
                      or ligne.at(j).at(1) == "H|"
                  ) {
                    2
                  } else {
                    3
                  }
                } else { 1 }),
            )
              .height
              .mm()
              / (2 * 10.65)
        )
      } else if ligne
        .at(j)
        .at(if indef {
          if (
            ligne.at(j).at(1) == "||"
              or ligne.at(j).at(1) == "h"
              or ligne.at(j).at(1) == "|h"
              or ligne.at(j).at(1) == "H"
              or ligne.at(j).at(1) == "H|"
          ) { 0 } else { 1 }
        } else { 0 })
        == bottom {
        (
          -coordY.at(i).at(1) / 2
            + 0.3
            + measure(
              ligne
                .at(j)
                .at(if ligne.at(j).len() > 2 {
                  if (
                    ligne.at(j).at(1) == "||"
                      or ligne.at(j).at(1) == "h"
                      or ligne.at(j).at(1) == "|h"
                      or ligne.at(j).at(1) == "H"
                      or ligne.at(j).at(1) == "H|"
                  ) {
                    2
                  } else {
                    3
                  }
                } else { 1 }),
            )
              .height
              .mm()
              / (2 * 10.65)
        )
      } else { 0 },
  )

  let (a, b) = (
    //les coordonées du prochain element
    coordX.at(indice_proch_ele).at(0) + if proch_indef and proch_indef != 0 { -d / 2 - 0.17 } else { 0 },
    coordY.at(i).at(0)
      + if ligne.at(indice_proch_ele).first() == top {
        (
          coordY.at(i).at(1) / 2
            - 0.3
            - measure(
              ligne
                .at(indice_proch_ele)
                .at(if ligne.at(indice_proch_ele).len() > 2 {
                  if (
                    ligne.at(indice_proch_ele).at(1) == "||"
                      or ligne.at(indice_proch_ele).at(1) == "h"
                      or ligne.at(indice_proch_ele).at(1) == "|h"
                      or ligne.at(indice_proch_ele).at(1) == "H"
                      or ligne.at(indice_proch_ele).at(1) == "H|"
                  ) {
                    2
                  } else {
                    3
                  }
                } else { 1 }),
            )
              .height
              .mm()
              / (2 * 10.65)
        )
      } else if ligne.at(indice_proch_ele).first() == bottom {
        (
          -coordY.at(i).at(1) / 2
            + 0.3
            + measure(
              ligne
                .at(indice_proch_ele)
                .at(if ligne.at(indice_proch_ele).len() > 2 {
                  if (
                    ligne.at(indice_proch_ele).at(1) == "||"
                      or ligne.at(indice_proch_ele).at(1) == "h"
                      or ligne.at(indice_proch_ele).at(1) == "|h"
                      or ligne.at(indice_proch_ele).at(1) == "H"
                      or ligne.at(indice_proch_ele).at(1) == "H|"
                  ) {
                    2
                  } else {
                    3
                  }
                } else { 1 }),
            )
              .height
              .mm()
              / (2 * 10.65)
        )
      } else { 0 },
  )

  let coefdir = (b - y) / (a - x)

  let f(t) = coefdir * (t - x) + y // équation de la droite entre les deux points
  let rf(t) = if calc.abs(coefdir) > 0.001 { 1 / coefdir * (t - y) + x } else { 0 } //équation réciproque

  let Ppoint = {
    if calc.abs(coefdir) > 0.001 {
      if calc.abs(f(x + l / 2) - y) < h / 2 {
        (
          x + l / 2,
          f(x + l / 2),
        )
      } else {
        (
          rf(y + h / 2 * coefdir / calc.abs(coefdir)),
          y + h / 2 * coefdir / calc.abs(coefdir),
        )
      }
    } else {
      (
        x + l / 2,
        y,
      )
    }
  }

  let Dpoint = {
    if calc.abs(coefdir) > 0.001 {
      if calc.abs(f(a + d / 2) - b) < n / 2 {
        (
          a - d / 2,
          f(a - d / 2),
        )
      } else {
        (
          rf(b - n / 2 * coefdir / calc.abs(coefdir)),
          b - n / 2 * coefdir / calc.abs(coefdir),
        )
      }
    } else {
      (
        a - d / 2,
        b,
      )
    }
  }

  (Ppoint, Dpoint)
}

// Quelque Tilling pour les hachurages
#let grille = tiling(size: (8pt, 8pt))[
  #place(line(start: (0%, 0%), end: (100%, 100%), stroke: .7pt))
  #place(line(start: (0%, 100%), end: (100%, 0%), stroke: .7pt))
]

#let nelines = tiling(size: (6pt, 6pt))[
  #place(line(start: (100%, 0%), end: (0%, 100%)))
  #place(line(start: (100%, -100%), end: (-100%, 100%)))
  #place(line(start: (200%, 0%), end: (0%, 200%)))
]

#let bignelines = tiling(size: (30pt, 30pt))[
  #place(line(start: (100%, 0%), end: (0%, 100%), stroke: 2pt))
  #place(line(start: (100%, -100%), end: (-100%, 100%), stroke: 2pt))
  #place(line(start: (200%, 0%), end: (0%, 200%), stroke: 2pt))
]

#let nwlines = tiling(size: (6pt, 6pt))[
  #place(line(start: (0%, 0%), angle: 45deg))
  #place(line(start: (-100%, 0%), angle: 45deg))
  #place(line(start: (100%, 0%), end: (200%, 100%)))
  #place(line(start: (100%, -100%), angle: -135deg))
]
#let hatch = tiling(size: (7pt, 7pt))[
  #place(polygon.regular(vertices: 6, size: 6.5pt, stroke: .6pt))
]

#let etoile = tiling(size: (7pt, 7pt))[
  #place(dy: 0.7mm, rotate(180deg, origin: center + horizon)[#polygon.regular(vertices: 3, size: 6.5pt, stroke: .6pt)])
  #place(polygon.regular(vertices: 3, size: 7pt, stroke: .5pt))
]

// ---------------------------------------------------------------------
// na-tabpos : marque de position relative (deux arcs qui se rejoignent au
// point d'intersection + texte "(Cf) coupe (Cg)" et une note facultative)
// ---------------------------------------------------------------------
// الكلمات الافتراضية حسب لغة المستند (#set text(lang: ...)) ؛ لغة غير موجودة هنا => الإنجليزية
#let _pos-words = (
  ar: (above: "فوق", below: "تحت", cross: "يقطع", at-point: "في النقطة"),
  fr: (above: "au-dessus", below: "au-dessous", cross: "coupe", at-point: "au point"),
  en: (above: "above", below: "below", cross: "crosses", at-point: "at the point"),
  es: (above: "encima", below: "debajo", cross: "corta", at-point: "en el punto"),
  de: (above: "oberhalb", below: "unterhalb", cross: "schneidet", at-point: "im Punkt"),
  it: (above: "sopra", below: "sotto", cross: "interseca", at-point: "nel punto"),
  pt: (above: "acima", below: "abaixo", cross: "corta", at-point: "no ponto"),
  nl: (above: "boven", below: "onder", cross: "snijdt", at-point: "in het punt"),
  tr: (above: "üstünde", below: "altında", cross: "keser", at-point: "noktasında"),
  ru: (above: "выше", below: "ниже", cross: "пересекает", at-point: "в точке"),
)
#let _pos-word(key, user) = if user != auto { user } else {
  context {
    let d = _pos-words.at(text.lang, default: _pos-words.en)
    d.at(key)
  }
}

// أسماء المنحنيين / المستقيم : قيمة عامة يمكن تغييرها مرة واحدة لكل المستند بـ
// #tabpos-names(first: $(C_1)$, second: $(Delta)$)
// وأي جدول يمكنه تجاوزها بـ tabpos(first: ..., second: ...)
// Names of the two curves / the line: set once for the whole document with
// #tabpos-names(first: $(C_1)$, second: $(Delta)$); a single table can still override them
// with tabpos(first: ..., second: ...).
#let _pos-names = state("na-tabpos-names", (first: $(C_f)$, second: $(C_g)$))
#let tabpos-names(first: auto, second: auto) = _pos-names.update(s => (
  first: if first == auto { s.first } else { first },
  second: if second == auto { s.second } else { second },
))
#let _pos-name(key, user) = if user != auto { user } else {
  context _pos-names.get().at(key)
}

// أسطر النص فوق بعضها بخطوة ثابتة (ارتفاع كل سطر 1.35em) حتى لا تتداخل الكلمات
#let _pos-stack(..items) = stack(
  dir: ttb,
  spacing: 0pt,
  ..items.pos().map(it => box(height: 1.35em, align(center + horizon, it))),
)

#let _pos-zero(x, yc, hh, note, o) = {
  import cetz.draw: bezier, content
  let d = o.arc-width
  let yt = yc + hh / 2
  let yb = yc - hh / 2
  bezier((x - d, yb), (x, yt), (x - d, yb + 0.47), (x - 0.6, yt - 0.72))
  bezier((x + d, yb), (x, yt), (x + d, yb + 0.47), (x + 0.6, yt - 0.72))
  content(
    (x, yc - 0.2),
    box(width: auto, align(center, {
      set text(size: 0.62em)
      _pos-stack(o.first, o.cross, o.second, ..(if note != none { (o.at-point, note) } else { () }))
    })),
  )
}

////// Return a variation table
/// Retourne un tableau de variation
#let tabvar(
  ////// variable is a content block which contains the table’s variable name (like $x$ or $t$)
  //////
  /// `variable` est la variable qui contient la variable du tableau (comme $x$ ou $t$)\
  /// *Exemple :* si la variable de la fonction est $t$, alors :\
  /// ```typst
  /// variable : $ t $
  /// ```
  ///  -> content
  variable: $ x $,
  ////// `label` is an array which contain arrays of 2 arguments that contains in first position the line’s label and in second position, if the line is a variation table or a sign table with this following keys : "v" for variation and "s" for sign \
  ////// *Example :* for a variation table of a function $f$, you should write : \
  ////// ```typst
  ////// init: (
  //////   variable: $x$,
  //////   label: (
  //////     ([sign of $f$], "Sign"), // the first line is a sign table
  //////     ([variation of $f$], "Variation") // the second line is a variation table
  //////   )
  ////// )
  ////// ```
  ///
  /// `label` est un array qui contient des array de longueur 2, une pour chaque ligne du tableau, dont le premier élément est le titre de la ligne et le second est le type de la ligne : signes ( "s" ) ou variations ( "v" ) \
  /// *Exemple :* pour le tableau de variations de la fonction $f$, vous devriez écrire :\
  /// ```typst
  /// label : (
  ///   ([Signe de $f$], "s"), // la première ligne est un tableau de signe
  ///   ([Variations de $f$], "v") // la seconde ligne est un tableau de variations
  /// )
  /// ```
  /// -> array
  label: (),
  ////// values taken by the variable \
  ////// for example if your funtions changes sign or reaches a max/min for $x in {0,1,2,3}$ \
  ////// you should write this :
  ////// ```typst
  ////// domain: ($0$, $1$, $2$, $3$)
  ////// ```
  ///
  /// Les valeurs prises par la variable. \
  /// Par exemple, si votre fonction change de signe ou atteint un extrémum pour $x in {0;1;2;3}$, \
  /// vous devriez écrire :
  /// ```typst
  /// domain: ($0$, $1$, $2$, $3$)
  /// ```
  ///
  /// -> array
  domain: (),
  /// the content of the table \
  /// see below for more details
  /// Le contenu du tableau\
  /// Voir 2.2<2.2> pour plus de détails
  /// -> array
  contents: ((),),
  ////// *Optional*\
  ////// The style of the table,\
  ////// the style type is defined by Cetz,
  ////// so I invite you to have a look at the #link("https://cetz-package.github.io/docs")[#underline(stroke: blue)[Cetz manual]]. \
  ////// *Caution :* if you haven't entered the mark symbol as none, all lines in the table will have an arrowhead.
  ///
  /// *Optionelle*\
  /// Le style du tableau\
  /// Le type style est défini par Cetz, aussi je vous recommande de vous référer au #link("https://cetz-package.github.io/docs")[#underline(stroke: blue)[manuel de Cetz]].\
  /// *Attention :* Si vous ne mettez pas le paramètre de style : `mark` à `none`, alors toutes les lignes du tableau auront une tête en flèche
  ///  -> style
  table-style: (stroke: 1pt + black, mark: (symbol: none)),
  ////// to hide the external cardre
  /// Pour cacher le cadre externe du tableau
  /// -> bool
  nocadre: false,
  ////// the style of the arrowhead, the type of which is defined by Cetz
  ///
  /// Le style de la tête de la flèche.\
  /// *NB.* le type `mark` est défini par Cetz
  /// -> mark
  arrow-mark: (end: "straight"),
  ////// *Optional*\
  //////  the style of the arrow, as for the `table-style` parameter\
  ////// *Caution :* the `mark` section is overwrite by the `arrow-mark`
  ///
  /// *Optionelle :*\
  /// Le style des flèches.\
  /// *Attention :* le paramètre `mark` est supplanté par le paramètre `arrow-mark`
  /// -> style
  arrow-style: (stroke: black + 1pt),
  //////  *Optional*\
  ////// if you want to change the default bar sign to a bar with a 0
  ///
  /// *Optionelle*\
  /// Si vous voulez remplacer la barre par défaut dans les tableaux de signes, par une barre avec un 0 en son centre
  /// -> bool
  line-0: false,
  ////// *Optional*\
  ////// change the undefined bar at the beginnig end the end of sub-table for a style that mimic tkz-tab
  /// *Optionelle*\
  /// change les bars d’indéfinies au début et à la fin des sous-tableaux pour copier le style de tkz-tab
  undefined-bar-alt: false,
  ////// *Optional*\
  ////// if you want to change the style of all separator lines between signs\
  //////
  ////// Warning: this will only change the default lines, the `||`, `|` or `0` lines will not be changed.
  ///
  /// *Optionelle*\
  /// Si vous voulez le style de toutes les barres de séparation entre les signes
  /// -> style
  line-style: (stroke: black + 1pt),
  ////// *Optional*\
  ////// The style of the hatching in the sign and variation table
  ///
  /// *Optionelle*\
  /// Le style des hachures, s’il y a des zones hachurées
  /// -> tiling
  hatching-style: tiling(size: (30pt, 30pt))[

    #place(line(start: (0%, 100%), end: (100%, 0%), stroke: 2pt))
    #place(line(start: (-100%, 100%), end: (100%, -100%), stroke: 2pt))
    #place(line(start: (0%, 200%), end: (200%, 0%), stroke: 2pt))
  ],
  ////// *Optional*\
  ////// change the width of the first column
  ///
  /// *Optionelle*\
  /// Change la largeur de la première colonne
  /// -> length
  first-column-width: none,
  ////// *Optional*\
  ////// change the height of the first line
  ///
  /// Change la hauteur de la première ligne (celle du domaine et de la variable)
  /// -> length
  first-line-height: none,
  ////// *Optional*\
  ////// change the distance betwen two elements
  ///
  /// *Optionelle*\
  /// Change la distance entre deux éléments
  /// -> length
  element-distance: none,
  ////// *Optional*\
  ////// To add values betwen to pre-defined values
  ///
  /// Pour ajouter des valeurs entre deux valeurs prédéfinies
  /// -> array
  values: ((),),
  ////// *Optional*\
  ////// The fill color for values (should be the same as the background of the table)
  ////// default : white
  ///
  /// *Optionelle*\
  /// La couleur de remplissage pour les valeurs sur les flèches (devrait être identique
  /// à l'arrière-plan du tableau)
  /// Par défaut : white
  /// -> color
  fill-color: white,
  ////// *Optional*\
  ////// To add more stuff with Cetz
  ///
  /// Pour ajouter davantage d’éléments, via Cetz
  /// -> content
  add: (),
  ////// na-tabpos : parameters of the relative-position line (type "p")
  first: auto,
  second: auto,
  // auto = الكلمة حسب لغة المستند (ar, fr, en, es, de, it, pt, nl, tr, ru) ؛ أو أي محتوى تكتبه
  above: auto,
  below: auto,
  cross: auto,
  at-point: auto,
  arc-width: 0.94,
  // الارتفاعات المكتوبة في label بالسنتيمتر بالضبط (وحدة CeTZ = 1 سم)
  pos-height: 3cm,
  // ارتفاع سطر الفرق f(x) - g(x) (سطر إشارة "s" يسبق مباشرة سطر الوضع النسبي "p") ؛ الافتراضي 1 سم
  // Height of the difference row (an "s" row placed right before a "p" row); default 1cm.
  // `none` = automatic height. A height written in the row, e.g. ([title], 2cm, "s"), has priority.
  diff-height: 1cm,
) = {
  //start of function

  let c1stroke = stroke

  // na-tabpos : les lignes de type "p" sont des lignes de signes "s" dont
  // "+" / "-" deviennent "au-dessus" / "au-dessous" et dont le zéro devient deux arcs
  let pos-rows = label.map(l => l.last() == "p")
  let popt = (first: _pos-name("first", first), second: _pos-name("second", second), cross: _pos-word("cross", cross), at-point: _pos-word("at-point", at-point), arc-width: arc-width)
  let label = label.enumerate().map(((k, l)) => if l.last() == "p" {
    if l.len() == 2 { (l.at(0), pos-height, "s") } else { (l.at(0), l.at(1), "s") }
  } else if diff-height != none and l.last() == "s" and l.len() == 2 and k + 1 < pos-rows.len() and pos-rows.at(k + 1) {
    // سطر الفرق : سطر إشارة يليه سطر وضع نسبي
    (l.at(0), diff-height, "s")
  } else { l })
  let _posc = word => {
    set text(size: 0.62em)
    align(center, _pos-stack(popt.first, word, popt.second))
  }
  let _sgn = e => if e == "+" { _posc(_pos-word("above", above)) } else if e == "-" { _posc(_pos-word("below", below)) } else { e }
  let _conv = e => if type(e) == str {
    _sgn(e)
  } else if type(e) == array and e.len() >= 2 {
    (e.at(0), _sgn(e.at(1)), ..e.slice(2))
  } else { e }
  let contents = contents.enumerate().map(((k, row)) => if k < pos-rows.len() and pos-rows.at(k) { row.map(_conv) } else { row })

  context {
    cetz.canvas({
      import cetz.draw: *

      set-style(..table-style)

      //Début des problèmes


      //Pour la conversion 1unit = 10,65mm
      if first-line-height != none and first-line-height < 0mm {
        panic("fist-line-height must be positive")
      }
      let largeur_permiere_colonne = 0
      if first-column-width == none {
        largeur_permiere_colonne = calc.max(
          //La largeur de la première colonne
          3,
          calc.max(..for i in range(0, label.len()) {
            (measure(label.at(i).at(0)).width.mm() / 10.65 + 1,)
          }),
        )
      } else {
        if first-column-width < 0mm {
          panic("first-column-width parameter must be positive")
        } else {
          largeur_permiere_colonne = first-column-width.mm() / 10.65
        }
      }

      let hauteur_permiere_ligne = 0
      if first-line-height == none {
        hauteur_permiere_ligne = calc.max(1, measure(variable).height.mm() / 10.65, ..for i in domain {
          (
            measure(if type(i) == array {
              i.first()
            } else {
              i
            })
              .height
              .mm()
              / 10.65
              + 1,
          )
        })
      } else {
        hauteur_permiere_ligne = first-line-height.mm() / 10.65
      }

      content((largeur_permiere_colonne / 2, -hauteur_permiere_ligne / 2), [#variable], name: "var") // La variable

      let coordX = for i in range(0, domain.len()) {
        ((0, 0),)
      }

      let distance_elements = 3
      if element-distance != none {
        distance_elements = element-distance.mm() / 10.65
      }

      let decalage_domaine = (
        largeur_permiere_colonne
          + 0.2
          + calc.max(
            // la distance entre les valeurs du domaine puis la largeur du talbeau de signe
            measure(if type(domain.at(0)) == array {
              domain.at(0).first()
            } else {
              domain.at(0)
            })
              .width
              .mm()
              / (2 * 10.65),
            ..for i in range(0, contents.len()) {
              if label.at(i).last() == "v" {
                (measure(contents.at(i).at(0).last()).width.mm() / (2 * 10.65),)
              } else { (0,) }
            },
          )
      )

      for i in range(0, domain.len() - 1) {
        //les éléments du domaine
        coordX.at(i) = (
          decalage_domaine,
          calc.max(
            if type(domain.at(i)) == array {
              measure(domain.at(i).first()).width.mm() / 10.65
            } else {
              measure(domain.at(i)).width.mm() / 10.65
            },
            ..for j in range(0, contents.len()) {
              if label.at(j).last() == "v" {
                let oui = {
                  if contents.at(j).at(i).len() > 2 {
                    calc.max(
                      measure(contents.at(j).at(i).last()).width.mm() / 10.65,
                      measure(
                        contents
                          .at(j)
                          .at(i)
                          .at(if contents.at(j).at(i).at(1) == "||"
                            or contents.at(j).at(i).at(1) == "h"
                            or contents.at(j).at(i).at(1) == "H"
                            or contents.at(j).at(i).at(1) == "|h"
                            or contents.at(j).at(i).at(1) == "H|" { 2 } else { 3 }),
                      )
                        .width
                        .mm()
                        / 10.65,
                    )
                  } else if contents.at(j).at(i).len() != 0 {
                    measure(contents.at(j).at(i).last()).width.mm() / 10.65
                  } else { 0 }
                }
                (oui,)
              } else { (0,) }
            },
          ),
        )

        let prochX1 = {
          calc.max(
            if type(domain.at(i + 1)) == array {
              measure(domain.at(i + 1).first()).width.mm() / 10.65
            } else {
              measure(domain.at(i + 1)).width.mm() / 10.65
            },
            ..for j in range(0, contents.len()) {
              if label.at(j).last() == "v" {
                // panic si il y a plus ou moins d’éléments qu’il faudrais
                if contents.at(j).len() != domain.len() {
                  panic("TabVar: Not enough elements in the table number " + str(j + 1))
                }

                let oui = {
                  if contents.at(j).at(i + 1).len() > 2 {
                    calc.max(
                      measure(contents.at(j).at(i + 1).last()).width.mm() / 10.65,
                      measure(
                        contents
                          .at(j)
                          .at(i + 1)
                          .at(if contents.at(j).at(i + 1).at(1) == "||"
                            or contents.at(j).at(i + 1).at(1) == "h"
                            or contents.at(j).at(i + 1).at(1) == "H"
                            or contents.at(j).at(i + 1).at(1) == "|h"
                            or contents.at(j).at(i + 1).at(1) == "H|" { 2 } else { 3 }),
                      )
                        .width
                        .mm()
                        / 10.65,
                    )
                  } else if contents.at(j).at(i + 1).len() != 0 {
                    measure(contents.at(j).at(i + 1).last()).width.mm() / 10.65
                  } else { 0 }
                }
                (oui,)
              } else { (0,) }
            },
          )
        }

        if i == 0 {
          content(
            (decalage_domaine, -hauteur_permiere_ligne / 2),
            box(width: auto, align(center, if type(domain.at(i)) == array {
              domain.at(i).first()
            } else {
              domain.at(i)
            })),
            name: "domain" + str(i),
          )
        } else {
          content(
            (decalage_domaine, -hauteur_permiere_ligne / 2),
            box(width: auto, align(center, if type(domain.at(i)) == array {
              show math.equation.where(block: false): math.equation.with(block: true)
              domain.at(i).first()
            } else {
              show math.equation.where(block: false): math.equation.with(block: true)
              domain.at(i)
            })),
            name: "domain" + str(i),
          )
        }

        decalage_domaine = (
          decalage_domaine
            + (coordX.at(i).at(1)) / 2
            + prochX1 / 2
            + if type(domain.at(i)) != array { distance_elements } else { domain.at(i).last().mm() / 10.65 }
        )
      }

      content(
        // le dernier éléments du domaine
        (decalage_domaine, -hauteur_permiere_ligne / 2),
        box(width: auto, align(center, {
          show math.equation.where(block: false): math.equation.with(block: true)
          domain.at(-1)
        })),
        name: "domain" + str(domain.len() - 1),
      )
      coordX.at(-1) = (
        decalage_domaine,
        calc.max(measure(domain.at(-1)).width.mm() / 10.65, ..for j in range(0, contents.len()) {
          if label.at(j).last() == "v" {
            let oui = {
              if contents.at(j).at(-1).len() > 2 {
                calc.max(
                  measure(contents.at(j).at(-1).last()).width.mm() / 10.65,
                  measure(
                    contents
                      .at(j)
                      .at(-1)
                      .at(if contents.at(j).at(-1).at(1) == "||"
                        or contents.at(j).at(-1).at(1) == "|h"
                        or contents.at(j).at(-1).at(1) == "h"
                        or contents.at(j).at(-1).at(1) == "H"
                        or contents.at(j).at(-1).at(1) == "H|" { 2 } else { 3 }),
                  )
                    .width
                    .mm()
                    / 10.65,
                )
              } else if contents.at(j).at(-1).len() != 0 {
                measure(contents.at(j).at(-1).last()).width.mm() / 10.65
              } else { 0 }
            }
            (oui,)
          } else { (0,) }
        }),
      )

      decalage_domaine = decalage_domaine + coordX.at(-1).at(1) / 2 + 0.2

      let coordY = for i in range(0, label.len()) {
        ((0, 0),)
      }

      let hauteur_total = hauteur_permiere_ligne
      for i in range(0, label.len()) {
        //le texte de la première colonne
        let hauteur_case = {
          if label.at(i).len() > 2 {
            label.at(i).at(1).mm() / 10 - 1.75
          } else {
            calc.max(1, measure(label.at(i).at(0)).height.mm() / 10.65, ..for j in range(contents.at(i).len()) {
              let ele = contents.at(i).at(j)
              if label.at(i).last() == "s" {
                if type(ele) == array and ele.len() > 2 {
                  (measure(ele.last()).height.mm() / 10.65,)
                } else if type(ele) != array and ele != "||" {
                  (measure(ele).height.mm() / 10.65,)
                } else {
                  (1,)
                }
              } else if label.at(i).last() == "v" {
                let oui = {
                  if contents.at(i).at(j).len() > 2 {
                    calc.max(
                      measure(contents.at(i).at(j).last()).height.mm() / 10.65,
                      measure(
                        contents
                          .at(i)
                          .at(j)
                          .at(if contents.at(i).at(j).at(1) == "||"
                            or contents.at(i).at(j).at(1) == "h"
                            or contents.at(i).at(j).at(1) == "|h"
                            or contents.at(i).at(j).at(1) == "H"
                            or contents.at(i).at(j).at(1) == "H|" { 2 } else { 3 }),
                      )
                        .height
                        .mm()
                        / 10.65,
                    )
                  } else if contents.at(i).at(j).len() != 0 {
                    measure(contents.at(i).at(j).last()).height.mm() / 10.65
                  } else { 0 }
                }
                (oui,)
              }
            })
          }
        }


        content(
          (largeur_permiere_colonne / 2, -hauteur_total - hauteur_case / 2 - 1.75 / 2),
          box(width: auto, align(center, label.at(i).at(0))),
          name: "label" + str(i),
        )

        line(
          (0, -hauteur_total),
          (decalage_domaine, -hauteur_total),
          name: "line-betwen-table-nb" + str(i),
        )

        coordY.at(i) = (-hauteur_total - hauteur_case / 2 - 1.75 / 2, hauteur_case + 1.75)

        hauteur_total = hauteur_total + hauteur_case + 1.75
      }

      if not nocadre {
        rect(
          //les countours du tableau
          (0, 0),
          (decalage_domaine, -hauteur_total),
          fill: none,
          name: "cadre",
        )
      } else {
        hide(rect(
          //les countours du tableau
          (0, 0),
          (decalage_domaine, -hauteur_total),
          fill: none,
          name: "cadre",
        ))
      }
      line(
        // ligne de séparation entre le texte et les tableaux
        (largeur_permiere_colonne, 0),
        (largeur_permiere_colonne, -hauteur_total),
        name: "line-separating-labels-tables",
      )
      hide(line(
        (0, -hauteur_permiere_ligne / 2),
        (decalage_domaine, -hauteur_permiere_ligne / 2),
        name: "line-centred-domain",
      ))

      for i in range(0, label.len()) {
        // Début des différents tableaux

        //Les tableaux de signe

        if label.at(i).last() == "s" {
          // panic si il y a plus ou moins d’éléments qu’il faudrais
          // panic si il y a plus ou moins d’éléments qu’il faudrais
          if contents.at(i).len() > domain.len()  {
            panic("TabVar: Wrong number of elements in the table number " + str(i + 1))
          }

          for j in range(0, contents.at(i).len() - 1) {

            let prochain = _prochain-signe(contents.at(i), j)

            if type(contents.at(i).at(j)) == array and contents.at(i).at(j).len() >= 2 {
              // le signe si le signe n'est pas vide mais à une bar spécial
              content(
                (
                  (coordX.at(prochain).at(0) + coordX.at(j).at(0)) / 2,
                  coordY.at(i).at(0),
                ),
                box(width: 1pt, align(center, {
                  show math.equation.where(block: false): math.equation.with(block: true)
                  contents.at(i).at(j).at(1)
                })),
                name: "sign" + str(i) + str(j),
              )

              if pos-rows.at(i) and (contents.at(i).at(j).at(0) == "0" or type(contents.at(i).at(j).at(0)) == type([])) {
                // na-tabpos : ligne de position relative -> deux arcs au lieu de la barre
                _pos-zero(
                  coordX.at(j).at(0), coordY.at(i).at(0), coordY.at(i).at(1),
                  if contents.at(i).at(j).at(0) == "0" { none } else { contents.at(i).at(j).at(0) },
                  popt,
                )
              } else if contents.at(i).at(j).at(0) == "0" {
                set-style(..line-style)
                line(
                  (coordX.at(j).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                  (coordX.at(j).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                  name: "zero",
                )
                content(
                  "zero.mid",
                  $ 0 $,
                )
              } else if type(contents.at(i).at(j).at(0)) == type([]) {
                // Marque libre : un contenu posé au milieu de la barre, comme le 0
                // (`type([])` : ici, `content` est la fonction de Cetz, pas le type)
                set-style(..line-style)
                line(
                  (coordX.at(j).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                  (coordX.at(j).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                  name: "zero",
                )
                content(
                  "zero.mid",
                  contents.at(i).at(j).at(0),
                )
              } else if contents.at(i).at(j).first() == "|" {
                set-style(..line-style)
                line(
                  (coordX.at(j).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                  (coordX.at(j).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                )
              } else if j != 0 or undefined-bar-alt {
                set-style(..line-style)
                if contents.at(i).at(j).at(0) == "||" {
                  line(
                    (coordX.at(j).at(0) - 0.07, coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                    (coordX.at(j).at(0) - 0.07, coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                  )
                  line(
                    (coordX.at(j).at(0) + 0.07, coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                    (coordX.at(j).at(0) + 0.07, coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                  )
                } else {
                  line(
                    (coordX.at(j).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                    (coordX.at(j).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                    name: "zero3",
                  )
                  content("zero3.mid", if line-0 { $ 0 $ } else { [] })
                }
              } else if contents.at(i).at(j).first() == "||" {
                set-style(..line-style)
                line(
                  (
                    largeur_permiere_colonne
                      + 0.15
                      + if type(table-style.at("stroke")) == c1stroke and table-style.at("stroke").thickness != auto {
                        table-style.at("stroke").thickness.mm() / 10.65
                      } else { 0 },
                    coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                  ),
                  (
                    largeur_permiere_colonne
                      + 0.15
                      + if type(table-style.at("stroke")) == c1stroke and table-style.at("stroke").thickness != auto {
                        table-style.at("stroke").thickness.mm() / 10.65
                      } else { 0 },
                    coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                  ),
                )
              }
              set-style(..table-style)
            } else if type(contents.at(i).at(j)) == array and contents.at(i).at(j).len() == 0 {
              // On ne fait rien s'il n'y a pas de signe
            } else {
              if contents.at(i).at(j) == "h" {
                set-style(..line-style)
                if j != 0 {
                  line(
                    (coordX.at(j).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                    (coordX.at(j).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                  )
                }
                if prochain - 1 != contents.at(i).len() - 1 + if ("||", "0", "|").contains(contents.at(i).at(-1)) {- 1} else {0} {
                  line(
                    (coordX.at(prochain).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                    (coordX.at(prochain).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                  )
                }
                set-style(..table-style)
                rect(
                  stroke: none,
                  (
                    if j == 0 { largeur_permiere_colonne } else { coordX.at(j).at(0) },
                    coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                  ),
                  (
                    if prochain == contents.at(i).len() { decalage_domaine } else { coordX.at(prochain).at(0) + if contents.at(i).at(-1) == "||" {0.15} else {0}  },
                    coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                  ),
                  fill: hatching-style,
                )
              } else if contents.at(i).at(j) == "|h" {
                set-style(..line-style)
                if j != 0 {
                  line(
                    (coordX.at(j).at(0) + 0.07, coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                    (coordX.at(j).at(0) + 0.07, coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                  )
                }
                if prochain - 1 != contents.at(i).len() - 1 + if ("||", "0", "|").contains(contents.at(i).at(-1)) {- 1} else {0} {
                  line(
                    (coordX.at(prochain).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                    (coordX.at(prochain).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                  )
                }
                set-style(..table-style)
                rect(
                  stroke: none,
                  (
                    if j == 0 { largeur_permiere_colonne } else { coordX.at(j).at(0) + 0.07 },
                    coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                  ),
                  (
                    if prochain == contents.at(i).len() { decalage_domaine } else { coordX.at(prochain).at(0) + if contents.at(i).at(-1) == "||" {0.15} else {0}  },
                    coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                  ),
                  fill: hatching-style,
                )
                if j != 0 {
                  line(
                    (
                      coordX.at(j).at(0) - 0.07,
                      coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                    ),
                    (
                      coordX.at(j).at(0) - 0.07,
                      coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                    ),
                  )
                }
              } else if contents.at(i).at(j) == "h|" {
                if prochain + 1 == contents.at(i).len() and ("0", "|").contains(contents.at(i).at(-1)) {
                  panic("The end of the hatch area for line no. i cannot be defined or specified as undefined. Please remove the '|' character from the hatch tag or the '|' and '0' characters at the end of the symbol table.")
                }
                set-style(..line-style)
                if j != 0 {
                  line(
                    (coordX.at(j).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                    (coordX.at(j).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                  )
                }
                if prochain != contents.at(i).len() and contents.at(i).at(prochain) != "||" {
                  line(
                    (coordX.at(prochain).at(0) - 0.07, coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                    (coordX.at(prochain).at(0) - 0.07, coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                  )
                  line(
                    (
                      coordX.at(prochain).at(0) + 0.07,
                      coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                    ),
                    (
                      coordX.at(prochain).at(0) + 0.07,
                      coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                    ),
                  )
                }
                set-style(..table-style)
                rect(
                  stroke: none,
                  (
                    if j == 0 { largeur_permiere_colonne } else { coordX.at(j).at(0) },
                    coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                  ),
                  (
                    if prochain == contents.at(i).len() {
                      decalage_domaine
                    } else if contents.at(i).at(prochain) == "||" {
                      decalage_domaine - 0.15
                    } else {
                      coordX.at(prochain).at(0) - 0.07
                    },
                    coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                  ),
                  fill: hatching-style,
                )
              } else if contents.at(i).at(j) == "|h|" {
                if prochain + 1 == contents.at(i).len() and ("0", "|").contains(contents.at(i).at(-1)) {
                  panic("The end of the hatch area for line no. i cannot be defined or specified as undefined. Please remove the '|' character from the hatch tag or the '|' and '0' characters at the end of the symbol table.")
                }
                set-style(..line-style)
                if j != 0 {
                  line(
                    (coordX.at(j).at(0) + 0.07, coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                    (coordX.at(j).at(0) + 0.07, coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                  )
                }
                if (
                  prochain != contents.at(i).len() and contents.at(i).at(prochain) != "||"
                ) {
                  line(
                    (coordX.at(prochain).at(0) - 0.07, coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                    (coordX.at(prochain).at(0) - 0.07, coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                  )
                }
                set-style(..table-style)
                rect(
                  stroke: none,
                  (
                    if j == 0 { largeur_permiere_colonne } else { coordX.at(j).at(0) + 0.07 },
                    coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                  ),
                  (
                    if prochain == contents.at(i).len() {
                      //cas si on termine à la fin du tableau
                      decalage_domaine
                    } else if contents.at(i).at(-1) == "||" {
                      //cas si on termine à la fin du tableau et qu’il est indéfinis
                      decalage_domaine - 0.15
                    } else {
                      // cas normal
                      coordX.at(prochain).at(0) - 0.07
                    },
                    coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                  ),
                  fill: hatching-style,
                )
                if prochain != contents.at(i).len() and contents.at(i).at(prochain) != "||" {
                  line(
                    (
                      coordX.at(prochain).at(0) + 0.07,
                      coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                    ),
                    (
                      coordX.at(prochain).at(0) + 0.07,
                      coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                    ),
                  )
                }
                if j != 0 {
                  line(
                    (
                      coordX.at(j).at(0) - 0.07,
                      coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                    ),
                    (
                      coordX.at(j).at(0) - 0.07,
                      coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                    ),
                  )
                }
              } else {
                content(
                  (
                    (coordX.at(prochain).at(0) + coordX.at(j).at(0)) / 2,
                    coordY.at(i).at(0),
                  ),
                  box(width: 1pt, align(center, {
                    show math.equation.where(block: false): math.equation.with(block: true)
                    contents.at(i).at(j)
                  })),
                  name: "sign" + str(i) + str(j),
                )

                if (
                  j != 0 and not _yatilhach(contents.at(i), j)
                ) {
                  //Si c'est pas le premier signe et qu’il n’y est pas d’hachurage avant
                  set-style(..line-style)
                  line(
                    (coordX.at(j).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                    (coordX.at(j).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                    name: "zero2",
                  )
                  content("zero2.mid", if line-0 { $ 0 $ } else { [] })
                  set-style(..table-style)
                }
              }
            }
          }

          //Cas du dernier signe

          if contents.at(i).at(-1) == "||" and not undefined-bar-alt {

            // Si bar indéfinie à la fin
            set-style(..line-style)
            line(
              (decalage_domaine - 0.15, coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
              (decalage_domaine - 0.15, coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
            )
          } else if contents.at(i).at(-1) == "||" and undefined-bar-alt {
            set-style(..line-style)

            line(
              (coordX.at(-1).at(0) - 0.07, coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
              (coordX.at(-1).at(0) - 0.07, coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
            )
            line(
              (coordX.at(-1).at(0) + 0.07, coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
              (coordX.at(-1).at(0) + 0.07, coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
            )
                

          } else if pos-rows.at(i) and contents.at(i).at(-1) == "0" {
            _pos-zero(coordX.at(-1).at(0), coordY.at(i).at(0), coordY.at(i).at(1), none, popt)
          } else if contents.at(i).at(-1) == "0" {
            // Si zéro à la fin
            set-style(..line-style)
            line(
              (coordX.at(-1).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
              (coordX.at(-1).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
              name: "zero",
            )
            content(
              "zero.mid",
              $ 0 $,
            )
          } else if contents.at(i).at(-1) == "|" {
            // Si barre à la fin
            set-style(..line-style)
            line(
              (coordX.at(-1).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
              (coordX.at(-1).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
            )
          } else if pos-rows.at(i) and contents.at(i).len() == domain.len() {
            _pos-zero(coordX.at(-1).at(0), coordY.at(i).at(0), coordY.at(i).at(1), contents.at(i).at(-1), popt)
          } else if contents.at(i).len() == domain.len() {
            set-style(..line-style)
            line(
              (coordX.at(-1).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
              (coordX.at(-1).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
              name: "zero",
            )
            content(
              "zero.mid",
              contents.at(i).at(-1),
            )
          } else {
            if type(contents.at(i).at(-1)) == array and contents.at(i).at(-1).len() == 0 {
              // On ne fait rien s'il n'y a pas de signe
            } else {
              if contents.at(i).at(-1) == "h" {
                set-style(..line-style)
                if contents.at(i).len() >= 2 {
                  line(
                    (coordX.at(-2).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                    (coordX.at(-2).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                  )
                }
                set-style(..table-style)
                rect(
                  stroke: none,
                  (
                    if contents.at(i).len() - 1 == 0 { largeur_permiere_colonne } else { coordX.at(-2).at(0) },
                    coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                  ),
                  (
                    decalage_domaine,
                    coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                  ),
                  fill: hatching-style,
                )
              } else if contents.at(i).at(-1) == "|h" {
                if contents.at(i).len() >= 2 {
                  set-style(..line-style)
                  line(
                    (coordX.at(-2).at(0) + 0.07, coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                    (coordX.at(-2).at(0) + 0.07, coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                  )
                  set-style(..table-style)
                }
                rect(
                  stroke: none,
                  (
                    if contents.at(i).len() - 1 == 0 { largeur_permiere_colonne } else { coordX.at(-2).at(0) + 0.07 },
                    coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                  ),
                  (
                    decalage_domaine,
                    coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                  ),
                  fill: hatching-style,
                )
                if contents.at(i).len() - 1 != 0 {
                  line(
                    (
                      coordX.at(-2).at(0) - 0.07,
                      coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                    ),
                    (
                      coordX.at(-2).at(0) - 0.07,
                      coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                    ),
                  )
                }
              } else if contents.at(i).at(-1) == "h|" {
                if contents.at(i).len() >= 2 {
                  set-style(..line-style)
                  line(
                    (coordX.at(-2).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                    (coordX.at(-2).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                  )
                  set-style(..table-style)
                }
                rect(
                  stroke: none,
                  (
                    if contents.at(i).len() - 1 == 0 { largeur_permiere_colonne } else { coordX.at(-2).at(0) },
                    coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                  ),
                  (
                    decalage_domaine,
                    coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                  ),
                  fill: hatching-style,
                )
              } else if contents.at(i).at(-1) == "|h|" {
                if contents.at(i).len() >= 2 {
                  set-style(..line-style)
                  line(
                    (coordX.at(-2).at(0) + 0.07, coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                    (coordX.at(-2).at(0) + 0.07, coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                  )
                  set-style(..table-style)
                }
                rect(
                  stroke: none,
                  (
                    if contents.at(i).len() - 1 == 0 { largeur_permiere_colonne } else { coordX.at(-2).at(0) + 0.07 },
                    coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                  ),
                  (
                    decalage_domaine,
                    coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                  ),
                  fill: hatching-style,
                )
                if contents.at(i).len() - 1 != 0 {
                  line(
                    (
                      coordX.at(-2).at(0) - 0.07,
                      coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                    ),
                    (
                      coordX.at(-2).at(0) - 0.07,
                      coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                    ),
                  )
                }
              } else {
                if type(contents.at(i).at(-1)) == array and contents.at(i).at(-1).len() >= 2 {
                  // le signe si le signe n'est pas vide et à une bar spécial
                  content(
                    (
                      (coordX.at(-2).at(0) + coordX.at(-1).at(0)) / 2,
                      coordY.at(i).at(0),
                    ),
                    box(width: 1pt, align(center, contents.at(i).at(-1).last())),
                    name: "sign" + str(i) + str(contents.at(i).len() - 1),
                  )

                  set-style(..line-style)
                  if contents.at(i).len() != 1 {
                    if contents.at(i).at(-1).at(0) == "||" {
                      set-style(..line-style)
                      line(
                        (coordX.at(-2).at(0) - 0.07, coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                        (coordX.at(-2).at(0) - 0.07, coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                      )
                      line(
                        (coordX.at(-2).at(0) + 0.07, coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                        (coordX.at(-2).at(0) + 0.07, coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                      )
                      set-style(..table-style)
                    } else if pos-rows.at(i) and (contents.at(i).at(-1).at(0) == "0" or type(contents.at(i).at(-1).at(0)) == type([])) {
                      _pos-zero(
                        coordX.at(-2).at(0), coordY.at(i).at(0), coordY.at(i).at(1),
                        if contents.at(i).at(-1).at(0) == "0" { none } else { contents.at(i).at(-1).at(0) },
                        popt,
                      )
                    } else if contents.at(i).at(-1).at(0) == "0" {
                      set-style(..line-style)
                      line(
                        (coordX.at(-2).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                        (coordX.at(-2).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                        name: "zero",
                      )
                      content(
                        "zero.mid",
                        $ 0 $,
                      )
                      set-style(..table-style)
                    } else if type(contents.at(i).at(-1).at(0)) == type([]) {
                      // Marque libre : un contenu posé au milieu de la barre, comme le 0
                // (`type([])` : ici, `content` est la fonction de Cetz, pas le type)
                      set-style(..line-style)
                      line(
                        (coordX.at(-2).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                        (coordX.at(-2).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                        name: "zero",
                      )
                      content(
                        "zero.mid",
                        contents.at(i).at(-1).at(0),
                      )
                      set-style(..table-style)
                    } else if contents.at(i).at(-1).first() == "|" {
                      set-style(..line-style)
                      line(
                        (coordX.at(-2).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                        (coordX.at(-2).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                      )
                      set-style(..table-style)
                    } else {
                      set-style(..line-style)
                      line(
                        (coordX.at(-2).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                        (coordX.at(-2).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                        name: "zero3",
                      )
                      set-style(..table-style)
                      content("zero3.mid", if line-0 { $ 0 $ } else { [] })
                    }
                  } else {
                    if contents.at(i).at(-1).contains("||") {
                      set-style(..line-style)
                      line(
                        (
                          largeur_permiere_colonne
                            + 0.15
                            + if type(table-style.at("stroke")) == c1stroke
                              and table-style.at("stroke").thickness != auto {
                              table-style.at("stroke").thickness.mm() / 10.65
                            } else { 0 },
                          coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                        ),
                        (
                          largeur_permiere_colonne
                            + 0.15
                            + if type(table-style.at("stroke")) == c1stroke
                              and table-style.at("stroke").thickness != auto {
                              table-style.at("stroke").thickness.mm() / 10.65
                            } else { 0 },
                          coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                        ),
                      )
                    }
                    set-style(..table-style)
                  }
                  set-style(..table-style)
                } else if type(contents.at(i).at(-1)) == array and contents.at(i).at(-1).len() == 0 {
                  // On ne fait rien s'il n'y a pas de signe
                } else {
                  content(
                    (
                      (coordX.at(-2).at(0) + coordX.at(-1).at(0)) / 2,
                      coordY.at(i).at(0),
                    ),
                    box(width: 1pt, align(center, contents.at(i).at(-1))),
                    name: "sign" + str(i) + str(contents.at(i).len() - 1),
                  )

                  if (
                    contents.at(i).len() >= 2
                      and not _yatilhach(
                        contents.at(i),
                        contents.at(i).len() - 1 + if contents.at(i).at(-1) == "||" { -1 },
                      )
                  ) {
                    set-style(..line-style)
                    line(
                      (coordX.at(-2).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                      (coordX.at(-2).at(0), coordY.at(i).at(0) + coordY.at(i).at(1) / 2),
                      name: "zero3",
                    )
                    set-style(..table-style) 
                    content("zero3.mid", if line-0 { $ 0 $ } else { [] })
                  }
                }
              }
            }
          }

          // Fin tableau de signe
        }

        // Tableau de variation

        if label.at(i).last() == "v" {
          // panic si il y a plus ou moins d’éléments qu’il faudrais
          if contents.at(i).len() != domain.len() {
            panic("TabVar: Not enough elements in the table number " + str(i + 1))
          }

          for j in range(1, domain.len() - 1) {
            if contents.at(i).at(j).len() == 2 {
              let element = contents.at(i).at(j).last()

              let (x, y) = (
                //les coordonées de l'element
                coordX.at(j).at(0),
                coordY.at(i).at(0)
                  + if contents.at(i).at(j).first() == top {
                    coordY.at(i).at(1) / 2 - 0.3 - measure(contents.at(i).at(j).last()).height.mm() / (2 * 10.65)
                  } else if contents.at(i).at(j).first() == bottom {
                    -coordY.at(i).at(1) / 2 + 0.3 + measure(contents.at(i).at(j).last()).height.mm() / (2 * 10.65)
                  } else { 0 },
              )

              content(
                (
                  x,
                  y,
                ),
                element,
                name: "variation" + str(i) + str(j),
              )

              let indice_proch_ele = _prochain-ele(contents.at(i), j)
              let proch_element = contents.at(i).at(indice_proch_ele)
              let (c1, c2) = _coord-fleche(i, j, false, proch_element.len() > 2, contents.at(i), coordX, coordY)
              set-style(..arrow-style)
              line(
                c1,
                c2,
                mark: arrow-mark,
                name: "arrow" + str(i) + str(j),
              )
              set-style(..table-style)
            } else if contents.at(i).at(j).len() > 2 and contents.at(i).at(j).contains("||") {
              //cas d'une bar indef

              line(
                (
                  coordX.at(j).at(0) - 0.07,
                  coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                ),
                (
                  coordX.at(j).at(0) - 0.07,
                  coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                ),
              )
              line(
                (
                  coordX.at(j).at(0) + 0.07,
                  coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                ),
                (
                  coordX.at(j).at(0) + 0.07,
                  coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                ),
              )

              let element_gauche = contents.at(i).at(j).at(if contents.at(i).at(j).at(1) == "||" { 2 } else { 3 })
              let element_droite = contents.at(i).at(j).last()

              content(
                // éléments à gauche de la bar
                (
                  coordX.at(j).at(0) - measure(element_gauche).width.mm() / (2 * 10.65) - 0.17,
                  coordY.at(i).at(0)
                    + if contents.at(i).at(j).first() == top {
                      coordY.at(i).at(1) / 2 - 0.3 - measure(element_gauche).height.mm() / (2 * 10.65)
                    } else if contents.at(i).at(j).first() == bottom {
                      -coordY.at(i).at(1) / 2 + 0.3 + measure(element_gauche).height.mm() / (2 * 10.65)
                    } else { 0 },
                ),
                element_gauche,
                name: "variation" + str(i) + str(j) + "g",
              )
              content(
                // éléments à droite de la bar
                (
                  coordX.at(j).at(0) + measure(element_droite).width.mm() / (2 * 10.65) + 0.17,
                  coordY.at(i).at(0)
                    + if contents.at(i).at(j).at(if contents.at(i).at(j).at(1) == "||" { 0 } else { 1 }) == top {
                      coordY.at(i).at(1) / 2 - 0.3 - measure(element_droite).height.mm() / (2 * 10.65)
                    } else if contents.at(i).at(j).at(if contents.at(i).at(j).at(1) == "||" { 0 } else { 1 })
                      == bottom {
                      -coordY.at(i).at(1) / 2 + 0.3 + measure(element_droite).height.mm() / (2 * 10.65)
                    } else { 0 },
                ),
                element_droite,
                name: "variation" + str(i) + str(j) + "d",
              )
              // les flèches entre un éléments avec bar et sont prochain non vide
              let proch_element = contents.at(i).at(j + 1)
              let (c1, c2) = _coord-fleche(i, j, true, proch_element.len() > 2, contents.at(i), coordX, coordY)
              set-style(..arrow-style)
              line(
                c1,
                c2,
                mark: arrow-mark,
                name: "arrow" + str(i) + str(j),
              )
              set-style(..table-style)
            } else if contents.at(i).at(j).len() > 2 and contents.at(i).at(j).contains("h") {
              //cas d'un hachurage def à gauche

              let element_gauche = contents.at(i).at(j).at(if contents.at(i).at(j).at(1) == "h" { 2 } else { 3 })

              content(
                // éléments à gauche du hachurage
                (
                  coordX.at(j).at(0) - measure(element_gauche).width.mm() / (2 * 10.65) - 0.1,
                  coordY.at(i).at(0)
                    + if contents.at(i).at(j).first() == top {
                      coordY.at(i).at(1) / 2 - 0.3 - measure(element_gauche).height.mm() / (2 * 10.65)
                    } else if contents.at(i).at(j).first() == bottom {
                      -coordY.at(i).at(1) / 2 + 0.3 + measure(element_gauche).height.mm() / (2 * 10.65)
                    } else { 0 },
                ),
                element_gauche,
                name: "variation" + str(i) + str(j),
              )

              // Le hachurage
              let proch_element = _prochainne-baliseh(contents.at(i), j)
              set-style(..line-style)
              line(
                (
                  coordX.at(j).at(0) + if contents.at(i).at(j).contains("|h") { 0.07 } else { 0 },
                  coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                ),
                (
                  coordX.at(j).at(0) + if contents.at(i).at(j).contains("|h") { 0.07 } else { 0 },
                  coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                ),
              )
              if proch_element != contents.at(i).len() - 1 {
                line(
                  (
                    coordX.at(proch_element).at(0)
                      - if contents.at(i).at(proch_element).contains("H|") { 0.07 } else { 0 },
                    coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                  ),
                  (
                    coordX.at(proch_element).at(0)
                      - if contents.at(i).at(proch_element).contains("H|") { 0.07 } else { 0 },
                    coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                  ),
                )
              }
              set-style(..table-style)
              rect(
                stroke: none,
                (coordX.at(j).at(0), coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                (
                  if proch_element != contents.at(i).len() - 1 {
                    (
                      coordX.at(proch_element).at(0)
                        - if contents.at(i).at(proch_element).contains("H|") { 0.07 } else { 0 }
                    )
                  } else { decalage_domaine },
                  coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                ),
                fill: hatching-style,
                name: "hatching" + str(i) + str(j),
              )
            } else if contents.at(i).at(j).len() > 2 and contents.at(i).at(j).contains("|h") {
              //cas d'un hachurage indef à gauche

              let element_gauche = contents.at(i).at(j).at(if contents.at(i).at(j).at(1) == "|h" { 2 } else { 3 })

              line(
                (
                  coordX.at(j).at(0) - 0.07,
                  coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                ),
                (
                  coordX.at(j).at(0) - 0.07,
                  coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                ),
              )

              content(
                // éléments à gauche du hachurage
                (
                  coordX.at(j).at(0) - measure(element_gauche).width.mm() / (2 * 10.65) - 0.17,
                  coordY.at(i).at(0)
                    + if contents.at(i).at(j).first() == top {
                      coordY.at(i).at(1) / 2 - 0.3 - measure(element_gauche).height.mm() / (2 * 10.65)
                    } else if contents.at(i).at(j).first() == bottom {
                      -coordY.at(i).at(1) / 2 + 0.3 + measure(element_gauche).height.mm() / (2 * 10.65)
                    } else { 0 },
                ),
                element_gauche,
                name: "variation" + str(i) + str(j),
              )

              // Le hachurage
              let proch_element = _prochainne-baliseh(contents.at(i), j)
              set-style(..line-style)
              line(
                (
                  coordX.at(j).at(0) + if contents.at(i).at(j).contains("|h") { 0.07 } else { 0 },
                  coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                ),
                (
                  coordX.at(j).at(0) + if contents.at(i).at(j).contains("|h") { 0.07 } else { 0 },
                  coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                ),
              )
              if proch_element != contents.at(i).len() - 1 {
                line(
                  (
                    coordX.at(proch_element).at(0)
                      - if contents.at(i).at(proch_element).contains("H|") { 0.07 } else { 0 },
                    coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                  ),
                  (
                    coordX.at(proch_element).at(0)
                      - if contents.at(i).at(proch_element).contains("H|") { 0.07 } else { 0 },
                    coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                  ),
                )
              }
              set-style(..table-style)
              rect(
                stroke: none,
                (coordX.at(j).at(0) + 0.07, coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
                (
                  if proch_element != contents.at(i).len() - 1 {
                    (
                      coordX.at(proch_element).at(0)
                        - if contents.at(i).at(proch_element).contains("H|") { 0.07 } else { 0 }
                    )
                  } else { decalage_domaine },
                  coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                ),
                fill: hatching-style,
                name: "hatching" + str(i) + str(j),
              )
            } else if contents.at(i).at(j).len() > 2 and contents.at(i).at(j).contains("H") {
              let element = contents.at(i).at(j).at(if contents.at(i).at(j).at(1) == "H" { 2 } else { 3 })

              content(
                (
                  coordX.at(j).at(0) + measure(element).width.mm() / (2 * 10.65) + 0.1,
                  coordY.at(i).at(0)
                    + if contents.at(i).at(j).first() == top {
                      coordY.at(i).at(1) / 2 - 0.3 - measure(element).height.mm() / (2 * 10.65)
                    } else if contents.at(i).at(j).first() == bottom {
                      -coordY.at(i).at(1) / 2 + 0.3 + measure(element).height.mm() / (2 * 10.65)
                    } else { 0 },
                ),
                element,
                name: "variation" + str(i) + str(j),
              )

              let proch_element = contents.at(i).at(j + 1)
              let (c1, c2) = _coord-fleche(i, j, true, proch_element.len() > 2, contents.at(i), coordX, coordY)
              set-style(..arrow-style)
              line(
                c1,
                c2,
                mark: arrow-mark,
                name: "arrow" + str(i) + str(j),
              )
              set-style(..table-style)
            } else if contents.at(i).at(j).len() > 2 and contents.at(i).at(j).contains("H|") {
              let element = contents.at(i).at(j).at(if contents.at(i).at(j).at(1) == "H|" { 2 } else { 3 })

              line(
                (
                  coordX.at(j).at(0) + 0.07,
                  coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                ),
                (
                  coordX.at(j).at(0) + 0.07,
                  coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                ),
              )

              content(
                (
                  coordX.at(j).at(0) + measure(element).width.mm() / (2 * 10.65) + 0.17,
                  coordY.at(i).at(0)
                    + if contents.at(i).at(j).first() == top {
                      coordY.at(i).at(1) / 2 - 0.3 - measure(element).height.mm() / (2 * 10.65)
                    } else if contents.at(i).at(j).first() == bottom {
                      -coordY.at(i).at(1) / 2 + 0.3 + measure(element).height.mm() / (2 * 10.65)
                    } else { 0 },
                ),
                element,
                name: "variation" + str(i) + str(j),
              )

              let proch_element = contents.at(i).at(j + 1)
              let (c1, c2) = _coord-fleche(i, j, true, proch_element.len() > 2, contents.at(i), coordX, coordY)
              set-style(..arrow-style)
              line(
                c1,
                c2,
                mark: arrow-mark,
                name: "arrow" + str(i) + str(j),
              )
              set-style(..table-style)
            }
          }

          // Dernier éléments
          let der_ele = contents.at(i).at(-1)
          if undefined-bar-alt {

          line(
              (
                coordX.at(-1).at(0) - 0.07,
                coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
              ),
              (
                coordX.at(-1).at(0) - 0.07,
                coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
              ),
            )
            line(
              (
                coordX.at(-1).at(0) + 0.07,
                coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
              ),
              (
                coordX.at(-1).at(0) + 0.07,
                coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
              ),
            )

            let element_gauche = contents.at(i).at(-1).at(if contents.at(i).at(-1).at(1) == "||" { 2 } else { 3 })
            let element_droite = contents.at(i).at(-1).last()

            content(
              // éléments à gauche de la bar
              (
                coordX.at(-1).at(0) - measure(element_gauche).width.mm() / (2 * 10.65) - 0.17,
                coordY.at(i).at(0)
                  + if contents.at(i).at(-1).first() == top {
                    coordY.at(i).at(1) / 2 - 0.3 - measure(element_gauche).height.mm() / (2 * 10.65)
                  } else if contents.at(i).at(-1).first() == bottom {
                    -coordY.at(i).at(1) / 2 + 0.3 + measure(element_gauche).height.mm() / (2 * 10.65)
                  } else { 0 },
              ),
              element_gauche,
              name: "variation" + str(i) + str(-1) + "g",
            )

            set-style(..table-style)

          } else if der_ele.len() > 2 and der_ele.contains("||") {
            //Si il y a une bar indef
            line(
              (
                decalage_domaine - 0.15,
                coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
              ),
              (
                decalage_domaine - 0.15,
                coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
              ),
            )

            content(
              (
                coordX.at(-1).at(0) - 0.17,
                coordY.at(i).at(0)
                  + if contents.at(i).at(-1).first() == top {
                    (
                      coordY.at(i).at(1) / 2 - 0.3 - measure(contents.at(i).at(-1).last()).height.mm() / (2 * 10.65)
                    )
                  } else if contents.at(i).at(-1).first() == bottom {
                    (
                      -coordY.at(i).at(1) / 2 + 0.3 + measure(contents.at(i).at(-1).last()).height.mm() / (2 * 10.65)
                    )
                  } else { 0 },
              ),
              der_ele.last(),
              name: "variation" + str(i) + str(contents.at(i).len() - 1),
            )
          } else if der_ele.len() <= 2 and not (der_ele.contains("H")) and not (der_ele.contains("H|")) {
            content(
              (
                coordX.at(-1).at(0),
                coordY.at(i).at(0)
                  + if contents.at(i).at(-1).first() == top {
                    (
                      coordY.at(i).at(1) / 2 - 0.3 - measure(contents.at(i).at(-1).last()).height.mm() / (2 * 10.65)
                    )
                  } else if contents.at(i).at(-1).first() == bottom {
                    (
                      -coordY.at(i).at(1) / 2 + 0.3 + measure(contents.at(i).at(-1).last()).height.mm() / (2 * 10.65)
                    )
                  } else { 0 },
              ),
              der_ele.last(),
              name: "variation" + str(i) + str(contents.at(i).len() - 1),
            )
          }

          // Premier élément

          let pr_ele = contents.at(i).at(0)
          let indice_proch_element = _prochain-ele(contents.at(i), 0)
          if pr_ele.len() > 2 and pr_ele.contains("||") and not undefined-bar-alt {
            let (c1, c2) = _coord-fleche(
              i,
              0,
              true,
              contents.at(i).at(indice_proch_element).len() > 2,
              contents.at(i),
              coordX,
              coordY,
            )

            {
              set-style(..arrow-style)
              line(
                c1,
                c2,
                mark: arrow-mark,
                name: "arrow" + str(i) + "0",
              )
            }

            set-style(..table-style)

            line(
              (
                largeur_permiere_colonne
                  + 0.15
                  + if type(table-style.at("stroke")) == c1stroke and table-style.at("stroke").thickness != auto {
                    table-style.at("stroke").thickness.mm() / 10.65
                  } else { 0 },
                coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
              ),
              (
                largeur_permiere_colonne
                  + 0.15
                  + if type(table-style.at("stroke")) == c1stroke and table-style.at("stroke").thickness != auto {
                    table-style.at("stroke").thickness.mm() / 10.65
                  } else { 0 },
                coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
              ),
            )

            content(
              (
                coordX.at(0).at(0) + 0.3,
                coordY.at(i).at(0)
                  + if contents.at(i).at(0).at(if contents.at(i).at(0).at(1) == "||" { 0 } else { 1 }) == top {
                    coordY.at(i).at(1) / 2 - 0.3 - measure(contents.at(i).at(0).last()).height.mm() / (2 * 10.65)
                  } else if contents.at(i).at(0).at(if contents.at(i).at(0).at(1) == "||" { 0 } else { 1 }) == bottom {
                    -coordY.at(i).at(1) / 2 + 0.3 + measure(contents.at(i).at(0).last()).height.mm() / (2 * 10.65)
                  } else { 0 },
              ),
              pr_ele.last(),
              name: "variation" + str(i) + "0",
            )
          } else if pr_ele.len() > 2 and pr_ele.contains("||") and undefined-bar-alt { //cas si style de tkz-tab est actif

            line(
                (
                  coordX.at(0).at(0) - 0.07,
                  coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                ),
                (
                  coordX.at(0).at(0) - 0.07,
                  coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                ),
              )
              line(
                (
                  coordX.at(0).at(0) + 0.07,
                  coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                ),
                (
                  coordX.at(0).at(0) + 0.07,
                  coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                ),
              )

              let element_gauche = contents.at(i).at(0).at(if contents.at(i).at(0).at(1) == "||" { 2 } else { 3 })
              let element_droite = contents.at(i).at(0).last()

              content(
                // éléments à droite de la bar
                (
                  coordX.at(0).at(0) + measure(element_droite).width.mm() / (2 * 10.65) + 0.17,
                  coordY.at(i).at(0)
                    + if contents.at(i).at(0).at(if contents.at(i).at(0).at(1) == "||" { 0 } else { 1 }) == top {
                      coordY.at(i).at(1) / 2 - 0.3 - measure(element_droite).height.mm() / (2 * 10.65)
                    } else if contents.at(i).at(0).at(if contents.at(i).at(0).at(1) == "||" { 0 } else { 1 })
                      == bottom {
                      -coordY.at(i).at(1) / 2 + 0.3 + measure(element_droite).height.mm() / (2 * 10.65)
                    } else { 0 },
                ),
                element_droite,
                name: "variation" + str(i) + str(0) + "d",
              )
              // les flèches entre un éléments avec bar et sont prochain non vide
              let proch_element = contents.at(i).at(0 + 1)
              let (c1, c2) = _coord-fleche(i, 0, true, proch_element.len() > 2, contents.at(i), coordX, coordY)
              set-style(..arrow-style)
              line(
                c1,
                c2,
                mark: arrow-mark,
                name: "arrow" + str(i) + str(0),
              )
              set-style(..table-style)

          } else if pr_ele.contains("h") or pr_ele.contains("|h") and not undefined-bar-alt {
            let proch_element = _prochainne-baliseh(contents.at(i), 0)
            if proch_element != contents.at(i).len() - 1 {
              set-style(..line-style)
              line(
                (
                  coordX.at(proch_element).at(0)
                    - if contents.at(i).at(proch_element).contains("H|") { 0.07 } else { 0 },
                  coordY.at(i).at(0) - coordY.at(i).at(1) / 2,
                ),
                (
                  coordX.at(proch_element).at(0)
                    - if contents.at(i).at(proch_element).contains("H|") { 0.07 } else { 0 },
                  coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
                ),
              )
              set-style(..table-style)
            }
            rect(
              stroke: none,
              (largeur_permiere_colonne, coordY.at(i).at(0) - coordY.at(i).at(1) / 2),
              (
                if proch_element != contents.at(i).len() - 1 {
                  (
                    coordX.at(proch_element).at(0)
                      - if contents.at(i).at(proch_element).contains("H|") { 0.07 } else { 0 }
                  )
                } else { decalage_domaine },
                coordY.at(i).at(0) + coordY.at(i).at(1) / 2,
              ),
              fill: hatching-style,
              name: "hatching" + str(i) + "0",
            )
          } else {
            let (c1, c2) = _coord-fleche(
              i,
              0,
              false,
              contents.at(i).at(indice_proch_element).len() > 2,
              contents.at(i),
              coordX,
              coordY,
            )

            set-style(..arrow-style)
            line(
              c1,
              c2,
              mark: arrow-mark,
              name: "arrow" + str(i) + "0",
            )
            set-style(..table-style)

            content(
              (
                coordX.at(0).at(0),
                coordY.at(i).at(0)
                  + if contents.at(i).at(0).first() == top {
                    coordY.at(i).at(1) / 2 - 0.3 - measure(contents.at(i).at(0).last()).height.mm() / (2 * 10.65)
                  } else if contents.at(i).at(0).first() == bottom {
                    -coordY.at(i).at(1) / 2 + 0.3 + measure(contents.at(i).at(0).last()).height.mm() / (2 * 10.65)
                  } else { 0 },
              ),
              pr_ele.last(),
              name: "variation" + str(i) + "0",
            )
          }
        }
      }

      if values != ((),) {
        let coulfleche = if type(values.last()) != array { values.last() } else { black }

        let longeur = if type(values.last()) != array { values.len() - 1 } else { values.len() }

        for i in range(longeur) {
          content(
            ("line-centred-domain", "-|", values.at(i).at(0)),
            values.at(i).at(1),
            name: "depart_values" + str(i),
            padding: .35,
          )

          let fill-color = if fill-color == page.fill { white } else { fill-color }

          content(
            values.at(i).at(0),
            values.at(i).at(2),
            name: "fin_values" + str(i),
            frame: "circle",
            fill: fill-color,
            stroke: none,
            padding: 0.05,
          )

          if values.at(i).len() == 4 {
            if values.at(i).at(3) == "f" {
              line(
                "depart_values" + str(i) + ".south",
                "fin_values" + str(i) + ".north",
                stroke: (thickness: .6pt, paint: coulfleche),
                mark: arrow-mark,
                fill: coulfleche,
              )
            } else {
              if values.at(i).at(3) == "l" {
                line("depart_values" + str(i) + ".south", "fin_values" + str(i) + ".north", stroke: (
                  thickness: .6pt,
                  paint: coulfleche,
                ))
              }
            }
          }
        }
      }

      set-style(..table-style)
      add
    })
  }
}

// ---------------------------------------------------------------------
// الأسماء المُصدَّرة : tabpos و tabvar (نفس الدالة) وأنماط التهشير
// ---------------------------------------------------------------------
#let tabpos = tabvar
