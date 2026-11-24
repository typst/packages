= Préparation

// Convertis des durées décimales ou fractionnaires en durées entières -> array
#let prepa-duree(
  // liste de 2 à 4 nombres (j,h,min,s) à (min, s) -> array | arguments
  ..args
) = {
  let duree = args.pos()
  // Autorise les deux écritures :
  //
  // prepa-dure((1, 2, 3, 4))
  //
  // prepa-dure(0, 5, 6, 7)
  // 
  if duree.len() == 1 {
    let premier = duree.at(0)

    if (
      type(premier) == array
      and premier.len() > 0
    ) {
      duree = premier
    }
  }
  let debut = 4 - duree.len()
    // Complète une durée à gauche pour obtenir :
  // (jours, heures, minutes, secondes).
  let normaliser(duree) = {
    (0,) * (4 - duree.len()) + duree
  }

  // ----------------------------------------------------------
  // Conversion en secondes
  // ----------------------------------------------------------

  let en-secondes(duree) = {
    duree.at(0) * 86400 + duree.at(1) * 3600 + duree.at(2) * 60 + duree.at(3)
  }

  let total-resultat = en-secondes(normaliser(duree))

  // ----------------------------------------------------------
  // Décomposition du résultat
  // ----------------------------------------------------------

  let jours = calc.trunc(total-resultat / 86400)
  let reste-jours = total-resultat - jours * 86400

  let heures = calc.trunc(reste-jours / 3600)
  let reste-heures = reste-jours - heures * 3600

  let minutes = calc.trunc(reste-heures / 60)
  let secondes = reste-heures - minutes * 60

  (jours, heures, minutes, int(secondes)).slice(debut)
}

= Additions de durées

