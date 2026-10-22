// Vitrine de la suite farfadet : un cours, une fiche d'exercices et une interrogation
// sur les fonctions affines (seconde), en trois pages.
//
// Un même fichier donne deux versions :
//   - professeur (par défaut) : réponses en couleur, bonnes réponses du QCM marquées ;
//   - élève : `--input correction=false`, les mêmes places restent vides.
//
//   typst compile vitrine.typ vitrine-prof.pdf
//   typst compile --input correction=false vitrine.typ vitrine-eleve.pdf
//
// Ce qu'elle montre, page par page :
//   1. modele, sections, Definition, Remarque, Propriete, Methode, Exemple, acc, encadrer,
//      MultiColonnes, tabvar (farfadet-tabvar), tcbtab (farfadet-tableaux), geo (farfadet-geom), crep ;
//   2. chapitre, EXO (niveaux, correction-as-lower), tcbenumerate, tcfillcrep, crep Seyès,
//      figure qui dépend de la version (ifcorrection), Mcq / McqQuest, vrai-faux, rd.attention (rdboites) ;
//   3. chapEval + tableauEval, EXOEVAL, itempoint et score, tccrep, rdsheet (tableur),
//      tableaucompetence + competence, total calculé (getsavedtotalpoints).

#import "@preview/farfadet:0.2.0": *

#show: modele(
  "cours",
  niveau: "2nde",
  theme: [Fonctions affines],
  type-document: "cours",
  cycle: [Lycée],
)

#setrdcrep(seyes: true)

// =====================================================================
// Page 1 : le cours
// =====================================================================

= Définition et premières propriétés

#definition[Fonction affine][
  Une fonction $f$ définie sur $RR$ est #acc[affine] s'il existe deux réels $m$ et $p$ tels que,
  pour tout réel $x$, #box($f(x) = m x + p$). Le réel $m$ est le #acc[coefficient directeur], $p$ l'#acc[ordonnée à l'origine].
]

#multi-colonnes(2)[
  - #remarque[Cas particuliers][
      - si $p = 0$, $f(x) = m x$ : $f$ est #acc[linéaire] ;
      - si $m = 0$, $f(x) = p$ : $f$ est #acc[constante].
    ]
  - #propriete[Taux d'accroissement][
      Pour tous réels $a != b$ :
      #align(center, encadrer($m = display((f(b) - f(a)) / (b - a))$))
    ]
]

#propriete[Sens de variation][
  #multi-colonnes(2)[
    - Si $m > 0$, $f$ est croissante sur $RR$.
      #align(center, tabvar(("-oo", "+oo"), tkz-tab-var($f(x)$, "-", "+", h: 1.4)))
    - Si $m < 0$, $f$ est décroissante sur $RR$.
      #align(center, tabvar(("-oo", "+oo"), tkz-tab-var($f(x)$, "+", "-", h: 1.4)))
  ]
]

= Représentation graphique

#propriete[Une droite][
  Dans un repère, la courbe représentative de $x |-> m x + p$ est une #acc[droite] non parallèle à l'axe des ordonnées :
  elle coupe cet axe au point de coordonnées $(0 ; p)$, et quand $x$ augmente de $1$, $y$ varie de $m$.
]

#methode[Retrouver $f$ à partir de deux points][
  On calcule $m$ par le taux d'accroissement, puis $p$ en écrivant que l'un des points est sur la droite.
]

#exemple[La droite $(A B)$ avec $A(1 ; 3)$ et $B(3 ; -1)$][
  #multi-colonnes(largeurs: (3, 2))[
    - $m = display((-1 - 3) / (3 - 1)) = display((-4) / 2) = -2$. Puis $f(1) = 3$ donne $-2 times 1 + p = 3$, soit $p = 5$.

      #tcbtab(6, entete-colonne: true, align: center,
        [$x$], [$-1$], [$0$], [$1$], [$2$], [$3$],
        [$f(x)$], [$7$], [$5$], [$3$], [$1$], [$-1$],
      )

      Conclusion :
      #crep[$f(x) = -2 x + 5$ ; comme $m < 0$, $f$ est décroissante sur $RR$.]
    - #align(center, geo(unite: 0.5cm, {
        repere(x: (0, 4), y: (-2, 6), pas-graduation: 2)
        droite((1, 3), (3, -1), couleur: "bleu")
        point((1, 3), "A", pos: "e")
        point((3, -1), "B", pos: "so")
        point((0, 5), $p$, pos: "e", couleur: "rouge")
      }))
  ]
]

