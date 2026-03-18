// ---- Variables ---- //

// Identificateurs
#let identificateur-titre = [x309QfWkIO]
#let identificateur-annexe = [U2pWAy70cU]
#let identificateur-sous-titre-annexe = [4rS78a14Pv]


// Couleurs
#let couleur-rouge = color.red
#let couleur-vert = color.rgb(0, 169, 51)
#let couleur-bleu = color.rgb(52, 101, 164)
#let couleur-bleu-legende = color.rgb(0,69,134)
#let couleur-pourpre = color.rgb(166,77,121)


// Polices
#let police-base = 12pt

#let police-en-tete = police-base - 1.5pt
#let police-pied-page = police-base - 2pt

#let police-titre = police-base + 6pt

#let police-stitre-1 = police-base + 2pt
#let police-stitre-2 = police-base + 1pt
#let police-stitre-3 = police-base

#let police-legende = police-base - 2pt

#let police-style-base = "HK Grotesk"
#let police-style-stitre = "HK Grotesk"


// Longueurs
#let tabulation = 0.76cm
#let titre-tabulation = 0.50cm
#let titre-demi-tabulation = titre-tabulation / 2
#let titre-tabulation-annexe = 0.33cm
#let tab-numerotation = 0.2cm
#let tab-sommaire = 0.4cm

#let espace-vert-titres = 0.15cm

// Divers
#let profondeur-sommaire = 3
#let style-numerotation-global = "I.1.A.1."
#let style-numerotation-annexes = "A.1.A.1"
#let nom-annexe = "Annexe"
#let nom-annexe-s = nom-annexe + "s"



// ---- Template ---- //

