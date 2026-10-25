// reglages.typ (farfadet-modele) — description des réglages du paquet, par le mécanisme du socle.
//
// Un seul registre « modele » (état « bfr-modele »), cinq types :
//   bfcours       le modèle de document (texte, polices, équations, sommaire, jeu de titres) ;
//   chapitre      le bandeau de \chapitre ;
//   chapEval      le bandeau de \chapEval ;
//   pied-de-page  le pied de page (fancyhdr, style monStyle) ;
//   SequenceItem  la ligne d'une progression (bfcours-commands).
// Réglé par `setbfmodele` (src/reglages.typ).
//
// Toutes les valeurs par défaut sont celles qui étaient codées en dur dans le moteur : le rendu par
// défaut ne change pas. Les clés de PAGE du modèle (papier, marges, decalage, avec-page, pied) ne sont
// pas ici : Typst interdit `set page` dans un `context`, ce sont des arguments de `farfadet`.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: (
  reglages-paquet, reglages-controles, reglages-choix, reglages-ou, bf-nommee, tailles-latex, ptl,
)

// Contrôles propres au paquet
#let _taille = reglages-ou(
  reglages-choix(..tailles-latex.at("12pt").keys()),
  reglages-controles.longueur,
)
#let _longueur-ou-auto = reglages-controles.longueur-ou-auto
#let _contenu-ou-auto = reglages-ou(reglages-controles.contenu, reglages-choix(auto))
#let _polices = (v => type(v) == array and v.all(x => type(x) == str), "une liste de noms de polices")

// Polices de la variante dys (bfcours-fonts : \choiceFontsDys{Fira|lmodern|tgheros}).
// Les polices absentes du poste sont remplacées par la suivante de la liste.
#let polices-dys = (
  Fira: (texte: ("Fira Sans", "Source Sans Pro", "Noto Sans"), maths: ("Fira Math", "New Computer Modern Math")),
  lmodern: (texte: ("Latin Modern Sans",), maths: ("New Computer Modern Math",)),
  tgheros: (texte: ("TeX Gyre Heros",), maths: ("New Computer Modern Math",)),
)
// Jeux de titres (clé `titres`) : le rendu est dans le sectionnement de farfadet-didactique.
#let _jeux-titres = ("bfcours", "sobre", "classique", "documentation", "rd")

#let _police-dys = (
  v => v in polices-dys.keys() or (type(v) == dictionary and "texte" in v and "maths" in v),
  "\"Fira\", \"lmodern\", \"tgheros\" ou un dictionnaire (texte: (…), maths: (…))",
)

// ---------------------------------------------------------------------
// Identité de l'auteur (ajout 11/10/2026) : clés communes aux bandeaux et au pied de page. Elles se
// règlent une fois pour toutes (`setbfmodele(pour: "identite", …)` ou réglage global) et ne s'affichent
// que si un rendu ou la clé `champs` les demande : par défaut, le rendu ne change pas.
// ---------------------------------------------------------------------
#let champs-identite = ("cycle", "etablissement", "professeur", "academie", "annee", "classe", "matiere", "logo", "mentions")
#let _identite = (
  cycle: [],
  etablissement: [],
  professeur: [],
  academie: [],
  annee: [],
  classe: [],
  matiere: [],
  logo: none, // un contenu : image("logo.png") (chemin lu dans le document qui l'écrit) ou un dessin
  mentions: [], // licence, mention légale, adresse…
)