// =====================================================================
// Page 2 : la fiche d'exercices
// =====================================================================
#pagebreak()
#chapitre(niveau: "2nde", theme: [Fonctions affines], type: "exercices")

#exo(level: 1, correction-as-lower: true)[Reconnaître une fonction affine][
  Pour chaque fonction définie sur $RR$, dire si elle est affine ; si oui, donner $m$ et $p$.
  #tcbenumerate(columns: 2)[
    + $f(x) = 3 x - 2$ #tcfillcrep[affine : $m = 3$, $p = -2$]
    + $g(x) = (2 x + 5) / 3$ #tcfillcrep[affine : $m = 2/3$, $p = 5/3$]
    + $h(x) = x^2 + 1$ #tcfillcrep[non affine]
    + $k(x) = (x + 1)^2 - x^2$ #tcfillcrep[affine : $m = 2$, $p = 1$]
  ]
  #exocorrection
  $k(x) = x^2 + 2 x + 1 - x^2 = 2 x + 1$ : le terme en $x^2$ disparaît, $k$ est affine.
]

#exo(level: 2)[Déterminer une expression][
  #multi-colonnes(largeurs: (3, 2))[
    - $f$ est une fonction affine telle que $f(-2) = 2$ et $f(4) = 5$.
      #tcbenumerate[
        + Calculer le coefficient directeur $m$.
          #crep[$m = (5 - 2) slash (4 - (-2)) = 3 slash 6 = 0","5$]
        + En déduire $p$, puis l'expression de $f(x)$.
          #crep[$p = 5 - 0","5 times 4 = 3$, d'où $f(x) = 0","5 x + 3$.]
        + Tracer la droite représentant $f$ dans le repère ci-contre.
      ]
    - #let figure-exo(trace) = geo(unite: 0.5cm, {
        repere(x: (-3, 5), y: (0, 6), pas-graduation: (2, 1))
        if trace {
          droite((-2, 2), (4, 5), couleur: "rouge")
          point((-2, 2), "C", pos: "se")
          point((4, 5), "D", pos: "se")
        }
      })
      // la droite n'apparaît que dans la version professeur
      #align(center, ifcorrection[#figure-exo(true)][#figure-exo(false)])
  ]
]

#exo(level: 1)[QCM][
  Pour chaque question, cocher la bonne réponse.
  #mcq(style: "Troyes", question-width: 8.5cm)[
    #mcq-quest(br: 1)[Coefficient directeur de $f(x) = 5 - 3 x$ :][$-3$][$5$][$3$]
    #mcq-quest(br: 2)[Sens de variation de $x |-> -0","5 x + 4$ :][croissante][décroissante][constante]
    #mcq-quest(br: 1)[$f$ affine, $f(2) = 7$, $f(5) = 13$ ; $m$ vaut :][$2$][$6$][$3$]
    #mcq-quest(br: 2)[La fonction $x |-> 2 x - 6$ s'annule en :][$-6$][$3$][$-3$]
  ]
]

#exo(level: 2)[Vrai ou faux][
  Pour chaque affirmation, cocher #frquote[Vrai] ou #frquote[Faux], puis justifier.
  #vrai-faux(
    lignes-justification: 1,
    affirmation(vrai: false, justification: [$m = (7 - 1) slash (3 - 0) = 2$, et non $3$.])[
      La droite passant par $(0 ; 1)$ et $(3 ; 7)$ a pour coefficient directeur $3$.
    ],
    affirmation(vrai: true, justification: [$f(x) = 0 times x + 4$ : c'est le cas $m = 0$.])[
      La fonction constante $x |-> 4$ est une fonction affine.
    ],
  )
]