#let ttuile(
  // Titre du TP ; `content?`.
  titre: none,
  
  // Liste des auteurs ; `array<str> | content?`.
  auteurs: none,

  // Nom ou numéro du groupe de TD ; `content?`.
  groupe: none,

  // Numéro du TP ; `content?`.
  numero-tp: none,

  // Numéro du poste auquel a été réalisé le TP ; `content?`.
  numero-poste: none,

  // Date à laquelle a été réalisé le TP ; `datetime | content?`.
  date: none,

  // Afficher la table des matières ? ; `bool`.
  sommaire: true,

  // Logo à utiliser ; `image?`.
  logo: image("logo-insa-lyon.png"),

  // Imposer le point à la fin des légendes ; `bool`.
  point-legende: false,

  // Contenu du rapport
  doc
) = {
  // ---- Langue ---- //

  set text(lang: "fr")
  
  // ---- Format général de la page ---- //
  
  set page(
    paper: "a4",
    margin: (
      left: 2cm,
      right: 2cm,
      top: 2.5cm,
      bottom: 2.5cm,
    ),
    // En-tête, avec auteurs et logo INSA
    header: [
      // Mise en page
      #set text(
        font: "Liberation Serif",
        size: police-en-tete,
      )

      // Espacement depuis le haut de la page
      #v(38.51pt)

      // Contenu
      #grid(
        columns: (5fr, 1fr),
        // Alignement à gauche des auteurs
        align(left + horizon)[
          #{
            let type-entree = type(auteurs)
            // Déclarations pour utiliser sur plusieurs scopes
            let prefixe
            let auteurs-display
            let groupe-display

            // Si `auteurs` est un array
            if (type-entree == array) {
              
              // Gestion des noms et du pluriel //
              let total = auteurs.len()
              
              // Si plusieurs auteurs
              if (total > 1) {
                // Initialisation
                auteurs-display = []
                prefixe = [Auteurs :]
                groupe-display = if (groupe != none) [ – #groupe]
                
                // On veut des virgules entre les auteurs, et un "et" avant le dernier
                for nb in range(total) {
                  if nb == total - 1 {
                    auteurs-display += [ et #auteurs.at(nb)]
                  } else if nb == total - 2 {
                    auteurs-display += [ #auteurs.at(nb)]
                  } else {
                    auteurs-display += [ #auteurs.at(nb),]
                  }
                }
              } else if total == 1 {
                // Initialisation
                prefixe = [Auteur : ]
                groupe-display = if (groupe != none) [ – #groupe]
                
                // Si un seul auteur, on laisse tel quel
                auteurs-display += [#auteurs.at(0)]
              }
            } else if (auteurs != none) {
              // Si `auteurs` n'est pas un array et n'est pas nul
              prefixe = [Auteur :]
              auteurs-display = [ #auteurs]
              groupe-display = if (groupe != none) [ – #groupe]
            }
          

            // Affichage
            text(weight: "bold", prefixe)
            auteurs-display
            groupe-display
          }
        ], // Align(left)
        
        // Alignement à droite du logo INSA, si applicable
        if (logo != none) {
          set image(width: 90%)
          align(right + horizon)[
            #logo
          ]
        }
      )
    ], // Header
    
    // Pied de page, avec poste, numérotation de page et date.
    footer: [
      // Mise en page
      #set text(
        font: "Liberation Serif",
        size: police-pied-page,
      )
      
      // Contenu
      #grid(
        columns: (1fr, 1fr, 1fr),
        align(left)[
          #if numero-poste != none [
            Poste n° #numero-poste
          ]
        ],
        align(center)[
          #counter(page).display(
            "– 1/1 –",
            both: true,
          )
        ],
        align(right)[
          #if type(date) == datetime {  
            date.display(
              "[day]/[month]/[year]"
            )
          } else {
            date
          }
        ],
      ) // Grid
    ], // Footer
  ) // Page

  // ---- Liens ---- //

  // Weird : if I place the following bit of code after the next section `Titre`,
  // links won't get styled properly in footnotes.

  // Souligner les liens externes, ne pas souligner
  // les liens locaux.
  show link: it => {
    if (type(it.dest) == str) {
      underline(it)
    } else {
      it
    }
  }
  
  // ---- Titre ---- //

  {
    set align(center)
    set text(
      font: "Liberation Serif"
    )
    rect(
      width: 100%,
      radius: 0%,
      inset: (top: 7pt, bottom: 10pt),
      stroke: 0.7pt,
    )[
      // Premier texte avec numéro de TP
      #text(
        police-titre - 4pt,
        couleur-rouge,
        weight: "bold",
        [
          #if (numero-tp != none) [
            Compte rendu de TP n°#numero-tp : \
          ]
        ]
      )
      // Titre du TP
      #text(
        police-titre,
        couleur-rouge,
        weight: "bold",
        titre
      )
    ]
  }

  // ---- Table des matières ---- //

  if sommaire {
    // Technique pour distinguer les titres des annexes et ceux du corps du TP
    // Le supplement est utilisé comme un identificateur.
    set outline(target: heading.where(supplement: identificateur-titre))
    set text(
      size: police-base
    )
    // Espace après le titre
    v(0.3cm)
    // Affichage de la table des matières
    outline(
      title: none,
      indent: tab-sommaire,
      depth: profondeur-sommaire,
    )
  }

  // ---- Numérotation titres ---- //

  // https://www.reddit.com/r/typst/comments/18exrv5/hide_previous_level_heading_counters/
  set heading(numbering: (..nums) => {
    
    let nums = nums.pos()
    // Niveau du titre
    let niveau = nums.len() - 1

    // Pour ne pas afficher toute la numérotation `I.1.A.` et juste `A`
    // Pour un titre de niveau 2
    if (niveau == 2) {
      let style = "A."
      let num = nums.last()
      numbering(style, num)
    } else {
      let style = "I.1."
      let num = nums
      numbering(style, ..num)
    }
  })
    
  // ---- Sous-Titres ---- //

  // J'espère que personne n'utilisera ce supplément haha
  // Le supplément sert à détecter les titres de la partie
  // principale (par opposition aux annexes par exemple)
  set heading(supplement: identificateur-titre)
  
  // TODO : show heading: set block(above: __ pt)
  // https://github.com/typst/typst/issues/686
  show heading.where(
    level: 1
  ): it => block(width: 100%)[
    #set align(left)
    #text(
    police-stitre-1,
    couleur-vert,
    weight: "bold",
    font: police-style-stitre
  )[
    #h(0 * titre-tabulation)
    #counter(heading).display()
    #h(tab-numerotation)
    #underline()[#it.body]
    #v(espace-vert-titres)
    
  ]
  ]

  // Style + logique pour détecter un titre précédent de niveau 1.
  // Dans ce cas, réduire l'espacement entre les deux.
  // C'est un palliatif en attendant https://github.com/typst/typst/issues/3127
  show heading.where(
    level: 2
  ): it => locate(
    loc => {
      let titres = query(
        selector(heading).before(loc),
        loc,
      ) // titres

      // Valeur par défaut de l'espacement
      let espacement = none
      
      // S'il y a un titre avant
      if titres.len() > 1 {
        // Titre précédent
        let titre-precedent = titres.at(-2)

        // Seuil à partir duquel un titre est considéré comme adjacent au précédent
        // 28pt correspond environ à l'espacement par défaut de typst, auquel
        // on rajoute l'espacement induit par le titre du dessus
        let seuil = 28pt + espace-vert-titres 
        
        // Si le titre de niveau 2 est assez proche du précédent,
        // que ce dernier est de niveau 1 et les deux sont sur la
        // même page
        if (titre-precedent.level == 1) and (titre-precedent.location().position().y + seuil > it.location().position().y) and (titre-precedent.location().page() == it.location().page()) {
          espacement = [#v(-espace-vert-titres -0.12cm)]
        }
      }

      // Ajouter l'éventuel espacement, puis style du titre
      espacement
      block(width: 100%)[
        #set align(left)
        #text(
          size: police-stitre-2,
          weight: "bold",
          font: police-style-stitre,
          couleur-bleu,
        )[
          #h(1 * titre-tabulation)
          #counter(heading).display()
          #h(tab-numerotation)
          #underline()[#it.body]
          #v(espace-vert-titres)
        ]
      ]
    }
  )

  show heading.where(
    level: 3
  ): it => locate(
    loc => {
      let titres = query(
        selector(heading).before(loc),
        loc,
      ) // titres

      // Valeur par défaut de l'espacement
      let espacement = none

      // Niveaux de titres précédents à détecter
      let niveaux = (1,2)
      
      // S'il y a un titre avant
      if titres.len() > 1 {
        // Titre précédent
        let titre-precedent = titres.at(-2)

        // Seuil à partir duquel un titre est considéré comme adjacent au précédent
        // 28pt correspond environ à l'espacement par défaut de typst, auquel
        // on rajoute l'espacement induit par le titre du dessus
        let seuil = 28pt + espace-vert-titres 
        
        // Si le titre de niveau 3 est assez proche du précédent,
        // que ce dernier est de niveau 1 ou 2 et les deux sont sur la
        // même page
        if (niveaux.contains(titre-precedent.level)) and (titre-precedent.location().position().y + seuil > it.location().position().y) and (titre-precedent.location().page() == it.location().page()) {
          espacement = [#v(-espace-vert-titres -0.12cm)]
        }
      }

      // Ajouter l'éventuel espacement, puis style du titre
      espacement
      block(width: 100%)[
        #set align(left)
        #text(
          size: police-stitre-2,
          font: police-style-stitre,
          weight: "bold",
          couleur-pourpre,
        )[
          #h(2 * titre-tabulation)
          #counter(heading).display()
          #h(tab-numerotation)
          #underline()[#it.body]
          #v(espace-vert-titres)
        ]
      ]
    }
  )

  show heading.where(
    level: 4
  ): it => text(
    size: police-stitre-3,
    font: police-style-stitre,
    weight: 600,
    block(width: 100%)[
      #h(1.5 * titre-tabulation)
      #str.from-unicode(10146) // ➢
      #h(tab-numerotation)
      #it.body
    ]
  )

  // ---- Listes ---- //

  set list(
    marker: ([•], [--]),
    indent: tabulation,
  )

  // ---- Figures ---- //

  show figure.caption: it => {
    text(
      police-legende,
      couleur-bleu-legende,
      weight: "bold",
      [
        #let legende = it.body

        // Ajout d'un point à la fin de la légende
        // FIXME : Spaghetti code, also kinda overkill
        #{
          if point-legende {
            let fin-valide = (".", "?", "!")
  
            // Si le corps contient du texte
            if (legende.has("text")) {
              // Extraction du dernier groupe de graphème
              let fin = legende.text.last()
              // Si ce dernier n'est pas un symbole de ponctuation, on ajoute un point
              legende = if not (fin-valide.contains(fin)) {[#legende] + [.]} else {legende}
            } else if (legende.has("children")) {
              // Si le dernier élément est un espace
              if (legende.children.last() == [ ]) {
                // Si un espace s'est glissé à la fin, on le supprime
                legende = legende.children.slice(0, -1).join()
  
                // Si notre version sans espace est toujours un array
                if (legende.has("children")) {
                  // Vérification du dernier groupe de graphème
                  let fin = if (legende.children.last().has("text")) {legende.children.last().text} else {"fallback"}
                  // Ajout éventuel d'un point
                  legende = if (fin-valide.contains(fin.last())) {legende} else {legende + [.]}
                } else if (legende.has("text")) {
                  // Sinon si ce n'est pas un array mais directement du texte
                  legende = legende.text + [.]
                }
              }
            }
          }
        }
        
        // Correctif pour Fig. utilisé en `lang: "fr"`
        #let sup = if (it.supplement == [Fig.]) [Figure] else {it.supplement}

        // Affichage de la légende
        #sup #it.counter.display() :
        #text(style: "italic")[#legende]
      ]
    )
  }

  // ---- Références ---- //

  // Correction de la référence « Fig. » --> « Figure »
  // et « Équation n » --> « (n) »
  show ref: it => {
    let element = it.element

    // Typst could use a match/switch syntax
    // or I just don't know what I'm doing ,_,
    if element != none {
      let element-type = element.func()
      
      if (element-type == math.equation) {
        
        let numero = numbering(
          element.numbering,
          ..counter(math.equation).at(element.location())
        )
        link(it.target)[#math.equation(numero)]
        
      } else if (element-type == figure) {
        
        let numero = numbering(
          element.numbering,
          ..counter(figure).at(element.location())
        )

        // Éviter de se faire piéger avec `supplement: auto`.
        if (it.element.caption.supplement == [Fig.]) {          
          link(it.target)[#underline(text(style: "italic")[Figure #numero])]
        } else {
          underline(text(style: "italic")[#it])
        }

      } else if (element-type == heading) {
        
        let texte

        if (element.supplement == identificateur-annexe) {
          
          let numero = numbering(
            style-numerotation-annexes,
            ..counter(heading).at(element.location()),
          )
          texte = underline(text(weight:500, style: "italic")[#nom-annexe #numero])
          
        } else if (element.level == 3) {
          
          let numero = numbering(
            style-numerotation-global,
            ..counter(heading).at(element.location()),
          )
          texte = underline(text(weight: 500, style: "italic", numero))
          
        } else if (element.level == 4) {
          
          texte = underline(text(weight: 400, style: "italic", element.body))
          
        } else {
          
          let numero = numbering(
            element.numbering,
            ..counter(heading).at(element.location()),
          )
          texte = underline(text(weight: 500, style: "italic", numero))
          
        }
        // Affichage de la référence fabriquée, ainsi qu'un lien vers
        // l'objet référencé.
        link(it.target)[#texte]
      } else {
        // Si aucun match, c'est qu'on a rien à changer
        it
      }
    }
  }

  // ---- Equations ---- //
  
  set math.equation(numbering: "(1)")
  
  // ---- Paragraphe et texte ---- //
  
  set align(left)
  set par(justify: true)
  set text(
    font: police-style-base,
    weight: "regular",
    stretch: 100%,
    size: 12pt,
  )

  // ---- Corps du document ---- //
  doc
}


/// Fait en sorte que la légende de la figure n'en dépasse pas
/// la largeur.
#let figure-emboitee(
  // Figure à traiter
  fig,

  // Référence éventuelle à utiliser dans le corps du rapport
  reference: none,
) = {
  // https://github.com/typst/typst/issues/2194#issuecomment-1760641264
  
  show figure: _fig => style(styles => {
      let fig-width = measure(_fig.body, styles).width
      show figure.caption: box.with(width: fig-width)
      _fig
  })

  [#fig #if (reference != none) {reference}]
}

/// Équation sans numérotation (label)
#let equation-anonyme(
  // Équation à traiter
  eq,
) = {  
  math.equation(
    block: true,
    numbering: none,
    eq.body
  )
}


/// Semblant de classe, bricolé avec un dictionnaire.
/// Représente un objet `annexe`.
#let annexe(
  // Titre de l'annexe
  titre: none,

  // Éventuelle référence à utiliser dans le corps du rapport
  reference: none,
  
  // Corps de l'annexe
  corps,
) = (
  titre: titre,
  reference: reference,
  corps: corps
)

/// Affiche le titre, la table et les annexes passées en argument.
/// TODO Autoriser les heading lv. 1 dans le corps des annexes.
#let afficher-annexes(
  // Liste d'objets `annexe`, dictionnaires renvoyés par la fonction helper `annexe`.
  // `dictionary`.
  annexes: none,
  
  // Inclure une table des annexes ? ; `bool`.
  table: true,

  // Saut de page après affichage de la table ? ; `bool`.
  saut-page-apres-table: false,
) = {
  // Misc
  let total = annexes.len()
  let compteur-annexes = counter("annexe")

  // Style des titres (autres que ceux des annexes)
  set heading(numbering: style-numerotation-annexes, supplement: identificateur-sous-titre-annexe)
  // Ne pas autoriser les titres de niveau 1 dans le corps (car overlap avec compteur des annexes)
  show heading.where(level:1): none

  // Titre des annexes, fonction helper utilisée en interne.
  let titre-annexe(titre: none, ref: none) = {
    // Pour ne prendre en compte que les annexes dans la
    // table des annexes.
    set heading(supplement: identificateur-annexe)
    
    // Style des titres des annexes, défini dans le scope
    // local pour ne pas affecter les autres titres
    show heading.where(level: 1): it => {
      // Comme on utiliser le compteur des heading lv.1, on doit faire attention
      // à ne pas en mettre dans le corps des annexes.
      let numero = numbering(
        it.numbering,
        ..counter(heading).at(it.location())
      )
      text(
        police-stitre-1,
        weight: "bold",
      )[
        //#compteur-annexes.step()
        #nom-annexe
        // #compteur-annexes.display(style-numerotation-annexes)
        #numero
        #h(titre-tabulation)
        #it.body
        #{4 * v(espace-vert-titres)}
      ]
    }
    if (titre != none) [
      #heading()[
        #titre
      ] #ref
    ] else [
      // Pour que le titre puisse être détecté comme vide par l'outline.
      #heading(none) #ref
    ]
  }

  // Affichage //
  
  // Aller à la prochaine page
  pagebreak()

  // Affichage du titre
  {
    set align(center)
    set text(
      font: "Liberation Serif"
    )
    // Ne pas afficher le titre, seulement l'inclure
    // dans la table des matières (pour ne pas adopter
    // le style classique des titres).
    show heading: none

    // Cadre + titre
    rect(
      width: 100%,
      radius: 0%,
      inset: (top: 7pt, bottom: 10pt),
      stroke: 0.7pt,
    )[
      #text(
        police-titre,
        black,
        weight: "bold",
        heading(
          level: 1,
          supplement: identificateur-titre,
          numbering: style-numerotation-global,
          nom-annexe-s
        )
        +
        nom-annexe-s
      )
    ]
  }

  // Définitions de nouveau //
  
  // Table des annexes
  if (table) {
    // Styles
    set heading(outlined: false, supplement: identificateur-titre)
    // Style pour le titre de l'annexe seulement (portée limitée par le scope)
    show heading.where(level: 1, supplement: identificateur-titre): it => {
      set align(left)
      text(
        police-titre,
        font: "Liberation Serif",
        weight: "bold",
      )[
        #it.body
        #v(espace-vert-titres)
      ]
    }
    // Style de titre pour chaque annexe.
    show heading.where(supplement: identificateur-annexe): it => {
      text(
        police-stitre-1,
        weight: "bold",
      )[
        #it.body
        #v(espace-vert-titres)
      ]
    }
    show outline.entry: it => {
      let element = it.element
      let numero = numbering(
        element.numbering,
        ..counter(heading).at(element.location())
      )

      // Lien vers l'annexe en question.
      link(it.element.location())[
        #text(
          weight: 500,
        )[
          // Ajouter les text "Annexe" devant chaque entrée
          Annexe #numero #{if (it.element.body != []) [:]}    // Ne pas afficher `:` si le titre est vide
        ]
        #it.element.body
        #box(width: 1fr, repeat(it.fill.body))
        #it.page
      ]
    }

    // Affichage de la table stylisée
    outline(
      title: [Table des annexes],
      target: heading.where(level: 1, supplement: identificateur-annexe),
    )
    // Ainsi que d'un espace vertical la séparant d'un éventuel titre
    v(0.5cm)

    // Si l'option est active, sauter une page après la table.
    if (saut-page-apres-table) {      
      pagebreak()
    }
  }

  // Remise à zero du compteur pour les titres afin de commencer
  // à compter les annexes à `0` (donc « A »)
  counter(heading).update(0)

  // Placement des différentes annexes passées en argument
  for nb in range(total) {

    // On formate le titre, en passant l'éventuelle référence
    titre-annexe(
      titre: annexes.at(nb).at("titre"),
      ref: annexes.at(nb).at("reference")
    )

    // Et affichage du corps de l'annexe
    annexes.at(nb).at("corps")

    // Sans oublier de sauter une page entre chaque annexe,
    // sauf pour la dernière
    if (nb != total - 1) {pagebreak()}
  }
}