// Rendus intégrés de l'en-tête (clé `rendu`) ; une fonction `d => contenu` est aussi acceptée.
#let rendus-entete = ("bf", "rd", "sobre", "encadre")
// Champs que la clé `champs` (et les zones du pied) peut citer par leur nom.
#let noms-champs = ("niveau", "type", "theme", "titre", "zone") + champs-identite
#let _zones-entete = ("gauche", "centre", "droite")
#let _element-champ(x) = type(x) in (str, content, symbol, function)
#let _liste-champs(v) = v == none or _element-champ(v) or (type(v) == array and v.all(_element-champ))
#let _champs = (
  v => v == auto or (type(v) == dictionary and v.keys().all(k => k in _zones-entete) and v.values().all(_liste-champs)),
  "auto ou un dictionnaire (gauche: (…), centre: (…), droite: (…)) dont chaque zone est none ou une liste de noms de champs ("
    + noms-champs.map(n => "\"" + n + "\"").join(", ") + "), de contenus ou de fonctions d => contenu",
)
#let _zone-pied = reglages-ou(
  reglages-controles.contenu,
  reglages-choix(auto),
  (v => type(v) in (array, function), "une liste de noms de champs (\"professeur\", \"annee\", \"numero\"…) ou une fonction d => contenu"),
)
#let _rendu-entete = (
  v => (type(v) == str and v in rendus-entete) or type(v) == function,
  rendus-entete.map(n => "\"" + n + "\"").join(", ") + " ou une fonction d => contenu",
)
#let _largeurs = (
  v => v == auto or (type(v) == array and v.len() == 3),
  "auto ou trois largeurs de colonnes (gauche, centre, droite), par exemple (auto, 1fr, auto)",
)
// Séparateur entre le libellé du type et le thème (ajout 11/10/2026) : `auto` (défaut) écrit « : »
// (« Cours : Thème »), ou l'espace d'origine si le libellé finit déjà par deux-points ; un contenu le remplace.
#let _separateur-type = (
  v => v == auto or type(v) in (content, str, symbol),
  "auto (« : », ou une espace si le libellé finit déjà par deux-points) ou un contenu, par exemple [ – ], \" - \" (un tiret simple s'écrit en chaîne), [ -- ] ou [ ] (une simple espace)",
)
// Libellés des types de document (clé `libelles-types`) : (cours: [Leçon], tp: [TP]) ; fusionnés avec les défauts.
#let _libelles-types = (
  v => type(v) == dictionary and v.pairs().all(((k, x)) => k.len() > 0 and type(x) in (content, str, symbol)),
  "un dictionnaire (type: libellé) dont chaque libellé est un contenu, par exemple (cours: [Leçon], exercices: [Entraînement], tp: [TP]) ; "
    + "les types non cités gardent leur libellé (cours, exercices, activite, fiche, evaluation)",
)

// ---------------------------------------------------------------------
// Bandeau (\chapitre, \chapEval)
// ---------------------------------------------------------------------
#let _bandeau = _identite + (
  niveau: [],
  theme: [],
  zone-droite: [],
  type: "cours",
  libelles-types: (:), // libellés des types de document, fusionnés avec les défauts (ajout 11/10/2026)
  separateur-type: auto, // entre le type et le thème ; auto : « : » (espace seule si le libellé finit par « : »)
  pied: true, // false : le bandeau ne renseigne pas le pied de page
  // rendu de l'en-tête (ajout 11/10/2026) : "bf" (ce rendu-ci, défaut), "rd" (bandeau `rd.entete` de rdboites),
  // "sobre", "encadre", ou une fonction d => contenu
  rendu: "bf",
  skin: (:), // options du rendu (d.options) ; pour "rd" : clés de `rd.entete`
  champs: auto, // champs affichés par zone : (gauche: (…), centre: (…), droite: (…)) ; auto : ceux du rendu
  police-titre: auto, // auto : police du texte
  graisse-titre: auto, // auto : celle du rendu
  police-champs: auto,
  taille-champs: "footnotesize", // champs d'identité (établissement, professeur…) affichés dans une zone
  couleur-champs: auto, // auto : couleur du texte
  couleur-fond: auto, // auto : dégradé couleur-debut → couleur-fin ("bf"), aucun fond (autres rendus)
  hauteur-logo: auto, // auto : hauteur du carré ("bf"), 1,2 cm sinon
  largeurs: auto, // colonnes gauche, centre, droite des rendus "rd", "sobre", "encadre"
  hauteur: 1.5cm, // height=1.5cm de la tcolorbox
  hauteur-etiquette: 1.4cm, // carré de niveau
  colonnes: 9, // raster columns
  colonnes-titre: 6, // raster multicolumn du titre (6 pour \chapitre, 4 pour \chapEval)
  boxsep: 1mm,
  gouttiere: ptl(5), // raster column skip
  epaisseur-filet: auto, // auto : 1 pt TeX (borderline north/south de "bf") ; 0,6 pt pour "sobre" et "encadre"
  couleur-filet: black, // le dégradé demandé par bfcours n'est pas appliqué au trait par tcolorbox
  couleur-debut: bf-nommee("gray!60"), // interior style : left color
  couleur-fin: bf-nommee("gray!10"), // right color
  couleur-etiquette: bf-nommee("gray!60"), // fond du carré de niveau
  couleur-niveau: black, // texte du niveau
  couleur-contour: white, // \contour{white}
  epaisseur-contour: 0.64pt,
  couleur-titre: auto, // auto : couleur d'accent (\acc) pour "bf", couleur du texte pour "sobre" et "encadre"
  taille-niveau: "Large",
  taille-titre: "large",
  espace-avant-type: 0.34em, // retour à la ligne du source LaTeX, avant #6
  espace-type-theme: 0.39em, // et entre #6 et #2
  espace-apres: 9.47pt, // espace fort après le bandeau (+ 1,65 pt faibles d'une section)
)