#rd.attention[Une droite parallèle à l'axe des ordonnées ne représente aucune fonction affine.]

// =====================================================================
// Page 3 : l'interrogation
// =====================================================================
#pagebreak()
#chap-eval(niveau: "2nde", theme: [Fonctions affines], type: [Interrogation :], apres: tableau-eval(30))
#displayitempoints(true)
#setrdexo(numexo: 0)   // l'interrogation repart de l'exercice 1

#exo-eval(tags: "Modéliser une situation")[Location de vélos][
  Une ville propose deux formules : #acc[A] coûte $2","50$ € par heure ; #acc[B] coûte $6$ € d'abonnement plus $1","50$ € par heure.
  On note $x$ la durée de location en heures, $f_A (x)$ et $f_B (x)$ les prix correspondants.

  #multi-colonnes(largeurs: (3, 2))[
    - #tcbenumerate[
        + #itempoint(2)[Exprimer $f_A (x)$ et $f_B (x)$ en fonction de $x$.]
          #crep[$f_A (x) = 2","5 x$ (linéaire) et $f_B (x) = 1","5 x + 6$.]
        + #itempoint(1)[Quelle formule a-t-on saisie en C2 avant de la recopier vers le bas ?
            #tccrep(4cm)[#raw("=1,5*A2+6")]]
      ]
    - // la barre de formule ne montre la réponse que dans la version professeur
      #rdsheet(select: "C2", bar: true, formula: ifcorrection[#raw("=1,5*A2+6")][],
        ("Heures", "Prix A", "Prix B"),
        ("1", "2,5", "7,5"), ("2", "5", "9"), ("4", "10", "12"), ("6", "15", "15"), ("8", "20", "18"))
  ]
  #tcbenumerate(columns: 2, depart: 3)[
    + #itempoint(2)[Résoudre $f_A (x) < f_B (x)$ et interpréter.]
      #crep[$2","5 x < 1","5 x + 6 <=> x < 6$ : \ A est moins chère avant $6$ h.]
    + #itempoint(1)[Donner le sens de variation de $f_B$. Justifier.]
      #crep[$m = 1","5 > 0$, donc $f_B$ est croissante.]
  ]
]

#exo[Lecture graphique][
  #multi-colonnes(largeurs: (2, 3))[
    - #align(center, geo(unite: 0.45cm, {
        repere(x: (0, 5), y: (-2, 5), pas-graduation: (1, 2))
        droite((0, -1), (2, 3), couleur: "bleu")
        droite((0, 3), (3, 1), couleur: "rouge")
        point((2, 3), $d_1$, pos: "e", couleur: "bleu")
        point((3, 1), $d_2$, pos: "ne", couleur: "rouge")
      }))
    - Les droites $d_1$ et $d_2$ représentent deux fonctions affines $f_1$ et $f_2$.
      #tcbenumerate[
        + #itempoint(1)[Lire l'ordonnée à l'origine et le coefficient directeur de $d_1$.]
          #crep[$p = -1$ et $m = 4 slash 2 = 2$, donc $f_1 (x) = 2 x - 1$.]
        + #itempoint(1)[Même question pour $d_2$, puis donner $f_2 (x)$.]
          #crep[$p = 3$ et $m = -2/3$, donc $f_2 (x) = -2/3 x + 3$.]
      ]
  ]
]

#multi-colonnes(largeurs: (4, 1))[
  - #tableaucompetence(
      competence(code: "C1")[Reconnaître une fonction affine],
      competence(code: "C2")[Lire $m$ et $p$ sur un graphique],
      competence(code: "C3")[Modéliser par une fonction affine],
    )
  - #align(center + horizon)[*Bilan* \ #v(0.6em) #tccrep(seyes: false, 1.2cm)[] / #getsavedtotalpoints()]
]