// Pose l’addition de deux ou plusieurs durées.
// 
// Chaque durée est un tableau de l'une des formes suivantes :
// - `(jours, heures, minutes, secondes)`.
// - `(heures, minutes, secondes)`.
// - `(minutes, secondes)`.
// *Exemples :*
// ```example
// #addition-durees(
//   (1, 2, 45, 50),
//   (0, 1, 20, 30),
// )
// ```
// 
// ```example
// #addition-durees(
//   (
//     (1, 2, 45, 50),
//     (0, 1, 20, 30),
//     (2, 23, 55, 45),
//   ),
//   hide-result: true,
// )
// ```
// 
// -> content
#let addition-durees(
  // Afficher les retenues. -> boolean
  show-carry: true,
  // Couleur des retenues. -> color
  couleur: red,
  // Taille des retenues et des symboles + et =, max 1em. -> relative length
  carry-size:.8em,
  // Largeur des colonnes correspondant aux unités. -> relative length
  size: 2.5em,
  // Mode convertion du résultat à la place des retenues. -> boolean
  convertion: false,
  // Cacher les colonnes n'ayant que des zéros -> boolean
  hide-empty:true,
  // Masquer le résultat. -> boolean
  hide-result: false,
  // Couleur du cadre des valeurs masquées. -> color
  couleur-cadre: blue.mix(gray),
  // Couleur des valeurs dans la correction. -> color
  couleur-solution: red,
  // Type de masque : "rect" ou "line". -> str
  type-mask: "rect",
  // Indices des cellules à masquer. -> array
  liste: (),
  // Afficher la solution des cellules masquées. -> boolean
  solution: false,
  // Signe placé devant le résultat. -> boolean | content
  signe: false,
  // Taille du texte. -> relative length
  texte: 1em,
  // Afficher les noms des unités. -> boolean
  show-units: true,
  // Noms des quatre unités. -> array
  units: ([j], [h], [min], [s]),
  // Taille des unités, max 1em -> relative length
  units-size:.75em,
  // couleur des unités -> color
  couleur-unites:gray,
  // Afficher heures, minutes et secondes sur deux chiffres. -> boolean
  zero-pad: true,
  // Aligner les chiffres des unités. -> boolean
  align: true,
  // Pointillés verticaux pour séparer les colonnes -> boolean
  verticales: false,
  // -> array | arguments
  ..args
) = {
  let unites = units
  let carry-size = calc.min(carry-size, 1em)
  let units-size = calc.min(units-size, 1em)
  let durees = args.pos()
  // Autorise les deux écritures :
  //
  // addition-durees((1, 2, 3, 4), (0, 5, 6, 7))
  //
  // addition-durees((
  //   (1, 2, 3, 4),
  //   (0, 5, 6, 7),
  // ))
  if durees.len() == 1 {
    let premier = durees.at(0)

    if (
      type(premier) == array
      and premier.len() > 0
      and type(premier.at(0)) == array
    ) {
      durees = premier
    }
  }

  if durees.len() < 2 {
    panic(
      "La fonction addition-durees nécessite au moins deux durées."
    )
  }
  for i in range(durees.len()) {durees.at(i) = prepa-duree(durees.at(i))}

  // Vérification des durées.
  for (index, duree) in durees.enumerate() {
    
    let nb_args = duree.len()
    if type(duree) != array or nb_args < 2 or nb_args > 4 {
      panic(
        "La durée "
        + str(index + 1)
        + " doit contenir entre 2 et 4 valeurs"
      )
    }

    for valeur in duree {
      if type(valeur) != int or valeur < 0 {
        panic(
          // "Les composantes d’une durée doivent être "
          // + "des entiers positifs ou nuls."
          "Une durée doit être positive ou nulle."
        )
      }
    }

    // if duree.at(-1) >= 60 {
    //   panic(
    //     "Le nombre de secondes d’une durée doit être inférieur à 60."
    //   )
    // }

    // if duree.at(-2) >= 60 {
    //   panic(
    //     "Le nombre de minutes d’une durée doit être inférieur à 60."
    //   )
    // }

    // if nb_args > 2 and duree.at(-3) >= 24 {
    //   panic(
    //     "Le nombre d'heures d’une durée doit être inférieur à 24."
    //   )
    // }
  }

  set text(texte)

  // Masque utilisé pour le résultat et les additions à trous.
  let mask(x) = if type-mask == "rect" {
    rect(
      width: 90%,
      height: 1em,
      radius: 0.35em,
      stroke: couleur-cadre + 0.75pt,
      text(
        fill: if solution { couleur-solution } else { white },
        x,
      ),
    )
  } else {
    box(
      inset: 2pt,
      underline(
        stroke: (
          paint: black,
          dash: "dotted",
          thickness: 0.75pt,
        ),
        extent: 0.45pt,
        offset: 1.65pt,
        text(
          fill: if solution { couleur-solution } else { white },
          x,
        ),
      ),
    )
  }

  // Secondes.
  let total-secondes = durees.map(d => d.at(-1)).sum()
  let retenue-minutes = calc.trunc(total-secondes / 60)
  let secondes = total-secondes - 60 * retenue-minutes

  // Minutes, en ajoutant la retenue des secondes.
  let total-minutes = (
    durees.map(d => d.at(-2)).sum()
    + retenue-minutes
  )
  let minutes-directes = durees.map(d => d.at(-2)).sum()
  
  let retenue-heures = calc.trunc(total-minutes / 60)
  let minutes = total-minutes - 60 * retenue-heures

  // Heures, en ajoutant la retenue des minutes.
  let total-heures = retenue-heures
  let heures-directes = 0
  for duree in durees {
    if duree.len() > 2 {
      total-heures += duree.at(-3)
      heures-directes += duree.at(-3)
    }
  }
  
  let retenue-jours = calc.trunc(total-heures / 24)
  let heures = total-heures - 24 * retenue-jours

  // Jours, en ajoutant la retenue des heures.
  let jours = retenue-jours
  let jours-directs = 0
  for duree in durees {
    if duree.len() > 3 {
      jours += duree.at(-4)
      jours-directs += duree.at(-4)
    }
  }
  
  let resultat = (
    jours,
    heures,
    minutes,
    secondes,
  )

  let resultat-court = {if resultat.at(0) == 0 and resultat.at(1) == 0 {resultat.slice(2)} else if resultat.at(0) == 0 {resultat.slice(1)} else {resultat}}

  // if convertion 
  let pre-result = (if signe == true {text(carry-size)[$ = $]} else if signe != false { signe } else [],) + if jours-directs != 0 {(str(jours-directs),)} else if resultat-court.len() > 3 {([],)} + if heures-directes !=0 {(str(heures-directes),)} else if resultat-court.len() > 2 {([],)} + (str(minutes-directes),str(total-secondes))
  
  // {
  //   if durees.len() > 3 {pre-result.push(str(durees.map(d => d.at(0)).sum()))} else if resultat-court.len() > 3 {pre-result.push([])}
  //   if durees.len() > 2 {pre-result.push(str(durees.map(d => d.at(1)).sum()))} else if resultat-court.len() > 2 {pre-result.push([])}
  //   pre-result += (str(durees.map(d => d.at(-2)).sum()), str(durees.map(d => d.at(-1)).sum()),)
  // }

  // Les retenues sont placées au-dessus de l’unité
  // dans laquelle elles doivent être ajoutées.
  let retenues = (
    retenue-jours,
    retenue-heures,
    retenue-minutes,
    0,
  )

  // ----------------------------------------------------------
  // Mise en forme des valeurs
  // ----------------------------------------------------------

  // on détermine le nombre maximum de colonnes de valeurs à afficher EN FONCTION du maximum du nombre d'arguments du résultat.
  let max-cols = resultat-court.len()

  // inscrit le nombre à deux chiffres en insérant des 0 à gauche si nécessaire
  let format-valeur(valeur, colonne) = {
    let texte-valeur = str(valeur)

    if (
      zero-pad
      and colonne > 0
      and texte-valeur.len() < 2
    ) {
      "0" * (2 - texte-valeur.len()) + texte-valeur
    } else if (
      align
      and texte-valeur.len() < 2
    ) {
      text(white,"0") * (2 - texte-valeur.len()) + texte-valeur
    } else {
      texte-valeur
    }
  }

  let lignes = ()

  // Les retenues sont cachées en même temps que le résultat,
  // sauf lorsque la correction est demandée.
  let has-carry-row = (
    show-carry and not convertion
    // and (
    //   (not hide-result and liste == ())
    //   or solution
    // )
  )
  // ---------------------------
  // 1. Ligne des retenues.
  // ---------------------------
  if has-carry-row {
    // on prévoit un espace vide pour la colonne avec le symbole...
    let ligne-retenues = ([],)

    for (i, retenue) in retenues.enumerate() {
      // si y a moins de 4 colonnes
      if i < 4 - max-cols {
        continue
      }
      if retenue > 0 {
        ligne-retenues.push(
          text(
            size: carry-size,
            fill: couleur,
          )[~~#retenue]
        )
      } else {
        ligne-retenues.push([])
      }
    }

    lignes.push(ligne-retenues)
  }
  // ---------------------------
  // 2. Lignes des durées à additionner.
  // ---------------------------
  for (index, duree) in durees.enumerate() {
    let ligne = (
      if index > 0 {
        text(carry-size)[$ + $]
      } else {
        []
      },
    )
    // ---------------------------
    // 2.i Ligne i
    // ---------------------------

    // dans le cas ou duree.len() < max-cols, on complète avec autant de [] que nécessaire
    let pad = max-cols - duree.len()
    for i in range(pad){ligne.push([])}
    for (i, valeur) in duree.enumerate() {
      ligne.push(format-valeur(valeur, i))
    }

    lignes.push(ligne)
  }
  // ---------------------------
  // 3. Ligne du résultat.
  // ---------------------------
  let ligne-resultat = (
    if signe == true or convertion {text(carry-size)[$ = $]} else if signe != false { signe } else [],
  )

  for (colonne, valeur) in resultat-court.enumerate() {
    ligne-resultat.push(
      format-valeur(valeur, colonne)
    )
  }

  // Masquage du résultat.
  if hide-result {
    for index in range(1, ligne-resultat.len()) {
      ligne-resultat.at(index) = mask(
        ligne-resultat.at(index)
      )
    }
  }

  pre-result = (pre-result.remove(0),) + {
    for (colonne, valeur) in pre-result.enumerate() {
      if valeur != [] {(format-valeur(valeur, colonne),)} else {([],)}
  }
  }

  for k in range(1,pre-result.len()) {
    if pre-result.at(k) != ligne-resultat.at(k) {pre-result.at(k) = if pre-result.at(k) != [] {text(gray,[$ cancel(#pre-result.at(k)) $])}}
  }

  let test = for k in range(1,pre-result.len()) {(pre-result.at(k) == ligne-resultat.at(k),)}

  ligne-resultat = if false in test or not convertion {ligne-resultat} else {()}

  if convertion and (not hide-result and liste == () or solution) {
    lignes.push(pre-result)
  }
  
  lignes.push(ligne-resultat)

  // ----------------------------------------------------------
  // Additions à trous
  // ----------------------------------------------------------

  // La ligne des retenues ne participe pas à la numérotation
  // des cellules masquées.
  let carry-line = if has-carry-row {
    lignes.remove(0)
  } else {
    none
  }
  
  let test-secondes = if hide-empty {for duree in durees {if duree.last() == 0 {(true,)} else {(false,)}}}

  let test-minutes = if hide-empty {for duree in durees {if duree.at(-2) == 0 {(true,)} else {(false,)}} + if (carry-line != none and carry-line.at(-2) == []) or carry-line == none {(true,)} else {(false,)} }

  if test-secondes == (true,) * durees.len() {
    for i in range(lignes.len()) {
      lignes.at(i) = lignes.at(i).slice(0,-1)
    }
    carry-line = if carry-line != none {carry-line.slice(0,-1)}
    if test-minutes == (true,) * (durees.len()+1) {
      for i in range(lignes.len()) {
      lignes.at(i) = lignes.at(i).slice(0,-1)
    }
    carry-line = if carry-line != none {carry-line.slice(0,-1)}
    }
  }

  let termes = lignes.flatten()

  for index in liste {
    if (
      type(index) == int
      and index > 0
      and index < termes.len()
      and termes.at(index) != []
    ) {
      termes.at(index) = mask(termes.at(index))
    }
  }

  if carry-line != none {
    termes = carry-line + termes
  }

  // ----------------------------------------------------------
  // En-tête des unités
  // ----------------------------------------------------------

  let entete = ()

  if show-units {
    entete.push([])

    for (i, unite) in unites.enumerate() {
      if i < 4 - max-cols { continue }
      entete.push(
        text(
          size: units-size,
          fill: couleur-unites,
          weight: "bold",
        )[#unite]
      )
    }
  }

  // Indice de la ligne de résultat.
  let y-resultat = (
    (if show-units { 1 } else { 0 })
    + (if has-carry-row { 1 } else { 0 })
    + durees.len()
  )

  if test-secondes == (true,) * durees.len() {
    entete = entete.slice(0,-1)
    if test-minutes == (true,) * (durees.len()+1) {entete = entete.slice(0,-1)}
  }

  // ----------------------------------------------------------
  // Rendu
  // ----------------------------------------------------------

  // autant de colonnes que max-cols
  let columns = (1.4em,)
  for i in range(max-cols){columns.push(size)}

  if test-secondes == (true,) * durees.len() {
    columns = columns.slice(0,-1)
    if test-minutes == (true,) * (durees.len()+1) {columns = columns.slice(0,-1)}
  }
  box(
    if columns.len() > 1 {table(
      columns: columns,
      stroke: (x,y) => if verticales and x > 1 {(left:(dash:"dotted",thickness:.5pt))} else {none},
      inset: (x: 3pt, y: 3pt),
      align: center + horizon,

      ..entete,
      ..termes,

      table.hline(
        y: y-resultat,
        stroke: 1pt,
      ),
    )}
  )
}

= Soustractions de durées

// Pose la soustraction de deux durées.
// 
// Chaque durée est un tableau de l’une des formes suivantes :
// - `(jours, heures, minutes, secondes)` ;
// - `(heures, minutes, secondes)` ;
// - `(minutes, secondes)`.
// 
// La première durée doit être supérieure ou égale à la seconde.
// 
// *Exemples :*
// ```example
// #soustraction-durees(
//   (2, 4, 15, 10),
//   (1, 6, 45, 30),
// )
// ```
// 
// ```example
// #soustraction-durees(
//   (2, 15, 10),
//   (1, 45, 30),
//   hide-result: true,
// )
// ```
// 
// -> content
#let soustraction-durees(
  // Afficher les emprunts et les retenues. -> boolean
  show-borrow: true,
  // Couleur des emprunts et retenues. -> color
  couleur: red,
  // Taille des retenues et des symboles + et =, max 1em.  -> relative length
  carry-size:.7em,
  // Largeur des colonnes. -> relative length
  size: 2.5em,
  // Mode convertion du minuende à la place des retenues -> boolean
  convertion: false,
  // Cacher les colonnes n'ayant que des zéros -> boolean
  hide-empty:true,
  // Masquer le résultat. -> boolean
  hide-result: false,
  // Couleur du cadre des valeurs masquées. -> color
  couleur-cadre: blue.mix(gray),
  // Couleur des valeurs dans la correction. -> color
  couleur-solution: red,
  // Type de masque : "rect" ou "line". -> str
  type-mask: "rect",
  // Indices des cellules à masquer. -> array
  liste: (),
  // Afficher la solution. -> boolean
  solution: false,
  // Signe placé devant le résultat. -> boolean | content
  signe: false,
  // Taille du texte. -> relative length
  texte: 1em,
  // Afficher les noms des unités. -> boolean
  show-units: true,
  // Noms des quatre unités. -> array
  units: ([j], [h], [min], [s]),
  // Taille des unités, max 1em. -> relative length
  units-size:.75em,
  // couleur des unités. -> color
  couleur-unites:gray,
  // Afficher heures, minutes et secondes sur deux chiffres. -> boolean
  zero-pad: true,
  // Aligner les chiffres des unités. -> boolean
  align:true,
  // Pointillés verticaux pour séparer les colonnes -> boolean
  verticales: false,
  // Liste des durées -> array | arguments
  ..args
) = {
  let unites = units
  let carry-size = calc.min(carry-size, 1em)
  let units-size = calc.min(units-size, 1em)
  let durees = args.pos()

  // Autorise :
  //
  // soustraction-durees(
  //   (1, 2, 3, 4),
  //   (0, 5, 6, 7),
  // )
  //
  // et :
  //
  // soustraction-durees((
  //   (1, 2, 3, 4),
  //   (0, 5, 6, 7),
  // ))
  if durees.len() == 1 {
    let premier = durees.at(0)

    if (
      type(premier) == array
      and premier.len() > 0
      and type(premier.at(0)) == array
    ) {
      durees = premier
    }
  }
  for i in range(durees.len()) {durees.at(i) = prepa-duree(durees.at(i))}

  if durees.len() != 2 {
    panic(
      "La fonction soustraction-durees nécessite exactement deux durées."
    )
  }

  // ----------------------------------------------------------
  // Vérification des durées
  // ----------------------------------------------------------

  for (index, duree) in durees.enumerate() {
    if type(duree) != array {
      panic(
        "La durée "
        + str(index + 1)
        + " doit être une liste d'entiers."
      )
    }

    let nb-args = duree.len()

    if nb-args < 2 or nb-args > 4 {
      panic(
        "La durée "
        + str(index + 1)
        + " doit contenir entre 2 et 4 valeurs."
      )
    }

    for valeur in duree {
      if type(valeur) != int or valeur < 0 {
        panic(
          "Les composantes d’une durée doivent être "
          + "des entiers positifs ou nuls."
        )
      }
    }

    if duree.at(-1) >= 60 {
      panic(
        "Le nombre de secondes doit être inférieur à 60."
      )
    }

    if duree.at(-2) >= 60 {
      panic(
        "Le nombre de minutes doit être inférieur à 60."
      )
    }

    if nb-args > 2 and duree.at(-3) >= 24 {
      panic(
        "Le nombre d’heures doit être inférieur à 24."
      )
    }
  }

  set text(texte)

  // ----------------------------------------------------------
  // Nombre de colonnes à afficher
  // ----------------------------------------------------------

  let max-cols = calc.max(
    durees.at(0).len(),
    durees.at(1).len(),
  )

  let debut = 4 - max-cols
  let colonnes = max-cols + 1

  // Complète une durée à gauche pour obtenir :
  // (jours, heures, minutes, secondes).
  let normaliser(duree) = {
    (0,) * (4 - duree.len()) + duree
  }
  
  let minuende = normaliser(durees.at(0))
  let soustrahende = normaliser(durees.at(1))

  // ----------------------------------------------------------
  // Conversion en secondes
  // ----------------------------------------------------------

  let en-secondes(duree) = {
    duree.at(0) * 86400 + duree.at(1) * 3600 + duree.at(2) * 60 + duree.at(3)
  }

  let total-minuende = en-secondes(minuende)
  let total-soustrahende = en-secondes(soustrahende)
  let total-resultat = total-minuende - total-soustrahende

  if total-resultat < 0 {
    panic(
      "La soustraction de durées donnerait un résultat négatif."
    )
  }

  // ----------------------------------------------------------
  // Décomposition du résultat
  // ----------------------------------------------------------

  let jours = calc.trunc(total-resultat / 86400)
  let reste-jours = total-resultat - jours * 86400

  let heures = calc.trunc(reste-jours / 3600)
  let reste-heures = reste-jours - heures * 3600

  let minutes = calc.trunc(reste-heures / 60)
  let secondes = reste-heures - minutes * 60

  let resultat-complet = (
    jours,
    heures,
    minutes,
    secondes,
  )

  let resultat = resultat-complet.slice(debut)

  // ----------------------------------------------------------
  // Calcul des emprunts
  // ----------------------------------------------------------
  //
  // emprunts-haut contient la quantité ajoutée au minuende :
  // - 60 pour les secondes ;
  // - 60 pour les minutes ;
  // - 24 pour les heures.
  //
  // retenues-bas contient le 1 ajouté à l’unité située
  // immédiatement à gauche dans le nombre soustrait.

  let bases = (none, 24, 60, 60)
  let emprunts-haut = (0, 0, 0, 0)
  let retenues-bas = (0, 0, 0, 0)

  let retenue = 0

  // Calcul de droite à gauche :
  // secondes, minutes, heures.
  for colonne in (3, 2, 1, 0) {
    let valeur-soustraite = soustrahende.at(colonne) + retenue
    let valeur-minuende = minuende.at(colonne)

    if valeur-minuende < valeur-soustraite {
      if convertion {
        emprunts-haut.at(colonne) = bases.at(colonne) + valeur-minuende - retenue
        emprunts-haut.at(colonne - 1) = emprunts-haut.at(colonne - 1) - 1
      } else {
        emprunts-haut.at(colonne) = bases.at(colonne)
      }
      retenues-bas.at(colonne) = 1
      retenue = 1
    } else {
      if convertion {
        emprunts-haut.at(colonne) = valeur-minuende + emprunts-haut.at(colonne)
      }
      retenue = 0
    }
  }

  // ----------------------------------------------------------
  // Masques
  // ----------------------------------------------------------

  let mask(x) = if type-mask == "rect" {
    rect(
      width: 90%,
      height: 1em,
      radius: 0.35em,
      stroke: couleur-cadre + 0.75pt,
      text(
        fill: if solution {
          couleur-solution
        } else {
          white
        },
        x,
      ),
    )
  } else {
    box(
      inset: 2pt,
      underline(
        stroke: (
          paint: black,
          dash: "dotted",
          thickness: 0.75pt,
        ),
        extent: 0.45pt,
        offset: 1.65pt,
        text(
          fill: if solution {
            couleur-solution
          } else {
            white
          },
          x,
        ),
      ),
    )
  }

  // ----------------------------------------------------------
  // Mise en forme des valeurs
  // ----------------------------------------------------------

  let format-valeur(valeur, colonne-interne) = {
    let texte-valeur = str(valeur)

    if (
      zero-pad
      and colonne-interne > 0
      and texte-valeur.len() < 2
    ) {
      "0" * (2 - texte-valeur.len()) + texte-valeur
    } else if (
      align
      and texte-valeur.len() < 2
    ) {
      text(white,"0") * (2 - texte-valeur.len()) + texte-valeur
    } else {
      texte-valeur
    }
  }

  let creer-ligne-duree(duree, symbole) = {
    let ligne = (symbole,)
    let decalage = max-cols - duree.len()

    // Unités absentes à gauche.
    for _ in range(decalage) {
      ligne.push([])
    }

    // Unités présentes.
    for (index, valeur) in duree.enumerate() {
      // let colonne-interne =  4 - duree.len() + index

      ligne.push(
        format-valeur(
          valeur,
          index,
        )
      )
    }

    ligne
  }

  // Les emprunts sont masqués pendant l’exercice, puis
  // réaffichés lorsque solution vaut true.
  let show-borrow-cond = (
    show-borrow or convertion
    // and (
    //   (not hide-result and liste == ())
    //   or solution
    // )
  )

  // ----------------------------------------------------------
  // Ligne supérieure des emprunts
  // ----------------------------------------------------------

  let ligne-emprunts = ([],)

  if show-borrow-cond {
    for colonne in range(debut, 4) {
      let emprunt = emprunts-haut.at(colonne)

      if emprunt > 0 and (
      (not hide-result and liste == ())
      or solution
    ) {if convertion {ligne-emprunts.push(format-valeur(
        emprunt,
        colonne - debut,
      )
          )
        } else {
        ligne-emprunts.push(
          pad(
            bottom: -0.4em,
            // right: .3em,
            text(
              size: carry-size,
              fill: couleur,
            )[+#emprunt]
          )
        )}
      } else {
        ligne-emprunts.push([])
      }
    }
  }

  // ----------------------------------------------------------
  // Lignes principales
  // ----------------------------------------------------------

  let ligne-minuende = creer-ligne-duree(
    durees.at(0),
    [],
  )
  
  if convertion and ((not hide-result and liste == ()) or solution) {
    for k in range(1,ligne-minuende.len()) {
      if ligne-minuende.at(k) != ligne-emprunts.at(k) {
        ligne-minuende.at(k) = if ligne-minuende.at(k) != [] {text(gray,[$ cancel(#ligne-minuende.at(k)) $])}
      } else {ligne-emprunts.at(k) = none}
  }}

  let ligne-soustrait = creer-ligne-duree(
    durees.at(1),
    text(carry-size)[$ - $],
  )

  let ligne-resultat = (
    if signe == true {$ = $} else if signe != false { signe } else { [] },
  )

  for (index, valeur) in resultat.enumerate() {
    // let colonne-interne = debut + index

    ligne-resultat.push(
      format-valeur(
        valeur,
        index,
      )
    )
  }

  // ----------------------------------------------------------
  // Ligne inférieure des retenues
  // ----------------------------------------------------------

  let ligne-retenues = ([],)

  if show-borrow-cond {
    for colonne in range(debut, 4) {
      // L’emprunt effectué dans la colonne située à droite
      // produit une retenue dans la colonne courante.
      let retenue-colonne = if colonne + 1 < 4 {
        retenues-bas.at(colonne + 1)
      } else {
        0
      }

      if retenue-colonne > 0 and (
      (not hide-result and liste == ())
      or solution
    ) {
        ligne-retenues.push(
          pad(
            top: -0.5em,
            text(
              size: carry-size,
              fill: couleur,
            )[+#retenue-colonne]
          )
        )
      } else {
        ligne-retenues.push([])
      }
    }
  }
  if convertion {ligne-retenues = ligne-retenues.map(x=>[])}

  // ----------------------------------------------------------
  // Masquage du résultat
  // ----------------------------------------------------------

  if hide-result {
    for index in range(1, ligne-resultat.len()) {
      ligne-resultat.at(index) = mask(
        ligne-resultat.at(index)
      )
    }
  }

  let test-secondes = if hide-empty {for duree in durees {if duree.last() == 0 {(true,)} else {(false,)}}}

  let test-minutes = if hide-empty {for duree in durees {if duree.at(-2) == 0 {(true,)} else {(false,)}} + if (ligne-emprunts != none and ligne-emprunts.at(-2) == []) or ligne-emprunts == none {(true,)} else {(false,)} }

  if test-secondes == (true,) * durees.len() {
    ligne-emprunts = ligne-emprunts.slice(0,-1)
    ligne-minuende = ligne-minuende.slice(0,-1)
    ligne-soustrait = ligne-soustrait.slice(0,-1)
    ligne-resultat = ligne-resultat.slice(0,-1)
    ligne-retenues = ligne-retenues.slice(0,-1)
    colonnes = colonnes - 1
    
    if test-minutes == (true,) * (durees.len()+1) {
      ligne-emprunts = ligne-emprunts.slice(0,-1)
      ligne-minuende = ligne-minuende.slice(0,-1)
      ligne-soustrait = ligne-soustrait.slice(0,-1)
      ligne-resultat = ligne-resultat.slice(0,-1)
      ligne-retenues = ligne-retenues.slice(0,-1)
      colonnes = colonnes - 1
    }
  }

  // ----------------------------------------------------------
  // Soustraction à trous
  // ----------------------------------------------------------
  //
  // La numérotation porte uniquement sur :
  // - le minuende ;
  // - la durée soustraite ;
  // - le résultat.
  //
  // Les lignes d’emprunts ne sont pas comptées.

  let termes = (
    ligne-minuende
    + ligne-soustrait
    + ligne-resultat
  )

  for index in liste {
    if (
      type(index) == int
      and index >= 0
      and index < termes.len()
      and termes.at(index) != []
    ) {
      termes.at(index) = mask(
        termes.at(index)
      )
    }
  }

  // Séparation nécessaire pour insérer la ligne des retenues
  // juste avant le résultat.
  let debut-resultat = 2 * colonnes

  let corps = ()

  if show-borrow-cond or convertion {
    corps += ligne-emprunts
  }

  corps += termes.slice(0, debut-resultat)

  if show-borrow-cond {
    corps += ligne-retenues
  }

  corps += termes.slice(debut-resultat)

  // ----------------------------------------------------------
  // En-tête
  // ----------------------------------------------------------

  let entete = ()

  if show-units {
    entete.push([])

    for colonne in range(debut, 4) {
      entete.push(
        text(
          size: units-size,
          fill: couleur-unites,
          weight: "bold",
        )[
          #unites.at(colonne)
        ]
      )
    }
  }

  // La ligne horizontale doit être placée immédiatement
  // au-dessus du résultat.
  let y-resultat = (
    (if show-units { 1 } else { 0 })
    + (if show-borrow-cond { 2 } else { 0 })
    + 2
    // + (if ligne-minuende == none {-2})
  )

  // ----------------------------------------------------------
  // Rendu
  // ----------------------------------------------------------

  let columns = (1.4em,)

  for _ in range(max-cols) {
    columns.push(size)
  }

  if test-secondes == (true,) * durees.len() {
    entete = entete.slice(0,-1)
    columns = columns.slice(0,-1)
    if test-minutes == (true,) * (durees.len()+1) {
      entete = entete.slice(0,-1)
      columns = columns.slice(0,-1)
    }
  }

  box(
    if columns.len() > 1 {table(
      columns: columns,
      stroke: (x,y) => if verticales and x > 1 {(left:(dash:"dotted",thickness:.5pt))} else {none},
      inset: (x: 3pt, y: 3pt),
      align: center + horizon,

      ..entete,
      ..corps,

      table.hline(
        y: y-resultat,
        stroke: 1pt,
      ),
    )}
  )
}