// ---------------------------------------------------------------------
// Le registre
// ---------------------------------------------------------------------
#let modele-reglages = reglages-paquet(
  "modele",
  (:),
  controles: (
    // document
    correction: reglages-controles.booleen,
    fontsize: _longueur-ou-auto,
    fleqn: reglages-controles.booleen,
    mathindent: _longueur-ou-auto,
    baselineskip: _longueur-ou-auto,
    abovedisplayskip: reglages-controles.longueur,
    belowdisplayskip: reglages-controles.longueur,
    dys: reglages-controles.booleen,
    police-dys: _police-dys,
    etirement-interligne: reglages-ou(reglages-controles.nombre, reglages-choix(auto)),
    espace-mot: reglages-ou(reglages-controles.longueur, reglages-choix(none, auto)),
    justifier: reglages-ou(reglages-controles.booleen, reglages-choix(auto)),
    police: reglages-ou(reglages-controles.tout, reglages-choix(auto)),
    police-maths: reglages-ou(reglages-controles.tout, reglages-choix(auto)),
    echelle-fourier: reglages-ou(reglages-controles.nombre, reglages-choix(auto)),
    echelle-police: reglages-ou(reglages-controles.nombre, reglages-choix(auto)),
    echelle-maths: reglages-ou(reglages-controles.nombre, reglages-choix(auto)),
    tracking-gras: _longueur-ou-auto,
    espace-mot-min: reglages-controles.longueur,
    espace-mot-max: reglages-controles.longueur,
    correction-fraction-haut: reglages-controles.longueur,
    correction-fraction-bas: reglages-controles.longueur,
    ecart-colonnes-matrice: reglages-controles.longueur,
    titres: reglages-choix(.._jeux-titres),
    numeros: reglages-ou(
      reglages-choix(auto, "arabe", "romain", "lettres"),
      (v => type(v) == array, "un tableau de motifs Typst, un par niveau"),
    ),
    sommaire: reglages-controles.booleen,
    titre-sommaire: reglages-controles.contenu,
    colonnes-sommaire: reglages-controles.entier,
    environnements: reglages-ou(reglages-controles.tout, reglages-choix(none)),
    // bandeau
    niveau: reglages-controles.contenu,
    theme: reglages-controles.contenu,
    cycle: reglages-controles.contenu,
    etablissement: reglages-controles.contenu,
    zone-droite: reglages-controles.contenu,
    type: reglages-controles.contenu,
    apres: reglages-controles.contenu,
    pied: reglages-controles.booleen,
    colonnes: reglages-controles.entier,
    colonnes-titre: reglages-controles.entier,
    couleur-filet: reglages-controles.couleur-ou-nom,
    couleur-debut: reglages-controles.couleur-ou-nom,
    couleur-fin: reglages-controles.couleur-ou-nom,
    couleur-etiquette: reglages-controles.couleur-ou-nom,
    couleur-niveau: reglages-controles.couleur-ou-nom,
    couleur-contour: reglages-controles.couleur-ou-nom,
    couleur-titre: reglages-ou(reglages-controles.couleur-ou-nom, reglages-choix(auto)),
    taille-niveau: _taille,
    taille-titre: _taille,
    espace-avant-type: reglages-controles.longueur,
    espace-type-theme: reglages-controles.longueur,
    separateur-type: _separateur-type,
    libelles-types: _libelles-types,
    // identité (ajout 11/10/2026)
    professeur: reglages-controles.contenu,
    academie: reglages-controles.contenu,
    annee: reglages-controles.contenu,
    classe: reglages-controles.contenu,
    matiere: reglages-controles.contenu,
    mentions: reglages-controles.contenu,
    logo: reglages-controles.contenu-ou-none,
    // rendu et réglage fin de l'en-tête (ajout 11/10/2026)
    rendu: _rendu-entete,
    skin: (v => type(v) == dictionary, "un dictionnaire d'options (icone: …, colframe: …)"),
    champs: _champs,
    police-titre: reglages-ou(reglages-controles.tout, reglages-choix(auto)),
    graisse-titre: reglages-ou(reglages-controles.tout, reglages-choix(auto)),
    police-champs: reglages-ou(reglages-controles.tout, reglages-choix(auto)),
    taille-champs: _taille,
    couleur-champs: reglages-ou(reglages-controles.couleur-ou-nom, reglages-choix(auto)),
    couleur-fond: reglages-ou(reglages-controles.couleur-ou-nom, reglages-choix(auto, none)),
    hauteur-logo: _longueur-ou-auto,
    largeurs: _largeurs,
    epaisseur-filet: _longueur-ou-auto,
    separateur: _contenu-ou-auto,
    // pied de page
    disposition: reglages-ou(
      reglages-choix("bfcours", "simple"),
      (v => type(v) == function, "une fonction d => contenu"),
    ),
    gauche: _zone-pied,
    centre: _zone-pied,
    droite: _zone-pied,
    numero: reglages-controles.booleen,
    taille: _taille,
    graisse: reglages-controles.tout,
    couleur-texte: reglages-controles.couleur-ou-nom,
    couleur-disque: reglages-controles.couleur-ou-nom,
    couleur-numero: reglages-controles.couleur-ou-nom,
    // SequenceItem
    couleur: reglages-controles.couleur-ou-nom,
    retrait: _longueur-ou-auto,
    fond-description: reglages-controles.longueur,
    fond-commentaire: reglages-controles.longueur,
    ombre: reglages-controles.booleen,
  ),
  types: (
    // --- le modèle de document -----------------------------------------------
    bfcours: (
      correction: true, // version professeur ; `--input correction=…` l'emporte
      fontsize: auto, // \normalsize NOMINAL : auto = 12 pt (scrextend), 14 pt en dys
      fleqn: true, // équations à gauche, en retrait de \mathindent
      mathindent: auto, // auto : 27,37 pt TeX
      baselineskip: auto, // auto : 14,5 pt TeX (dys : 1,2 × la taille)
      abovedisplayskip: ptl(12),
      belowdisplayskip: ptl(12),
      dys: false, // police et interlignage adaptés (bfcours-fonts, option dys)
      police-dys: "Fira", // \choiceFontsDys
      etirement-interligne: auto, // \setstretch : auto = 1 (dys : 1,2)
      espace-mot: auto, // \spaceskip : auto = none (dys : 0,8 em)
      justifier: auto, // auto : oui (dys : non)
      police: auto, // auto : Erewhon, repli Libertinus Serif (dys : police-dys)
      police-maths: auto, // auto : Erewhon Math, repli New Computer Modern Math (intégrée à Typst)
      echelle-fourier: auto, // auto : 11/12 (dys : 1)
      echelle-police: auto, // auto : 1,065 (dys : 1)
      echelle-maths: auto, // auto : 1 (formules à la taille du texte)
      tracking-gras: auto, // auto : -0,009 em (dys : 0)
      espace-mot-min: 100% * (0.207 - 0.05) / 0.207, // espace d'Utopia : 0,207, se resserre de 0,05…
      espace-mot-max: 160%, // … et s'étire de 0,124
      correction-fraction-haut: 1.9pt, // fractions de Fourier plus hautes que celles d'Erewhon Math
      correction-fraction-bas: 2.3pt,
      ecart-colonnes-matrice: ptl(10), // \arraycolsep × 2
      titres: "bfcours", // jeu de titres : "bfcours" (bandeaux des cours), "sobre", "classique", "documentation", "rd"
      numeros: auto, // numérotation des titres : auto (réglage de setbfsections, "arabe" par défaut), "arabe", "romain", "lettres" ou un tableau de motifs
      sommaire: false,
      titre-sommaire: [Table des matières],
      colonnes-sommaire: 2,
      environnements: none, // même contenu que les arguments de `regler-environnements`
    ),
    // --- bandeaux -------------------------------------------------------------
    chapitre: _bandeau,
    chapEval: _bandeau + (
      type: "evaluation",
      apres: [], // contenu placé sous le bandeau
      colonnes-titre: 4, // la zone de droite porte Classe et Date
      espace-type-theme: 0.25em,
      // \chapEval est suivi du cartouche (`apres`), posé comme un tcbraster : l'espace est celui de
      // « after skip balanced » de la tcolorbox du bandeau (0,5 \baselineskip), pas celui d'un titre.
      espace-apres: ptl(7.25),
    ),
    // --- pied de page ---------------------------------------------------------
    "pied-de-page": _identite + (
      // "simple" : filet fin, texte à gauche, numéro au centre, texte à droite ; ou une fonction d => contenu
      disposition: "bfcours",
      gauche: auto, // auto : « type thème » du dernier bandeau ; ou une liste de champs ("professeur", "annee"…)
      centre: auto, // auto : le numéro de page (disposition "simple")
      droite: auto, // auto : « cycle établissement »
      separateur: auto, // entre les champs d'une liste ; auto : «  · »
      separateur-type: auto, // entre « type » et « thème » ; auto : celui du dernier bandeau
      hauteur-logo: auto, // auto : 1 em
      numero: true,
      hauteur: ptl(30), // \footskip
      epaisseur-filet: 0.3985pt, // \footrulewidth
      position-filet: 14.65pt, // distance du filet au bas de la zone
      couleur-filet: black,
      taille: "scriptsize",
      graisse: "bold",
      couleur-texte: black,
      espace-avant-type: 0.2em,
      espace-type-theme: 0.59em,
      decalage-droite: 30%, // la zone de droite commence à 30 % de la largeur…
      largeur-droite: 40%, // … et occupe 40 %
      rayon: 7.815pt, // disque du numéro (nœud TikZ circle, scale=0.8)
      decalage-numero: 7.815pt,
      couleur-disque: bf-nommee("gray!80!black"),
      couleur-numero: white,
      echelle-numero: 0.8,
    ),
    // --- une ligne de progression (SequenceItem) -------------------------------------------
    SequenceItem: (
      couleur: bf-nommee("myblue"),
      couleur-texte: white,
      hauteur: 3cm,
      largeur-forme: 3cm,
      largeur-boite: 15cm,
      largeur-texte: 2.5cm,
      pointe: 0.7cm, // signal pointer angle 130°
      fond-description: 25%, // colback = myblue!25!white
      fond-commentaire: 10%, // colbacklower = myblue!10!white
      rayon: 4pt,
      epaisseur: 0.5mm,
      ombre: true, // drop lifted shadow
      retrait: 0pt,
    ),
  ),
  // groupes (ajout 11/10/2026) : `pour: "entete"` règle les deux bandeaux ; `pour: "identite"` les bandeaux
  // et le pied de page (les clés d'identité y sont toutes)
  groupes: (
    entete: ("chapitre", "chapEval"),
    identite: ("chapitre", "chapEval", "pied-de-page"),
  ),
  commande: "setbfmodele",
)
